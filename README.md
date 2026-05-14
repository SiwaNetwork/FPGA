# FPGA Open Source Time Card

This repository contains the FPGA design for the [Open Source Time Card](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card) from the Open Compute Project.

## Overview

The Time Card is a PCI Express card for precise time synchronization. It supports:
- **GNSS receivers** (up to 2 modules) for UTC/time-of-day reception
- **PPS (Pulse Per Second)** input/output via SMA connectors
- **High-precision timestamping** of external events
- **Signal generation** (PWM) aligned to the local clock
- **PCIe Gen2** host interface
- **Field-updatable FPGA firmware** with fallback/golden image support

## Target Hardware

| Variant | FPGA | Notes |
|---------|------|-------|
| TimeCard (Base) | Xilinx Artix-7 XC7A100T | Standard open-source variant |
| TimeCard_200T | Xilinx Artix-7 XC7A200T | Larger FPGA variant |
| TimeCard_LitePcie | Xilinx Artix-7 | LitePCIe-based implementation |
| TimeCard_Production | Xilinx Artix-7 | Production-optimized variant |

## Project Structure

```
Open-Source/
├── Implementation/     # Vendor-specific implementations
│   └── Xilinx/
│       ├── TimeCard/           # Base design (Vivado 2019.1)
│       ├── TimeCard_200T/      # 200T variant
│       ├── TimeCard_LitePcie/  # LitePCIe variant
│       └── TimeCard_Production/# Production variant
├── Ips/                # Custom open-source IP cores
│   ├── AdjustableClock
│   ├── ClockDetector
│   ├── ConfMaster
│   ├── CoreList
│   ├── PpsGenerator
│   ├── PpsSlave
│   ├── SignalTimestamper
│   ├── SignalGenerator
│   ├── SmaSelector
│   ├── TodSlave
│   └── ... (see Ips/ for full list)
├── Modules/            # Reusable VHDL modules
│   ├── BufgMux
│   └── Irq
└── Package/            # Shared constants and procedures
    └── TimeCard_Package.vhd
```

## Building the Project

### Prerequisites
- Xilinx Vivado 2019.1 (or compatible)

### Steps
1. Open Vivado and run the TCL console:
   ```tcl
   source /[YOUR_PATH]/Open-Source/Implementation/Xilinx/TimeCard/CreateProject.tcl
   ```
2. Generate bitstreams:
   ```tcl
   source /[YOUR_PATH]/Open-Source/Implementation/Xilinx/TimeCard/CreateBinariesAll.tcl
   ```

Generated binaries will be placed in the `Binaries/` folder.

### Build Outputs
- `Factory_TimeCardOS.bin` — Combined golden + regular image (for initial flash)
- `Golden_TimeCardOS.bin` — Fallback/golden image
- `TimeCardOS.bin` — Regular operational image
- `TimeCardOS_Gotham.bin` — Regular image with PCIe ID header

## Documentation

- [Project Structure](Open-Source/README.md) (Russian)
- [Implementation Guide](Open-Source/Implementation/Xilinx/TimeCard/Readme.md)
- Individual IP core documentation is located in each `Ips/<CoreName>/` folder.

## License

This project is licensed under the **GNU Lesser General Public License v3** (LGPL v3).

Copyright (c) 2022, NetTimeLogic GmbH, Switzerland.
