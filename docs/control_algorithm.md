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
