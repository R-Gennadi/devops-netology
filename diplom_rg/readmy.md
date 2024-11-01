# DEVOPS: Дипломное задание по профессии "DevOps-инженер"

### Автор: Репьевский Г.В.

#### 2024 г.

---

# Содержание

| Пункт | Наименование                                                                                                |
|-------|:------------------------------------------------------------------------------------------------------------|
| 1     | [Создание облачной инфраструктуры](#cloud_infra_creation)                                                   |
| 1.1   | [Создание каталога](#catalog_creation)                                                                      |
| 1.2   | [Создание бэкенда для хранения файлов состояния Terraform](#backend_creation)                               |
| 1.3   | [Создание сетей и виртуальных машин](#net_vm_creation)                                                      |
| 2     | [Создание кластера Kubernetes](#cluster_creation)                                                           |
| 2.1   | [Набор манифестов Ansible](#ansible_manifests)                                                              |
| 2.2   | [Наполнение кластера программной инфраструктурой](#cluster_infill)                                          |
| 2.3   | [Проверка состояния кластера](#cluster_check)                                                               |
| 3     | [Создание тестового приложения](#test_app_creation)                                                         |
| 3.1   | [Состав приложения](#test_app_content)                                                                      |
| 3.2   | [Контейнеризация и проверка работоспособности приложения](#test_app_check)                                  |
| 3.3   | [Сохранение образа приложения в публичном репозитории](#test_app_store)                                     |
| 4     | [Подготовка cистемы мониторинга и разворачивание приложения в кластере Kubernetes](#cluster_monitoring_app) |
| 4.1   | [Подготовка манифестов пакета Kube-Prometheus](#kube_prometheus_manifests)                                  |
| 4.2   | [Установка системы мониторинга пакета Kube-Prometheus](#kube_prometheus_deploy)                             |
| 4.3   | [Получение пользовательского доступа к системе мониторинга](#kube_prometheus_access)                        |
| 4.4   | [Разворачивание приложения в кластере Kubernetes](#cluster_app_deploy)                                      |
| 4.4.1 | [Шаблонизация приложения с помощью Helm](#cluster_app_templating)                                           |
| 4.4.2 | [Разворачивание веб-приложения из чарта Helm](#cluster_app_chart_deploy)                                    |
| 5     | [Использование Helm Artifactory](#helm_artifactory)                                                         |
| 5.1   | [Подготовка чарта Helm](#helm_chart_preparation)                                                            |
| 5.2   | [Сохранение чарта Helm в Git-репозитории](#helm_chart_store)                                                |
| 5.3   | [Получение статуса "Verified Publisher"](#helm_chart_verified)                                              |
| 5.3.1 | [Идентификация Git-репозитория](#helm_chart_verified_git_repo)                                              |
| 5.3.2 | [Обновление образа приложения в Dockerhub](#helm_chart_verified_dockerhub)                                  |
| 5.3.3 | [Обновление чарта в Git-репозитории](#helm_chart_verified_git_chart)                                        |
| 5.3.4 | [Присвоение репозиторию статуса "Verified Publisher"](#helm_chart_verified_granted)                         |
| 5.4   | [Установка приложения из артефактория Helm](#helm_chart_deploy)                                             |
| 6     | [Настройка системы мониторинга кластера Kubernetes](#monitoring_customization)                              |
| 6.1   | [Использование Prometheus](#monitoring_customization_prometheus)                                            |
| 6.2   | [Использование Grafana](#monitoring_customization_grafana)                                                  |
| 7     | [Установка и настройка процессов CI/CD](#cicd)                                                              |
| 7.1   | [Разворачивание виртуальных машин](#cicd_vm_creation)                                                       |
| 7.2   | [Установка компонентов Teamcity](#cicd_teamcity)                                                            |
| 7.3   | [Предварительная настройка сервера Teamcity](#cicd_teamcity_server_customization_pre)                       |
| 7.4   | [Настройка процедуры сборки](#cicd_teamcity_server_customization_build)                                     |
| 7.4.1 | [Шаг 1: получение тега последнего коммита](#cicd_teamcity_server_customization_build_1)                     |
| 7.4.2 | [Шаг 2: сборка Docker-образа](#cicd_teamcity_server_customization_build_2)                                  |
| 7.4.3 | [Шаг 3: сохранение Docker-образа в репозиторий Dockerhub](#cicd_teamcity_server_customization_build_3)      |
| 7.4.4 | [Шаг 4: получение содержимого чарта Helm](#cicd_teamcity_server_customization_build_4)                      |
| 7.4.5 | [Шаг 5: обновление Git-репозитория Helm](#cicd_teamcity_server_customization_build_5)                       |
| 7.5   | [Автоматизация получения обновлений кластером Kubernetes с помощью CRON](#cicd_cluster_customization)       |
| 8     | [Итоговая проверка работоспособности процессов CI/CD](#cicd_in_action)                                      |
| 8.1   | [Этап 1: разработка приложения](#cicd_in_action_1)                                                          |
| 8.2   | [Этап 2: автоматическая обработка результатов разработки](#cicd_in_action_2)                                |
| 8.3   | [Этап 3: разворачивание релиза приложения в кластере Kubernetes](#cicd_in_action_3)                         |
| 9     | [Заключение](#conclusion)                                                                                   |

---

## <a name="cloud_infra_creation">1. Создание облачной инфраструктуры</a>

Подготовим облачную инфраструктуру с помощью Terraform.
В целях удобства разобьём процесс создание на несколько этапов:

- создание каталога Yandex.Cloud;
- создание бэкенда в Object Storage Yandex.Cloud для хранения файлов состояния ".tfstate";
- создание конфигурации облачной инфраструктуры.

Такое разбиение обусловлено тем, что каждый последующий этап требует полного выполнения предыдущего и использует
результаты его выполнения.

Так выполнение первого этапа позволит нам получить идентификаторы облака и каталога Yandex.Cloud, а также
сгенерировать ключи доступа, что в свою очередь, позволит на втором этапе создать бэкенд для хранения состояний
конфигурации Terraform.

И только на третьем этапе мы будем обладать всей доступной инфраструктурой для дальнейшей работы.

---

### <a name="catalog_creation">1.1. Создание каталога</a>

Проверим, не устарела ли наша версия Terraform:

![img.png](files/img/img.png)

Версия подходящая, поэтому инициализируем конфигурацию Терраформ:

![img_1.png](files/img/img_1.png)

Далее создаём рабочие пространства, которые предполагается использовать. К применению предполагаются два
рабочих пространства "stage", применяемый для разработки, и "prod", в котором функционирует инфраструктура,
используемая конечными пользователями. В наших целях мы будем использовать только "stage":

````bash
$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
````

Как результат, имеем два рабочих пространства - созданное "stage" и дефолтное рабочее пространство,
которое удалить нельзя (использовать пространство "default" мы не будем):

![img_2.png](files/img/img_2.png)

Для наглядности вся наша конфигурация разделена не следующие файлы:

| Файл                                                                                | Назначение                                  |
|:------------------------------------------------------------------------------------|:--------------------------------------------|
| [010_provider.tf](./files/terraform/000_folder/010_provider.tf)                     | Объявление провайдера YC                    |
| [020_folder.tf](./files/terraform/000_folder/020_folder.tf)                         | Создание каталога                           |
| [030_tf_service_account.tf](./files/terraform/000_folder/030_tf_service_account.tf) | Создание сервисных аккаунтов                |
| [040_symmetric_key.tf](./files/terraform/000_folder/040_symmetric_key.tf)           | Генерация ключа для шифрации Storage Bucket |
| [050_tf_backend_bucket.tf](./files/terraform/000_folder/050_tf_backend_bucket.tf)   | Создание Storage Bucket                     |
| [outputs.tf](./files/terraform/000_folder/outputs.tf)                               | Вывод значимой информации                   |
| [variables.tf](./files/terraform/000_folder/variables.tf)                           | Объявление переменных                       |

Все файлы находятся в единой папке и выполение команды `terraform apply` применит их все.

Применим [данную конфигурацию](./files/terraform/000_folder):

````bash
$ terraform apply -auto-approve
...
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
current-workspace-name = "stage"
yc-folder-id = "b1gvmjjk70bt2apdrabf"
yc-id = "b1g8mq58h421raomnd64"
yc-zone = "ru-central1"
````

Укажем идентификаторы облака и каталога в файле `./bashrc` (`~/.zshrc`) для того, чтобы явно не упоминать
в файлах конфигурации. Для этого используются специальные переменные окружения `YC_CLOUD_ID` и `YC_FOLDER_ID`:

````bash
export YC_CLOUD_ID=<Идентификатор Облака>
export YC_FOLDER_ID=<Идентификатор Каталога>
````

Помимо этих переменных окружения дополнительно используется переменная окружения `YC_TOKEN`, содержащая
[IAM-токен](https://cloud.yandex.ru/docs/iam/concepts/authorization/iam-token) для доступа к облаку.
Значение токена выдаётся пользователю после прохождения аутентификации и является чувствительными данными,
которые не следует хранить в конфигурации, а также в общедоступных местах.

Теперь нам нужно сгенерировать ключи для инициализации бэкенда, которое будет выполнено на следующем этапе.
Для этого сначала инициализируем командную строку Yandex.Cloud:

````bash
$ yc init
Welcome! This command will take you through the configuration process.
Pick desired action:
 [1] Re-initialize this profile 'default' with new settings 
 [2] Create a new profile
Please enter your numeric choice: 1
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.

Please enter OAuth token: [AQAAAAABL*********************PBEbq222c] 
You have one cloud available: 'netology-cloud' (id = b1g8mq58h421raomnd64). It is going to be used by default.
Please choose folder to use:
 [1] diploma-folder (id = b1g9l9dm6trokqsnm68f)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'diploma-folder' (id = b1g9l9dm6trokqsnm68f).
Do you want to configure a default Compute zone? [Y/n] n
````

Когда командная строка инициалирована, её можно использовать для доступа к Yandex.Cloud.
Для начала получим список существующих сервисных аккаунтов:

````bash
$ yc iam service-account list
+----------------------+--------------+
|          ID          |     NAME     |
+----------------------+--------------+
| aje5cp35s6rqaruu12rc | terraform-sa |
+----------------------+--------------+
````

Как видим, присутствует сгенерированный с помощью [конфигурации](./files/terraform/000_folder/030_tf_service_account.tf)
сервисный аккаунт под именем "terraform-sa":

````bash
$ yc iam access-key create --service-account-name terraform-sa
access_key:
  id: aje3jn02jscc23e3d4cc
  service_account_id: aje5cp35s6rqaruu12rc
  created_at: "2023-01-23T15:04:49.990741955Z"
  key_id: YCAJ...
secret: YCMDDN-...-cVXfEVFt
````

> Значение секретного ключа (поле `secret`) повторно получить невозможно, поэтому его следует сразу сохранить
> в безопасном месте!

Так как значение ключей доступа также является чувствительными данными, то также сохраним их в переменных
окружения, объявляемых в файле `./bashrc` (`~/.zshrc`). Для этого используются специальные имена переменных
окружения `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY`:

````bash
export AWS_ACCESS_KEY_ID=<Значение `key_id`>
export AWS_SECRET_ACCESS_KEY=<Значение `secret`>
````

После того, как значения переменных окружения были заданы необходимо повторно инициализовать командную оболочку,
чтобы данные переменные вступили в силу:

````bash
$ source ~/.zshrc  
````

Исходная конфигурация задана, теперь нужно создать в ней хранилище состояний Terraform.

### <a name="backend_creation">1.2. Создание бэкенда для хранения файлов состояния Terraform</a>

Переходим в [следующую папку](./files/terraform/100_backend). Она содержит следующие файлы:

| Файл                                                             | Назначение                                 |
|:-----------------------------------------------------------------|:-------------------------------------------|
| [110_provider.tf](./files/terraform/100_backend/110_provider.tf) | Объявление бэкенда в составе провайдера YC |
| [outputs.tf](./files/terraform/100_backend/outputs.tf)           | Вывод значимой информации                  |
| [variables.tf](./files/terraform/100_backend/variables.tf)       | Объявление переменных                      |

И инициализируем конфигурацию Terraform:

````bash
$ terraform init
````

Т.к. текущая конфигурация никак не связана с предыдущей, то нам придется снова создать требуемое рабочее пространство
"stage":

````bash
$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform workspace list     
  default
* stage
````

Применяем текущую конфигурацию:

````bash
$ terraform apply -auto-approve
````

Если бы при инициализации бэкенда было бы выбрано рабочее пространство `default`, то файл `tfstate` появился бы
непосредственно в корне бакета:

![img_3.png](files/img/img_3.png)


> Формат пути к файлу `tfstate`: `workspace_key_prefix/workspace_name/key`

Хранилище состояний Terraform создано, теперь можно приступить непосредственно к созданию облачной конфигурации.

### <a name="net_vm_creation">1.3. Создание сетей и виртуальных машин</a>

Переходим в [следующую папку](./files/terraform/200_config). Она содержит следующие файлы:

| Файл                                                                          | Назначение                                                                                |
|:------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------|
| [210_provider.tf](./files/terraform/200_config/210_provider.tf)               | Объявление бэкенда в составе провайдера YC,<br/>а также указание "terraform_remote_state" |
| [220_network.tf](./files/terraform/200_config/220_network.tf)                 | Объявление сети YC                                                                        |
| [230_private_subnets.tf](./files/terraform/200_config/230_private_subnets.tf) | Объявление подсетей YC                                                                    |
| [240_vms.tf](./files/terraform/200_config/240_vms.tf)                         | Объявление виртуальных машин YC                                                           |
| [main.tf](./files/terraform/200_config/modules/instance/main.tf)              | Модуль конфигурации виртуальной машины                                                    |
| [outputs.tf](./files/terraform/200_config/outputs.tf)                         | Вывод значимой информации                                                                 |
| [variables.tf](./files/terraform/200_config/variables.tf)                     | Объявление переменных                                                                     |

Инициализируем конфигурацию Терраформ:

````bash
$ terraform init          
Initializing modules...
- vm-for-each in modules/instance

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.84.0...
- Installed yandex-cloud/yandex v0.84.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.
...
Terraform has been successfully initialized!
````

Благодаря указанию "terraform_remote_state" нам будут доступны рабочие пространства, созданные на предыдущих этапах,
и снова объявлять их в текущей папке конфигурации не нужно:

````bash
$ terraform workspace list
* default
  stage
````

Просто переключимся на требуемое нам рабочее пространство "stage":

````bash
$ terraform workspace select stage
Switched to workspace "stage".

$ terraform workspace list        
  default
* stage
````

Применяем [конфигурацию](./files/terraform/200_config):

````bash
$ terraform apply -auto-approve
...
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
current-workspace-name = "stage"
network-id = "enp04ovvjreu8qgebo0a"
remote_execution_determine = "Run environment: Local"
vpc-network-private-id = "enp04ovvjreu8qgebo0a"
vpc-subnet-private1-id = "e9bctfrh8r42nnd4nt8c"
vpc-subnet-private1-zone = "ru-central1-a"
vpc-subnet-private2-id = "e2lmjb5ivovpd6g8833u"
vpc-subnet-private2-zone = "ru-central1-b"
vpc-subnet-private3-id = "b0c945nvee2mcn1d2juu"
vpc-subnet-private3-zone = "ru-central1-c"
````

Как результат имеем следующий инфраструктурный набор Yandex.Cloud:

![img_4.png](files/img/img_4.png)

С составом из трех виртуальных машин:

![img_5.png](files/img/img_5.png)

И трех подсетей, расположенных в разных зонах:

![img_3.png](files/img/img_3.png)

Таким образом, посредством Terraform мы создали инфраструктуру, которая м.б.создана или удалена командами
`apply` и `destroy` без каких-либо дополнительных действий.

Теперь можно приступать к созданию кластера Kubernetes.

---

## <a name="cluster_creation">2. Создание кластера Kubernetes</a>

### <a name="ansible_manifests">2.1. Набор манифестов Ansible</a>

Создадим кластер Kubernetes, используя [Ansible](https://www.ansible.com/)
и применяя [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/) развернём
его на созданных ранее трех виртуальных машинах Yandex.Cloud.

[Конфигурация Ansible](./files/ansible/infrastructure) состоит из следующих файлов:

| Наименование                                                                                              | Назначение                                                           |
|:----------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------|
| [**Папка "infrastructure"**](./files/ansible/infrastructure)                                              | Корневая папка Ansible                                               |
| [ansible.cfg](./files/ansible/infrastructure/ansible.cfg)                                                 | Параметры Ansible                                                    |
| [site.yaml](./files/ansible/infrastructure/site.yaml)                                                     | Перечень файлов конфигурации для исполнения                          |
| [**Папка "inventory"**](./files/ansible/infrastructure/inventory)                                         | Папка переменных                                                     |
| [hosts.yaml](./files/ansible/infrastructure/inventory/hosts.yaml)                                         | Указание IP-адресов хостов                                           |
| [**Папка "inventory/group_vars/all"**](./files/ansible/infrastructure/inventory/group_vars/all)           | Папка переменных, предназначенных группам хостов                     |
| [common.yaml](./files/ansible/infrastructure/inventory/group_vars/all/common.yaml)                        | Переменные, не предполагаемые к изменению                            |
| [public_ips.yaml](./files/ansible/infrastructure/inventory/group_vars/all/public_ips.yaml)                | Публичные IP хостов                                                  |
| [**Папка "playbooks"**](./files/ansible/infrastructure/playbooks)                                         | Папка файлов конфигурации                                            |
| [deploy-dashboard.ansible.yaml](./files/ansible/infrastructure/playbooks/deploy-dashboard.ansible.yaml)   | Разворачивание графической панели Kubernetes                         |
| [grant-permissions.ansible.yaml](./files/ansible/infrastructure/playbooks/grant-permissions.ansible.yaml) | Выдача разрешений на кластер                                         |
| [mount-cluster.ansible.yaml](./files/ansible/infrastructure/playbooks/mount-cluster.ansible.yaml)         | Запуск Kubespray для разворачивания кластера                         |
| [post-setup.ansible.yaml](./files/ansible/infrastructure/playbooks/post-setup.ansible.yaml)               | Удаление временных файлов                                            |
| [pre-setup.ansible.yaml](./files/ansible/infrastructure/playbooks/pre-setup.ansible.yaml)                 | Заполнение файла параметров кластера<br/>и передача приватного ключа |
| [setup.ansible.yaml](./files/ansible/infrastructure/playbooks/setup.ansible.yaml)                         | Установка инструментов кластера                                      |
| [**Папка "playbooks/k8s_cluster"**](./files/ansible/infrastructure/playbooks/k8s_cluster)                 | Шаблоны параметров кластера                                          |
| [k8s-cluster.yml](./files/ansible/infrastructure/playbooks/k8s_cluster/k8s-cluster.yml)                   | Шаблон параметров Kubernetes                                         |
| [k8s-net-calico.yml](./files/ansible/infrastructure/playbooks/k8s_cluster/k8s-net-calico.yml)             | Шаблон параметров CNI-плагина Calico                                 |
| [**Папка "playbooks/templates"**](./files/ansible/infrastructure/playbooks/templates)                     | Компоненты кластера                                                  |
| [admin-user-rbac.yaml](./files/ansible/infrastructure/playbooks/templates/admin-user-rbac.yaml)           | ClusterRoleBinding администратора                                    |
| [admin-user-sa.yaml](./files/ansible/infrastructure/playbooks/templates/admin-user-sa.yaml)               | ServiceAccount администратора                                        |
| [dashboard.yaml](./files/ansible/infrastructure/playbooks/templates/dashboard.yaml)                       | Компоненты графической панели Kubernetes                             |
| [deploy-pg.yaml](./files/ansible/infrastructure/playbooks/templates/deploy-pg.yaml)                       | Разворачивание StatefulSet БД PostgreSQL                             |
| [deployment.ansible.yaml](./files/ansible/infrastructure/playbooks/templates/deployment.ansible.yaml)     | Deployment экземпляра Nginx                                          |
| [empty-dir.ansible.yaml](./files/ansible/infrastructure/playbooks/templates/empty-dir.ansible.yaml)       | Pod экземпляра Nginx                                                 |
| [hosts.ansible.yaml.j2](./files/ansible/infrastructure/playbooks/templates/hosts.ansible.yaml.j2)         | Шаблон параметров кластера                                           |
| [**Папка "playbooks/debug"**](./files/ansible/infrastructure/playbooks/templates/debug)                   | Папка вспомогательных инструментов                                   |
| [dnsutils.ansible.yaml](./files/ansible/infrastructure/playbooks/templates/debug/dnsutils.ansible.yaml)   | Набор DNS-утилит                                                     |
| [minipg.ansible.yaml](./files/ansible/infrastructure/playbooks/templates/debug/minipg.ansible.yaml)       | Клиент БД PostgreSQL                                                 |

### <a name="cluster_infill">2.2. Наполнение кластера программной инфраструктурой</a>

Запустим наши виртуальные машины Yandex.Cloud, дождёмся готовности и назначения им внешних IP-адресов, после чего
укажем эти адреса в специально предназначенном для них конфигурационном файле
[public_ips.yaml](./files/ansible/infrastructure/inventory/group_vars/all/public_ips.yaml):

````yaml
---
public_ip:
  cp1: 158.160.33.90
  node1: 158.160.21.98
  node2: 51.250.43.112
````

> Файл может быть любым, просто мы решили хранить внешние IP-адреса именно здесь.

Теперь перейдём в папку [конфигурации Ansible](./files/ansible/infrastructure) и инициализуем создание кластера:

````bash
$ ansible-playbook -i inventory/hosts.yaml site.yaml
...
TASK [Gathering Facts] *****************************************************************************************************************************************************************************************************************
ok: [cp1]
ok: [node1]
ok: [node2]
...
TASK [Install common tools] ************************************************************************************************************************************************************************************************************
changed: [cp1]
changed: [node1]
changed: [node2]
...
TASK [Available nodes] *****************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "NAME    STATUS   ROLES           AGE     VERSION",
        "cp1     Ready    control-plane   4m59s   v1.24.4",
        "node1   Ready    <none>          3m27s   v1.24.4",
        "node2   Ready    <none>          3m28s   v1.24.4"
    ]
}
...
TASK [Access token is] *****************************************************************************************************************************************************************************************************************
ok: [cp1] => {
    "msg": [
        "eyJhbGciOiJSUzI1NiIsImtpZCI6ImxoTi1Fb2dOdjR1QkREaXdVWDJyTWhQTkpxd1VUaEJVc21oQ0kxTGljZ2cifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjc0MTE0MDg5LCJpYXQiOjE2NzQxMTA0ODksImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiYzk1MmIyNjUtOGEyZS00YzBkLTk3NDMtNTgwOGEwYTI2MGVjIn19LCJuYmYiOjE2NzQxMTA0ODksInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.v5p03OfBmW38y3hkuPiWC5zKaQoH9bfIEPwdtcLtvhMxd39cQV5N8cFsBP5Y2HqcT723EPLaSeDE1DaneE_ncz-uZw5eUDapAqd4SMNSK7UXltOdGEqipZQR1exk9gd2iuDYgLNZRoTrSq2Ujgg9hsjek2ixf7-Xf_282qQOZ86FGZH8W9oXSqv8pusbBIbv3yvMUyyOx_6c1RKEE4g41OQ09jH4-L0qH3JLvMmCDDOqP0hwMc4hGsu3LdrfmS8hfTis5ektXgjHcoOOXI_FbIymq6SATFQQM_LWMdVlTVlQ0ywGUcfx5beyW4A4XjyDp_EuiNbHQPueAtvihI7CQg",
        "1. Run 'kubectl proxy' on host supposed to be used for access to Kubernetes Dashboard",
        "2. Proceed to the link: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/",
        "3. Select 'Token' option and enter the token."
    ]
}
...
PLAY RECAP *****************************************************************************************************************************************************************************************************************************
localhost                  : ok=13   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
cp1                        : ok=35   changed=26   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
````

После инициализации кластера конфигурация доступа к нему хранится в домашней папке пользователя по
пути `~/.kube/config`:
файл `config` выглядит так:

```
root@node-0:/home/ubuntu/myapp# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://158.160.111.242:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
root@node-0:/home/ubuntu/myapp# 

```

### <a name="cluster_check">2.3. Проверка состояния кластера</a>

Доступ к кластеру можно проверить, получив, например, набор подов и нод кластера командой `kubectl get pods`:

![img_6.png](files/img/img_6.png)

На данный момент полная инфраструктура Kubernetes-кластера выглядит следующим образом:

````bash
$ kubectl get all,cm,sts,svc,deploy,sa,rs,po,pv,pvc,ep -A -o wide                                                        
NAMESPACE              NAME                                            READY   STATUS    RESTARTS        AGE     IP               NODE    NOMINATED NODE   READINESS GATES
kube-system            pod/calico-kube-controllers-7f679c5d6f-b24lt    1/1     Running   0               8m8s    10.200.104.1     node2   <none>           <none>
kube-system            pod/calico-node-9l6mn                           1/1     Running   0               8m59s   10.20.20.1       node1   <none>           <none>
kube-system            pod/calico-node-w5rng                           1/1     Running   2 (8m28s ago)   8m59s   10.30.30.1       node2   <none>           <none>
kube-system            pod/calico-node-xvzx6                           1/1     Running   2 (8m28s ago)   8m59s   10.10.10.1       cp1     <none>           <none>
kube-system            pod/coredns-5867d9544c-7hmsp                    1/1     Running   0               7m38s   10.200.166.129   node1   <none>           <none>
kube-system            pod/coredns-5867d9544c-wjxx9                    1/1     Running   0               7m48s   10.200.176.1     cp1     <none>           <none>
kube-system            pod/dns-autoscaler-59b8867c86-29w9c             1/1     Running   0               7m42s   10.200.176.2     cp1     <none>           <none>
kube-system            pod/kube-apiserver-cp1                          1/1     Running   1               11m     10.10.10.1       cp1     <none>           <none>
kube-system            pod/kube-controller-manager-cp1                 1/1     Running   2 (10m ago)     11m     10.10.10.1       cp1     <none>           <none>
kube-system            pod/kube-proxy-6pq9z                            1/1     Running   0               9m30s   10.30.30.1       node2   <none>           <none>
kube-system            pod/kube-proxy-978bh                            1/1     Running   0               9m30s   10.10.10.1       cp1     <none>           <none>
kube-system            pod/kube-proxy-zwz67                            1/1     Running   0               9m30s   10.20.20.1       node1   <none>           <none>
kube-system            pod/kube-scheduler-cp1                          1/1     Running   2 (10m ago)     11m     10.10.10.1       cp1     <none>           <none>
kube-system            pod/nginx-proxy-node1                           1/1     Running   0               8m27s   10.20.20.1       node1   <none>           <none>
kube-system            pod/nginx-proxy-node2                           1/1     Running   0               8m26s   10.30.30.1       node2   <none>           <none>
kube-system            pod/nodelocaldns-6s2qw                          1/1     Running   0               7m42s   10.30.30.1       node2   <none>           <none>
kube-system            pod/nodelocaldns-j5mzn                          1/1     Running   0               7m42s   10.20.20.1       node1   <none>           <none>
kube-system            pod/nodelocaldns-kxzbp                          1/1     Running   0               7m42s   10.10.10.1       cp1     <none>           <none>
kubernetes-dashboard   pod/dashboard-metrics-scraper-8c47d4b5d-bbwz6   1/1     Running   0               6m25s   10.200.166.130   node1   <none>           <none>
kubernetes-dashboard   pod/kubernetes-dashboard-6c75475678-44dqd       1/1     Running   0               6m26s   10.200.104.2     node2   <none>           <none>

NAMESPACE              NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE     SELECTOR
default                service/kubernetes                  ClusterIP   10.32.0.1       <none>        443/TCP                  11m     <none>
kube-system            service/coredns                     ClusterIP   10.32.0.3       <none>        53/UDP,53/TCP,9153/TCP   7m48s   k8s-app=kube-dns
kubernetes-dashboard   service/dashboard-metrics-scraper   ClusterIP   10.32.214.180   <none>        8000/TCP                 6m26s   k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   service/kubernetes-dashboard        ClusterIP   10.32.78.248    <none>        443/TCP                  6m26s   k8s-app=kubernetes-dashboard

NAMESPACE     NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE     CONTAINERS    IMAGES                                          SELECTOR
kube-system   daemonset.apps/calico-node    3         3         3       3            3           kubernetes.io/os=linux   9m      calico-node   quay.io/calico/node:v3.24.5                     k8s-app=calico-node
kube-system   daemonset.apps/kube-proxy     3         3         3       3            3           kubernetes.io/os=linux   11m     kube-proxy    registry.k8s.io/kube-proxy:v1.24.4              k8s-app=kube-proxy
kube-system   daemonset.apps/nodelocaldns   3         3         3       3            3           kubernetes.io/os=linux   7m42s   node-cache    registry.k8s.io/dns/k8s-dns-node-cache:1.21.1   k8s-app=nodelocaldns

NAMESPACE              NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS                  IMAGES                                                            SELECTOR
kube-system            deployment.apps/calico-kube-controllers     1/1     1            1           8m9s    calico-kube-controllers     quay.io/calico/kube-controllers:v3.24.5                           k8s-app=calico-kube-controllers
kube-system            deployment.apps/coredns                     2/2     2            2           7m49s   coredns                     registry.k8s.io/coredns/coredns:v1.9.3                            k8s-app=kube-dns
kube-system            deployment.apps/dns-autoscaler              1/1     1            1           7m47s   autoscaler                  registry.k8s.io/cpa/cluster-proportional-autoscaler-amd64:1.8.5   k8s-app=dns-autoscaler
kubernetes-dashboard   deployment.apps/dashboard-metrics-scraper   1/1     1            1           6m25s   dashboard-metrics-scraper   kubernetesui/metrics-scraper:v1.0.8                               k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   deployment.apps/kubernetes-dashboard        1/1     1            1           6m26s   kubernetes-dashboard        kubernetesui/dashboard:v2.6.1                                     k8s-app=kubernetes-dashboard

NAMESPACE              NAME                                                  DESIRED   CURRENT   READY   AGE     CONTAINERS                  IMAGES                                                            SELECTOR
kube-system            replicaset.apps/calico-kube-controllers-7f679c5d6f    1         1         1       8m9s    calico-kube-controllers     quay.io/calico/kube-controllers:v3.24.5                           k8s-app=calico-kube-controllers,pod-template-hash=7f679c5d6f
kube-system            replicaset.apps/coredns-5867d9544c                    2         2         2       7m49s   coredns                     registry.k8s.io/coredns/coredns:v1.9.3                            k8s-app=kube-dns,pod-template-hash=5867d9544c
kube-system            replicaset.apps/dns-autoscaler-59b8867c86             1         1         1       7m47s   autoscaler                  registry.k8s.io/cpa/cluster-proportional-autoscaler-amd64:1.8.5   k8s-app=dns-autoscaler,pod-template-hash=59b8867c86
kubernetes-dashboard   replicaset.apps/dashboard-metrics-scraper-8c47d4b5d   1         1         1       6m25s   dashboard-metrics-scraper   kubernetesui/metrics-scraper:v1.0.8                               k8s-app=dashboard-metrics-scraper,pod-template-hash=8c47d4b5d
kubernetes-dashboard   replicaset.apps/kubernetes-dashboard-6c75475678       1         1         1       6m26s   kubernetes-dashboard        kubernetesui/dashboard:v2.6.1                                     k8s-app=kubernetes-dashboard,pod-template-hash=6c75475678

NAMESPACE              NAME                                           DATA   AGE
default                configmap/kube-root-ca.crt                     1      10m
kube-node-lease        configmap/kube-root-ca.crt                     1      10m
kube-public            configmap/cluster-info                         5      11m
kube-public            configmap/kube-root-ca.crt                     1      10m
kube-system            configmap/calico-config                        2      9m2s
kube-system            configmap/coredns                              1      7m51s
kube-system            configmap/dns-autoscaler                       1      7m39s
kube-system            configmap/extension-apiserver-authentication   6      11m
kube-system            configmap/kube-proxy                           2      11m
kube-system            configmap/kube-root-ca.crt                     1      10m
kube-system            configmap/kubeadm-config                       1      11m
kube-system            configmap/kubelet-config                       1      11m
kube-system            configmap/kubernetes-services-endpoint         0      8m59s
kube-system            configmap/nodelocaldns                         1      7m44s
kubernetes-dashboard   configmap/kube-root-ca.crt                     1      6m27s
kubernetes-dashboard   configmap/kubernetes-dashboard-settings        0      6m27s

NAMESPACE              NAME                                                SECRETS   AGE
default                serviceaccount/default                              0         10m
kube-node-lease        serviceaccount/default                              0         10m
kube-public            serviceaccount/default                              0         10m
kube-system            serviceaccount/attachdetach-controller              0         10m
kube-system            serviceaccount/bootstrap-signer                     0         10m
kube-system            serviceaccount/calico-kube-controllers              0         8m9s
kube-system            serviceaccount/calico-node                          0         9m
kube-system            serviceaccount/certificate-controller               0         10m
kube-system            serviceaccount/clusterrole-aggregation-controller   0         10m
kube-system            serviceaccount/coredns                              0         7m50s
kube-system            serviceaccount/cronjob-controller                   0         10m
kube-system            serviceaccount/daemon-set-controller                0         10m
kube-system            serviceaccount/default                              0         10m
kube-system            serviceaccount/deployment-controller                0         10m
kube-system            serviceaccount/disruption-controller                0         10m
kube-system            serviceaccount/dns-autoscaler                       0         7m45s
kube-system            serviceaccount/endpoint-controller                  0         10m
kube-system            serviceaccount/endpointslice-controller             0         10m
kube-system            serviceaccount/endpointslicemirroring-controller    0         10m
kube-system            serviceaccount/ephemeral-volume-controller          0         11m
kube-system            serviceaccount/expand-controller                    0         10m
kube-system            serviceaccount/generic-garbage-collector            0         10m
kube-system            serviceaccount/horizontal-pod-autoscaler            0         10m
kube-system            serviceaccount/job-controller                       0         10m
kube-system            serviceaccount/kube-proxy                           0         11m
kube-system            serviceaccount/namespace-controller                 0         10m
kube-system            serviceaccount/node-controller                      0         11m
kube-system            serviceaccount/nodelocaldns                         0         7m44s
kube-system            serviceaccount/persistent-volume-binder             0         10m
kube-system            serviceaccount/pod-garbage-collector                0         10m
kube-system            serviceaccount/pv-protection-controller             0         10m
kube-system            serviceaccount/pvc-protection-controller            0         10m
kube-system            serviceaccount/replicaset-controller                0         10m
kube-system            serviceaccount/replication-controller               0         11m
kube-system            serviceaccount/resourcequota-controller             0         10m
kube-system            serviceaccount/root-ca-cert-publisher               0         10m
kube-system            serviceaccount/service-account-controller           0         10m
kube-system            serviceaccount/service-controller                   0         10m
kube-system            serviceaccount/statefulset-controller               0         10m
kube-system            serviceaccount/token-cleaner                        0         10m
kube-system            serviceaccount/ttl-after-finished-controller        0         11m
kube-system            serviceaccount/ttl-controller                       0         10m
kubernetes-dashboard   serviceaccount/admin-user                           0         6m22s
kubernetes-dashboard   serviceaccount/default                              0         6m27s
kubernetes-dashboard   serviceaccount/kubernetes-dashboard                 0         6m27s

NAMESPACE              NAME                                  ENDPOINTS                                                         AGE
default                endpoints/kubernetes                  10.10.10.1:6443                                                   11m
kube-system            endpoints/coredns                     10.200.166.129:53,10.200.176.1:53,10.200.166.129:53 + 3 more...   7m49s
kubernetes-dashboard   endpoints/dashboard-metrics-scraper   10.200.166.130:8000                                               6m26s
kubernetes-dashboard   endpoints/kubernetes-dashboard        10.200.104.2:8443                                                 6m27s
````

Как результат, на трех виртуальных машинах Yandex.Cloud развернут работоспособный кластер Kubernetes и получена
конфигурация доступа к нему в локальной папке `~/.kube`. Благодаря этому есть возможность выполнения
команд `kubectl` из локального окружения.

На следующем этапе создадим веб-приложение, предполагаемое для развёртывания в созданном кластере Kubernetes.

---

## <a name="test_app_creation">3. Создание тестового приложения</a>

### <a name="test_app_content">3.1 Состав приложения</a>

Подготовим простейшее [тестовое веб-приложение](./files/diploma-repo/web-app), состоящее из
единственной [html-страницы](./files/diploma-repo/web-app/index.html), отображающей некоторые сведения:

````html

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    <title>DEVOPS-14</title>
    <link rel="icon" type="image/x-icon" href="favicon.png">
</head>
<body>
<h1>Diploma work DEVOPS-14</h1>
<h2>Repyevskiy G.V.</h2>
<h3>v.0.0.1</h3>
</body>
</html>
````

Также подготовим простую [конфигурацию веб-сервера](diploma-repo/nginx/nginx.conf), позволяющую выводить статические
данные (в нашем случае - страницу
[index.html](diploma-repo/web-app/index.html)):

````nginx configuration
server {
    listen 80;
    server_name  testref.com www.testref.com; # Name of virtual server (delivered in "HOST" header).

    access_log  /var/log/nginx/domains/testref.com-access.log  main; # Access logging.
    error_log   /var/log/nginx/domains/testref.com-error.log info;   # Error logging.

    location / { # Handles a certain type of client request.
        root /; #  Directory that will be used to search for a file
        index index.html;  # Defines files that will be used as an index.
        try_files $uri /index.html; # Checks whether the specified file or directory exists.
    }
}
````

### <a name="test_app_check">3.2 Контейнеризация и проверка работоспособности приложения</a>

Контейнеризируем данное веб-приложение с помощью Docker используя образ
веб-сервера [Nginx](https://hub.docker.com/_/nginx/):

````Dockerfile
FROM nginx
COPY web-app/index.html /usr/share/nginx/html
ADD nginx/nginx.conf /nginx/nginx.conf
````

В целях проверки работоспособности соберем образ:

````bash
$ docker build -t R-Gennadi/diploma:0.0.1 .
Sending build context to Docker daemon  56.32kB
Step 1/3 : FROM nginx
 ---> 2d389e545974
Step 2/3 : COPY web-app/index.html /usr/share/nginx/html
 ---> Using cache
 ---> 239ee511c3d7
Step 3/3 : ADD nginx/nginx.conf /nginx/nginx.conf
 ---> Using cache
 ---> 28f4b7049a10
Successfully built 28f4b7049a10
Successfully tagged R-Gennadi/diploma:0.0.1
````

Образ собран и присутствует в репозитории под тегом `R-Gennadi/diploma:0.0.1`:

````bash
$ docker image ls
REPOSITORY                TAG     IMAGE ID       CREATED          SIZE
R-Gennadi/diploma      0.0.1   28f4b7049a10   25 minutes ago   142MB
...
````

Запустим собранный образ локально:

````bash
$ docker run --network host R-Gennadi/diploma:0.0.1 
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/01/17 15:42:14 [notice] 1#1: using the "epoll" event method
2023/01/17 15:42:14 [notice] 1#1: nginx/1.23.1
2023/01/17 15:42:14 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6) 
2023/01/17 15:42:14 [notice] 1#1: OS: Linux 5.19.17-1-MANJARO
2023/01/17 15:42:14 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/01/17 15:42:14 [notice] 1#1: start worker processes
2023/01/17 15:42:14 [notice] 1#1: start worker process 31
2023/01/17 15:42:14 [notice] 1#1: start worker process 32
2023/01/17 15:42:14 [notice] 1#1: start worker process 33
2023/01/17 15:42:14 [notice] 1#1: start worker process 34
::1 - - [17/Jan/2023:15:42:18 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" "-"
````

Видим, что контейнеризированное веб-приложение доступно по `localhost` на стандартном порту `80`:

![img_7.png](files/img/img_7.png)![webapp_v001.png](./files/images/webapp_v001.png)

### <a name="test_app_store">3.3 Сохранение образа приложения в публичном репозитории</a>

Для хранения разворачиваемого веб-приложения создадим на [github.com](https://github.com) отдельный репозиторий
с именем ["diploma-repo"](https://github.com/R-Gennadi/diploma-repo):

Для хранения же Docker-образа воспользуемся репозиторием [dockerhub.com](https://hub.docker.com/). Для этого
сначала залогинимся в него (учётная запись у нас уже имеется):

````bash
$ docker login                                                
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/rgen/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
````

И после успешной аутентификации отправим наш образ в репозиторий:

````bash
$ docker push R-Gennadi/diploma:0.0.1                   
The push refers to repository [docker.io/R-Gennadi/diploma]
7e46b64469bd: Pushed 
f1b7541425c2: Pushed 
36665e416ec8: Mounted from R-Gennadi/hello-world 
31192a8593ec: Mounted from R-Gennadi/hello-world 
7ee9bf58503c: Mounted from R-Gennadi/hello-world 
a064c1703bfd: Mounted from R-Gennadi/hello-world 
9388548487b1: Mounted from R-Gennadi/hello-world 
b45078e74ec9: Mounted from R-Gennadi/hello-world 
0.0.1: digest: sha256:a99757f9eb9cb6056aec64200fd35e721bf1130616357230da4ed9aa207b7486 size: 1984
````

После этого наш образ можно
[наблюдать в репозитории](https://hub.docker.com/repository/docker/R-Gennadi/diploma) через веб-интерфейс:

Таким образом мы создали [git-репозиторий](https://github.com/R-Gennadi/diploma-repo),
содержащий [тестовое веб-приложение](https://github.com/R-Gennadi/diploma-repo/tree/main/web-app) и
[Dockerfile](https://github.com/R-Gennadi/diploma-repo/blob/main/Dockerfile) для его контейнеризации, а также
разместили в реестре Dockerhub
[контейнеризированный образ](https://hub.docker.com/repository/docker/R-Gennadi/diploma) этого веб-приложения.

Создав веб-приложение развернём его в кластере Kubernetes, предварительно запустив в этом же кластере систему
мониторинга.

---

## <a name="cluster_monitoring_app">4. Подготовка cистемы мониторинга и разворачивание приложения в кластере Kubernetes</a>

### <a name="kube_prometheus_manifests">4.1 Подготовка манифестов пакета Kube-Prometheus</a>

Создадим систему мониторинга с помощью пакета [Kube-Prometheus](https://github.com/prometheus-operator/kube-prometheus).

Этот пакет содержит в себе полный набор инструментов, позволяющих реализовать мониторинг кластера и приложений,
работающих в нём. В состав пакета входят:

- **Prometheus Operator** - инструмент разворачивания приложений в кластере, а также контроля системы мониторинга;
- **Prometheus** - инструмент сбора метрик с серверов по HTTP-протоколу с использованием правил. Для запросов
  используется язык PromQL;
- **Alert Manager** - система оповещения для Prometheus, призванная следить за сопоставлением правил уведомлений и
  событий, находящихся в TSDB Prometheus;
- **Prometheus Node Exporter** - экспортер метрик хостовой ОС. Запускается на каждом хосте и отвечает за передачу данных
  в Prometheus;
- **Prometheus Adapter for Kubernetes Metrics APIs** - адаптер метрик;
- **kube-state-metrics** - сервис, прослушивающий сервер Kubernetes API и генерирующий метрики состояния его объектов;
- **Grafana** - инструмент визуализации данных, поставляемых различными источниками.

Пакет Kube-Prometheus позволяет кастомизацию устанавливаемых пакетов. Для этого создадим папку
[kube-prometheus](./files/kube-prometheus) и развернём в ней необходимые компоненты.

Потребуется установить пакет поддержки языка Golang:

````bash
$ sudo pacman -S go
````

Для удобства путь к исполняемым файлам Golang следует указать в PATH:

````bash
export PATH=$PATH:$HOME/go/bin
````

Далее следует установить инструмент [jsonnet-bundler](https://jsonnet.org/):

````bash
$ go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
go: downloading github.com/jsonnet-bundler/jsonnet-bundler v0.5.1
go: downloading github.com/pkg/errors v0.9.1
go: downloading gopkg.in/alecthomas/kingpin.v2 v2.2.6
go: downloading github.com/fatih/color v1.13.0
go: downloading github.com/mattn/go-colorable v0.1.12
go: downloading github.com/mattn/go-isatty v0.0.14
go: downloading github.com/alecthomas/template v0.0.0-20190718012654-fb15b899a751
go: downloading github.com/alecthomas/units v0.0.0-20211218093645-b94a6e3cc137
go: downloading golang.org/x/sys v0.0.0-20220615213510-4f61da869c0c
````

Далее переходим в папку [kube-prometheus](./files/kube-prometheus), инициализуем в ней "jsonnet-bundler" и устанавливаем
необходимые для "kube-prometheus" зависимости:

````bash
$ jb init

$ jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main
GET https://github.com/prometheus-operator/kube-prometheus/archive/67c08545193ebdd75f57e0afa922f87d56c98781.tar.gz 200
GET https://github.com/kubernetes/kube-state-metrics/archive/c75215203025bdbfd57bb4dfb191cc8142cfc087.tar.gz 200
GET https://github.com/prometheus/node_exporter/archive/a3bd2e13052929663dbd7d680fab4a952efb1de6.tar.gz 200
GET https://github.com/prometheus/prometheus/archive/9f91215bf6d22d1eea7b56d17a9b55ebd72dd32e.tar.gz 200
GET https://github.com/prometheus/alertmanager/archive/a8e4c166a86df10acca7612c9db462aa4e663bfe.tar.gz 200
GET https://github.com/pyrra-dev/pyrra/archive/31b9ac3c75e7aa904ea1b5fca37f6b2ea2622230.tar.gz 200
GET https://github.com/brancz/kubernetes-grafana/archive/d039275e4916aceae1c137120882e01d857787ac.tar.gz 200
GET https://github.com/etcd-io/etcd/archive/756875151fa61d040119ecce72ad909a5cce6175.tar.gz 200
GET https://github.com/prometheus-operator/prometheus-operator/archive/e5ee07bda82538d1122be100b6cd89f2a54b8e35.tar.gz 200
GET https://github.com/kubernetes-monitoring/kubernetes-mixin/archive/05ca993f01ee4dada3ea4d2afd51693784c6d858.tar.gz 200
GET https://github.com/kubernetes/kube-state-metrics/archive/c75215203025bdbfd57bb4dfb191cc8142cfc087.tar.gz 200
GET https://github.com/thanos-io/thanos/archive/57145061be15671d23493c60d8a500e70849b865.tar.gz 200
GET https://github.com/grafana/grafana/archive/1120f9e255760a3c104b57871fcb91801e934382.tar.gz 200
GET https://github.com/prometheus-operator/prometheus-operator/archive/e5ee07bda82538d1122be100b6cd89f2a54b8e35.tar.gz 200
GET https://github.com/grafana/grafonnet-lib/archive/30280196507e0fe6fa978a3e0eaca3a62844f817.tar.gz 200
GET https://github.com/grafana/jsonnet-libs/archive/a924ab1b5fd4e6eacd7235a20978d050a27bdb65.tar.gz 200
GET https://github.com/grafana/grafonnet-lib/archive/30280196507e0fe6fa978a3e0eaca3a62844f817.tar.gz 200
````

Далее скачиваем файл [example.jsonnet](./files/kube-prometheus/example.jsonnet) используемый в качестве образца файла
конфигурирования:

````bash
$ wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/example.jsonnet -O example.jsonnet
--2023-01-19 08:12:19--  https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/example.jsonnet
Загружен сертификат CA «/etc/ssl/certs/ca-certificates.crt»
Распознаётся raw.githubusercontent.com (raw.githubusercontent.com)… 185.199.111.133, 185.199.109.133, 185.199.110.133, ...
Подключение к raw.githubusercontent.com (raw.githubusercontent.com)|185.199.111.133|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа… 200 OK
Длина: 2273 (2,2K) [text/plain]
Сохранение в: «example.jsonnet»

example.jsonnet    100%[=====================================================================================================================================>]   2,22K  --.-KB/s    за 0s      

2023-01-19 08:12:20 (27,6 MB/s) - «example.jsonnet» сохранён [2273/2273]
````

А также скачиваем скрипт, используемый для сборки:

````bash
$ wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/build.sh -O build.sh
--2023-01-19 08:14:15--  https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/build.sh
Загружен сертификат CA «/etc/ssl/certs/ca-certificates.crt»
Распознаётся raw.githubusercontent.com (raw.githubusercontent.com)… 185.199.108.133, 185.199.109.133, 185.199.111.133, ...
Подключение к raw.githubusercontent.com (raw.githubusercontent.com)|185.199.108.133|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа… 200 OK
Длина: 679 [text/plain]
Сохранение в: «build.sh»

build.sh    100%[=====================================================================================================================================>]     679  --.-KB/s    за 0s      

2023-01-19 08:14:16 (34,8 MB/s) - «build.sh» сохранён [679/679]
````

Полученный файл [build.sh](./files/kube-prometheus/build.sh) помечаем как исполняемый:

````bash
$ chmod u+x build.sh

$ ls -la
итого 32
drwxr-xr-x 3 rgen rgen 4096 ноя 19 08:14 .
drwxr-xr-x 8 rgen rgen 4096 ноя 19 08:17 ..
-rwxr--r-- 1 rgen rgen  679 ноя 19 08:14 build.sh
-rw-r--r-- 1 rgen rgen 2273 ноя 19 08:12 example.jsonnet
-rw-r--r-- 1 rgen rgen  287 ноя 19 08:10 jsonnetfile.json
-rw-r--r-- 1 rgen rgen 5287 ноя 19 08:16 jsonnetfile.lock.json
drwxr-xr-x 3 rgen rgen 4096 ноя 19 08:16 vendor
````

Далее обновляем зависимости для "kube-prometheus":

````bash
$ jb update                                                                             
GET https://github.com/prometheus-operator/kube-prometheus/archive/67c08545193ebdd75f57e0afa922f87d56c98781.tar.gz 200
GET https://github.com/prometheus/alertmanager/archive/a8e4c166a86df10acca7612c9db462aa4e663bfe.tar.gz 200
GET https://github.com/pyrra-dev/pyrra/archive/31b9ac3c75e7aa904ea1b5fca37f6b2ea2622230.tar.gz 200
GET https://github.com/thanos-io/thanos/archive/57145061be15671d23493c60d8a500e70849b865.tar.gz 200
GET https://github.com/brancz/kubernetes-grafana/archive/d039275e4916aceae1c137120882e01d857787ac.tar.gz 200
GET https://github.com/prometheus-operator/prometheus-operator/archive/e5ee07bda82538d1122be100b6cd89f2a54b8e35.tar.gz 200
GET https://github.com/kubernetes/kube-state-metrics/archive/c75215203025bdbfd57bb4dfb191cc8142cfc087.tar.gz 200
GET https://github.com/prometheus/node_exporter/archive/a3bd2e13052929663dbd7d680fab4a952efb1de6.tar.gz 200
GET https://github.com/kubernetes/kube-state-metrics/archive/c75215203025bdbfd57bb4dfb191cc8142cfc087.tar.gz 200
GET https://github.com/prometheus/prometheus/archive/9f91215bf6d22d1eea7b56d17a9b55ebd72dd32e.tar.gz 200
GET https://github.com/grafana/grafana/archive/1120f9e255760a3c104b57871fcb91801e934382.tar.gz 200
GET https://github.com/etcd-io/etcd/archive/756875151fa61d040119ecce72ad909a5cce6175.tar.gz 200
GET https://github.com/prometheus-operator/prometheus-operator/archive/e5ee07bda82538d1122be100b6cd89f2a54b8e35.tar.gz 200
GET https://github.com/kubernetes-monitoring/kubernetes-mixin/archive/05ca993f01ee4dada3ea4d2afd51693784c6d858.tar.gz 200
GET https://github.com/grafana/grafonnet-lib/archive/30280196507e0fe6fa978a3e0eaca3a62844f817.tar.gz 200
GET https://github.com/grafana/jsonnet-libs/archive/a924ab1b5fd4e6eacd7235a20978d050a27bdb65.tar.gz 200
GET https://github.com/grafana/grafonnet-lib/archive/30280196507e0fe6fa978a3e0eaca3a62844f817.tar.gz 200
````

Перед компиляцией следует дополнительно установить инструменты "gojsontoyaml" и "jsonnet":

````bash
$ go install github.com/brancz/gojsontoyaml@latest
go: downloading github.com/brancz/gojsontoyaml v0.1.0
go: downloading github.com/ghodss/yaml v1.0.0
go: downloading gopkg.in/yaml.v2 v2.4.0

$ go install github.com/google/go-jsonnet/cmd/jsonnet@latest
go: downloading github.com/google/go-jsonnet v0.19.1
go: downloading github.com/fatih/color v1.12.0
go: downloading sigs.k8s.io/yaml v1.1.0
go: downloading gopkg.in/yaml.v2 v2.2.7
go: downloading github.com/mattn/go-isatty v0.0.12
go: downloading github.com/mattn/go-colorable v0.1.8
go: downloading golang.org/x/sys v0.1.0
````

Создаём копию файла [example.jsonnet](./files/kube-prometheus/example.jsonnet) под
именем [monitoring.jsonnet](./files/kube-prometheus/monitoring.jsonnet)
и указываем в нем [настройки](https://github.com/prometheus-operator/kube-prometheus/tree/main/docs/customizations)
инструментов мониторинга, установка которых предполагается в кластер Kubenetes. После этого запускаем скрипт генерации
манифестов:

````bash
$ ./files/build.sh monitoring.jsonnet 
+ set -o pipefail
++ pwd
+ PATH=/run/media/rgen/Second/Netology/devops-diploma-yandexcloud/16-diploma-yc/kube-prometheus/tmp/bin:/opt/oracle/instantclient_21_7::/home/rgen/yandex-cloud/bin:/home/rgen/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/var/lib/snapd/snap/bin:/usr/lib/jvm/amazon-corretto-11.0.16.9.1-linux-x64/bin:/usr/bin/qbec-linux-amd64:/home/rgen/go/bin
+ rm -rf manifests
+ mkdir -p manifests/setup
+ jsonnet -J vendor -m manifests monitoring.jsonnet
+ xargs '-I{}' sh -c 'cat {} | gojsontoyaml > {}.yaml' -- '{}'
+ find manifests -type f '!' -name '*.yaml' -delete
+ rm -f kustomization
````

В результате в папке [manifests](./files/kube-prometheus/manifests) получаем набор манифестов для разворачивания системы
мониторинга. Для их применения используется утилита `kubectl`. Её вызов производится в два этапа.

### <a name="kube_prometheus_deploy">4.2 Установка системы мониторинга пакета Kube-Prometheus</a>

Перейдем в папку [kube-prometheus](./files/kube-prometheus) и создадим пространства имен и CRD (Custom Resource
Definition - [специальный ресурс](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
в Kubernetes, позволяющий вносить любые данные):

````bash
$ kubectl apply --server-side -f manifests/setup
namespace/monitoring serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
clusterrole.rbac.authorization.k8s.io/prometheus-operator serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator serverside-applied
deployment.apps/prometheus-operator serverside-applied
networkpolicy.networking.k8s.io/prometheus-operator serverside-applied
service/prometheus-operator serverside-applied
serviceaccount/prometheus-operator serverside-applied
````

Дождёмся запуска всех ресурсов и запустим ресурсы, непосредственно реализующие систему мониторинга:

````bash
$ kubectl apply -f manifests
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
servicemonitor.monitoring.coreos.com/prometheus-operator created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
````

> Инсталляцию ресурсов в кластер можно выполнять и одной командой, добавив в неё условие ожидания готовности:
>````bash
>kubectl apply --server-side -f manifests/setup
>kubectl wait \
>  --for condition=Established \
>  --all CustomResourceDefinition \
>  --namespace=monitoring
>kubectl apply -f manifests/
>````

### <a name="kube_prometheus_access">4.3 Получение пользовательского доступа к системе мониторинга</a>

Доступ к развернутым в кластере приложениям мониторинга можно организовать несколькими способами, например:

- создать сервис вида NodePort, и получать доступ по внешним IP-адресам любой из нод кластера
  в диапазоне портов от 30000 до 32768;
- создать сервис вида LoadBalancer и получать доступ по единому IP-адресу балансировщика через любой желаемый порт;
- организовать сетевой балансировщик нагрузки на уровне облачного провайдера;
- воспользоваться проброской портов и получить доступ к сервисам мониторинга из локального окружения.

Воспользуемся последним из перечисленных способов по причине его простоты.

Когда все ресурсы запустились, можно выполнить проброску портов кластера в локальное окружение с помощью команды
`kubectl port-forward`:

````bash
$ kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
...
$ kubectl --namespace monitoring port-forward svc/grafana 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
Handling connection for 3000
...
$ kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
Forwarding from 127.0.0.1:9093 -> 9093
Forwarding from [::1]:9093 -> 9093
Handling connection for 9093
...
````

После чего убедиться в доступности инструментов мониторинга:

|             Port 9090             |             Port 3000             |              Port 9093              |
|:---------------------------------:|:---------------------------------:|:-----------------------------------:|
| ![img_8.png](files/img/img_8.png) | ![img_9.png](files/img/img_9.png) | ![img_10.png](files/img/img_10.png) |

### <a name="cluster_app_deploy">4.4 Разворачивание приложения в кластере Kubernetes</a>

#### <a name="cluster_app_templating">4.4.1 Шаблонизация приложения с помощью Helm</a>

Оснастив наш кластер системой мониторинга развернём в нём и наше веб-приложение. Для удобства разворачивания применим
инструмент [Helm](https://helm.sh/), позволяющий шаблонизировать манифесты и организовать установку приложений
из репозитория.

Создадим директорию с именем [helm](./files/helm), перейдём в неё и создадим в ней заготовку чартов нашего
веб-приложения:

````bash
$ helm create web-app
Creating web-app
````

В папке [helm](./files/helm) появилась соответствующая директория [web-app](helm/web-app).

Удалим из неё те файлы и папки, которые нам не нужны:

- папка `charts` - используется для шаблонов, необходимых создаваемому шаблону; у нас таких нет;
- папка `templates/tests` - используется для хранения тестов; тестов у нас нет;
- файл `templates/hpa.yaml` - параметры горизонтального масштабирования, которое мы не используем;
- файл `templates/serviceaccount.yaml` - задаёт параметры сервисного аккаунта для доступа к API Kubernetes; нам это не
  требуется;
- файл `templates/deployment.yaml` - шаблон Deployment, который мы не используем;
- файл `templates/ingress.yaml` - шаблон Ingress, который мы не используем;
- файл `templates/service.yaml` - шаблон Service, который мы не используем.

Кроме того, из файла [_helpers.tpl](helm/web-app/templates/_helpers.tpl), являющегося локальной библиотекой
шаблонов,
удалим шаблон получения имени сервисного аккаунта `webnews-app.serviceAccountName`.

Разместим в [директории шаблонов](helm/web-app/templates) создаваемого чарта всё файлы, которые мы желаем
развернуть в нашем кластере, т.е. все файлы шаблонов нашего веб-приложения.

Ввиду простоты приложения файл у нас только один - [deploy-web-app](helm/web-app/templates/deploy-web-app.yaml),
представляющий из себя деплоймент
нашего приложения, состоящего только из фронтенд-компоненты.

Обратим внимание, что в этом файле шаблонизированы параметры репозитория, образа и его версии:

````bash
containers:
- name: diploma
  image: "{{- .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
````

Значения параметров, соответственно заданы в файле [values.yaml](helm/web-app/values.yaml):

````bash
image:
  repository: R-Gennadi/frontend
  pullPolicy: IfNotPresent
  tag: ""
````

А дефолтное значение параметра - в файле [Chart.yaml](helm/web-app/Chart.yaml):

````bash
appVersion: "0.0.1"
````

Кроме того, в файле [deploy-web-app](helm/web-app/templates/deploy-web-app.yaml) шаблонизировано применяемое
пространство имен и порт, используемый для службы NodePort:

````bash
namespace: {{ include "ns" . }}
...
nodePort: {{ include "frontend-port" . }}
````

Но здесь мы применяем собственные шаблоны, определённыйе в
файле [_helpers.tpl](helm/web-app/templates/_helpers.tpl):

````bash
{{/*
Returns name of applied namespace.
*/}}
{{- define "ns" -}}
{{- default .Release.Namespace .Values.currentNamespace }}
{{- end }}

{{/*
Returns frontend port number.
*/}}
{{- define "frontend-port" -}}
{{- "30000" }}
{{- end }}
````

Данный шаблон определен под коротким именем "ns" и буквально означает - "если переменная `currentNamespace` не
определена,
то использовать значение `default`".

Дополнительно мы определили шаблон файла [NOTES.txt](helm/web-app/templates/NOTES.txt) чтобы при запуске
нашего чарта пользователю выводилось соответствующее сообщение.

#### <a name="cluster_app_chart_deploy">4.4.2 Разворачивание веб-приложения из чарта Helm</a>

Шаблонизация закончена, теперь применим её и развернем наше приложение в кластере Kubernetes.

````bash
$ helm install web-app web-app
NAME: web-app
LAST DEPLOYED: Thu Jan 19 09:58:11 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Welcome to "web-app" (A Helm chart for Kubernetes) version "0.0.1" for namespace "default",
for current namespace "",
proudly build from repository "R-Gennadi/diploma".

Release revision: 1

This is installation: true
This is upgrade: false
````

Приложение развёрнуто в нашем кластере и благодаря применению NodePort доступно по адресу любой ноды кластера
через порт `30000`:

![img_11.png](files/img/img_11.png)

Список приложений, развернутых с помощью "Helm", можно вывести командой:

````bash
$ helm list                   
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION      
web-app         default         1               2023-01-19 09:58:11.721129899 +0100 CET deployed        web-app-0.0.1                   0.0.1    
````

---

## <a name="helm_artifactory">5. Использование Helm Artifactory</a>

Разместим созданное приложение в репозитории Helm, чтобы иметь возможность доступа к нему в любой момент.

### <a name="helm_chart_preparation">5.1 Подготовка чарта Helm</a>

Чарты в артифактории хранятся в архивированном виде, поэтому сначала следует такой архив создать.

Для этого используется команда `helm package`:

````bash
$ helm package web-app -d charts
Successfully packaged chart and saved it to: charts/web-app-0.0.1.tgz
````

Полученный в результате архив с именем `web-app-0.0.1.tgz` будут иметь следующее содержание:

- [Chart.yaml](./files/helm/web-app/Chart.yaml) - описание чарта, включая номер его версии;
- [values.yaml](./files/helm/web-app/values.yaml) - описание используемого чартом Docker-образа;
- [.helmignore](./files/helm/web-app/.helmignore) - список игнорируемых при сборке пакета файлов;
- [папка `templates`](./files/helm/web-app/templates), содержащая файлы:
    - [deploy-web-app.yaml](./files/helm/web-app/templates/deploy-web-app.yaml) - Kubernetes-манифесты, применяемые при
      разворачивании приложения в кластере;
    - [_helpers.tpl](./files/helm/web-app/templates/_helpers.tpl) - шаблоны, используемые чартом;
    - [NOTES.txt](./files/helm/web-app/templates/NOTES.txt) - сообщение, выводимое пользователю при применении чарта;

После создания архива чарта следует сгенерировать файл индексный файл чарта (index.html), что
выполняется простой командой `helm repo index`:

````bash
$ helm repo index charts
$
````

Полученный в результате файл [index.yaml](./files/helm/charts/index.yaml) содержит перечень предоставляемых
чартом версий приложения, составленный с соответствующими архивами (их может быть несколько, добавляемых
по мере развития приложения).

Кроме того, рекомендуется в корневой директории чарта создать `html`-файл, предназначенный быть
пригласительной поясняющей страницей при входе в Git-репозиторий, в котором будет храниться наш чарт.
Создадим такой файл, назвав его [index.html](./files/helm/index.html):

````html

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
</head>
<body>
<h1>Welcome to Helm repository!</h1>
<h2>Repyevskiy G.V.</h2>
</body>
</html>
````

### <a name="helm_chart_store">5.2 Сохранение чарта Helm в Git-репозитории</a>

Отправляем содержимое папки [helm](./files/helm) в отдельный [репозиторий](https://github.com/R-Gennadi/diploma-chart)
на GitHub:

![img_13.png](files/img/img_13.png)

В настройках [репозитория](https://github.com/R-Gennadi/diploma-chart) Github переходим на закладку Pages и указываем
ветку, которая будет соответствовать
нашему репозиторию. В данном случае это ветка main, выбираем её и нажимаем "Save":

![img_12.png](files/img/img_12.png)

> Следует некоторое время подождать, пока Github создаёт страницу и генерирует URL, который можно использовать
> для создания репозитория на [artifacthub.io](https://artifacthub.io).
>
> В нашем случае это адрес [https://R-Gennadi.github.io/diploma-chart/](https://R-Gennadi.github.io/diploma-chart/)

Если перейти по [сгенерированному Github URL](https://R-Gennadi.github.io/diploma-chart/), то мы увидим
пригласительную страницу нашего репозитория:

![img_14.png](files/img/img_14.png)

Опубликуем наш репозиторий на хабе [artifacthub.io](https://artifacthub.io). Для этого на контрольной панели
пользователя (аккаунт у нас уже есть) выбираем закладку "Repositories" и нажимаем "Add repository":
В параметрах репозитория указываем его имя и URL,

![img_15.png](files/img/img_15.png)

> Здесь следует обратить внимание, что в качестве URL указан адрес, предоставленный нам Github, но
> с указанием папки [charts](./files/helm/charts), в которой находятся
> наши файлы - индексный [index.yaml](./files/helm/charts/index.yaml) и [архив](./files/helm/charts/web-app-0.0.1.tgz)

Репозиторий создан!

### <a name="helm_chart_verified">5.3 Получение статуса репозитория "Verified Publisher"</a>

#### <a name="helm_chart_verified_git_repo">5.3.1 Идентификация Git-репозитория</a>

Подтвердим нашу возможность контролировать репозиторий, чтобы получить статус "Verified Publisher".
Для это в директории, указанной в качестве URL репозитория, т.е. в [charts](./files/helm/charts) создадим специальный
файл
метаданных [artifacthub-repo.yml](https://artifacthub.io), в котором укажем идентификатор репозитория, имя нашей
учётной записи и e-mail:

````yaml
repositoryID: 1afeeefa-c585-4b84-a4b1-aeea6effd729
owners:
  - name: R-Gennadi
    email: rgenvik@gmail.com
````

#### <a name="helm_chart_verified_dockerhub">5.3.2 Обновление образа приложения в Dockerhub</a>

Кроме того, чтобы сервис [artifacthub-repo.yml](https://artifacthub.io) воспринял изменение репозитория необходимо,
обновить версию приложения в репозитории.

Обновим версию приложения (это просто текст в файле [index.html](./files/diploma-repo/web-app/index.html)) и
пересоберем docker-образ:

````bash
$ docker build -t R-Gennadi/diploma:0.0.3 .   
Sending build context to Docker daemon  56.32kB
Step 1/3 : FROM nginx
 ---> 2d389e545974
Step 2/3 : COPY web-app/index.html /usr/share/nginx/html
 ---> d851d7f5eb01
Step 3/3 : ADD nginx/nginx.conf /nginx/nginx.conf
 ---> f406a744d842
Successfully built f406a744d842
Successfully tagged R-Gennadi/diploma:0.0.3
````

Теперь имеем несколько версий нашего приложения:

````bash
$ docker image ls                                
REPOSITORY                                TAG          IMAGE ID       CREATED              SIZE
R-Gennadi/diploma                      0.0.3        f406a744d842   About a minute ago   142MB
R-Gennadi/diploma                      0.0.2        28f4b7049a10   2 days ago           142MB
R-Gennadi/diploma                      0.0.1        28f4b7049a10   2 days ago           142MB
````

Отправим новый образ, имеющий тег `0.0.3` в репозиторий:

````bash
$ docker push R-Gennadi/diploma:0.0.3
The push refers to repository [docker.io/R-Gennadi/diploma]
7c59c9ea735a: Pushed 
4e4147fa9482: Pushed 
36665e416ec8: Layer already exists 
31192a8593ec: Layer already exists 
7ee9bf58503c: Layer already exists 
a064c1703bfd: Layer already exists 
9388548487b1: Layer already exists 
b45078e74ec9: Layer already exists 
0.0.3: digest: sha256:4e1ebff50eff8897b9517a9f9e94f315e39c156a8d71d7adf9f6d5b15d709358 size: 1984
````

Добавленный образ можно наблюдать через веб-интерфейс Dockerhub:
![img_16.png](files/img/img_16.png)

#### <a name="helm_chart_verified_git_chart">5.3.3 Обновление чарта в Git-репозитории</a>

Обновим версию приложения на `0.0.3` в файлах [values.yaml](./files/helm/web-app/values.yaml) и
[Chart.yaml](./files/helm/web-app/Chart.yaml) после чего сгенерируем новый helm-пакет (tgz-архив):

````bash
$ helm package web-app -d charts
Successfully packaged chart and saved it to: charts/web-app-0.0.3.tgz
````

Индексный файл Helm тоже нужно пересоздать:

````bash
$ helm repo index charts
````

Все изменения отправляем в тот [Git-репозиторий](https://github.com/R-Gennadi/diploma-chart/tree/main/charts),
который контролируется артефакторием Helm:

````bash
$ git commit -m "Version 0.0.3"      
[main f2129bd] Version 0.0.3
 4 files changed, 16 insertions(+), 6 deletions(-)
 create mode 100644 charts/web-app-0.0.3.tgz

$ git push   
Перечисление объектов: 14, готово.
Подсчет объектов: 100% (14/14), готово.
При сжатии изменений используется до 4 потоков
Сжатие объектов: 100% (8/8), готово.
Запись объектов: 100% (8/8), 2.52 КиБ | 860.00 КиБ/с, готово.
Всего 8 (изменений 5), повторно использовано 0 (изменений 0), повторно использовано пакетов 0
remote: Resolving deltas: 100% (5/5), completed with 5 local objects.
To github.com:R-Gennadi/diploma-chart.git
   c5b8938..f2129bd  main -> main
````

В Git-репозитории имеем новый набор файлов, в котором также присутствуют и все исторические версии пакетов:

![img_17.png](files/img/img_17.png)

> Удалять старые версии не рекомендуется, потому что они уже могут быть в работе у пользователей репозитория
> и их пользовательские манифесты могут перестать собираться!

#### <a name="helm_chart_verified_granted">5.3.4 Присвоение репозиторию статуса "Verified Publisher"</a>

Через некоторое время (оно несколько больше, чем указано у репозитория в поле "LAST PROCESSED")
сервис [artifacthub.io](https://artifacthub.io/) посетит наш репозиторий и, обнаружив, что
файл [index.yaml](./files/helm/charts/index.yaml) обновлён, перечитает наш репозиторий, проверит в нём содержимое
[файла метаданных](./files/helm/charts/artifacthub-repo.yml) и присвоит нашему репозиторию
статус "Verified Publisher":

![img_18.png](files/img/img_18.png)

> Кроме присвоения статуса "Verified Publisher" наш репозиторий **успешно прошел проверку безопасности**,
> о чём свидетельствует зелёная галочка в поле "LAST SECURITY SCAN".

### <a name="helm_chart_deploy">5.4 Установка приложения из артефактория Helm</a>

Теперь, когда наше веб-приложение добавлено в репозиторий, мы получаем возможность устанавливать его в кластер
автоматизированным способом еще на этапе сборки кластера.

Создадим файл [deploy-web-app.ansible.yaml](./files/ansible/infrastructure/playbooks/deploy-web-app.ansible.yaml), в
котором
опишем процедуру добавления нашего репозитория и установки из него веб-приложения в кластер.

Добавим указание на этот файл в файл [site.yaml](./files/ansible/infrastructure/site.yaml), используемый для сборки
кластера,
чтобы в следующий раз получить кластер Kubernetes с уже установленным в нём веб-приложением.

Проверим работоспособность схемы установки нашего веб-приложения из репозитория "Helm".
Для этого заново установим его же, но уже из репозитория, используя созданный нами Ansible-манифест
[deploy-web-app.ansible.yaml](./files/ansible/infrastructure/playbooks/deploy-web-app.ansible.yaml):

````bash
$ ansible-playbook -i inventory/hosts.yaml playbooks/deploy-web-app.ansible.yaml
PLAY [Setup Kubernetes Cluster] ************************************************
TASK [Gathering Facts] *********************************************************
ok: [cp1]
TASK [Add 'Helm' chart repo] ***************************************************
ok: [cp1]
TASK [Update `Helm` repository cache] ******************************************
ok: [cp1]
TASK [Deploy certain version of web-application] *******************************
changed: [cp1]
PLAY RECAP *********************************************************************
cp1: ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
````

Как результат, имеем веб приложение, развернутое в кластере Kubernetes:

````bash
$ kubectl get deploy -n default
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
web-app   2/2     2            2           7m
````

Благодаря применению NodePort приложение доступно по адресу любой ноды кластера через порт `30000` и мы видим, что это
новая версия приложения - `0.0.3`:

![img_19.png](files/img/img_19.png)

> Удалять старую версию приложения не понадобилось - Kubernetes сам об этом позаботился.

---

## <a name="monitoring_customization">6. Настройка системы мониторинга кластера Kubernetes</a>

Имея работающий кластер Kubernetes и приложение в нём, создадим несложную схему мониторинга.
Допустим, мы хотим видеть общее количество подов в кластере и какая доля из них находится статусе "Running".
Аналогичные показатели мы желаем видеть для подов, относящися к нашему веб-приложению, т.е. имеющих
идентификаторы начинающиеся на строку "web-app-".

### <a name="monitoring_customization_prometheus">6.1 Использование Prometheus</a>

Зайдем в интерфейс Prometheus и создадим соответствующие показатели, используя язык запросов PromQL.

PromQL-запрос для получения общего количества подов в кластере:

````bash
sum(kube_pod_status_phase{phase="Running"})
````

Доля работающих подов:

````bash
sum(kube_pod_status_phase{phase="Running"})/sum(kube_pod_status_phase)*100
````

Общее количество подов веб-приложения:

````bash
sum(kube_pod_status_phase {phase="Running", pod=~"web-app-.+"})
````

Доля работающих подов веб-приложения:

````bash
sum(kube_pod_status_phase {phase="Running", pod=~"web-app-.+"})/sum(kube_pod_status_phase {pod=~"web-app-.+"})*100
````

В веб-интерфейсе Prometheus данные PromQL-запросы выглядят следующим образом:

![img_20.png](files/img/img_20.png)

### <a name="monitoring_customization_grafana">6.2 Использование Grafana</a>

Prometheus имеет определенные возможности для отображения результатов запросов, но возможности Grafana гораздо шире.
Настроим графические панели Grafana для отображения этих же параметров. Язык запросов используется тот же - PromQL,
поэтому мы можем просто скопировать в Grafana те же самые запросы, что мы создали в Prometheus.

> Если Grafana не откликается, то можно её перезапустить, удалив соответствующий под:
> ````bash$
> kubectl config set-context --current --namespace=monitoring                                                                   
> Context "kubernetes-admin@cluster.local" modified.
> 
> $ kubectl delete pod/grafana-6b4547d9b8-scv8c              
> pod "grafana-6b4547d9b8-scv8c" deleted
> ````

Панель для отображения общего количество подов нашего кластера и количества подов, обслуживающих наше веб-приложение,
будет выглядеть следующим образом:

![img_21.png](files/img/img_21.png)

Панель, отображающая долю работающих подов кластера, и долю работающих подов веб-приложения:

![img_22.png](files/img/img_22.png)

Обе созданные панели можно совместить на итоговой приборной панели Grafana:

![img_23.png](files/img/img_23.png)

Таким образом, мы имеем **систему мониторинга кластера Kubernetes и развернутого в нём веб-приложения**.

---

## <a name="cicd">7. Установка и настройка процессов CI/CD</a>

### <a name="cicd_vm_creation">7.1 Разворачивание виртуальных машин</a>

Развернём с помощью Терраформа два дополнительных экземляра виртуальных машин на основе образов, оптимизированных
для запуска Docker-контейнеров:

- `tc-server` - сервер TeamCity;
- `tc-agent` - агент задач TeamCity;

Сервер TeamCity является более ресурсоёмким, поэтому мы назначили ему больше ресурсов - 100% времени CPU вместо 20%,
как у остальных машин, и 4Гб RAM:

![img_24.png](files/img/img_24.png)

> Использование образов, оптимизированных для использования Docker, обусловлено тем, что для работы агентов Teamcity
> необходим демон Docker для сборки образов на основе Dockerfile и отправки их в регистр. В образах, оптимизированных
> для запуска Docker-контейнеров демон Docker уже установлен, что экономит нам ресурсы.
>
> Список образов, оптимизированных для использования Docker, можно получить командой:
> ````bash
> $ yc compute image list --folder-id standard-images | grep "container"
> | fd80lqp9cp96q4nfae51 | container-optimized-image-1586329357 | container-optimized-image | f2enhr48fnru5k4gd30r | READY |
> | fd80m2h15krph9b36mfg | container-optimized-image-1567699175 | container-optimized-image | f2e5i3c69q4vdui0agq5 | READY |
> | fd80o2eikcn22b229tsa | container-optimized-image-v20220204a | container-optimized-image | f2elf7186figj4p34at5 | READY |
> ...
> ````
>
> Выбирать можно любой образ.

### <a name="cicd_teamcity">7.2 Установка компонентов Teamcity</a>

С помощью Ansible установим
[сервер и агент Teamcity](./files/ansible/infrastructure/playbooks/deploy-tc.ansible.yaml).

Установка сервера не вызывает особых вопросов, но с установкой агента всё сложнее и следует учитывать несколько
нюансов:

- в связи с тем, что Docker-контейнеры более не запускаются с `root`-правами, следует использовать только те образы
  репозитория [TeamCity](https://hub.docker.com/r/jetbrains/teamcity-agent), которые именованы как
  `teamcity-agent:<Номер версии>-linux-sudo`;
- образы должны запускаться и с параметром `privileged=true`, и с параметром `DOCKER_IN_DOCKER=start` в противном
  случае сокет докера из контейнера доступен не будет:
-

````yaml
docker_container:
  name: tc-agent
  image: jetbrains/teamcity-agent:2022.10.1-linux-sudo
  privileged: true
  volumes:
    - "/home/ubuntu/teamcity_agent/conf:/data/teamcity_agent/conf"
  env:
    DOCKER_IN_DOCKER: "start"
    SERVER_URL: "10.10.10.10:8111"
````

Если агент Teamcity не обладает доступом к сокету Docker, то об этом будет сообщено что у агента не установлен
необходимый параметр `docker.server.version`. Дело в том, что Teamcity периодически проверяет агента путем вызова
в контейнере агента команды `docker version` и если она не возвращает и версию **Docker-агента** и версию
**Docker-сервера**, то это трактуется, как отсутствие доступа к соответствующему компоненту Docker.

> Команда `docker -v` возвращает только номер версии **клиента** Docker.

> Следует обращать внимание, чтобы агент Teamcity имел доступ ко всем инструментам, которые ему требуются
> в процессе сборки, например, таким как Git или Helm.

### <a name="cicd_teamcity_server_customization_pre">7.3 Предварительная настройка сервера Teamcity</a>

После установки и запуска как сервера, так и агента Teamcity необходимо сконфигурировать процесс сборки.

Teamcity использует базу данных для хранения настроек, проектов, сборочных конфигураций, логов и прочего.
В качестве базы данных была установлена PostgreSQL, поэтому сконфигурируем Teamcity на подключение к ней:

![img_25.png](files/img/img_25.png)

Предложено задать пароль администратора. Используем `admin/admin`:
Перейдем на закладку Agents (вверху страницы) и видим, что агент
присутствует, но не авторизован:

![img_26.png](files/img/img_26.png)

Авторизуем агента:

![img_27.png](files/img/img_27.png)

После этого нажав на закладку "Projects" в верхней части
страницы создадим новый проект, который назовем "Diploma Repo", указав ему адрес репозитория,
изменения в котором должны отслеживаться:

![img_28.png](files/img/img_28.png)

В корне нашего репозитория находится файл сборки образа Dockerfile,
Teamcity обнаружив его, предложит нам в качестве этапа сборки создание нашего Docker-образа?
отметив этот этап галочкой и нажмём "Use selected":

![img_29.png](files/img/img_29.png)

Так как мы предполагаем работу с Docker-репозиторием, то следует настроить доступ к нему.
Для этого следует зайти в меню редактирование проекта (проект -> кнопка "Edit project"),
выбрать в нём закладку "Connections" и нажать "Add Connection":

![img_30.png](files/img/img_30.png)

После успешного тестирования соединения следует подключить поддержку работы с Docker для данной сборки.
Для этого переходим на закладку "Build Features":
Нажимаем "Add build feature", выбираем "Docker Support" и указываем настроенное на предыдущем шаге
соединение с Docker-репозиторием:

![img_31.png](files/img/img_31.png)

После сохранения, поддержка Docker для данной сборки подключена:

![img_32.png](files/img/img_32.png)

### <a name="cicd_teamcity_server_customization_build">7.4 Настройка процедуры сборки</a>

Процедура сборки состоит из следующих шагов:

| Шаг | Действие                                                                                        | Используемые команды                                                              |
|:---:|:------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------|
|  1  | Получение тега последнего коммита в репозитории приложения                                      | git fetch<br/>git tag --points-at HEAD                                            |
|  2  | Проверка соответствия коммита шаблону и сборка образа                                           | COMMIT_TAG matches [0-9]+\.[0-9]+\.[0-9]+<br/>docker build                        |
|  3  | Отправка образа в Docker-репозиторий                                                            | docker push                                                                       |
|  4  | Создание временной директории и получение в неё содержимого репозитория Helm                    | mkdir<br/>git clone                                                               |
|  5  | Обновление файлов репозитория Helm, сохранение их в репозитории и удаление временной директории | sed -e<br/>helm package<br/>helm repo index<br/>git add<br/>git push<br/> rm -rdf |

#### <a name="cicd_teamcity_server_customization_build_1">7.4.1 Шаг 1: получение тега последнего коммита</a>

В логике нашей сборки мы хотим использовать тег, назначенный коммиту в качестве тега нашего Docker-образа.
Для этого создадим отдельный этап, позволяющий выполнять произвольный код командной строки.
Для этого на закладке "Build Step" выбираем тип шага "Command Line":

![img_33.png](files/img/img_33.png)

Далее, заходим в настройки этого шага задаём скрипт, который должен исполняться:

![img_34.png](files/img/img_34.png)

**где:**

- `commit_tag=$(git tag --points-at HEAD)` - команда получения тега последнего коммита Git и размещение
  её результата в переменной `commit_tag`;

- `echo "##teamcity[setParameter name='COMMIT_TAG' value='$commit_tag']"` - специальная нотация Teamcity,
  позволяющая разместить в некоей переменной (здесь - `COMMIT_TAG`), некоторое значение
  (здесь - содержимое переменной `commit_tag`).

После подтверждения параметров шага следует переместиться на закладку "Parameters" (появится после
нажатия кнопки "Show more") и объявить переменную `COMMIT_TAG`, значение которой мы заполнили
нашим скриптом:

![img_35.png](files/img/img_35.png)

> Так как значение переменной изначально пустое и заполняется скриптом на самом первом шаге
> нашей сборки, то следует зайти в редактирование переменной и выйти из нёё. Так будет считаться,
> что переменная заполнена пустым значением.

#### <a name="cicd_teamcity_server_customization_build_2">7.4.2 Шаг 2: сборка Docker-образа</a>

После того, как тег последнего коммита получен,
перейдем к шагу - сборка нового Docker-образа нашего приложения.
Для этого добавляем второй шаг нашей сборки с типом `Docker`, указываем действие `build` и задаём параметры
создаваемого образа:

![img_36.png](files/img/img_36.png)

Все необходимые поля заполнены автоматически,
нам нужно указать наименование собираемого образа и его тег,
значение которого будет извлекаться из заполненной на первом шаге
переменной `COMMIT_TAG`.

> Обращаем внимание, что имя образа предваряется именем используемого репозитория, обычно совпадающего с именем
> пользователя Github (здесь - это `R-Gennadi`)!
>
> Кроме того, т.к. мы хотим следовать **принципу семантического версионирования**, то дополнительно настроим требование
> к тегу, присвоенному коммиту и используемому на 2-м и 3-м шагах сборки. Для этого добавим условие
> выполнения шага:
>
> ![img_37.png](files/img/img_37.png)
>
> Зададим условие, что тег должен состоять из трех чисел, разделенных точкой, что соответствует шаблону обозначения
> версий, как `MAJOR.MINOR.PATCH` и может быть определено регулярным выражением `[0-9]+\.[0-9]+\.[0-9]+`:
>
> ![img_38.png](files/img/img_38.png)

#### <a name="cicd_teamcity_server_customization_build_3">7.4.3 Шаг 3: сохранение Docker-образа в репозиторий Dockerhub</a>

Следующим создадим шаг по отправке собранного образа в репозиторий.
Для этого в настройках сборки (сборка -> кнопка "Edit configuration") на закладке "Build Steps" добавляем новый шаг для
Docker:
Настройки здесь в целом такие же, как на этапе `docker build`, но команда будет `push`, а также следует указать,
что шаг будет выполняться только если статус сборки успешный:

![img_39.png](files/img/img_39.png)

#### <a name="cicd_teamcity_server_customization_build_4">7.4.4 Шаг 4: получение содержимого чарта Helm</a>

Следующим шагом добавим действие по получению содержимого Git-репозитория, связанного с Helm-артефакторием.
Здесь следует пояснить, что в нашем решении Веб-приложение попадает в кластер посредством артефактория Helm
и связанного с ним Git-репозитория, размещенного отдельно от репозитория с веб-приложением.
Корректное обновление артефактория состоит из следующих этапов:

- обновление номера версии приложения файлах [values.yaml](./files/helm/web-app/values.yaml)
  и [Chart.yaml](./files/helm/web-app/Chart.yaml);
- создание Helm-архива командой `helm package web-app -d charts`;
- обновление индексного файла Helm `index.yaml` командой `helm repo index charts`;
- оправка нового содержимого Git-репозиторий, привязанного к Helm-артефактория (следует обратить внимание, что это не
  тот репозиторий, где хранится код приложения);

После того, как в Git-репозитории, привязанном к Helm-артефакторию, окажется новое содержимое, то Helm-артефакторий
обнаружит изменения в файле `index.yaml` и автоматически обновит ссылки, проверив перед этим присутствие корректного
образа в Dockerhub.

Данная процедура реализована на 4-м и 5-м шагах нашей сборки.

На 4-м шаге мы просто создаём временную папку и клонируем туда содержание репозитория. Все действия выполняются
утилитами командной строки:

![img_40.png](files/img/img_40.png)

> Здесь следует обратить внимание, для доступа к Git-репозиторию мы используем аутентификацию с помощью персонального
> токена, полученного от Github с ограниченным доступом к требуемому git-репозиторию, связанному с артефакторием Helm:
> Для подключения по HTTPS этот токен применяется в составе следующего шаблона:
>
> ````bash
> https://<github-username>:<github-token>@github.com/<github-repository>.git
> ````
>
> При этом имя `github`-репозитория предваряется именем пользователя, т.к. нашем случае шаблон применяется
> следующим образом:
>
>````bash
>$ git clone https://R-Gennadi:%GITHUB_PERSONAL_TOKEN%@github.com/R-Gennadi/%HELM_REPO_NAME%.git;
> ````

#### <a name="cicd_teamcity_server_customization_build_5">7.4.5 Шаг 5: обновление Git-репозитория Helm</a>

Последним, 5-м шагом будет модификация файлов Git-репозитория, связанного с Helm-артефакторием.
Здесь нам нужно изменить версии приложения в двух файлах -  `Chart.yaml` и `values.yaml`,
после чего создать Helm-архив и индексный файл новой версии.
Все действия, как и на предыдущем шаге, выполняются утилитами командной строки:

![img_41.png](files/img/img_41.png)

По окончании этого шага созданная временная папка удаляется.

Полностью примененный на этом шаге скрипт выглядит следующим образом:

````bash
cd %TEMP_HELM_REPO_FOLDER_NAME%/%HELM_REPO_NAME%;

# Update chart version.
cd %WEB_APP_NAME%;
cat Chart.yaml | sed -e "s/version:.*/version: %COMMIT_TAG%/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

cat Chart.yaml | sed -e "s/appVersion:.*/appVersion: \"%COMMIT_TAG%\"/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

# Update image tag.
cat values.yaml | sed -e "s/tag:.*/tag: \"%COMMIT_TAG%\"/" > values.tmp.yaml
mv values.tmp.yaml values.yaml

cd ..;

# Create Helm-archive.
helm package %WEB_APP_NAME% -d charts;

# Update Helm-index file.
helm repo index charts;

# Update repository.
git add .;
git config --global user.email "%USER_EMAIL%"
git config --global user.name "%USER_NAME%"
git commit -m "Build #%build.number%"
git push origin -f;

# Cleanout.
cd ..;
rm test/ -rdf;

# Update previous commit tag.
echo "##teamcity[setParameter name='PREV_COMMIT_TAG' value='$commit_tag']"
````

Настройка в целом закончена, и в итоге состав наших шагов будет выглядет следующим образом:

![img_42.png](files/img/img_42.png)

#### <a name="cicd_cluster_customization">7.5 Автоматизация получения обновлений кластером Kubernetes с помощью CRON</a>

Осталось выполнить последний этап процесса - обновление нашего работающего в кластер веб-приложения до последней версии.
Для этого существует множество способов, но мы воспользуемся обычным
[CRON-планировщиком](./files/ansible/infrastructure/playbooks/deploy-web-app-cron.ansible.yaml),
запускающего каждые 30 минут определённый набор команд на контрольном узле кластера.
Набор команд представляет собой действия по обновлению репозитория Helm (иначе новая версия приложения
не будет доступна) и обновлению самого приложения:

````bash
ubuntu@cp1:~$ helm repo update
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "diploma-chart" chart repository
Update Complete. ⎈Happy Helming!⎈

ubuntu@cp1:~$ helm upgrade --install web-app diploma-chart/web-app
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
Release "web-app" has been upgraded. Happy Helming!
NAME: web-app
LAST DEPLOYED: Wed Jan 25 13:30:08 2023
NAMESPACE: default
STATUS: deployed
REVISION: 15
TEST SUITE: None
NOTES:
Welcome to "web-app" (A demo Helm chart for Kubernetes) version "0.0.7" for namespace "default",
for current namespace "",
proudly build from repository "R-Gennadi/diploma".

Release revision: 15

This is installation: false
This is upgrade: true
````

После инсталляции с помощью Ansible CRON-расписание обновления выглядит следующим образом:

````bash
ubuntu@cp1:/usr/local/bin$ crontab -l
#Ansible: helm-web-app-update-30min
*/30 * * * *
 /usr/local/bin/helm repo add diploma-chart https://R-Gennadi.github.io/diploma-chart/charts/;
 /usr/local/bin/helm repo update;
 /usr/local/bin/helm upgrade --install web-app diploma-chart/web-app --atomic;
````

---

## <a name="cicd_in_action">8. Итоговая проверка работоспособности процессов CI/CD</a>

После того, как настройка всех процессов CI/CD завершена, выполним проверку её работоспособности.

### <a name="cicd_in_action_1">8.1 Этап 1: разработка приложения</a>

Т.к. конечным этапом всего цикла сборки является обновление рабочей нагрузки (веб-приложения) в работающем кластере
Kubernetes, то сначала отметим состояние веб-приложения до начала автоматизированной сборки. Ориентироваться будем на
версию приложения и здесь она `0.0.7`:

![img_43.png](files/img/img_43.png)

Обновим наше веб-приложение, присвоив коммиту версию `0.0.8` и отправим её в репозиторий:

````bash
commit c952e6818d15c507fee228d373314cedb3ed1833 (HEAD -> main, tag: 0.0.8, origin/main)
Author: Repyevskiy G.V. <rgenvik@gmail.com>
Date:   Wed Jan 25 14:46:40 2023 +0100

    Version 0.0.8

commit fd3b892585c7948393ce026a48b604d786628dfd (tag: 0.0.7)
Author: Repyevskiy G.V. <rgenvik@gmail.com>
Date:   Wed Jan 25 13:47:01 2023 +0100

    Version 0.0.7
...
````

![img_44.png](files/img/img_44.png)

### <a name="cicd_in_action_2">8.2 Этап 2: автоматическая обработка результатов разработки</a>

Обнаружив новый коммит с тегов в Git-репозитории, Teamcity запустит сборку, которая успешно выполняется:

![img_45.png](files/img/img_45.png)

Мы видим, что обнаружен тег с номером `0.0.8` - это именно тот тег, который мы присвоили очередному коммиту.

После успешного прохождения сборки собранный образ оказывается в нашем репозитории Dockerhub:

![img_46.png](files/img/img_46.png)

### <a name="cicd_in_action_3">8.3 Этап 3: разворачивание релиза приложения в кластере Kubernetes</a>

Каждые 30 минут срабатывает расписание CRON, которое обновляет чарт и, соответственно, обновляется наше веб-приложение:

![img_47.png](files/img/img_47.png)

Статус именованного Helm-релиза:

````bash
$ helm status web-app              
NAME: web-app
LAST DEPLOYED: Wed Jan 25 12:24:13 2023
NAMESPACE: default
STATUS: deployed
REVISION: 8
TEST SUITE: None
NOTES:
Welcome to "web-app" (A demo Helm chart for Kubernetes) version "0.0.8" for namespace "default",
for current namespace "",
proudly build from repository "R-Gennadi/diploma".

Release revision: 8

This is installation: false
````

> Интересной особенностью использования чартов Helm является возможность их отката к предыдущим релизам непосредственно
> через функционал самого кластера. Это пригождается, например, в случае возникновения каких-либо проблем после
> обновления приложения, когда можно выполнить откат незаметно для пользователей.
>
> Откат можно выполнить следующим образом:
>
> ````bash
> ubuntu@cp1:~$ helm list
> WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
> WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
> NAME   	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
> web-app	default  	17      	2023-01-25 14:08:46.671246207 +0000 UTC	deployed	web-app-0.0.8	0.0.8
>
> ubuntu@cp1:~$ helm rollback web-app 16
> WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
> WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
> Rollback was a success! Happy Helming!
> ````

Таким образом, мы добились того, что при появлении в репозитории нового релиза приложения этот релиз автоматически
разворачивается и в кластере Kubenetes.

---

## <a name="conclusion">9. Заключение</a>

В данной работе был продемонстрирован пример создания программного комплекса, позволяющего организовать полный
производственный цикл создания и использования программного продукта в облачной среде Yandex.Cloud с применением
отказоустойчивых решений кластера Kubernetes.

В процесс выполнения была подготовлена облачная инфраструктура на базе облачного провайдера Yandex.Cloud которая,
благодаря применению инструмента Terraform может быть быстро воссоздана в автоматическом режиме без каких-либо
значительных усилий со стороны инженерного персонала.

В целях обеспечения отказоустойчивости всей системы был запущен и сконфигурирован кластер системы Kubernetes доступ
к которому был установлен непосредственно из локального окружения, что значительно повышает удобство его
конфигурирования и настройки.

Применённый программный комплекс является сложным, состоит из множества компонент и для повышения надёжности его
эксплуатации была установлена и настроена система мониторинга на основе программных продуктов Prometheus, Grafana
и Alert Manager. Доступ к графическим интерфейсам этих инструментов был организован из локального окружения
пользователя.

С целью автоматизации сборки и разворачивания приложений в качестве рабочей нагрузки кластера Kubernetes была
применена связка сервера и агента Teamcity, что позволило автоматизировать все этапы процесса CI/CD,
когда выпуск релиза приложения, проходя весь цикл обработки, оказывался развёрнутым в целевом кластере и доступен
пользователям.

Дополнительно был подробно рассмотрен пример использования артефактория Helm, применение соответствующих инструментов
которого является индустриальным стандартом при эксплуатации кластеров Kubernetes.

Схему взаимодействия всех компонентов кратко можно представить следующим образом:

![img_48.png](files/img/img_48.png)

Для проверки работоспособности созданной системы CI/CD было написано простое статическое веб-приложение, позволяющее,
однако, отследить версии релизов и убедиться в том, что все этапы обрабатываются в соответствии с ожиданиями.
На завершающем этапе работы был продемонстрирован пример срабатывания всего цикла обработки, когда отправка нового
релиза приложения в Git-репозиторий приводит к последовательному обновлению всех участвующих компонентов
системы - Git-репозитория, Docker-хаба, артифактория Helm и релиза приложения в кластере Kubernetes.

Несмотря на несколько упрощённый характер реализованной системы данное решение позволяет избавить процесс разработки
программного продукта от рутинных операций.

---
_** Netology, 2023-2024 гг. **_

---
