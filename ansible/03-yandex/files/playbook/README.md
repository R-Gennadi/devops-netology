## Что делает playbook:

Playbook устанавливает на заданных хостах приложения:
На *первую* виртуальную машину устанавливаются:
- nginx
- lighthouse
- git
По шагам: 
устанавливается и конфигурируется web-сервер Nginx (он нужен для работы Lighthouse). 
Здесь же скачивается Lighthouse, создается его файл web-конфигурации по указанному шаблону и перезапускается web-сервер Nginx.


На *вторую* виртуальную машину устанавливаются:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
По шагам: 
скачивается дистрибутив clickhouse-server и сlickhouse-client по указанному пути с указанными именами файлов. 
Устанавливается clickhouse-server и сlickhouse-client, 
создается база данных, 
запускается сервис Clickhouse. 


На *третью* виртуальную машину устанавливается:
- vector
По шагам: 
выполняется установка дистрибутива Vector, путь к источнику установки указан в файле vars.yml. 
Создается сервис приложения по файлу из шаблона. 
После выполнения действий запускается Vector.


## Параметры
- IP адреса целевых хостов указаны в файле prod.yml.
- остальные нужные параметры указываются в файлах vars.yml

## Теги
- nginx
- lighthouse
- clickhouse
- vector