# Домашнее задание к занятию «Управление доступом»

> ## Задания:

<details> <summary> . </summary>
### Цель задания
В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.------### Чеклист готовности к домашнему заданию1. Установлено k8s-решение, например MicroK8S.2. Установленный локальный kubectl.3. Редактор YAML-файлов с подключённым github-репозиторием.------### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).------### Задание 1. Создайте конфигурацию для подключения пользователя1. Создайте и подпишите SSL-сертификат для подключения к кластеру.2. Настройте конфигурационный файл kubectl для подключения.3. Создайте роли и все необходимые настройки для пользователя.4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.------### Правила приёма работы1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, скриншоты результатов.3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.------
</details>


> ## Решения:
>
###  Задание 1.

Создадим сертификаты для подключения к кластеру: 
- [netology.crt](scr%2Fcrt%2Fnetology.crt)
- [netology.key](scr%2Fcrt%2Fnetology.key)
```bash
debian@netology-01:~$ mkdir cert && cd cert

debian@netology-01:~/cert$ openssl genrsa -out netology.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
....................+++++
.............................................+++++
e is 65537 (0x010001)

debian@netology-01:~/cert$ openssl req -new -key netology.key -out netology.csr -subj "/CN=netology/O=group2"

debian@netology-01:~/cert$ openssl x509 -req -in netology.csr -CA /var/snap/microk8s/6089/certs/ca.crt -CAkey /var/snap/microk8s/6089/certs/ca.key -CAcreateserial -out netology.crt -days 500
Signature ok
subject=CN = netology, O = group2
Getting CA Private Key
```


Перенесем на машину с которой будем подключаться и настроим конфигурационный файл.
Добавим юзера, добавим контекст и проверим конфигурацию:
```bash
ubuntu@ubuntu2004:~/.kube$ kubectl config set-credentials netology --client-certificate=/home/nikulinn/.kube/cert/netology.crt --client-key=/home/nikulinn/.kube/cert/netology.key
User "netology" set.

ubuntu@ubuntu2004:~/.kube$ cd

ubuntu@ubuntu2004:~$ kubectl config set-context netology-context --cluster=microk8s-cluster --user=netology
Context "netology-context" created.

ubuntu@ubuntu2004:~$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://178.154.204.168:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: microk8s-cluster
    user: netology
  name: netology-context
current-context: microk8s
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
- name: netology
  user:
    client-certificate: cert/netology.crt
    client-key: cert/netology.key
```
- [config](scr%2Frbac%2Fconfig)

настройки для пользователя.
Role: [role.yaml](scr%2Frbac%2Frole.yaml)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-logs-describe
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["watch", "list"]
```
RoleBinding: [role-binding.yaml](scr%2Frbac%2Frole-binding.yaml)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader
  namespace: default
subjects:
- kind: User
  name: netology
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-logs-describe
  apiGroup: rbac.authorization.k8s.io
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl apply -f role.yaml 
role.rbac.authorization.k8s.io/pod-logs-describe created

ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl apply -f role-binding.yaml 
rolebinding.rbac.authorization.k8s.io/pod-reader created
```

 
Пользователь может просматривать логи подов и их конфигурацию 

```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl get role pod-logs-describe -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"Role","metadata":{"annotations":{},"name":"pod-logs-describe","namespace":"default"},"rules":[{"apiGroups":[""],"resources":["pods","pods/logs"],"verbs":["watch","list"]}]}
  creationTimestamp: "2024-02-27T18:52:54Z"
  name: pod-logs-describe
  namespace: default
  resourceVersion: "662673"
  uid: 67fe31e2-3ae4-44ea-a58b-47f11d4144d9
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/logs
  verbs:
  - watch
  - list
```
На кластере присутствует pod:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl get pods -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
test-multitool   1/1     Running   0          16s   10.1.123.180   netology-01   <none>           <none>
```
Переключимся на пользователя и проверим pod:
```bash
root@nikulin:/home/nikulinn/other/kuber_2-4/scr# kubectl config get-contexts
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl config get-contexts
CURRENT   NAME               CLUSTER            AUTHINFO   NAMESPACE
*         microk8s           microk8s-cluster   admin      
          netology-context   microk8s-cluster   netology   
          
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl config use-context netology-context
Switched to context "netology-context".

ubuntu@ubuntu2004:~/.kube$ kubectl describe pod test-multitool
Error from server (Forbidden): pods "test-multitool" is forbidden: User "netology" cannot get resource "pods" in API group "" in the namespace "default"

ubuntu@ubuntu2004:~/.kube$ kubectl logs pod test-multitool
Error from server (Forbidden): pods "pod" is forbidden: User "netology" cannot get resource "pods" in API group "" in the namespace "default"
```
Выяснилось, что для выполнения команд ```logs ``` и ```describe``` пользователю требуется добавление в роль verbs: ["get"]:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-logs-describe
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["watch", "list", "get"]
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl apply -f role.yaml 
role.rbac.authorization.k8s.io/pod-logs-describe configured

ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl get role pod pod-logs-describe -o yaml
apiVersion: v1
items:
- apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"Role","metadata":{"annotations":{},"name":"pod-logs-describe","namespace":"default"},"rules":[{"apiGroups":[""],"resources":["pods","pods/logs"],"verbs":["watch","list","get"]}]}
    creationTimestamp: "2024-02-27T18:52:54Z"
    name: pod-logs-describe
    namespace: default
    resourceVersion: "668321"
    uid: 67fe31e2-3ae4-44ea-a58b-47f11d4144d9
  rules:
  - apiGroups:
    - ""
    resources:
    - pods
    - pods/logs
    verbs:
    - watch
    - list
    - get
```
Проверяем повторно:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl config use-context netology-context
Switched to context "netology-context".

ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl describe pod test-multitool
Name:             test-multitool
Namespace:        default
Priority:         0
Service Account:  default
Node:             netology-01/192.168.101.26
Start Time:       Tue, 27 Feb 2024 23:54:58 +0500
Labels:           <none>
Annotations:      cni.projectcalico.org/containerID: 408a70b884bcee4bd1c05f51d84530f1f94e532522c923d4c697bc7275ac14ae
                  cni.projectcalico.org/podIP: 10.1.123.180/32
                  cni.projectcalico.org/podIPs: 10.1.123.180/32
Status:           Running
IP:               10.1.123.180
IPs:
  IP:  10.1.123.180
Containers:
  test-multitool:
    Container ID:   containerd://272aea3914d361f83d0a4e68daef9b2429f7ee719683164a79b331576611606e
    Image:          wbitt/network-multitool
    Image ID:       docker.io/wbitt/network-multitool@sha256:d1137e87af76ee15cd0b3d4c7e2fcd111ffbd510ccd0af076fc98dddfc50a735
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 27 Feb 2024 23:55:01 +0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-s6rdj (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-s6rdj:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl logs test-multitool
The directory /usr/share/nginx/html is not mounted.
Therefore, over-writing the default index.html file with some useful information:
WBITT Network MultiTool (with NGINX) - test-multitool - 10.1.123.180 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Попробуем удалить pod:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-4/scr/rbac$ kubectl delete -f role.yaml 
Error from server (Forbidden): error when deleting "role.yaml": roles.rbac.authorization.k8s.io "pod-logs-describe" is forbidden: User "netology" cannot delete resource "roles" in API group "rbac.authorization.k8s.io" in the namespace "default"
```

манифесты и скриншоты и/или вывод необходимых команд.

- [config](scr%2Frbac%2Fconfig)
- [role.yaml](scr%2Frbac%2Frole.yaml)
- [role-binding.yaml](scr%2Frbac%2Frole-binding.yaml)

------