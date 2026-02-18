/*
  AquaSmart - Smart Water Temperature Control (Demo-Ready Firmware)
  Board: ESP32-S2
  IDE: Arduino IDE

  Features:
  - DS18B20 temperature feedback (1-Wire)
  - YF-S201 flow pulses -> L/min + total liters
  - OLED (SSD1306 I2C) UI + Rotary Encoder setpoint
  - Time-proportional valve driving (mechanic-friendly)
  - PI + flow feed-forward control (competition-grade)
  - WiFi HTTP API for mobile app integration (demo endpoints)

  Notes:
  - If you will NOT test on hardware now, you can still keep this code in GitHub.
  - Pin mapping is centralized below.
*/

#include <WiFi.h>
#include <WebServer.h>

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#include <OneWire.h>
#include <DallasTemperature.h>

// =====================
// 0) BUILD MODE
// =====================
// DEMO_MODE=1: Simulated sensors (useful if you won't test physically)
// DEMO_MODE=0: Real DS18B20 + YF-S201 readings
#define DEMO_MODE 0

// =====================
// 1) PIN MAP (EDIT HERE ONLY)
// =====================
// Valves (MOSFET gates)
static const int PIN_VALVE_HOT  = 10;
static const int PIN_VALVE_COLD = 12;

// DS18B20 (1-Wire)
static const int PIN_DS18B20 = 9;

// Flow sensor (YF-S201 pulse)
static const int PIN_FLOW = 25;

// OLED I2C pins
static const int PIN_I2C_SDA = 13;
static const int PIN_I2C_SCL = 14;
static const uint8_t OLED_ADDR = 0x3C;

// Rotary encoder
static const int PIN_ENC_A  = 37;  // A/CLK
static const int PIN_ENC_B  = 38;  // B/DT
static const int PIN_ENC_SW = 39;  // push button

// =====================
// 2) WIFI (Demo Integration Layer)
// =====================
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASS = "YOUR_WIFI_PASS";
WebServer server(80);

// =====================
// 3) OLED
// =====================
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// =====================
// 4) Temperature (DS18B20)
// =====================
OneWire oneWire(PIN_DS18B20);
DallasTemperature tempSensors(&oneWire);

// =====================
// 5) Flow (YF-S201)
// =====================
// Common approximation: Flow(L/min) = frequency(Hz) / 7.5
// This constant may vary between sensor batches.
static const float FLOW_K_HZ_PER_LMIN = 7.5f;

// Pulses per liter is also sometimes used (e.g., ~450 pulses/L), but varies.
// We'll compute L/min from freq and integrate liters from L/min.
volatile uint32_t g_flowPulses = 0;

void IRAM_ATTR flowISR() {
  g_flowPulses++;
}

// =====================
// 6) Control + State Machine
// =====================
enum SystemState { IDLE, CONTROL, OVERHEAT, SENSOR_ERROR };
SystemState g_state = IDLE;

bool g_showerEnabled = false;   // controlled by encoder push OR API
float g_T_set = 38.0f;          // target temp
float g_T_meas = NAN;           // measured temp
float g_flow_Lmin = 0.0f;       // measured flow
float g_totalLiters = 0.0f;     // integrated liters (for UI + API)
float g_estimatedCost = 0.0f;   // optional demo cost

// Cost model (demo)
static const float COST_PER_LITER = 0.025f;

// Safety thresholds
static const float T_OVERHEAT_C = 50.0f;
static const float MIN_FLOW_TO_CONTROL_LMIN = 0.2f;

// PI + Feed-forward gains (starting values; tune later)
float Kp = 15.0f;
float Ki = 0.5f;
float Kf = 2.0f;

// Integrator (anti-windup)
float integral = 0.0f;

// Time-proportional window (ms)
static const uint32_t WINDOW_MS = 1000;
uint32_t windowStartMs = 0;

// Encoder handling
int lastEncA = HIGH;
uint32_t lastBtnMs = 0;

// =====================
// 7) Helpers
// =====================
static inline float clampf(float x, float lo, float hi) {
  if (x < lo) return lo;
  if (x > hi) return hi;
  return x;
}

void valvesWrite(bool hotOn, bool coldOn) {
  digitalWrite(PIN_VALVE_HOT,  hotOn  ? HIGH : LOW);
  digitalWrite(PIN_VALVE_COLD, coldOn ? HIGH : LOW);
}

const char* stateToStr(SystemState s) {
  switch (s) {
    case IDLE: return "IDLE";
    case CONTROL: return "CONTROL";
    case OVERHEAT: return "OVERHEAT";
    case SENSOR_ERROR: return "SENSOR_ERROR";
    default: return "UNKNOWN";
  }
}

