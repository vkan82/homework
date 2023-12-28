#!/bin/sh
# Функция получения времени в формате %d/%b/%Y:%H, до которого необходимо
# осуществить выборку из лог-файла
# Как использовать:
#
#         #!/bin/sh
#         . ./to_hour.sh
#         to_hour=$(hour1)
#         echo $to_hour
hour1() {
 
    corrective=589
    formatted_hour=$(LANG=en_EN date -d "$corrective hour ago" +%d/%b/%Y:%H)
    echo $formatted_hour
}
