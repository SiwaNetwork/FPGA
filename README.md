# FPGA Open Source Time Card

Этот репозиторий содержит FPGA-проект для [Open Source Time Card](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card) из Open Compute Project.

## Обзор

Time Card — это плата PCI Express для точной синхронизации времени. Она поддерживает:
- **GNSS-приёмники** (до 2 модулей) для приёма UTC/времени суток
- **PPS (Pulse Per Second)** вход/выход через разъёмы SMA
- **Высокоточное нанесение меток времени** внешних событий
- **Генерацию сигналов** (PWM), выровненную с локальными часами
- **PCIe Gen2** интерфейс хоста
- **Обновляемую в поле FPGA-прошивку** с поддержкой резервного/golden образа

## Целевое оборудование

| Вариант | FPGA | Примечания |
|---------|------|-------|
| TimeCard (Base) | Xilinx Artix-7 XC7A100T | Стандартный open-source вариант |
| TimeCard_200T | Xilinx Artix-7 XC7A200T | Вариант с большей FPGA |
| TimeCard_LitePcie | Xilinx Artix-7 | Реализация на базе LitePCIe |
| TimeCard_Production | Xilinx Artix-7 | Производственный оптимизированный вариант |

## Структура проекта

```
Open-Source/
├── Implementation/     # Реализации для конкретных производителей
│   └── Xilinx/
│       ├── TimeCard/           # Базовый проект (Vivado 2019.1)
│       ├── TimeCard_200T/      # Вариант 200T
│       ├── TimeCard_LitePcie/  # Вариант LitePCIe
│       └── TimeCard_Production/# Производственный вариант
├── Ips/                # Пользовательские открытые IP-ядра
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
│   └── ... (полный список см. в Ips/)
├── Modules/            # Переиспользуемые VHDL-модули
│   ├── BufgMux
│   └── Irq
└── Package/            # Общие константы и процедуры
    └── TimeCard_Package.vhd
```

## Сборка проекта

### Предварительные требования
- Xilinx Vivado 2019.1 (или совместимый)

### Шаги
1. Откройте Vivado и запустите TCL-консоль:
   ```tcl
   source /[YOUR_PATH]/Open-Source/Implementation/Xilinx/TimeCard/CreateProject.tcl
   ```
2. Сгенерируйте bitstream:
   ```tcl
   source /[YOUR_PATH]/Open-Source/Implementation/Xilinx/TimeCard/CreateBinariesAll.tcl
   ```

Сгенерированные бинарные файлы будут помещены в папку `Binaries/`.

### Результаты сборки
- `Factory_TimeCardOS.bin` — Комбинированный golden + обычный образ (для начальной прошивки)
- `Golden_TimeCardOS.bin` — Резервный/golden образ
- `TimeCardOS.bin` — Обычный рабочий образ
- `TimeCardOS_Gotham.bin` — Обычный образ с заголовком PCIe ID

## Документация

- [Структура проекта](Open-Source/README.md) (русский)
- [Руководство по реализации](Open-Source/Implementation/Xilinx/TimeCard/Readme.md)
- Документация по отдельным IP-ядрам находится в каждой папке `Ips/<CoreName>/`.

## Лицензия

Этот проект распространяется под лицензией **GNU Lesser General Public License v3** (LGPL v3).

Copyright (c) 2022, NetTimeLogic GmbH, Switzerland.
