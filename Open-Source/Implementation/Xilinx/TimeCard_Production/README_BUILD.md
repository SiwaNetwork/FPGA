# Инструкция по компиляции TimeCard_Production

## Быстрый старт

### Вариант 1: Компиляция через GUI (рекомендуется)

1. **Откройте проект:**
   - Запустите `BuildProject.bat` (двойной клик)
   - Или откройте Vivado и выберите: File → Open Project → `TimeCard\TimeCard.xpr`

2. **После открытия проекта в Vivado:**
   - В TCL консоли выполните:
     ```tcl
     source CreateBinaries.tcl
     ```
   - Или через меню: Tools → Run Tcl Script... → выберите `CreateBinaries.tcl`

3. **Дождитесь завершения компиляции** (30-60+ минут)

### Вариант 2: Компиляция без GUI (headless)

Запустите `BuildProjectHeadless.bat` (двойной клик)

Скрипт автоматически:
- Откроет проект
- Запустит синтез
- Запустит implementation
- Создаст bitstream
- Скопирует файлы в папку `Binaries\`

## Результаты компиляции

После успешной компиляции файлы будут в:

- `Binaries\TimeCardOS_Production.bit` - основной битстрим
- `Binaries\TimeCardOS_Production.bin` - бинарный файл для загрузки
- `Binaries\TimeCardOS_Production.hdf` - hardware definition file
- `Binaries\Factory_TimeCardOS_Production.bin` - фабричный образ (если есть Golden Image)

Также создается резервная копия с timestamp в папке:
- `Binaries\YYYY_MM_DD HH_MM_SS\`

## Что было изменено в конфигурации

В `DefaultConfigFile.txt` были внесены следующие изменения:

1. **Правильный порядок инициализации:**
   - ToD Slave → PPS Slave → Adjustable Clock → PPS Generator

2. **Инициализация Signal Generator (4 экземпляра):**
   - Установлена полярность (active high)
   - Генераторы выключены, готовы к программной настройке

3. **Инициализация RGB LED:**
   - Включен shutdown disable
   - Инициализирован GPIO RGB

## Проверка пути к Vivado

Скрипты автоматически ищут Vivado по пути:
- `C:\Xilinx\Vivado\2019.1\bin\vivado.bat`

Если Vivado установлен в другом месте, отредактируйте переменную `VIVADO_PATH` в батниках.

## Требования

- Vivado 2019.1 или совместимая версия
- Часть FPGA: xc7a100tfgg484-1 (Artix-7 100T)
- Достаточно места на диске (несколько GB для временных файлов)
- Время компиляции: 30-60+ минут в зависимости от ПК
