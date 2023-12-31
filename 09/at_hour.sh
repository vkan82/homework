#!/bin/sh
# Функция получения предыдущего часа в формате %d/%b/%Y:%H, который необходим для
# осуществления выборки из лог-файла с датой указанного формата
# Как использовать:
#
#         #!/bin/sh
#         . ./at_hour.sh
#         at_hour=$(hour)
#         echo $at_hour
hour() {
    # local d=$(LANG=en_EN date -d '1 hour ago' +%d/%b/%Y:%H)
    # Так как необходимо производить выборку за предыдущий час из лога,
    # то производится -d '1 hour ago'
    # При этом локаль принудительно LANG=en_EN, иначе генерирует дату в текущей локали
    # Так как мы используем тестовый лог файл, то в нем нет сведений на актуальное время,
    # имитируем выборку в прошлом, для этого вычтем необходимое количество часов 681
    
    corrective=590
    formatted_hour=$(LANG=en_EN date -d "$corrective hour ago" +%d/%b/%Y:%H)
    echo $formatted_hour
}
