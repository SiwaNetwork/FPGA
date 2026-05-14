# Описание архитектуры Communication Selector
## Содержание

[1. Общий обзор контекста](#1-context-overview)

[2. Описание интерфейса](#2-interface-description)

[3. Набор регистров](#3-register-set)

[4. Описание архитектуры](#4-design-description)

## 1. Общий обзор контекста
Communication Selector — это полностью аппаратная (FPGA) реализация, которая выбирает, какой коммуникационный интерфейс будет использоваться между FPGA и модулем тактового сигнала (например, MAC, OCXO). Выбор может быть получен из регистра конфигурации AXI (например, с помощью [AXI GPIO](https://www.xilinx.com/products/intellectual-property/axi_gpio.html#documentation)) и устанавливается как UART (Selection:'0') или I<sup>2</sup>C (Selection:'1'). Конфигурация по умолчанию — UART.

## 2. Описание интерфейса
### 2.1 Communication Selector IP
Интерфейс Communication Selector:
- Выбор коммуникационного интерфейса из регистра AXI на входе
- UART интерфейс (входы и выходы)
- UART Interrupt request на входе
- I<sup>2</sup>C интерфейс (входы и выходы)
- UART Interrupt request на входе

![CommunicatioSelectorIP](Additional%20Files/CommunicationSelectorIP.png)

Ядро не предоставляет параметров конфигурации

## 3. Набор регистров
Communication Selector не имеет выделенного интерфейса AXI4L. Он получает вход Selection, который может быть предоставлен через внешний AXI интерфейс. Этот интерфейс зависит от реализации и выходит за рамки данного документа.

## 4 Описание архитектуры
Ядро мультиплексирует UART и I<sup>2</sup>C интерфейсы таким образом, что один и тот же вывод платы может поддерживать оба интерфейса. Поскольку интерфейс I<sup>2</sup>C имеет больше выводов, чем UART, при выборе UART интерфейса некоторые выводы будут неиспользованными.

![CommunicationMux](Additional%20Files/CommunicationMux.png)



Таблица ниже показывает назначение входов на выходы при Selection = 0 (UART):

|                       |SCL In|SCL Out|SCL T|SDA In|SDA Out|SDA T|IRQ|
|-----------------------|:----:|:-----:|:---:|:----:|:-----:|:---:|:-:|
|UART Rx                ||||X|
|UART Tx                ||X|
|UART IRQ               |||||||X|
|I<sup>2</sup>C SCL In |
|I<sup>2</sup>C SCL Out|
|I<sup>2</sup>C SCL T  |
|I<sup>2</sup>C SDA In |
|I<sup>2</sup>C SDA Out|
|I<sup>2</sup>C SDA T  |
|I<sup>2</sup>C IRQ    |

Таблица ниже показывает назначение входов на выходы при Selection = 1 (I<sup>2</sup>C):

|                       |SCL In|SCL Out|SCL T|SDA In|SDA Out|SDA T|IRQ|
|-----------------------|:----:|:-----:|:---:|:----:|:-----:|:---:|:-:|
|UART Rx                |
|UART Tx                |
|UART IRQ               |
|I<sup>2</sup>C SCL In |X|
|I<sup>2</sup>C SCL Out||X|
|I<sup>2</sup>C SCL T  |||X|
|I<sup>2</sup>C SDA In ||||X|
|I<sup>2</sup>C SDA Out|||||X|
|I<sup>2</sup>C SDA T  ||||||X|
|I<sup>2</sup>C SDA IRQ|||||||X|
