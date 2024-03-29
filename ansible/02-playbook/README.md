# Домашнее задание к занятию 2 «Работа с Playbook»

#### Подготовка к выполнению
<details><summary>.</summary>
1. Необязательно. Изучите, что такое ClickHouse и Vector.
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте Playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.
</details>  

>результат 

Выполнено


## Основная часть
1. Подготовьте свой inventory-файл prod.yml.

![img_1.png](Files%2Fimg%2Fimg_1.png)

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает vector. 
Конфигурация vector должна деплоиться через template файл jinja2. 
От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. 
Информация по шаблонам по ссылке. не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: get_url, template, unarchive, file.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.

>результат:

Выполняется скачивание, разархивировация в директорию, а так же добавление конфигурации из файла шаблона и запуск Vector.
   
5. Запустите ansible-lint site.yml и исправьте ошибки, если они есть.

>результат:
При запуске  ansible-lint site.yml, отображаются список ошибок:
* лишние отступы в коде, 
* использовался не корректный синтаксис, 
* порядок запуска сервиса Clickhouse.
![img.png](Files/img/img4.png)


6. Попробуйте запустить playbook на этом окружении с флагом --check.

>результат:
>
Запуск playbook с флагом --check происходит без изменений в конечную систему. 
Выполнение плейбука полноценно невозможно с этим флагом, т.к. нет скачанных файлов дистрибутива, а значит не сможет  устанавливиться
![img.png](Files/img/img.png)

7. Запустите playbook на prod.yml окружении с флагом --diff. Убедитесь, что изменения на системе произведены.
>результат:
>
Запуск playbook с флагом --diff. 
![img.png](Files/img/img2.png)

8. Повторно запустите playbook с флагом --diff и убедитесь, что playbook идемпотентен.
>результат:
>
playbook идемпотентен, за исключением запуска Vector:
![img.png](Files/img/img3.png)

9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, 
какие у него есть параметры и теги. Пример качественной документации ansible playbook по ссылке. 
Так же приложите скриншоты выполнения заданий №5-8

[README.md](https://github.com/R-Gennadi/devops-netology/blob/main/ansible/02-playbook/Files/playbook/README.md "описание playbook")


