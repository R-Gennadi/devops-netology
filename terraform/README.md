#исключения для terraform
# Начиная с OS MSdos символ (*) соответствует 0 или более символам 
#локальный каталог
**/.terraform/*


# лог
crash.log
crash.*.log


# файлы         
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc


# при необходимости включить коммит для файлов
# !example_override.tf

# и так же при использовании команды: terraform plan -out=tfplan
# example: *tfplan*

