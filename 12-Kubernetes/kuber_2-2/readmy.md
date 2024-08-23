# Домашнее задание к занятию «Хранение в K8s. Часть 2»

> ## Задания:

<details> <summary> . </summary>
### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

</details>


> ## Решения:
>
###  Задание 1.

Создаём новый namespace для задания:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl create ns dz2-2
namespace/dz2-2 created
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get ns
NAME              STATUS   AGE
kube-system       Active   7d1h
kube-public       Active   7d1h
kube-node-lease   Active   7d1h
default           Active   7d1h
ingress           Active   4d
dz2-2             Active   2s
```
Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-app-multitool-busybox
  namespace: dz2-2
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
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true; do echo "current date = $(date)" >> /busybox_dir/date.log; sleep 5; done']
        volumeMounts:
          - name: my-vol-pvc
            mountPath: /busybox_dir

      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
          - name: my-vol-pvc
            mountPath: /multitool_dir
      volumes:
        - name: my-vol-pvc
          persistentVolumeClaim:
            claimName: pvc-vol
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f deployment_busybox_multitool.yaml 
deployment.apps/netology-app-multitool-busybox created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pods -n dz2-2 -o wide
NAME                                             READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
netology-app-multitool-busybox-5d49bd56d-q2k9q   2/2     Running   0          23s   10.1.123.134   netology-01   <none>           <none>

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get deployment -n dz2-2
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
netology-app-multitool-busybox   1/1     1            1           97s
```
PV-vol:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/pv
  persistentVolumeReclaimPolicy: Retain
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f pv_vol.yaml 
persistentvolume/pv created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv     2Gi        RWO            Retain           Available           manual                  13s
```
Pvc-vol:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-vol
  namespace: dz2-2
spec:
  storageClassName: manual
  accessModes:
    ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f pvc_vol.yaml 
persistentvolumeclaim/pvc-vol created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pvc -n dz2-2
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-vol   Bound    pv       2Gi        RWO            manual         20s
```
Заходим в контейнер multitool и проверяем файл date.log:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl exec netology-app-multitool-busybox-5d49bd56d-q2k9q -n dz2-2 -c multitool -it -- sh

/ # cat /multitool_dir/date.log 
current date = Mon Feb 19 18:31:36 UTC 2024
current date = Mon Feb 19 18:31:41 UTC 2024
current date = Mon Feb 19 18:31:46 UTC 2024
current date = Mon Feb 19 18:31:51 UTC 2024
current date = Mon Feb 19 18:31:56 UTC 2024
current date = Mon Feb 19 18:32:01 UTC 2024
current date = Mon Feb 19 18:32:06 UTC 2024
current date = Mon Feb 19 18:32:11 UTC 2024
current date = Mon Feb 19 18:32:16 UTC 2024
current date = Mon Feb 19 18:32:21 UTC 2024
current date = Mon Feb 19 18:32:26 UTC 2024
current date = Mon Feb 19 18:32:31 UTC 2024
current date = Mon Feb 19 18:32:36 UTC 2024
current date = Mon Feb 19 18:32:41 UTC 2024
```
Проверяем файл на ноде:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ ssh debian@158.160.40.165
Linux netology-01 5.10.0-19-amd64 #1 SMP Debian 5.10.149-2 (2022-10-21) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Feb 19 18:03:03 2024 from 94.140.146.229

debian@netology-01:~$ cat /data/pv/date.log 
current date = Mon Feb 19 18:31:36 UTC 2024
current date = Mon Feb 19 18:31:41 UTC 2024
current date = Mon Feb 19 18:31:46 UTC 2024
current date = Mon Feb 19 18:31:51 UTC 2024
current date = Mon Feb 19 18:31:56 UTC 2024
current date = Mon Feb 19 18:32:01 UTC 2024
current date = Mon Feb 19 18:32:06 UTC 2024
current date = Mon Feb 19 18:32:11 UTC 2024
current date = Mon Feb 19 18:32:16 UTC 2024
current date = Mon Feb 19 18:32:21 UTC 2024
current date = Mon Feb 19 18:32:26 UTC 2024
current date = Mon Feb 19 18:32:31 UTC 2024
current date = Mon Feb 19 18:32:36 UTC 2024
current date = Mon Feb 19 18:32:41 UTC 2024
```
Удаляем deployment:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl delete -n dz2-2 -f deployment_busybox_multitool.yaml 
deployment.apps "netology-app-multitool-busybox" deleted

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get deployment -n dz2-2
No resources found in dz2-2 namespace.

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pods -n dz2-2
NAME                                             READY   STATUS        RESTARTS   AGE
netology-app-multitool-busybox-5d49bd56d-q2k9q   2/2     Terminating   0          11m

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pods -n dz2-2
No resources found in dz2-2 namespace.
```
pv и pvc остались:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pv -n dz2-2
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM           STORAGECLASS   REASON   AGE
pv     2Gi        RWO            Retain           Bound    dz2-2/pvc-vol   manual                  17m

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pvc -n dz2-2
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-vol   Bound    pv       2Gi        RWO            manual         15m
```
Проверяем файлы на ноде:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ ssh debian@158.160.40.165
Linux netology-01 5.10.0-19-amd64 #1 SMP Debian 5.10.149-2 (2022-10-21) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Feb 19 18:40:49 2024 from 94.140.146.229

