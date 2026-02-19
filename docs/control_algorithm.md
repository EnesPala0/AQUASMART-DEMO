# Control Algorithm

The AquaSmart system operates using a closed-loop temperature control architecture.

## Control Strategy

The control loop is based on a PI (Proportional–Integral) controller combined with flow-based feed-forward compensation.

### Error Definition

Error = T_set − T_measured

### Control Output

u(t) = Kp * error + Ki * integral(error) + Kf * flow_rate

Where:
- Kp = proportional gain
- Ki = integral gain
- Kf = feed-forward coefficient
- flow_rate = measured water flow (L/min)

## Actuation Method

Instead of high-frequency PWM, the system uses time-proportional control over a fixed time window to actuate the hot and cold solenoid valves.

This method:

- Reduces mechanical stress on valves
- Increases actuator lifespan
- Provides stable temperature regulation

## Safety Mechanisms

- Overheat protection (temperature threshold)
- Sensor failure detection
- No-flow idle mode
- Integrator anti-windup limiting

### Fail-Safe Behavior

- If temperature exceeds the overheat threshold, the system enters a safe mode (hot valve disabled, cooling action applied).
- If temperature sensing fails (invalid DS18B20 reading), all valves are shut down to prevent uncontrolled heating.
- If no flow is detected, the system remains in idle mode and keeps valves closed to avoid unnecessary actuation.
- If WiFi communication is unavailable, the system continues operating locally via OLED + rotary encoder (communication is non-critical for core control).
- Valve fault detection (stuck valve / coil failure) can be added in future revisions using current sensing or position feedback.

