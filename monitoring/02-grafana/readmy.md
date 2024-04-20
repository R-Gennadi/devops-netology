# Домашнее задание к занятию 14 «Средство визуализации Grafana»

## Обязательные задания
<details> <summary> . </summary>

## Задание 1
Используя директорию help внутри этого домашнего задания, запустите связку prometheus-grafana.
Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
Подключите поднятый вами prometheus, как источник данных.
Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.
#

## Задание 2
Изучите самостоятельно ресурсы:

PromQL tutorial for beginners and humans.
Understanding Machine CPU usage.
Introduction to PromQL, the Prometheus query language.
Создайте Dashboard и в ней создайте Panels:

утилизация CPU для nodeexporter (в процентах, 100-idle);
CPULA 1/5/15;
количество свободной оперативной памяти;
количество места на файловой системе.
Для решения этого задания приведите promql-запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.
#

## Задание 3
Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
В качестве решения задания приведите скриншот вашей итоговой Dashboard.
#

## Задание 4
Сохраните ваш Dashboard. Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
В качестве решения задания приведите листинг этого файла.

</details>

> ### Результат:
>
1.
![img.png](files/img/img.png)
#

2.  Dashboard c panels:
- утилизация CPU для node-exporter (в процентах, 100-idle):
```text
100 - avg(irate(node_cpu_seconds_total{job="node-exporter", mode="idle"}[1m])) * 100
```
Скриншот:

![img_1.png](files/img/img_1.png)
#

- CPULA 1/5/15:
```text
avg(node_load1{job="node-exporter"})
avg(node_load5{job="node-exporter"})
avg(node_load15{job="node-exporter"})
```
Скриншот:

![img_2.png](files/img/img_2.png)
#
 
- количество свободной оперативной памяти:
```text
node_memory_MemFree_bytes
```
Скриншот:

![img_3.png](files/img/img_3.png)
#
- количество места на файловой системе:
```text
node_filesystem_avail_bytes
```
Скриншот:

![img_4.png](files/img/img_4.png)

Общий скриншот Dashboard:

![img_5.png](files/img/img_5.png)
#

3.  

- Скриншот правил alert:

![img_6.png](files/img/img_6.png)
#

- скриншот итоговой Dashboard:

![img_7.png](files/img/img_7.png)

#

4. 

[Листинг](files/json/dashboard.json)

---