debian@netology-01:~$ cat /data/pv/date.log 
current date = Mon Feb 19 18:31:36 UTC 2024
current date = Mon Feb 19 18:31:41 UTC 2024
current date = Mon Feb 19 18:31:46 UTC 2024
current date = Mon Feb 19 18:31:51 UTC 2024
current date = Mon Feb 19 18:31:56 UTC 2024
current date = Mon Feb 19 18:32:01 UTC 2024
current date = Mon Feb 19 18:32:06 UTC 2024
current date = Mon Feb 19 18:32:11 UTC 2024
current date = Mon Feb 19 18:32:16 UTC 2024
current date = Mon Feb 19 18:32:21 UTC 2024
current date = Mon Feb 19 18:32:26 UTC 2024
current date = Mon Feb 19 18:32:31 UTC 2024
current date = Mon Feb 19 18:32:36 UTC 2024
current date = Mon Feb 19 18:32:41 UTC 2024
current date = Mon Feb 19 18:32:46 UTC 2024
current date = Mon Feb 19 18:32:51 UTC 2024
current date = Mon Feb 19 18:32:56 UTC 2024

debian@netology-01:~$ ls -l /data/pv/ 
total 8
-rw-r--r-- 1 root root 6336 Feb 19 18:43 date.log
```
Файлы остались на ноде. Во-первых, не были удалены ```pv и pvc```, во-вторых, при конфигурировании ```pv``` использовался режим ```ReclaimPolicy: Retain```. Retain - после удаления PV ресурсы из внешних провайдеров автоматически не удаляются. После удаления ```pv``` файлы так же останутся:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl delete -f pvc_vol.yaml 
persistentvolumeclaim "pvc-vol" deleted

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pvc -n dz2-2
No resources found in dz2-2 namespace.

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl delete -f pv_vol.yaml 
persistentvolume "pv" deleted

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pv
No resources found

debian@netology-01:~$ ls -l /data/pv/ 
total 8
-rw-r--r-- 1 root root 6336 Feb 19 18:43 date.log

debian@netology-01:~$ cat /data/pv/date.log 
current date = Mon Feb 19 18:31:36 UTC 2024
current date = Mon Feb 19 18:31:41 UTC 2024
current date = Mon Feb 19 18:31:46 UTC 2024
current date = Mon Feb 19 18:31:51 UTC 2024
current date = Mon Feb 19 18:31:56 UTC 2024
current date = Mon Feb 19 18:32:01 UTC 2024
current date = Mon Feb 19 18:32:06 UTC 2024
current date = Mon Feb 19 18:32:11 UTC 2024
current date = Mon Feb 19 18:32:16 UTC 2024
current date = Mon Feb 19 18:32:21 UTC 2024
current date = Mon Feb 19 18:32:26 UTC 2024
current date = Mon Feb 19 18:32:31 UTC 2024
current date = Mon Feb 19 18:32:36 UTC 2024
current date = Mon Feb 19 18:32:41 UTC 2024
current date = Mon Feb 19 18:32:46 UTC 2024
current date = Mon Feb 19 18:32:51 UTC 2024
current date = Mon Feb 19 18:32:56 UTC 2024
```
Ссылка на манифест Deployment - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_2-2/file/scr/deployment_busybox_multitool.yaml

Ссылка на манифест PV - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_2-2/file/scr/pv_vol.yaml

Ссылка на манифест PVC - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_2-2/file/scr/pvc_vol.yaml

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

