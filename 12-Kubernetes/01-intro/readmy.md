# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

## Задача 
<details> <summary> . </summary>
### Инструкция к заданию

1. Установка MicroK8S:
    - sudo apt update,
    - sudo apt install snapd,
    - sudo snap install microk8s --classic,
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`,
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`.

2. Полезные команды:
    - проверить статус `microk8s status --wait-ready`;
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`;
    - включить addon можно через команду `microk8s enable`; 
    - список addon `microk8s status`;
    - вывод конфигурации `microk8s config`;
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`.

3. Настройка внешнего подключения:
    - отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89
    ```
    - обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`.

4. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl;
    - chmod +x ./kubectl;
    - sudo mv ./kubectl /usr/local/bin/kubectl;
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`;
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.
</details>


> ## Решения:
>
### 1. Устанавливаю MicroK8S на локальную машину
![img.png](File/Img/img.png)
Добавляю пользователя в группу microk8s, создаю директорию с конфигурацией и даю пользователю доступ к этой директории:
![img_1.png](File/Img/img_1.png)

проверяю статус MicroK8S:
![img_2.png](File/Img/img_2.png)

Устанавливаю Kubernetes Dashboard:
![img_3.png](File/Img/img_3.png)

добавляю адрес для внешнего подключения:
![img_4.png](File/Img/img_4.png)

Обновляю сертификаты:
![img_5.png](File/Img/img_5.png)

### 2. Установка и настройка локального kubectl

Установить на локальную машину kubectl
![img_6.png](File/Img/img_6.png)

Настроить локально подключение к кластеру.
```bash
ubuntu@ubuntu2004:~$ kubectl get nodes
NAME          STATUS   ROLES    AGE   VERSION
ubuntu2004   Ready    <none>   79m   v1.29.0
```

Подключиться к дашборду с помощью port-forward.
```bash
ubuntu@ubuntu2004:~$ kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
Forwarding from 127.0.0.1:10443 -> 8443
Forwarding from [::1]:10443 -> 8443
Handling connection for 10443
```
![img_7.png](File/Img/img_7.png)
#

