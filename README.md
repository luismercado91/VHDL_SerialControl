# Serial LED Controller – CPE 3020 Final Project

---

## Overview

A UART-controlled LED system that lets a user turn individual LEDs on or off from a serial terminal (e.g. PuTTY). The design receives ASCII commands over a serial interface, parses a command letter followed by a two-digit LED number, and drives a 16-LED output accordingly.

### Serial Command Format

| Command | Action | Example |
|---|---|---|
| `L` + two-digit number (00–15) | Turn the specified LED **on** | `L07` turns on LED 7 |
| `M` + two-digit number (00–15) | Turn the specified LED **off** | `M07` turns off LED 7 |

Connect to the board using PuTTY (or any terminal emulator) at the appropriate baud rate and type commands directly.

---

## System Architecture

The design is implemented as a **Moore state machine** (`SerialControl`) with the following internal structure:

```
UART RX (external)
      │
      ▼
  dataReady / dataOut[7:0]
      │
      ▼
┌─────────────────────────────────────────────────────┐
│                  SerialControl                       │
│                                                     │
│  STATE_REGISTER ──► STATE_TRANSITIONS               │
│         │                  │                        │
│         ▼                  ▼                        │
│  CONTROL_SIGNALS ──► COMMAND_REG  ──► letter        │
│         │            TENS_DIGIT   ──► firstDigit    │
│         │            ONES_DIGIT   ──► secondDigit   │
│         │                  │                        │
│         │           SERIAL_TO_INTEGER ──► ledValue  │
│         │                  │                        │
│         └──────────► LED_DRIVER ──────────────────► leds[15:0]
└─────────────────────────────────────────────────────┘
```

---

## State Machine

| State | Description |
|---|---|
| `IDLE` | Waiting for a valid command character (`L` or `M`) |
| `LATCH_COMMAND` | Stores the command character; asserts `commandEn` |
| `WAIT_FOR_TENS` | Waits for the tens digit (only `0` or `1` accepted) |
| `LATCH_TENS` | Stores the tens digit; asserts `tensEn` |
| `WAIT_FOR_ONES` | Waits for the ones digit (`0`–`9`) |
| `LATCH_ONES` | Stores the ones digit; asserts `onesEn` |
| `EXECUTE_COMMAND` | Asserts `ledOnEn` or `ledOffEn`; returns to `IDLE` |

Invalid characters at any stage reset the machine back to `IDLE`.

---

## File Structure

```
serial-led-controller/
├── README.md
├── src/
│   └── SerialControl.vhd      # Full design (state machine + datapath)
└── sim/
    └── SerialControl_TB.vhd   # Testbench
```

---

## I/O Port Map

| Port | Direction | Width | Description |
|---|---|---|---|
| `clock` | in | 1-bit | 100 MHz system clock |
| `reset` | in | 1-bit | Active-high synchronous reset |
| `dataOut` | in | 8-bit | Received ASCII byte from UART |
| `dataReady` | in | 1-bit | Pulses high for one cycle when `dataOut` is valid |
| `leds` | out | 16-bit | Persistent LED state (individual bits set/cleared) |

---

## Internal Signals

| Signal | Type | Description |
|---|---|---|
| `currentState` / `nextState` | `States_t` | Moore FSM state registers |
| `letter` | `character` | Latched command (`'L'` or `'M'`) |
| `firstDigit` / `secondDigit` | `std_logic_vector(7:0)` | ASCII tens and ones digits |
| `ledValue` | `integer 0–15` | Decoded LED index from ASCII pair |
| `ledState` | `std_logic_vector(15:0)` | Persistent LED bit register |
| `commandEn`, `tensEn`, `onesEn` | `std_logic` | Latch enable strobes |
| `ledOnEn`, `ledOffEn` | `std_logic` | LED set/clear enable strobes |

---

## ASCII Decoding

The tens digit must be `'0'` (0x30) or `'1'` (0x31); the ones digit must be `'0'`–`'9'` (0x30–0x39). The concatenated pair (`firstDigit & secondDigit`) is decoded by a combinational `with/select` statement into an integer 0–15 for LED indexing.

---

## How to Simulate (Vivado)

1. Create a new Vivado project targeting the Nexys A7 board.
2. Add `src/SerialControl.vhd` as a design source.
3. Add `sim/SerialControl_TB.vhd` as a simulation source.
4. Set `SerialControl_TB` as the top simulation module.
5. Run **Behavioral Simulation** and verify the LED state changes on the waveform.

---

## Design Notes

- **Persistent LED state:** Unlike a one-hot system, individual LEDs can be switched on or off independently. The `ledState` register accumulates changes across multiple commands.
- **Invalid input handling:** Any unexpected character during `WAIT_FOR_TENS` or `WAIT_FOR_ONES` immediately returns the FSM to `IDLE`, discarding the partial command.
- **Control signal generation:** `CONTROL_SIGNALS` is a synchronous process clocked on the *current* state, so all enable signals are registered and glitch-free.
- **UART integration:** This module expects pre-framed, 8-bit parallel data from an upstream UART receiver (not included in this repo). The `dataReady` strobe must be a single-cycle pulse.