// =====================
// 8) UI: OLED + Encoder
// =====================
void oledDraw() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  display.setCursor(0, 0);
  display.print("AquaSmart (ESP32-S2)");

  display.setCursor(0, 12);
  display.print("Temp: ");
  if (isnan(g_T_meas)) display.print("--.-");
  else display.print(g_T_meas, 1);
  display.print(" C");

  display.setCursor(0, 24);
  display.print("Set : ");
  display.print(g_T_set, 1);
  display.print(" C");

  display.setCursor(0, 36);
  display.print("Flow: ");
  display.print(g_flow_Lmin, 1);
  display.print(" L/m");

  display.setCursor(0, 48);
  display.print("Use : ");
  display.print(g_totalLiters, 1);
  display.print(" L");

  display.setCursor(0, 58);
  display.print("St: ");
  display.print(stateToStr(g_state));
  display.print(g_showerEnabled ? " ON" : " OFF");

  display.display();
}

void encoderPoll() {
  int a = digitalRead(PIN_ENC_A);
  int b = digitalRead(PIN_ENC_B);

  // Detect edge on A
  if (a != lastEncA) {
    // Direction depends on wiring; if reversed, swap +/-
    if (b != a) g_T_set += 0.5f;
    else        g_T_set -= 0.5f;

    g_T_set = clampf(g_T_set, 30.0f, 45.0f);
  }
  lastEncA = a;

  // Push toggles shower enabled
  int sw = digitalRead(PIN_ENC_SW);
  if (sw == LOW && (millis() - lastBtnMs) > 300) {
    g_showerEnabled = !g_showerEnabled;
    lastBtnMs = millis();
  }
}

// =====================
// 9) Sensors
// =====================
void readTemperatureReal() {
  tempSensors.requestTemperatures();
  float t = tempSensors.getTempCByIndex(0);

  // Dallas returns -127 on disconnect; also guard unrealistic values
  if (t < -50.0f || t > 125.0f) {
    g_T_meas = NAN;
  } else {
    g_T_meas = t;
  }
}

void readTemperatureDemo() {
  // Demo: converge toward setpoint slowly
  static float t = 36.0f;
  float err = g_T_set - t;
  t += err * 0.05f; // slow convergence
  g_T_meas = t;
}

void computeFlowRealAndIntegrate() {
  static uint32_t lastMs = 0;
  static uint32_t lastPulses = 0;

  uint32_t now = millis();
  if (now - lastMs < 1000) return;

  uint32_t p;
  noInterrupts();
  p = g_flowPulses;
  interrupts();

  uint32_t delta = p - lastPulses;
  lastPulses = p;
  lastMs = now;

  float freq = (float)delta; // pulses per second (since 1s window)
  g_flow_Lmin = freq / FLOW_K_HZ_PER_LMIN;
  if (g_flow_Lmin < 0) g_flow_Lmin = 0;

  // Integrate liters over this 1 second interval:
  // L/min -> L/sec = /60. Add 1 second worth.
  float litersThisSecond = g_flow_Lmin / 60.0f;
  g_totalLiters += litersThisSecond;
  g_estimatedCost += litersThisSecond * COST_PER_LITER;
}

void computeFlowDemoAndIntegrate() {
  // Demo: fixed-ish flow when enabled
  float target = g_showerEnabled ? 9.0f : 0.0f; // L/min
  g_flow_Lmin += (target - g_flow_Lmin) * 0.2f;

  static uint32_t lastMs = 0;
  uint32_t now = millis();
  if (now - lastMs < 1000) return;
  lastMs = now;

  float litersThisSecond = g_flow_Lmin / 60.0f;
  g_totalLiters += litersThisSecond;
  g_estimatedCost += litersThisSecond * COST_PER_LITER;
}

// =====================
// 10) Control (PI + feed-forward + time-proportional)
// =====================
void controlStep() {
  // Default safe behavior
  if (!g_showerEnabled) {
    g_state = IDLE;
    valvesWrite(false, false);
    integral = 0.0f;
    return;
  }

  // Sensor validity
  if (isnan(g_T_meas)) {
    g_state = SENSOR_ERROR;
    valvesWrite(false, false);
    return;
  }

  // Safety: overheat
  if (g_T_meas > T_OVERHEAT_C) {
    g_state = OVERHEAT;
    // Force cool open for demo safety; or close both if you prefer
    valvesWrite(false, true);
    return;
  }

  // If no flow, keep closed (prevents hunting)
  if (g_flow_Lmin < MIN_FLOW_TO_CONTROL_LMIN) {
    g_state = IDLE;
    valvesWrite(false, false);
    integral = 0.0f;
    return;
  }

  g_state = CONTROL;

  // PI + flow feed-forward
  float err = g_T_set - g_T_meas;
  integral += err * (WINDOW_MS / 1000.0f);
  integral = clampf(integral, -50.0f, 50.0f);

  float u = (Kp * err) + (Ki * integral) + (Kf * g_flow_Lmin);

  // Map to hot duty [0..100]
  float dutyHot = clampf(u, 0.0f, 100.0f);
  float dutyCold = 100.0f - dutyHot;

  // Time-proportional window
  uint32_t now = millis();
  if (now - windowStartMs >= WINDOW_MS) windowStartMs = now;
  uint32_t t = now - windowStartMs;

  uint32_t hotOnMs  = (uint32_t)(WINDOW_MS * (dutyHot / 100.0f));
  uint32_t coldOnMs = (uint32_t)(WINDOW_MS * (dutyCold / 100.0f));

  bool hotOn  = (t < hotOnMs);
  bool coldOn = (t < coldOnMs);

  // Optional: prevent both on at the same time
  // If you want strictly one valve at a time, uncomment:
  /*
  if (hotOn && coldOn) {
    // prioritize the larger duty
    if (dutyHot >= dutyCold) coldOn = false;
    else hotOn = false;
  }
  */

  valvesWrite(hotOn, coldOn);
}

