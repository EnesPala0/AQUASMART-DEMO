# Hardware

This folder contains the schematic-level hardware design of the AquaSmart system.

## Structure

- `kicad/` → KiCad project files (.kicad_sch, .kicad_pro)
- `pdf/`   → Exported schematic PDF for quick review

## Design Overview

The hardware design includes:

- 12V protected power input stage
- LM2596 buck converter (5V generation)
- 3.3V regulation for ESP32-S2 logic
- MOSFET-driven hot and cold solenoid valves
- DS18B20 digital temperature sensor
- YF-S201 flow sensor
- OLED display and rotary encoder interface

> Note: PCB layout is not finalized. Current design is schematic-level prototype.
