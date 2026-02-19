# Bill of Materials (BOM)

This document lists the main hardware components used in the AquaSmart prototype.

---

## Core Components

| Component | Model | Quantity | Description |
|------------|--------|----------|-------------|
| Microcontroller | ESP32-S2 | 1 | Main control unit |
| Temperature Sensor | DS18B20 | 1 | Digital 1-Wire temperature sensor |
| Flow Sensor | YF-S201 | 1 | Hall-effect water flow sensor |
| OLED Display | SSD1306 (I2C) | 1 | 128x64 OLED display |
| Rotary Encoder | Generic EC11 | 1 | User input interface |
| Solenoid Valve | 12V ON/OFF | 2 | Hot & Cold water control |

---

## Power Stage

| Component | Model | Quantity | Description |
|------------|--------|----------|-------------|
| Buck Converter | LM2596S-5 | 1 | 12V to 5V regulation |
| Voltage Regulator | AMS1117-3.3 | 1 | 5V to 3.3V regulation |
| Fuse | 12V Inline Fuse | 1 | Overcurrent protection |
| TVS Diode | SMBJ Series | 1 | Surge protection |

---

## Switching Stage

| Component | Model | Quantity | Description |
|------------|--------|----------|-------------|
| MOSFET | IRLZ44N | 2 | Low-side valve control |
| Flyback Diode | 1N4007 | 2 | Inductive load protection |
| Gate Resistor | 220Ω | 2 | Gate current limiting |
| Pull-down Resistor | 10kΩ | 2 | Gate stabilization |

---

## Passive Components

- 4.7kΩ pull-up resistor (DS18B20)
- 10kΩ pull-up resistors (Encoder)
- Decoupling capacitors (100nF)
- Bulk capacitors (10µF – 100µF)

---

> This BOM represents the prototype-level design and may be refined during PCB implementation.