Установим и настроим NFS-сервер:
```bash
debian@netology-01:~$ microk8s kubectl get csidrivers
NAME             ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS   REQUIRESREPUBLISH   MODES        AGE
nfs.csi.k8s.io   false            false            false             <unset>         false               Persistent   46s
```
Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-app-multitool
  namespace: dz2-2
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
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
          - name: my-vol-pvc
            mountPath: /multitool_dir
      volumes:
        - name: my-vol-pvc
          persistentVolumeClaim:
            claimName: my-pvc-nfs
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f deployment_multitool_nfs.yaml 
deployment.apps/netology-app-multitool created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pods -n dz2-2
NAME                                      READY   STATUS    RESTARTS   AGE
netology-app-multitool-5bfc76ff89-r89kt   1/1     Running   0          13s
```
StorageClass:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: 158.160.40.165
  share: /srv/nfs
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f sc_nfs.yaml 
storageclass.storage.k8s.io/nfs-csi created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get sc
NAME      PROVISIONER                            RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs       cluster.local/nfs-server-provisioner   Delete          Immediate           true                   24m
nfs-csi   nfs.csi.k8s.io                         Delete          Immediate           false                  20s
```
PVC:
```yaml
# pvc-nfs.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc-nfs
  namespace: dz2-2
spec:
  storageClassName: nfs-csi
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 2Gi
```
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl apply -f pvc_nfs.yaml 
persistentvolumeclaim/my-pvc-nfs created

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pvc -n dz2-2
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-pvc-nfs   Bound    pvc-cd550d34-58fa-4a59-a778-617deb65b7a1   2Gi        RWO            nfs-csi        27s

ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl describe pvc my-pvc-nfs -n dz2-2
Name:          my-pvc-nfs
Namespace:     dz2-2
StorageClass:  nfs-csi
Status:        Bound
Volume:        pvc-cd550d34-58fa-4a59-a778-617deb65b7a1
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: nfs.csi.k8s.io
               volume.kubernetes.io/storage-provisioner: nfs.csi.k8s.io
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      2Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                 Age                From                                                             Message
  ----    ------                 ----               ----                                                             -------
  Normal  Provisioning           49s                nfs.csi.k8s.io_netology-01_f632689b-9cc4-4f7b-93d1-896930435435  External provisioner is provisioning volume for claim "dz2-2/my-pvc-nfs"
  Normal  ExternalProvisioning   49s (x2 over 49s)  persistentvolume-controller                                      Waiting for a volume to be created either by the external provisioner 'nfs.csi.k8s.io' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
  Normal  ProvisioningSucceeded  48s                nfs.csi.k8s.io_netology-01_f632689b-9cc4-4f7b-93d1-896930435435  Successfully provisioned volume pvc-cd550d34-58fa-4a59-a778-617deb65b7a1
```
Проверим автоматическое создание PV:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl get pv -n dz2-2
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS   REASON   AGE
data-nfs-server-provisioner-0              1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                           28m
pvc-cd550d34-58fa-4a59-a778-617deb65b7a1   2Gi        RWO            Delete           Bound    dz2-2/my-pvc-nfs                                       nfs-csi                 2m17s
```
Проверим возможность чтения и записи файла изнутри пода:
1. Создадим файл на ноде:
```bash
debian@netology-01:/srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1$ sudo -i

root@netology-01:~# cd /srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1/

root@netology-01:/srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1# echo 123 >> test.txt

root@netology-01:/srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1# cat test.txt 
123
```
2. Проверим чтение и запись файла изнутри пода:
```bash
ubuntu@ubuntu2004:~/other/kuber_2-2/scr$ kubectl exec netology-app-multitool-5bfc76ff89-r89kt -n dz2-2 -it -- bin/bash

netology-app-multitool-5bfc76ff89-r89kt:/# echo 321 >> multitool_dir/test2.txt

netology-app-multitool-5bfc76ff89-r89kt:/# ls -l multitool_dir/
total 8
-rw-r--r--    1 root     root             4 Feb 19 21:37 test.txt
-rw-r--r--    1 nobody   nobody           4 Feb 19 22:02 test2.txt

netology-app-multitool-5bfc76ff89-r89kt:/# cat multitool_dir/test2.txt 
321

```
3. Проверим файл на ноде:
```bash
root@netology-01:~# ls -l /srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1/
total 8
-rw-r--r-- 1 nobody nogroup 4 Feb 19 22:02 test2.txt
-rw-r--r-- 1 root   root    4 Feb 19 21:37 test.txt

root@netology-01:~# cat /srv/nfs/pvc-cd550d34-58fa-4a59-a778-617deb65b7a1/test2.txt 
321
```
Запись прошла успешно.
Ссылка на манифест Deployment - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_2-2/file/scr/deployment_multitool_nfs.yaml

Ссылка на манифест PVC - https://github.com/R-Gennadi/devops-netology/blob/main/12-Kubernetes/kuber_2-2/file/scr/pvc_nfs.yaml

------