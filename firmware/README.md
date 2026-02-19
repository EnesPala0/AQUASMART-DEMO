# Firmware (ESP32-S2)

This folder contains the embedded firmware for the AquaSmart control unit.

Main file:
- `esp32_s2/AquaSmart_Controller.ino`

---

## Platform

- Microcontroller: ESP32-S2
- Development Environment: Arduino IDE
- Recommended Board: ESP32-S2 Dev Module

---

## Features

- Closed-loop PI temperature control
- Flow-based feed-forward compensation
- Time-proportional valve actuation
- Real-time water consumption calculation
- Overheat and sensor-fault protection
- HTTP API for mobile integration

---

## Configuration

- All pin mappings are defined at the top of the `.ino` file.
- Control gains (Kp, Ki, Kf) can be tuned in the source code.
- DEMO_MODE can be enabled for simulation without hardware testing.

---

## API Documentation

See: `docs/api_reference.md`

