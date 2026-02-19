# HTTP API Reference

The ESP32-S2 firmware exposes HTTP endpoints for remote monitoring and control.

These endpoints enable integration with the mobile application or other IoT systems.

---

## GET /status

Returns system status information in JSON format.

Response fields:

- temperature (°C)
- setpoint (°C)
- flow_lmin (Liters per minute)
- total_liters (Cumulative consumption)
- estimated_cost
- system_state (IDLE, CONTROL, OVERHEAT, SENSOR_ERROR)
- shower (0 or 1)
### Example Response

```json
{
  "temperature": 37.8,
  "setpoint": 38.5,
  "flow_lmin": 8.9,
  "total_liters": 42.3,
  "estimated_cost": 1.05,
  "system_state": "CONTROL",
  "shower": 1
}


---

## POST /set_temp?value=38.5

Sets the target water temperature.

Constraints:
- Allowed range: 30°C – 45°C

---

## POST /shower?on=1

Enables or disables temperature control mode.

Parameters:
- on=1 → enable control
- on=0 → disable control

---

## POST /reset_usage

Resets total water consumption and cost counters.

---

## Communication Behavior

- If WiFi is unavailable, the system continues operating locally.
- API communication is non-critical to core control functionality.
