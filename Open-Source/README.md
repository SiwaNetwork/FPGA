# Структура проекта FPGA Open Source Time Card

Репозиторий FPGA Open Source TimeCard имеет структуру, показанную ниже

```bash
    │
    │   Readme.md
    │   
    ├───Implementation
    │   └───Xilinx
    │       └───TimeCard
    │           │   CoreListFile.txt
    │           │   DefaultConfigFile.txt
    │           │   CreateBinaries.tcl
    │           │   CreateBinariesAll.tcl
    │           │   CreateBinariesGolden.tcl
    │           │   CreateProject.tcl
    │           │   Readme.md
    │           │   
    │           ├───Additional Files
    │           │       
    │           ├───Bd
    │           │       
    │           ├───Binaries
    │           │
    │           ├───Constraints
    │           │
    │           ├───(TimeCard)
    │           │
    │           └───Top
    │                   
    ├───Ips
    │   │   TC_ClockAdjustment.xml
    │   │   TC_ClockAdjustment_rtl.xml
    │   │   TC_Servo.xml
    │   │   TC_Servo_rtl.xml
    │   │   TC_Time.xml
    │   │   TC_Time_rtl.xml
    │   │   
    │   ├───AdjustableClock
    │   │               
    │   ├───ClockDetector
    │   │               
    │   ├───ConfMaster
    │   │               
    │   ├───CoreList
    │   │               
    │   ├───DummyAxiSlave
    │   │               
    │   ├───FPGA Version
    │   │               
    │   ├───FrequencyCounter
    │   │               
    │   ├───MsiIrq
    │   │               
    │   ├───PpsGenerator
    │   │               
    │   ├───PpsSlave
    │   │               
    │   ├───PpsSourceSelector
    │   │               
    │   ├───SignalGenerator
    │   │               
    │   ├───SignalTimestamper
    │   │               
    │   ├───SmaSelector
    │   │               
    │   └───TodSlave
    │                   
    ├───Modules
    │   └───BufgMux
    │           
    └───Package
```

## Implementation

Реализации FPGA TimeCard разделены в зависимости от производителя/версии. В настоящее время доступна только реализация Xilinx для Open Source Timecard. 
Верхняя папка проекта находится по пути [*/[YOUR_PATH]/Implementation/Xilinx/TimeCard*](implementation/Xilinx/TimeCard/).

В этой папке находятся файлы, зависящие от производителя и реализации:
- Файл **Readme.md** описывает проект реализации и инструктирует, как создать/реализовать проект и сгенерировать бинарные файлы.
- Файл **DefaultConfigFile.txt** - это конфигурация по умолчанию ядер FPGA
- Файл **CoreListFile.txt** перечисляет настраиваемые ядра FPGA
- 4 файла **.tcl** для создания/реализации проекта и генерации бинарных файлов
- Папка **Additional Files** содержит файлы (например, изображения) для документации проекта 
- Папка **Bd** содержит файлы **.tcl** для создания Block Design проекта (вызываются CreateProject.tcl)
- Папка **Binaries** содержит сгенерированные бинарные файлы проекта после каждого запуска реализации 
- Папка **Constraints** содержит все файлы ограничений проекта 
- Папка **TimeCard** содержит файлы проекта, созданные во время создания, синтеза и реализации проекта. 
Папка создается при выполнении **CreateProject.tcl**. Папка не добавляется в репозиторий и должна быть удалена, чтобы успешно вызвать CreateProject.tcl
- Папка **Top** содержит верхний файл .vhd проекта

## Ips

Папка [**Ips**](Ips) содержит все пользовательские открытые IP-ядра. Каждая папка IP-ядра имеет похожую структуру 
- Файл **Readme.md** описывает ядро FPGA (обзор проекта, описание набора регистров и т.д.)     
- Файл(ы) **.vhd** ядра
- Папка **Xilinx** содержит специфичные для производителя файлы IPI для интеграции ядер в инструмент Vivado
- Папка **Additional Files** содержит файлы (например, изображения) для документации ядра

Дополнительно, папка **Ips** содержит файлы .xml пользовательских определений типов для интерфейсов IP-ядер.

## Modules

Папка [**Modules**](Modules) содержит все пользовательские открытые файлы .vhd, которые не инстанцированы как IPI.

## Package

Папка [**Package**](Package) содержит библиотечный файл проекта, который содержит различные константы и часто используемые процедуры.
