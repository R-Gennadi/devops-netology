## Задача 1:
>Создайте собственный образ любой операционной системы (например, debian-11) с помощью Packer версии 1.7.0 
Чтобы получить зачёт, вам нужно предоставить скриншот страницы с созданным образом из личного кабинета YandexCloud.
 
![img.png](/img/img.png)

## Задача 2:
> 2.1. Создайте вашу первую виртуальную машину в YandexCloud с помощью web-интерфейса YandexCloud.
![img.png](/img/img_1.png)

> 2.2.* (Необязательное задание)
Создайте вашу первую виртуальную машину в YandexCloud с помощью Terraform (вместо использования веб-интерфейса YandexCloud). Используйте Terraform-код в директории (src/terraform).
Чтобы получить зачёт, вам нужно предоставить вывод команды terraform apply и страницы свойств, созданной ВМ из личного кабинета YandexCloud. 
 
 
          
       
 

 
## Задача 3:
* Запустите первый контейнер из образа centos c любым тегом в фоновом режиме, подключив папку /data из текущей рабочей директории на хостовой машине в /data контейнера.

        ubuntu@ubuntu2004:~/docker/task3$ docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
        Unable to find image 'centos:latest' locally
        latest: Pulling from library/centos
  

## Задача 4:
* Воспроизвести практическую часть лекции самостоятельно

      docker pull repgen/netology-rg:v3
