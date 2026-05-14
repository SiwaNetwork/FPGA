# Описание архитектуры FPGA Version
## Содержание

[1. Общий обзор контекста](#1-context-overview)

[2. Описание интерфейса](#2-interface-description)

[3. Набор регистров](#3-register-set)


## 1. Общий обзор контекста
Ядро FPGA Version — это 32-битный регистр, доступный через AXI4-Lite интерфейс.
Регистр состоит из 2 частей:
- версия FPGA, которая занимает 2 младших байта (LSB) регистра
- FPGA Golden version, которая занимает 2 младших байта (LSB) регистра
Вход выбирает, какая из 2 версий предоставляется на AXI интерфейс.

## 2. Описание интерфейса

Интерфейс Core List:
- System Reset и System Clock на входе
- AXI4L slave интерфейс, через который CPU считывает информацию о версии FPGA
- Вход, который выбирает, какая из 2 версий предоставляется на AXI интерфейс
 
![FPGA Version IP](Additional%20Files/FpgaVersion_IP.png) 

Параметры конфигурации ядра — это версии FPGA и Golden FPGA

![FPGA Version Config](Additional%20Files/FpgaVersion_Config.png)

## 3. Набор регистров
CPU получает версии путем доступа к регистру с отображением в памяти ядра FPGA Version.
![FPGA Version Regset](Additional%20Files/FpgaVersion_Regset.png)

