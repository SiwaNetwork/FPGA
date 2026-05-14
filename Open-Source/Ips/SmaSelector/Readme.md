# Описание проекта SMA Selector
## Содержание

[1. Обзор контекста](#1-обзор-контекста)

[2. Описание интерфейса](#2-описание-интерфейса)

[3. Набор регистров](#3-набор-регистров)

[4. Описание проекта](#4-описание-проекта)

## 1. Обзор контекста
SMA Selector — это полностью аппаратная (только FPGA) реализация, которая мультиплексирует выходы и демультиплексирует входы 
4 разъёмов SMA [Timecard](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card).
Каждый разъём может быть сконфигурирован как вход или выход в зависимости от настроенного отображения.
Следующие сигналы могут поступать с входа SMA:
- 10MHz Clock (только от SMA 1)
- External PPS 1
- External PPS 2
- Source to Signal Timestamper 1
- Source to Signal Timestamper 2
- Source to Signal Timestamper 3
- Source to Signal Timestamper 4
- Source to Frequency Counter 1
- Source to Frequency Counter 2
- Source to Frequency Counter 3
- Source to Frequency Counter 4 
- IRIG Slave (unused)
- DCF Slave (unused)
- External UART Rx

Следующие сигналы могут быть отображены на выход SMA:
- 10MHz pulse
- PPS FPGA
- PPS MAC
- PPS GNSS 1
- PPS GNSS 2
- IRIG Master (unused)
- DCF Master (unused)
- Signal Generator 1
- Signal Generator 2
- Signal Generator 3
- Signal Generator 4
- GNSS 1 UART Messages
- GNSS 2 UART Messages
- External UART Tx

Возможные отображения направлений данных SMA:
|Разъём|Выбор 1|Выбор 2|
|-----|---------|---------|
|SMA 1|Input|Output|
|SMA 2|Input|Output|
|SMA 3|Output|Input|
|SMA 4|Output|Input|

Настроенное отображение выполняется через 2 интерфейса slave AXI4L, названных AXI1 и AXI2. Каждый интерфейс slave управляет одним вариантом отображения.

## 2. Описание интерфейса
### 2.1 IP SMA Selector
Интерфейс SMA Selector:
- System Reset и System Clock на вход
- Источники выхода SMA на вход ядра
- Источники входа SMA на выход ядра 
- Сигнал SMA для каждого разъёма SMA на вход, в случае если разъём сконфигурирован как вход
- Сигнал SMA для каждого разъёма SMA на выход, в случае если разъём сконфигурирован как выход   
- Сигналы разрешения входа и выхода для каждого разъёма SMA на выход
- Интерфейс slave AXI4L для конфигурации отображения 1 (AXI1)
- Интерфейс slave AXI4L для конфигурации отображения 2 (AXI2)
 
![SMA Selector IP](Additional%20Files/SmaSelectorIP.png) 

Ядро имеет следующие параметры конфигурации. 

![SMA Selector CONFIG](Additional%20Files/SmaSelectorConfig.png) 
 
## 3. Набор регистров
SMA Selector имеет два набора регистров, по одному для каждой конфигурации отображения. Каждая конфигурация отображения доступна через AXI4 Light Memory Mapped. 
Все регистры 32-битные, не поддерживаются пакетный доступ, невыровненный доступ, byte enables, таймауты. 
Адресное пространство регистров не непрерывно. Адреса регистров — это только смещения в области памяти, где ядро отображено в AXI interconnect. 
Обращение к несуществующему регистру в отображённой области памяти возвращает ошибку декодирования slave.
### 3.1 Набор регистров 1
Набор регистров 1 конфигурирует отображение 1. В отображении 1 SMA 1 и SMA 2 являются входами, а SMA 3 и SMA 4 — выходами. 

Кроме того, Набор регистров 1 предоставляет статус 4 входов SMA.

#### 3.1.1 Обзор набора регистров 1 
Обзор набора регистров 1 показан в таблице ниже. 
![RegisterSet1](Additional%20Files/Regset1_Overview.png)
#### 3.1.2 Описание регистров
Таблицы ниже описывают регистры отображения 1 SMA Selector. 
![InputSel1](Additional%20Files/Regset1_1_InputSel.png)
![OutputSel1](Additional%20Files/Regset1_2_OutputSel.png)
![Version1](Additional%20Files/Regset1_3_Version.png)
![InputStatus](Additional%20Files/Regset1_4_InputStatus.png)
### 3.2 Набор регистров 2
Набор регистров 2 конфигурирует отображение 2. В отображении 2 SMA 1 и SMA 2 являются выходами, а SMA 3 и SMA 4 — входами. 
#### 3.2.1 Обзор набора регистров 2 
Обзор набора регистров 2 показан в таблице ниже. 
![RegisterSet2](Additional%20Files/Regset2_Overview.png)
#### 3.2.2 Описание регистров
Таблицы ниже описывают регистры отображения 2 SMA Selector. Версия идентична для отображений 1 и 2 (**should i remove version for mapping2?**)     
![InputSel2](Additional%20Files/Regset2_1_InputSel.png)
![OutputSel2](Additional%20Files/Regset2_2_OutputSel.png)
![Version2](Additional%20Files/Regset2_3_Version.png)

## 4 Описание проекта
SMA Selector мультиплексирует входные и выходные опции в соответствии с конфигурациями отображения. 
Ядро содержит 2 интерфейса slave AXI4Lite для конфигурации и контроля статуса со стороны CPU. 

Компонент состоит из 2 основных операций:
- Отображение входов и выходов SMA     
- Интерфейс с CPU (AXI master) через 2 интерфейса slave AXI
### 4.1 Отображение входов и выходов SMA

Существует 4 возможных сигнала выбора источника входа SMA, полученных из конфигурации (см. [Главу 3](#3-register-set)). Каждый из них определяет использование соответствующего входа SMA. **Использование входа SMA X, где X=1,2,3,4, отображается следующим образом:**  
|SMA Input X является источником для |Bit 0|Bit 1|Bit 2|Bit 3|Bit 4|Bit 5|Bit 6|Bit 7|Bit 8|Bit 9|Bit 10|Bit 11|Bit 12|Bit 13|Bit 14|Bit 15|
|-------------------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|:----:|:----:|
|Ext PPS 1|1|
|Ext PPS 2||1|
|Signal Timestamper 1|||1|
|Signal Timestamper 2||||1|
|IRIG Slave (unused)|||||1|
|DCF Slave (unused)||||||1|
|Signal Timestamper 3|||||||1|
|Signal Timestamper 4||||||||1|
|Frequency Counter 1|||||||||1|
|Frequency Counter 2||||||||||1|
|Frequency Counter 3|||||||||||1|
|Frequency Counter 4||||||||||||1|
|External UART Rx|||||||||||||1|
|10 MHz enable*|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|
|Enable SMA Input X||||||||||||||||1|

*Примечание: Импульс 10 МГц поддерживается только через вход SMA 1 и включается, если источник выбора входа SMA 1 не отображён ни на какой другой выбор. 
*Примечание 2: Вход SMA может быть источником для нескольких назначений.   
 
Существует 4 возможных сигнала выбора источника выхода SMA, полученных из конфигурации (см. [Главу 3](#3-register-set)). Каждый из них определяет, что должно быть отправлено на соответствующий выход SMA. **Подключение выхода SMA X, где X=1,2,3,4, отображается следующим образом**  

|SMA Output X получает сигнал от|Bit 0|Bit 1|Bit 2|Bit 3|Bit 4|Bit 5|Bit 6|Bit 7|Bit 8|Bit 9|Bit 10|Bit 11|Bit 12|Bit 13|Bit 14|Bit 15|
|-------------------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|FPGA PPS|1|
|MAC PPS||1|
|GNSS 1 PPS|||1|
|GNSS 2 PPS||||1|
|IRIG Master (unused)|||||1|
|DCF Master (unused)||||||1|
|Signal Generator 1|||||||1|
|Signal Generator 2||||||||1|
|Signal Generator 3|||||||||1|
|Signal Generator 4||||||||||1|
|UART GNSS 1 UART Messages|||||||||||1|
|UART GNSS 2 UART Messages||||||||||||1|
|External UART Tx|||||||||||||1|
|GND||||||||||||||1|
|VCC|||||||||||||||1|
|10 MHz pulse|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|
|Enable SMA Output X||||||||||||||||1|
### 4.2 AXI slave SMA Selector 
SMA Selector включает 2 интерфейса slave AXI Light Memory Mapped. Каждый интерфейс slave предоставляет доступ к регистрам отображения и позволяет конфигурировать ядро. 
AXI Master должен конфигурировать наборы данных записью AXI в регистры, что обычно выполняется CPU. Полное описание набора регистров приведено в [Главе 3](#3-register-set).
