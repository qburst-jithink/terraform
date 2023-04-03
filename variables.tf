# Role permissions
variable "aws-glue-role" {
   default = "arn:aws:iam::789733903478:role/service-role/AWSGlueServiceRole"
}

# s3 configurations
variable "script-location" {
  default = "s3://sample-rds-glue-bucket/teraform/scripts/postgres_to_s3_parquet.py"
}

variable "tempdir" {
  default = "s3://sample-rds-glue-bucket/teraform/tempdir/"
}

variable "spark-logs" {
  default = "s3://sample-rds-glue-bucket/teraform/logs/"
}


# Names for components
# glue datasource connection name
variable "glue-connection-name" {
  default = "glue_postgres_connection_terraform"
}
# glue catalog database 
variable "glue-catalog-db-name" {
  default = "glue_catalog_database_terraform"
}
# glue crawler
variable "glue-crawler-name" {
  default = "glue_crawler_postgres_terraform"
}
# glue job
variable "glue-job-name" {
  default = "glue_job_terraform"
}


# RDS Secrets name
variable "rds-secret-name" {
  default = "glue-postgres-rds-creds"
}