// =====================
// 11) HTTP API (for "remote/app control" demo)
// =====================
// Endpoints:
// GET  /status
// POST /set_temp?value=38.5
// POST /shower?on=0/1
// POST /reset_usage
// POST /set_gains?kp=15&ki=0.5&kf=2
void apiStatus() {
  String json = "{";
  json += "\"temp\":" + String(isnan(g_T_meas) ? -1.0f : g_T_meas, 2) + ",";
  json += "\"set\":" + String(g_T_set, 2) + ",";
  json += "\"flow_lmin\":" + String(g_flow_Lmin, 2) + ",";
  json += "\"total_liters\":" + String(g_totalLiters, 2) + ",";
  json += "\"estimated_cost\":" + String(g_estimatedCost, 2) + ",";
  json += "\"shower\":" + String(g_showerEnabled ? 1 : 0) + ",";
  json += "\"state\":\"" + String(stateToStr(g_state)) + "\"";
  json += "}";
  server.send(200, "application/json", json);
}

void apiSetTemp() {
  if (!server.hasArg("value")) {
    server.send(400, "text/plain", "Missing value");
    return;
  }
  float v = server.arg("value").toFloat();
  if (v < 30.0f || v > 45.0f) {
    server.send(400, "text/plain", "value out of range (30-45)");
    return;
  }
  g_T_set = v;
  server.send(200, "text/plain", "OK");
}

void apiShower() {
  if (!server.hasArg("on")) {
    server.send(400, "text/plain", "Missing on=0/1");
    return;
  }
  int on = server.arg("on").toInt();
  g_showerEnabled = (on == 1);
  server.send(200, "text/plain", "OK");
}

void apiResetUsage() {
  g_totalLiters = 0.0f;
  g_estimatedCost = 0.0f;
  server.send(200, "text/plain", "OK");
}

void apiSetGains() {
  if (server.hasArg("kp")) Kp = server.arg("kp").toFloat();
  if (server.hasArg("ki")) Ki = server.arg("ki").toFloat();
  if (server.hasArg("kf")) Kf = server.arg("kf").toFloat();
  server.send(200, "text/plain", "OK");
}

// =====================
// 12) WiFi Setup
// =====================
void wifiStart() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED && (millis() - start) < 8000) {
    delay(200);
  }

  // Even if WiFi fails, local UI/control still works.
  if (WiFi.status() == WL_CONNECTED) {
    server.on("/status", HTTP_GET, apiStatus);
    server.on("/set_temp", HTTP_POST, apiSetTemp);
    server.on("/shower", HTTP_POST, apiShower);
    server.on("/reset_usage", HTTP_POST, apiResetUsage);
    server.on("/set_gains", HTTP_POST, apiSetGains);
    server.begin();
  }
}

// =====================
// 13) Arduino Setup/Loop
// =====================
void setup() {
  // GPIO
  pinMode(PIN_VALVE_HOT, OUTPUT);
  pinMode(PIN_VALVE_COLD, OUTPUT);
  valvesWrite(false, false);

  pinMode(PIN_ENC_A, INPUT);
  pinMode(PIN_ENC_B, INPUT);
  pinMode(PIN_ENC_SW, INPUT);

  pinMode(PIN_FLOW, INPUT);
#if DEMO_MODE == 0
  attachInterrupt(digitalPinToInterrupt(PIN_FLOW), flowISR, RISING);
#endif

  // I2C OLED
  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);
  display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR);
  display.clearDisplay();
  display.display();

  // Temp sensor
  tempSensors.begin();

  // WiFi API
  wifiStart();

  windowStartMs = millis();
}

void loop() {
  // Local UI
  encoderPoll();

  // Sensors
#if DEMO_MODE == 1
  readTemperatureDemo();
  computeFlowDemoAndIntegrate();
#else
  static uint32_t lastTempMs = 0;
  if (millis() - lastTempMs > 1000) {
    readTemperatureReal();
    lastTempMs = millis();
  }
  computeFlowRealAndIntegrate();
#endif

  // Control
  controlStep();

  // HTTP server
  if (WiFi.status() == WL_CONNECTED) {
    server.handleClient();
  }

  // OLED refresh
  static uint32_t lastOledMs = 0;
  if (millis() - lastOledMs > 250) {
    oledDraw();
    lastOledMs = millis();
  }
}
