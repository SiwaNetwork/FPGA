# Описание проекта Open Source TimeCard Production

## Содержание

[1. Обзор проекта](#1-обзор-проекта)

[2. Адресное пространство](#2-адресное-пространство)

[3. Карта прерываний](#3-карта-прерываний)

[4. SMA разъемы](#4-sma-разъемы)

[5. Светодиоды состояния](#5-светодиоды-состояния)

[6. Конфигурация по умолчанию](#6-конфигурация-по-умолчанию)

[7. Список ядер](#7-список-ядер)

[8. Создание проекта FPGA и генерация бинарных файлов](#8-создание-проекта-fpga-и-генерация-бинарных-файлов)

[9. Программирование FPGA и SPI Flash](#9-программирование-fpga-и-spi-flash)

## 1. Обзор проекта

Проект Open Source TimeCard включает открытые IP-ядра от [NetTimeLogic](https://www.nettimelogic.com/) и бесплатные IP-ядра от [Xilinx](https://www.xilinx.com/).
В проекте Open Source TimeCard используются следующие ядра.

|Ядро|Производитель|Описание|
|----|:----:|-----------|
|[AXI Memory Mapped to PCI Express](https://www.xilinx.com/products/intellectual-property/axi_pcie.html) |Xilinx|Интерфейс между AXI4 и кремниевым ядром PCI Express Gen2 (PCIe)|
|[AXI GPIO](https://www.xilinx.com/products/intellectual-property/axi_gpio.html) |Xilinx|Универсальный интерфейс ввода/вывода для AXI4-Lite|
|[AXI I2C](https://www.xilinx.com/products/intellectual-property/axi_iic.html) |Xilinx| Интерфейс между AXI4-Lite и шиной IIC|
|[AXI UART 16550](https://www.xilinx.com/products/intellectual-property/axi_uart16550.html)|Xilinx|Интерфейс между AXI4-Lite и UART|
|[AXI HWICAP](https://www.xilinx.com/products/intellectual-property/axi_hwicap.html) |Xilinx|Интерфейс AXI4-Lite для чтения и записи конфигурационной памяти FPGA через Internal Configuration Access Port (ICAP)|
|[AXI Quad SPI Flash](https://www.xilinx.com/products/intellectual-property/axi_quadspi.html) |Xilinx|Интерфейс между AXI4-Lite и Dual или Quad SPI||
|[AXI Interconnect](https://www.xilinx.com/products/intellectual-property/axi_interconnect.html) |Xilinx|Соединение между одним или несколькими ведущими устройствами AXI4 с памятью и одним или несколькими ведомыми устройствами с памятью|
|[Clocking Wizard](https://www.xilinx.com/products/intellectual-property/clocking_wizard.html) |Xilinx|Конфигурация схемы тактирования в соответствии с требованиями пользователя|
|[Processor System Reset](https://www.xilinx.com/products/intellectual-property/proc_sys_reset.html) |Xilinx|Установка определенных параметров для включения/отключения функций|
|[TC Adj. Clock](../../../Ips/AdjustableClock/)|NetTimeLogic|Таймер-часы в формате секунд и наносекунд, которые могут быть скорректированы по частоте и фазе|
|[TC Signal Timestamper](../../../Ips/SignalTimestamper)|NetTimeLogic|Временная метка сигнала события с настраиваемой полярностью и генерация прерываний|
|[TC PPS Generator](../../../Ips/PpsGenerator)|NetTimeLogic|Генерация импульса в секунду (PPS) с настраиваемой полярностью и синхронизацией с началом новой секунды локальных часов|
|[TC Signal Generator](../../../Ips/SignalGenerator)|NetTimeLogic|Генерация сигналов с широтно-импульсной модуляцией (ШИМ) с настраиваемой полярностью и синхронизацией с локальными часами|
|[TC PPS Slave](../../../Ips/PpsSlave)|NetTimeLogic|Вычисление коррекций смещения и дрейфа для применения к Adjustable Clock с целью синхронизации с PPS входом|
|[TC ToD Slave](../../../Ips/TodSlave)|NetTimeLogic|Прием сообщений от GNSS приемника через UART и синхронизация с Time of Day|
|[TC Frequency Counter](../../../Ips/FrequencyCounter)| NetTimeLogic|Измерение частоты входного сигнала в диапазоне 1 - 10'000'000 Гц|
|[TC CoreList](../../../Ips/CoreList)|NetTimeLogic|Список текущих экземпляров ядер FPGA, доступных через интерфейс AXI4-Lite|
|[TC Conf Master](../../../Ips/ConfMaster)|NetTimeLogic|Конфигурация по умолчанию, предоставляемая ведомым устройствам AXI4-Lite при запуске, без поддержки CPU|
|[TC MsiIrq](../../../Ips/MsiIrq)|NetTimeLogic|Пересылка одиночных прерываний как Message-Signaled Interrupts в [AXI-PCIe мост](https://www.xilinx.com/products/intellectual-property/axi_pcie.html)|
|[TC Clock Detector](../../../Ips/ClockDetector)|NetTimeLogic|Обнаружение доступных источников тактирования и выбор используемых тактовых сигналов в соответствии со схемой приоритетов и конфигурацией|
|[TC SMA Selector](../../../Ips/SmaSelector)|NetTimeLogic|Выбор сопоставления входов и выходов 4 SMA разъемов [TimeCard](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card)|
|[TC PPS Selector](../../../Ips/PpsSourceSelector)|NetTimeLogic|Обнаружение доступных источников PPS и выбор используемого источника PPS в соответствии со схемой приоритетов и конфигурацией|
|[TC Dummy Axi Slave](../../../Ips/DummyAxiSlave)|NetTimeLogic|Ведомое устройство AXI4L, используемое как заполнитель диапазона адресов|
|[TC FPGA Version](../../../Ips/FpgaVersion)|NetTimeLogic|Регистр AXI, хранящий номера версий проекта|

Описание топ-уровневого проекта показано ниже.

![TimeCardTop](Additional%20Files/TimeCardTop.png) 

*ПРИМЕЧАНИЕ:* Для упрощения схемы не все AXI соединения показаны, в то время как соединения IRQ с контроллером MSI упомянуты непосредственно у IP-ядер.

TimeCard частично работает от 200 МГц осциллятора SOM. 
Ядра NetTimeLogic со всеми высокоточными частями работают на основе выбранного тактового сигнала детектором тактирования (10 МГц от MAC, SMA и т.д.).

## 2. Адресное пространство

Ядра проекта доступны через ведомые интерфейсы AXI4 Light Memory Mapped для конфигурации и отчетности. 
Ведомые интерфейсы AXI доступны через AXI interconnect от 2 ведущих устройств AXI:
- [TC ConfMaster](../../../Ips/ConfMaster) предоставляет конфигурацию по умолчанию ядрам после сброса. Конфигурация по умолчанию может быть изменена во время компиляции.
- [AXI PCIe](https://www.xilinx.com/products/intellectual-property/axi_pcie.html) предоставляет полную функциональность моста между архитектурой AXI4 и сетью PCIe. 
Обычно CPU подключается к TimeCard через этот интерфейс PCIe. 

Ведомые интерфейсы AXI имеют следующие адреса:

|Ведомое устройство|Интерфейс AXI Slave|Смещение адреса|Высокий адрес|
|-----|-------------------|--------------|------------|
|AXI PCIe Control|S_AXI_CTL|0x0001_0000|0x0001_0FFF|
|TC FPGA Version|axi4l_slave|0x0002_0000|0x0002_0FFF|
|AXI GPIO Ext|S_AXI|0x0010_0000|0x0010_0FFF|
|AXI GPIO GNSS/MAC|S_AXI|0x0011_0000|0x0011_0FFF|
|TC Clock Detector|axi4l_slave|0x0013_0000|0x0013_0FFF|
|TC SMA Selector|axi4l_slave1|0x0014_0000|0x0014_3FFF|
|AXI I2C PCA9546|S_AXI|0x0015_0000|0x0015_FFFF|
|AXI UART 16550 GNSS1|S_AXI|0x0016_0000|0x0016_FFFF|
|AXI UART 16550 GNSS2|S_AXI|0x0017_0000|0x0017_FFFF|
|AXI UART 16550 MAC|S_AXI|0x0018_0000|0x0018_FFFF|
|AXI UART 16550 EXT|S_AXI|0x001A_0000|0x001A_FFFF|
|AXI I2C EEPROM|S_AXI|0x0020_0000|0x0020_0FFF|
|AXI I2C RGB|S_AXI|0x0021_0000|0x0021_0FFF|
|TC SMA Selector|axi4l_slave2|0x0022_0000|0x0022_3FFF|
|AXI GPIO RGB|S_AXI|0x0023_0000|0x0023_0FFF|
|AXI HWICAP|S_AXI_LITE|0x0030_0000|0x0030_FFFF|
|AXI Quad SPI Flash|AXI_LITE|0x0031_0000|0x0031_FFFF|
|TC Adj. Clock|axi4l_slave|0x0100_0000|0x0100_FFFF|
|TC Signal TS GNSS1 PPS|axi4l_slave|0x0101_0000|0x0101_FFFF|
|TC Signal TS1|axi4l_slave|0x0102_0000|0x0102_FFFF|
|TC PPS Generator|axi4l_slave|0x0103_0000|0x0103_FFFF|
|TC PPS Slave|axi4l_slave|0x0104_0000|0x0104_FFFF|
|TC ToD Slave|axi4l_slave|0x0105_0000|0x0105_FFFF|
|TC Signal TS2|axi4l_slave|0x0106_0000|0x0106_FFFF|
|TC Dummy Axi Slave1|axi4l_slave|0x0107_0000|0x0107_FFFF|
|TC Dummy Axi Slave2|axi4l_slave|0x0108_0000|0x0108_FFFF|
|TC Dummy Axi Slave3|axi4l_slave|0x0109_0000|0x0109_FFFF|
|TC Dummy Axi Slave4|axi4l_slave|0x010A_0000|0x010A_FFFF|
|TC Dummy Axi Slave5|axi4l_slave|0x010B_0000|0x010B_FFFF|
|TC Signal TS FPGA PPS|axi4l_slave|0x010C_0000|0x010C_FFFF|
|TC Signal Generator1|axi4l_slave|0x010D_0000|0x010D_FFFF|
|TC Signal Generator2|axi4l_slave|0x010E_0000|0x010E_FFFF|
|TC Signal Generator3|axi4l_slave|0x010F_0000|0x010F_FFFF|
|TC Signal Generator4|axi4l_slave|0x0110_0000|0x0110_FFFF|
|TC Signal TS3|axi4l_slave|0x0111_0000|0x0111_FFFF|
|TC Signal TS4|axi4l_slave|0x0112_0000|0x0112_FFFF|
|TC Frequency Counter 1|axi4l_slave|0x0120_0000|0x0120_FFFF|
|TC Frequency Counter 2|axi4l_slave|0x0121_0000|0x0121_FFFF|
|TC Frequency Counter 3|axi4l_slave|0x0122_0000|0x0122_FFFF|
|TC Frequency Counter 4|axi4l_slave|0x0123_0000|0x0123_FFFF|
|TC CoreList|axi4l_slave|0x0130_0000|0x0130_FFFF|

Подробное описание регистров каждого экземпляра доступно в соответствующем документе описания ядра (см. ссылки в [Главе 1](#1-обзор-проекта)). 

### 2.1 Регистр версии FPGA

Ведомое устройство Version имеет один 32-битный регистр. 
Старшие 16 бит показывают номер версии golden образа, а младшие 16 бит - номер версии обычного образа.
Например:

- Регистр 0x0200_0000 golden образа показывает: 0x8001_0000
- Регистр 0x0200_0000 обычного образа показывает: 0x0000_8001

Если младшие 16 бит равны 0x0000, загружен golden образ. Дополнительно, светодиоды SMA мигают красным.

### 2.2 Регистры AXI GPIO

В реализации используются три экземпляра IP [AXI GPIO](https://www.xilinx.com/products/intellectual-property/axi_gpio.html). 
Входы или выходы могут быть активными по высокому или низкому уровню для внешнего сигнала. 
Инверсия выполняется в FPGA. В AXI GPIO всегда используется активный высокий уровень. Инвертированные сигналы подчеркнуты в таблицах ниже.

Сопоставление AXI GPIO Ext показано ниже

![AXI_GPIO_Ext](Additional%20Files/AXI_GPIO_Ext.png)

Сопоставление AXI GPIO GNSS/MAC показано ниже

![AXI_GPIO_GNSS_MAC](Additional%20Files/AXI_GPIO_GNSS_MAC.png)

Сопоставление AXI GPIO RGB показано ниже

![AXI_GPIO_RGB](Additional%20Files/AXI_GPIO_RGB.png)

## 3. Карта прерываний

Прерывания в проекте подключены к вектору MSI ядра AXI Memory Mapped to PCI Express через контроллер MSI. 
Ядро PCI Express должно установить MSI_enable в '1'. 
Контроллер MSI отправляет INTX_MSI Request с MSI_Vector_Num в ядро PCI Express, и с INTX_MSI_Grant прерывание подтверждается. 
Если есть несколько ожидающих прерываний, сообщения отправляются по принципу round-robin. 
Уровневые прерывания (например, AXI UART 16550) занимают как минимум один цикл для следующего прерывания.

|Номер MSI|Источник прерывания|
|----------|----------------|
|0|TC Signal TS FPGA PPS|
|1|TC Signal TS GNSS1 PPS|
|2|TC Signal TS1|
|3|AXI UART 16550 GNSS1|
|4|AXI UART 16550 GNSS2|
|5|AXI UART 16550 MAC|
|6|TC Signal TS2|
|7|AXI I2C PCA9546|
|8|AXI HWICAP|
|9|AXI Quad SPI Flash|
|10|Зарезервировано|
|11|TC Signal Generator1|
|12|TC Signal Generator2|
|13|TC Signal Generator3|
|14|TC Signal Generator4|
|15|TC Signal TS3|
|16|TC Signal TS4|
|17|AXI I2C EEPROM|
|18|AXI I2C RGB|
|19|AXI UART 16550 Ext|

## 4. SMA разъемы

[TimeCard](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card) имеет в настоящее время 4 SMA разъема с настраиваемым входом/выходом и дополнительный SMA вход антенны GNSS.
Конфигурация по умолчанию SMA разъемов показана ниже.

<p align="left"> <img src="Additional%20Files/SmaConnectors.png" alt="Sublime's custom image"/> </p>

Это сопоставление по умолчанию и направление могут быть изменены через 2 ведомых устройства AXI IP-ядра [TC SMA Selector](../../../Ips/SmaSelector). 

## 5. Светодиоды состояния

В текущем проекте светодиоды состояния не подключены к AXI GPIO Ext и используются напрямую FPGA.

- LED1: Индикатор активности внутреннего тактового сигнала FPGA (50 МГц)
- LED2: Индикатор активности части тактирования PCIe (62.5 МГц)
- LED3: PPS от FPGA (время локальных часов через PPS Master)
- LED4: PPS от MAC (дифференциальные входы от MAC через дифференциальный буфер)

RGB светодиоды (SMA1-4 и GNSS1) могут управляться через I2C или GPIO (в зависимости от варианта сборки).
В случае загрузки Fall-Back образа все четыре светодиода SMA мигают красным.

## 6. Конфигурация по умолчанию 

Конфигурация по умолчанию предоставляется [TC ConfMaster](../../../Ips/ConfMaster) и может быть отредактирована путем обновления [DefaultConfigFile.txt](DefaultConfigFile.txt).
В настоящее время следующие ядра настроены при запуске файлом конфигурации по умолчанию. 

|Экземпляр ядра|Конфигурация|
|-------------|-------------|
|Adjustable Clock|Включить с источником синхронизации 1 (ToD+PPS)|
|PPS Generator|Включить с высокой полярностью выходного импульса|
|PPS Slave|Включить с высокой полярностью входного импульса|
|ToD Slave|Включить с высокой полярностью UART входа|
|SMA Selector|Установить FPGA PPS и GNSS PPS как выходы SMA|

## 7. Список ядер 
Список настраиваемых ядер (через AXI) предоставляется [TC CoreList](../../../Ips/CoreList) и может быть отредактирован путем обновления [CoreListFile.txt](CoreListFile.txt).

## 8. Создание проекта FPGA и генерация бинарных файлов

### 8.1 Создание проекта FPGA

Проект Vivado был создан с помощью Vivado 2019.1.
Поскольку проект Vivado не предназначен для хранения в системе контроля версий или хранения как есть в целом, был создан скрипт проекта, который создаст проект Vivado из скрипта.

Скрипт должен быть запущен один раз для создания проекта с нуля.

Запустите это из консоли TCL Vivado:

*source /[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/CreateProject.tcl*

(Альтернативно, это может быть запущено через меню Tool=>Run Tcl Script… в GUI Vivado)

Скрипт добавит все необходимые файлы в проект, а также ограничения, так что все готово для генерации битстрима для FPGA.
Проект будет создан в следующей папке:

*/[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/TimeCard*

### 8.2 Синтез, реализация и генерация битстрима

Скрипт генерации битстрима запускает синтез и реализацию и генерирует битстримы для указанных запусков проекта:
- Скрипт */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/CreateBinaries.tcl* запускает синтез/реализацию проекта TimeCardOS_Production, генерирует битстримы и обновляет соответствующим образом Factory_TimeCardOS_Production.bin
- Скрипт */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/CreateBinariesGolden.tcl* запускает синтез/реализацию проекта Golden_TimeCardOS_Production, генерирует битстримы и обновляет соответствующим образом Factory_TimeCardOS_Production.bin
- Скрипт */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/CreateBinariesAll.tcl* запускает синтез/реализацию обоих проектов, генерирует соответствующие битстримы и обновляет соответствующим образом Factory_TimeCardOS_Production.bin. Он также создает файл TimeCardOS_Production_Gotham.bin, который основан на TimeCardOS_Production.bin и имеет дополнительный 16-байтовый заголовок с ID PCIe. 

Бинарные файлы копируются в папку */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/*. 
Существующие битстримы в папке Binaries перезаписываются, а также создается копия файлов в подпапке папки Binaries с временной меткой. Таким образом, последний запуск реализации всегда находится в одном и том же месте, но резервные копии предыдущих (и текущих) запусков все еще доступны.

Последние бинарные файлы можно найти здесь:
- */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/Factory_TimeCardOS_Production.bin*
- */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/Golden_TimeCardOS_Production.bin*
- */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/TimeCardOS_Production.bin*
- */[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/TimeCardOS_Production_Gotham.bin*

Резервные копии с временной меткой находятся в папке в следующем формате:

*/[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/YYYY_MM_DD hh_mm_ss/*, где YYYY: Год, MM: Месяц, DD: День, hh: Час, mm: Минута, ss: Секунда

Например, для 30 января 2022 года в 13:05:00: 
/[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/Binaries/2022_01_30 13_05_00/

Скрипт может быть запущен из консоли TCL Vivado (когда проект открыт) командой:

*source /[YOUR_PATH]/Implementation/Xilinx/TimeCard_Production/CreateBinariesAll.tcl*

(Альтернативно, это может быть запущено через меню Tool=>Run Tcl Script… в GUI Vivado, пока проект открыт)

### 8.3 Использование ресурсов

Проект реализован на FPGA [Artix-7 XC7A100T-FGG484-1](https://docs.xilinx.com/v/u/en-US/ug475_7Series_Pkg_Pinout).

Сводка использования ресурсов показана ниже.
|Ресурс|Использовано|Доступно|Использование %|
|--------|:--:|:-------:|:---:|
|LUTs|35300|63400|55.68|
|Триггеры|29881|126800|23.57|
|BRAMs|22.5|135|22.90|
|DSPs|23|240|9.58|


## 9. Программирование FPGA и SPI Flash

Для первоначального программирования FPGA и SPI Flash требуется JTAG программатор, который должен быть подключен к USB JTAG.
После успешного программирования FPGA, проект содержит ядро AXI QUAD SPI, которое позволяет обновления в полевых условиях.

Образы FPGA хранятся в папке [Binaries](Binaries/).

### 9.1 Битстримы с конфигурацией Fallback

Проект FPGA разделен на два различных битстрима/бинарных файла для обеспечения безопасного обновления в полевых условиях. 
- Первый образ - это Golden/Fallback образ *Golden_TimeCardOS_Production.bin*. Он содержит только ограниченную функциональность, которая обеспечивает доступ к SPI Flash. 
- Второй образ - это последняя версия обычного образа *TimeCardOS_Production.bin*. Он используется для нормальной работы и является тем, который заменяется при обновлении в полевых условиях.

Конфигурация FPGA всегда начинается с Addr0, где находится Golden образ. Golden образ имеет начальный адрес образа обновления TimeCardOS_Production. 
Конфигурация переходит непосредственно к этому адресу и пытается загрузить образ обновления. Если эта загрузка не удалась, происходит возврат к Golden образу.

Подробности об этом подходе Multiboot/Fallback можно найти в примечании по применению Xilinx 
[MultiBoot with 7 Series FPGAs and BPI](https://www.xilinx.com/support/documentation/application_notes/xapp1246-multiboot-bpi.pdf).

Образ *Factory_TimeCardOS_Production.bin* содержит два битстрима и должен использоваться для программирования SPI flash в первый раз, например, во время производства. 

Этот объединенный образ имеет следующую структуру:

|Информация о конфигурации|Значение|
|-------------------|----------|
|Формат файла        |BIN       |
|Интерфейс          |SPIX4     |
|Размер               |16M       |
|Начальный адрес      |0x00000000|
|Конечный адрес        |0x00FFFFFF|

|Адрес1         |Адрес2         |Файл(ы)              |
|:------------:|:------------:|---------------------|
|0x00000000    |0x002C8B2F    |Golden_TimeCardOS_Production.bit|
|0x00400000    |0x006CA157    |TimeCardOS_Production.bit       |

Образ *TimeCardOS_Production.bin* - это образ обновления/обычный образ и должен использоваться для обновления в полевых условиях через SPI.
Для обновления этот битстрим должен быть размещен по адресу 0x00400000 в SPI flash.

### 9.2 Шаги программирования SPI (нелетучий)

Если устройство конфигурационной памяти уже добавлено в проект, перейдите к шагу 7, в противном случае перейдите к шагу 1.
1. Перейдите в меню Hardware Manager

   ![Hardware Manager](Additional%20Files/HwManager.png) 

2. Правый клик на "xc7a100t_0(1)", появится меню
3. Выберите "Add Configuration Memory Device …" из меню, появится следующее окно

   ![Add Config Memory](Additional%20Files/AddConfigMemory.png)

4. Выберите "mt25ql128-spi-x1_x2_x4" как тип SPI Flash
5. Нажмите Ok, появится новое окно:

   ![Add Config Confirm](Additional%20Files/AddConfigConfirm.png)

6. Нажмите cancel
7. Перейдите в меню Hardware Manager, где будет подключена flash

   ![Hardware Manager Updated](Additional%20Files/HwManagerUpdated.png) 

8. Правый клик на "mt25ql128-spi-x1_x2_x4", появится меню
9. Выберите "Program Configuration Memory Device …" из меню, появится следующее окно

   ![Config Mem Program](Additional%20Files/ConfigMemProgram.png) 

10. Выберите битстрим, который хотите запрограммировать:
**Factory_TimeCardOS_Production.bin** 

ВАЖНОЕ ПРИМЕЧАНИЕ: 
Если TimeCardOS_Production.bin загружен на этом шаге, обновление в полевых условиях не будет работать, как описано в [Главе 9.1](#91-битстримы-с-конфигурацией-fallback)!

11. Нажмите Ok и дождитесь завершения
12. Отключите интерфейс JTAG от платы
13. Выполните цикл питания или сброс платы / Холодный запуск ПК
14. Светодиод RUN будет мигать
