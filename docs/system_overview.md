# AquaSmart System Overview

AquaSmart is a smart water temperature and consumption control system built around an ESP32-S2 microcontroller.

## Hardware Components

- ESP32-S2 control unit
- DS18B20 digital temperature sensor
- YF-S201 flow sensor
- MOSFET-driven hot and cold solenoid valves
- OLED display (SSD1306, I2C)
- Rotary encoder user interface

## Functional Flow

1. The user sets a target temperature via the mobile app or rotary encoder.
2. DS18B20 provides real-time water temperature feedback to the control loop.
3. YF-S201 measures instantaneous flow rate and enables total consumption (liters) calculation.
4. The ESP32-S2 executes the control algorithm to regulate the hot/cold mixing ratio.
5. Solenoid valves are actuated using time-proportional control.
6. Status and consumption data can be exposed via HTTP API for remote monitoring.
