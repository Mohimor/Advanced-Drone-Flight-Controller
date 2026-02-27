# 🚁 Advanced Drone Flight Controller

**Digital Logic Design Course Project**  
**Shahid Beheshti University – Spring 2025**

---

## 📌 Overview

This project implements an **advanced flight controller for a drone** using a **Finite State Machine (FSM)** in Verilog. The controller manages the drone's behaviour through different flight phases, responds to pilot commands and environmental sensors, and includes safety mechanisms such as emergency stop and fault detection.

The design is fully synthesizable and has been tested with a comprehensive testbench covering normal operation, emergency scenarios, and fault conditions.

---

## ✨ Key Features

- ✅ **8‑state Finite State Machine** covering all flight phases from landed to emergency
- ✅ **Multi‑input control** including flight commands, joystick, altimeter, battery sensor, and emergency stop
- ✅ **Fault detection system** that monitors motor feedback and triggers safe mode on persistent mismatch
- ✅ **Status outputs** for motor control and visual LED indicators
- ✅ **Comprehensive testbench** with tasks for arming, takeoff, manoeuvres, and emergencies

---

## 🎮 Inputs & Outputs

### Inputs
| Port | Width | Description |
| :--- | :--- | :--- |
| `clk` | 1 | System clock |
| `reset` | 1 | Asynchronous reset |
| `flight_command` | 2 | Pilot commands (arm/disarm, takeoff, land) |
| `joystick_input` | 4 | Directional control during flight |
| `altimeter_reading` | 8 | Current altitude for automatic transitions |
| `low_battery_sensor` | 1 | Forces landing when battery is low |
| `motor_feedback` | 2 | Actual motor status for fault detection |
| `emergency_stop` | 1 | Instant emergency activation |

### Outputs
| Port | Width | Description |
| :--- | :--- | :--- |
| `motor_status` | 2 | Commanded motor state (stopped, idle, flight, landing) |
| `status_led` | 3 | Visual indicator for current drone state |

---

## 🧠 State Machine Overview

The controller implements an 8‑state Moore FSM with the following states:

| State | Description |
| :--- | :--- |
| `S_LANDED` | Drone on ground, motors off |
| `S_IDLE` | Armed and ready, motors at idle |
| `S_TAKING_OFF` | Ascending to safe altitude |
| `S_IN_FLIGHT` | Stable flight, awaiting commands |
| `S_MANEUVERING` | Executing joystick movements |
| `S_LANDING` | Descending to ground |
| `S_EMERGENCY` | Immediate stop triggered |
| `S_FAULT` | Persistent motor mismatch detected |

State transitions are determined by:
- Pilot commands (`flight_command`, `joystick_input`)
- Sensor readings (`altimeter_reading`, `low_battery_sensor`)
- Safety signals (`emergency_stop`, `fault_detected`)

---

## ⚠️ Safety Features

### Emergency Stop
The `emergency_stop` input forces the drone into `S_EMERGENCY` from any state, immediately cutting motor power and activating emergency LED indicators.

### Fault Detection
A 7‑bit counter monitors the difference between commanded `motor_status` and actual `motor_feedback`. If they mismatch for 100 consecutive clock cycles, a fault is declared and the drone transitions to `S_FAULT`, which then automatically initiates landing. This prevents brief glitches from triggering false alarms while still catching persistent hardware issues.

### Low Battery Protection
When `low_battery_sensor` is asserted, the drone automatically transitions to `S_LANDING` from any flight state, ensuring safe recovery before power failure.

---

## 🧪 Testbench

The testbench (`tb_advanced_drone_controller.v`) includes reusable tasks that simulate real flight scenarios:

| Task | Description |
| :--- | :--- |
| `arm()` / `disarm()` | Arm or disarm the drone |
| `takeoff()` | Initiate takeoff sequence |
| `land()` | Initiate landing sequence |
| `joystick(val, cycles)` | Apply joystick input for specified duration |
| `increas_height(limit)` | Simulate altitude gain |
| `decreas_height()` | Simulate altitude loss |
| `emergency(cycles)` | Trigger emergency stop |

The testbench runs through a complete mission including:
- Normal takeoff, manoeuvre, and landing
- Low‑battery forced landing
- Emergency stop from flight
- Fault injection via motor feedback mismatch
- Multiple flight cycles

---

## 🚀 How to Simulate

### Using Icarus Verilog

```bash
# Compile both files
iverilog -o drone_sim advanced_drone_controller.v tb_advanced_drone_controller.v

# Run simulation
vvp drone_sim

# View waveform
gtkwave output.vcd
