# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

## Чек-лист готовности к домашнему заданию
>"Ранее было представлено" [Урок02](https://github.com/R-Gennadi/devops-netology/blob/main/Terra/Terr_2.md "Ранее было представлено")

## Задание 1
* 1. Возьмите из демонстрации к лекции готовый код для создания ВМ с помощью remote-модуля.
    
>результат ![img_1.png](files_4/img/img_1.png)

* 2.  Создайте одну ВМ, используя этот модуль. В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. 
Передайте ssh-ключ в функцию template_file в блоке vars ={} . Воспользуйтесь примером. Обратите внимание, 
что ssh-authorized-keys принимает в себя список, а не строку.

>результат ![img_3.png](files_4/img/img_3.png)

* 3. Добавьте в файл cloud-init.yml установку nginx.

![img_2.png](files_4/img/img_2.png)

* 4.  Предоставьте скриншот подключения к консоли и вывод команды sudo nginx -t.

![img.png](files_4/img/img.png)

 Листинг кода заданиям 1 по [ссылке](files_4%2Fscr%2Fset_1)

## Задание 2
* 1. Напишите локальный модуль vpc, который будет создавать 2 ресурса: одну сеть и одну подсеть в зоне, 
объявленной при вызове модуля, например: ru-central1-a.

![img_8.png](files_4/img/img_8.png)

* 2.  Вы должны передать в модуль переменные с названием сети, zone и v4_cidr_blocks.

![img_7.png](files_4/img/img_7.png)

* 3. Модуль должен возвращать в root module с помощью output информацию о yandex_vpc_subnet. 
Пришлите скриншот информации из terraform console о своем модуле. Пример: > module.vpc_dev

![img_6.png](files_4/img/img_6.png)

* 4.  Замените ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем. 
Не забудьте передать необходимые параметры сети из модуля vpc в модуль с виртуальной машиной.

![img_5.png](files_4/img/img_5.png)

* 5. Откройте terraform console и предоставьте скриншот содержимого модуля. Пример: > module.vpc_dev.

![img_4.png](files_4/img/img_4.png)

* 6.  Сгенерируйте документацию к модулю с помощью terraform-docs.
 
[readmy.md](files_4%2Fscr%2Fset_2%2Freadmy.md)

> Листинг кода заданиям 2 по [ссылке](files_4%2Fscr%2Fset_2)

## Задание 3
* 1. Выведите список ресурсов в стейте

![img_9.png](files_4/img/img_9.png)

* 2.  Полностью удалите из стейта модуль vpc.

![img_10.png](files_4/img/img_10.png)

* 3. Полностью удалите из стейта модуль vm.

![img_11.png](files_4/img/img_11.png)

* 4.  Импортируйте всё обратно. Проверьте terraform plan. 
 Приложите список выполненных команд и скриншоты процессы.

> import network
![img_12.png](files_4/img/img_12.png)

> import subnet
![img_13.png](files_4/img/img_13.png)
 
> import compute
![img_14.png](files_4/img/img_14.png) 

Изменений быть не должно.

![img.png](files_4/img/img_15.png)

![img_15.png](files_4/img/img_15.png)