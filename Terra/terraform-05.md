# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

## Чек-лист готовности к домашнему заданию
>"Ранее было представлено" [Домашнее задание к занятию «Основы Terraform. Yandex Cloud»](https://github.com/R-Gennadi/devops-netology/blob/main/Terra/Terr_2.md "Ранее было представлено")

## Задание 1
* 1. Возьмите код:
- из ДЗ к лекции 4,
- из демо к лекции 4.
>результат 
> Использую код из ДЗ к лекции 4
![img.png](img.png)

* 2. Проверьте код с помощью tflint и checkov. Вам не нужно инициализировать этот проект.

<details>
<summary> вывод команды  tflint </summary>
ubuntu@ubuntu2004:~/cloud/test$ docker run --rm -v $(pwd):/data -t ghcr.io/terraform-linters/tflint
7 issue(s) found:

Warning: Module source "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main" uses a default branch as ref (main) (terraform_module_pinned_source)

  on main.tf line 9:
   9:   source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_module_pinned_source.md

Warning: Missing version constraint for provider "template" in `required_providers` (terraform_required_providers)

  on main.tf line 26:
  26: data "template_file" "cloudinit" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_required_providers.md

Warning: Missing version constraint for provider "yandex" in `required_providers` (terraform_required_providers)

  on providers.tf line 3:
   3:     yandex = {
   4:       source = "yandex-cloud/yandex"
   5:     }

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_required_providers.md

Warning: [Fixable] variable "default_cidr" is declared but not used (terraform_unused_declarations)

  on variables.tf line 22:
  22: variable "default_cidr" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "vpc_name" is declared but not used (terraform_unused_declarations)

  on variables.tf line 28:
  28: variable "vpc_name" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "vm_web_name" is declared but not used (terraform_unused_declarations)

  on variables.tf line 44:
  44: variable "vm_web_name" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "vm_db_name" is declared but not used (terraform_unused_declarations)

  on variables.tf line 51:
  51: variable "vm_db_name" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md
</details>
> --download-external-modules true --directory /tf

       _               _              
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V / 
  \___|_| |_|\___|\___|_|\_\___/ \_/  
                                      
By Prisma Cloud | version: 3.1.29 

terraform scan results:

Passed checks: 1, Failed checks: 3, Skipped checks: 0

Check: CKV_YC_4: "Ensure compute instance does not have serial console enabled."
        PASSED for resource: module.test-vm.yandex_compute_instance.vm[0]
        File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
        Calling File: /main.tf:8-24
Check: CKV_YC_2: "Ensure compute instance does not have public IP."
        FAILED for resource: module.test-vm.yandex_compute_instance.vm[0]
        File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
        Calling File: /main.tf:8-24

                Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_YC_11: "Ensure security group is assigned to network interface."
        FAILED for resource: module.test-vm.yandex_compute_instance.vm[0]
        File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
        Calling File: /main.tf:8-24

                Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash"
        FAILED for resource: test-vm
        File: /main.tf:8-24
        Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-git-url-with-commit-hash-revision

                8  | module "test-vm" {
                9  |   source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
                10 |   env_name        = "develop"
                11 |   network_id      = module.vpc.network_id
                12 |   subnet_zones    = ["ru-central1-a"]
                13 |   subnet_ids      = [ module.vpc.subnet_id ]
                14 |   instance_name   = "web"
                15 |   instance_count  = 1
                16 |   image_family    = "ubuntu-2004-lts"
                17 |   public_ip       = true
                18 |   
                19 |   metadata = {
                20 |       user-data          = data.template_file.cloudinit.rendered 
                21 |       serial-port-enable = 1
                22 |   } 
                23 |   
                24 | }



<details>
<summary> вывод команды  checkov </summary>


</details>

* 3. Перечислите, какие типы ошибок обнаружены в проекте (без дублей).


## Задание 2
* 1. Возьмите ваш GitHub-репозиторий с выполненным ДЗ 4 в ветке 'terraform-04' и сделайте из него ветку 'terraform-05'.



* 2. Повторите демонстрацию лекции: настройте YDB, S3 bucket, yandex service account, права доступа и мигрируйте state проекта в S3 с блокировками. Предоставьте скриншоты процесса в качестве ответа.


* 3. Закоммитьте в ветку 'terraform-05' все изменения.



* 4. Откройте в проекте terraform console, а в другом окне из этой же директории попробуйте запустить terraform apply.



* 5. Пришлите ответ об ошибке доступа к state.


 
* 6. Принудительно разблокируйте state. Пришлите команду и вывод.


## Задание 3
* 1. Сделайте в GitHub из ветки 'terraform-05' новую ветку 'terraform-hotfix'.



* 2. Проверье код с помощью tflint и checkov, исправьте все предупреждения и ошибки в 'terraform-hotfix', сделайте коммит.


* 3. Откройте новый pull request 'terraform-hotfix' --> 'terraform-05'.



* 4. Вставьте в комментарий PR результат анализа tflint и checkov, план изменений инфраструктуры из вывода команды terraform plan.


* 5. Пришлите ссылку на PR для ревью. Вливать код в 'terraform-05' не нужно.


## Задание 4
* 1. Напишите переменные с валидацией и протестируйте их, заполнив default верными и неверными значениями. 
Предоставьте скриншоты проверок из terraform console.


* 2. type=string, description="ip-адрес" — проверка, 
что значение переменной содержит верный IP-адрес с помощью функций cidrhost() или regex(). 
Тесты: "192.168.0.1" и "1920.1680.0.1";


* 3. type=list(string), description="список ip-адресов" — проверка, что все адреса верны. 
Тесты: ["192.168.0.1", "1.1.1.1", "127.0.0.1"] и ["192.168.0.1", "1.1.1.1", "1270.0.0.1"].

