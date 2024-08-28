# Домашнее задание к занятию «Helm»

> ## Задания:

<details> <summary> . </summary>
### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

### Правила приёма работы

1. Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, `helm`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

</details>


> ## Решения:
>
###  Задание 1.


Проверяем установку ```helm```:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm version
version.BuildInfo{Version:"v3.14.2", GitCommit:"c309b6f0ff63856811846ce18f3bdc93d2b4d54b", GitTreeState:"clean", GoVersion:"go1.21.7"}
```
Подготовим ```deployment``` ```service``` и разместим их в директории ```templates/```:

- [templates/deployment.yaml](file%2Fscr%2Fhelm_chart_nginx%2Ftemplates%2Fdeployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main
  labels:
    app: main
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: {{ .Values.appPort }}
              protocol: TCP
```
- [templates/service.yaml](scr%2Fhelm_chart_nginx%2Ftemplates%2Fservice.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: main
  labels:
    app: main
spec:
  ports:
    - port: {{ .Values.appPort }}
      name: http
  selector:
    app: main
```
Подготовим ```Chart```: 
- [Chart.yaml](scr%2Fhelm_chart_nginx%2FChart.yaml)
```yaml
  apiVersion: v2
  name: netology

  type: application

  version: 0.1.2
  appVersion: "1.16.0"
```
Подготовим ```values```:
- [values.yaml](scr%2Fhelm_chart_nginx%2Fvalues.yaml)
```yaml
replicaCount: 1

image:
  repository: nginx
  tag: ""

appPort: 80
```
Создадим шаблон на основе этих файлов:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm template helm_chart_nginx
---
# Source: netology/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: main
  labels:
    app: main
spec:
  ports:
    - port: 80
      name: http
  selector:
    app: main
---
# Source: netology/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main
  labels:
    app: main
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - name: netology
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```
Поменяем номер версии приложения в файле ```Chart.yaml```:
```yaml
  apiVersion: v2
  name: netology

  type: application

  version: 0.1.2
  appVersion: "1.19.0"
```
Смотрим шаблон:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm template helm_chart_nginx
---
# Source: netology/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: main
  labels:
    app: main
spec:
  ports:
    - port: 80
      name: http
  selector:
    app: main
---
# Source: netology/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main
  labels:
    app: main
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - name: netology
          image: "nginx:1.19.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```
Видим, что версия образа поменялась на ```1.19.0```
Внесем версию в файл ```values.yaml```:
```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "1.20.0"

appPort: 80
```
Проверим шаблон теперь:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm template helm_chart_nginx
---
# Source: netology/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: main
  labels:
    app: main
spec:
  ports:
    - port: 80
      name: http
  selector:
    app: main
---
# Source: netology/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main
  labels:
    app: main
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - name: netology
          image: "nginx:1.20.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```
Видим, что версия образа встала ```1.20.0```, это произошло, потому что при задании условий подстановки переменных было указано, что в первую очередь данные брать из файла с переменными, если в них не будет указано данных, тогда подставлять данные из файла ```Chart.yaml```



------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

#### Решение

Проверим установку:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm install netology1  helm_chart_nginx 
NAME: netology1
LAST DEPLOYED: Sun Mar  3 22:41:03 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/main-7bf8b847c9-49f42   1/1     Running   0          23s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP   20d
service/main         ClusterIP   10.152.183.67   <none>        80/TCP    23s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main   1/1     1            1           24s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/main-7bf8b847c9   1         1         1       24s

nikulinn@nikulin:~/other/kuber_2-5/scr$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
netology1       default         1               2024-03-03 22:41:03.873313146 +0500 +05 deployed        netology-0.1.2  1.19.0     
```
Обновим установку с изменением параметра ```replicaCount=2```:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm upgrade --install netology1 --set replicaCount=2 helm_chart_nginx 
Release "netology1" has been upgraded. Happy Helming!
NAME: netology1
LAST DEPLOYED: Sun Mar  3 22:47:31 2024
NAMESPACE: default
STATUS: deployed
REVISION: 3
TEST SUITE: None

nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/main-7bf8b847c9-49f42   1/1     Running   0          6m34s
pod/main-7bf8b847c9-4wwsl   1/1     Running   0          6s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP   20d
service/main         ClusterIP   10.152.183.67   <none>        80/TCP    6m35s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main   2/2     2            2           6m35s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/main-7bf8b847c9   2         2         2       6m35s

nikulinn@nikulin:~/other/kuber_2-5/scr$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
netology1       default         3               2024-03-03 22:47:31.517592548 +0500 +05 deployed        netology-0.1.2  1.19.0 
```
Удалим данные для продолжения задания:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm uninstall netology1
release "netology1" uninstalled

nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   20d
```
Создаем версию в ```namespace=app1```:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm install netology1 --namespace app1 --create-namespace helm_chart_nginx 
NAME: netology1
LAST DEPLOYED: Sun Mar  3 22:53:35 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None

nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all -n app1
NAME                        READY   STATUS    RESTARTS   AGE
pod/main-7bf8b847c9-p5nm5   1/1     Running   0          19s

NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/main   ClusterIP   10.152.183.21   <none>        80/TCP    19s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main   1/1     1            1           19s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/main-7bf8b847c9   1         1         1       19s

nikulinn@nikulin:~/other/kuber_2-5/scr$ helm list --namespace=app1
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
netology1       app1            1               2024-03-03 22:53:35.600375339 +0500 +05 deployed        netology-0.1.2  1.19.0 
```
Создаем вторую версию в ```namespace=app1```:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm upgrade --install netology2 --namespace app1 --create-namespace helm_chart_nginx 
Release "netology2" does not exist. Installing it now.
Error: Unable to continue with install: Service "main" in namespace "app1" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "netology2": current value is "netology1"
```
Ошибка, т.к. мы пытаемся запустить несколько приложений в одном пространстве имен, с разными параметрами, но одинаковыми именами. Так нельзя. Для этого необходимо настраивать переменные таким образом, чтобы имена ресурсов приложения так же менялись, тогда возможен запуск дополнительного приложения в этом пространстве имен. Для решения задачи проведем манипуляции вручную перед запуском:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main2
  labels:
    app: main2
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: main2
  template:
    metadata:
      labels:
        app: main2
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: {{ .Values.appPort }}
              protocol: TCP
```
```yaml
apiVersion: v1
kind: Service
metadata:
  name: main2
  labels:
    app: main2
spec:
  ports:
    - port: {{ .Values.appPort }}
      name: http
  selector:
    app: main2
```

Запустим повторно:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm upgrade --install netology2 --namespace app1 --create-namespace helm_chart_nginx 
Release "netology2" does not exist. Installing it now.
NAME: netology2
LAST DEPLOYED: Sun Mar  3 23:24:24 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None

nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all -n app1
NAME                         READY   STATUS    RESTARTS   AGE
pod/main-7bf8b847c9-p5nm5    1/1     Running   0          30m
pod/main2-786ddf4ccb-7xdld   1/1     Running   0          5s

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/main    ClusterIP   10.152.183.21    <none>        80/TCP    30m
service/main2   ClusterIP   10.152.183.152   <none>        80/TCP    5s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main    1/1     1            1           30m
deployment.apps/main2   1/1     1            1           5s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/main-7bf8b847c9    1         1         1       30m
replicaset.apps/main2-786ddf4ccb   1         1         1       5s

nikulinn@nikulin:~/other/kuber_2-5/scr$ helm list --namespace=app1
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
netology1       app1            1               2024-03-03 22:53:35.600375339 +0500 +05 deployed        netology-0.1.2  1.19.0     
netology2       app1            1               2024-03-03 23:24:24.737205375 +0500 +05 deployed        netology-0.1.2  1.19.0  
```

Запускаем третью версию в ```namespace=app2```:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm upgrade --install netology3 --namespace app2 --create-namespace helm_chart_nginx 
Release "netology3" does not exist. Installing it now.
NAME: netology3
LAST DEPLOYED: Sun Mar  3 23:25:45 2024
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None

nikulinn@nikulin:~/other/kuber_2-5/scr$ helm list --namespace=app2
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
netology3       app2            1               2024-03-03 23:25:45.934944802 +0500 +05 deployed        netology-0.1.2  1.19.0   
  
nikulinn@nikulin:~/other/kuber_2-5/scr$ kubectl get all -n app2
NAME                       READY   STATUS    RESTARTS   AGE
pod/main-579fd7868-7m4x2   1/1     Running   0          13s

NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/main   ClusterIP   10.152.183.54   <none>        80/TCP    13s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main   1/1     1            1           13s

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/main-579fd7868   1         1         1       14s
```

---

Задание можно было выполнить на предустановленном и настроенном Chart с приложением nginx:
```bash
nikulinn@nikulin:~/other/kuber_2-5/scr$ helm create helm_chart_nginx_test
Creating helm_chart_nginx_test
```
Созданные манифесты представлены в директории [helm_chart_nginx_test](scr%2Fhelm_chart_nginx_test)