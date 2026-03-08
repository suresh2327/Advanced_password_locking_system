# 📋 01 Specifications

This section defines the hardware specifications, I/O definitions, timing boundaries, and logical functional constraints established before RTL design of the **Advanced Password Locking System**.

## 📖 System Description
The system functions as a robust hardware lock. The default password stored internally is a 16-bit word (`0x1234`). When a user inputs a 16-bit word on `passin` and commits it via the `enter` signal, the system verifies the input against both the current stored password and a predefined master password (`0xABCD`). If the match is successful, access is granted. Otherwise, an internal consecutive attempt counter increments. The system permanently transitions to an `alarm` state, locking out all access, upon failing the maximum number of attempts (configured as N=4, locking at exactly N-1 failed inputs). The correct password resets the counter.

## ✅ Functional Requirements
- Secure matching combinational logic operating asynchronously to the register updates.
- Synchronous updating of the internal `current_password` via secure change requests.
- Fail-secure tracking of missed attempts.
- Alarm output assertion when the limit is reached, independent of future correct combinations until a hard reset occurs.

## 📥 Input Signals Table
| Signal     | Width  | Description |
|------------|--------|-------------|
| `reset`    | 1 bit  | Active-low system reset, forcing the internal password to `0x1234` and clearing variables. |
| `clk`      | 1 bit  | Global system clock used for synchronous counter logic and password updating. |
| `passin`   | 16 bit | The active user password input applied to the login comparator. |
| `newpass`  | 16 bit | The replacement password, provided alongside `chg_pass` when updating the current password. |
| `enter`    | 1 bit  | Push-button/Strobe to execute the active verify logical block. |
| `chg_pass` | 1 bit  | Input flag requesting an overwrite of the internally stored password. |

## 📤 Output Signals Table
| Signal   | Width | Description |
|----------|-------|-------------|
| `access` | 1 bit | Goes **HIGH** (1) when `passin` matches the current/master password. Default initially **HIGH** at reset. Goes **LOW** (0) continuously on mismatch. |
| `alarm`  | 1 bit | Goes **HIGH** (1) to indicate continuous failure. Once `alarm` is HIGH, the user is locked out until a hard system reset. |
| `count`  | 2 bit | Indicates the hardware failure attempt stage. Rolls from 0 up to 3 depending on `N-1`. |

## ⏱️ Timing Requirements
- Setup and hold limits observed closely for synchronous logic arrays preventing metastable paths.
- All password change updates must occur cleanly on the active positive edge of the clock signal (`posedge clk`), immediately honoring the updated constraints in the following cycles.

## 🛡️ Security Constraints
- **Tamper Alarm:** N = 4 consecutive failure limits trigger a non-resettable alarm (must engage `reset` to clear).
- **Master Keying:** Incorporating `16'hABCD` to act as an unalterable override.
- **Fail-Secure Reset:** Dropping power (`reset` LOW) resets default keys rather than caching corrupt keys unconditionally.

## 🔄 FSM Description
- **IDLE/RESET**: Resets variables; `cnt=0`, `access=1`, `alarm=0`.
- **ENTER_ST:** If `enter` is detected on `posedge clk`:
  - If `is_correct`: sets `cnt=0`, `access=1`, `alarm=0`.
  - If NOT `is_correct` and `cnt == 2` (N-2): increments `cnt`, clears `access`, sets `alarm=1`.
  - If NOT `is_correct` and `cnt == 3` (N-1): clears `access`, maintains `alarm=1`.
  - Else: increments `cnt`, clears `access`, maintains `alarm=0`.

## 📐 Block Diagram
![Block Diagram](placeholder.png)
