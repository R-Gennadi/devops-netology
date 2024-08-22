# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

> ## Задания

<details> <summary> . </summary>
### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

</details>
> 


> ## Решения:
>
###  Задание 1.
#### 1. 
Создадим пространство имен для ДЗ:
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4$ kubectl create namespace dz4
namespace/dz4 created
ubuntu@ubuntu2004:~/other/kuber_1-4$ kubectl get ns
NAME              STATUS   AGE
kube-system       Active   2d
kube-public       Active   2d
kube-node-lease   Active   2d
default           Active   2d
dz4               Active   6s
```
Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-deployment
  namespace: dz4
  labels:
    app: main
spec:
  replicas: 3
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.2
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
```
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl apply -f my_deployment.yaml 
deployment.apps/netology-deployment created
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get pods -n dz4 -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
netology-deployment-77497ddc64-8lgh9   2/2     Running   0          26s   10.1.123.162   netology-01   <none>           <none>
netology-deployment-77497ddc64-4t9gd   2/2     Running   0          26s   10.1.123.163   netology-01   <none>           <none>
netology-deployment-77497ddc64-rmjhc   2/2     Running   0          26s   10.1.123.164   netology-01   <none>           <none>
```
#### 2. 
```yaml
apiVersion: v1
kind: Service
metadata:
  name: deployment-service
  namespace: dz4
spec:
  ports:
    - name: http-app
      port:  9001
      protocol: TCP
      targetPort: 80
    - name: http-app-mult
      port:  9002
      protocol: TCP
      targetPort: 8080
  selector:
    app: main
```
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl apply -f svc_nginx.yaml 
service/deployment-service created
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get svc -n dz4 -o wide
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
deployment-service   ClusterIP   10.152.183.134   <none>        9001/TCP,9002/TCP   16s   app=main
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get ep -n dz4 -o wide
NAME                 ENDPOINTS                                                           AGE
deployment-service   10.1.123.162:8080,10.1.123.163:8080,10.1.123.164:8080 + 3 more...   3m7s

```
#### 3. 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-multitool
  namespace: dz4
spec:
  containers:
    - image: wbitt/network-multitool
      name: test-multitool
```
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl apply -f test_multitool.yaml 
pod/test-multitool created
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get pods -n dz4 -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
netology-deployment-77497ddc64-8lgh9   2/2     Running   0          5m51s   10.1.123.162   netology-01   <none>           <none>
netology-deployment-77497ddc64-4t9gd   2/2     Running   0          5m51s   10.1.123.163   netology-01   <none>           <none>
netology-deployment-77497ddc64-rmjhc   2/2     Running   0          5m51s   10.1.123.164   netology-01   <none>           <none>
test-multitool                         1/1     Running   0          7s      10.1.123.165   netology-01   <none>           <none>
```
Тестируем, что ПОДы отвечают по ожидаемым портам:
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.162:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0  36745      0 --:--:-- --:--:-- --:--:-- 38250
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.162:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0     0  96814      0 --:--:-- --:--:-- --:--:--  151k
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-8lgh9 - 10.1.123.162 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.163:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   432k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.163:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0     0   105k      0 --:--:-- --:--:-- --:--:--  151k
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-4t9gd - 10.1.123.163 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.164:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   501k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.1.123.164:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0     0  14693      0 --:--:-- --:--:-- --:--:-- 15500
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-rmjhc - 10.1.123.164 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
Тестируем, что Сервис отвечает по нужным портам:
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.152.183.134:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   526k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl 10.152.183.134:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0     0   152k      0 --:--:-- --:--:-- --:--:--  151k
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-rmjhc - 10.1.123.164 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
#### 4.
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl deployment-service:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   196k      0 --:--:-- --:--:-- --:--:--  298k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl exec -n dz4 test-multitool -- curl deployment-service:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0     0  75646      0 --:--:-- --:--:-- --:--:--  151k
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-rmjhc - 10.1.123.164 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
#### 5. 
Ссылка на манифест Deployment - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_1-4/file/scr/my_deployment.yaml

Ссылка на манифест Service - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_1-4/file/scr/svc_nginx.yaml

Ссылка на манифест Pod -  https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_1-4/file/scr/test_multitool.yaml

------

### Задание 2.

#### 1. 
```yaml
apiVersion: v1
kind: Service
metadata:
  name: deployment-service-nodeport
  namespace: dz4
spec:
  ports:
    - name: http-app
      port:  80
      nodePort: 30000
    - name: http-app-mult
      port:  8080
      nodePort: 30001
  selector:
    app: main
  type: NodePort
```
```bash
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl apply -f svc_nginx_nodeport.yaml 
service/deployment-service-nodeport created
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get svc -n dz4 -o wide
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE   SELECTOR
deployment-service            ClusterIP   10.152.183.134   <none>        9001/TCP,9002/TCP             19m   app=main
deployment-service-nodeport   NodePort    10.152.183.44    <none>        80:30000/TCP,8080:30001/TCP   29s   app=main
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get ep -n dz4 -o wide
NAME                          ENDPOINTS                                                           AGE
deployment-service            10.1.123.162:8080,10.1.123.163:8080,10.1.123.164:8080 + 3 more...   20m
deployment-service-nodeport   10.1.123.162:8080,10.1.123.163:8080,10.1.123.164:8080 + 3 more...   45s
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ kubectl get nodes -o wide
NAME          STATUS   ROLES    AGE    VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
netology-01   Ready    <none>   2d1h   v1.28.3   192.168.101.26   <none>        Debian GNU/Linux 11 (bullseye)   5.10.0-19-amd64   containerd://1.6.15
```
#### 2.
```bash
2. ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ curl 178.154.200.234:30000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
ubuntu@ubuntu2004:~/other/kuber_1-4/scr$ curl 178.154.200.234:30001
WBITT Network MultiTool (with NGINX) - netology-deployment-77497ddc64-4t9gd - 10.1.123.163 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

#### 3. 
Ссылка на манифест Service - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_1-4/file/scr/svc_nginx_nodeport.yaml

------