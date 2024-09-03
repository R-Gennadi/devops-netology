// Create SA
resource "yandex_iam_service_account" "sa-bucket" {
  name = "sa-backet"
}

// Grant permissions
resource "yandex_resourcemanager_cloud_iam_member" "bucket-editor" {
  cloud_id = var.yandex_cloud_id  
  role = "storage.editor"
  member = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
  depends_on = [ yandex_iam_service_account.sa-bucket ]
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-kms-encrypter" {
  cloud_id = var.yandex_cloud_id  
  role = "kms.keys.encrypter"
  member = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
  depends_on = [ yandex_iam_service_account.sa-bucket ]
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-kms-decrypter" {
  cloud_id = var.yandex_cloud_id  
  role = "kms.keys.decrypter"
  member = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
  depends_on = [ yandex_iam_service_account.sa-bucket ]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
  description = "static access key for bucket"
}

// Create KMS Key
resource "yandex_kms_symmetric_key" "bo-key" {
  name = "my-entcryption-key"
  description = "Key for encrypting bucket objects"
  default_algorithm = "AES_256"
  rotation_period = "8760h"
}

// Use keys to create bucket with encryption
resource "yandex_storage_bucket" "netology-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "nikulinm-netology-bucket"
  acl = "public-read"
  anonymous_access_flags {
    read = true
    list = true
    config_read = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bo-key.id
        sse_algorithm = "aws:kms"
      }
    }
  }
}

// Add picture to bucket
resource "yandex_storage_object" "object-1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.netology-bucket.bucket
  key = "space_1.jpg"
  source = "space_1.jpg"
  acl = "public-read"
  # depends_on = [ yandex_storage_bucket.netology-bucket ]
}