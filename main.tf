terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Authenitaction happens here
provider "aws" {
    region = "eu-north-1"
    access_key = "****"
    secret_key = "**************"
}


#####Resource block#####
#Creating glue connection for a postgres database
resource "aws_glue_connection" "glue_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["host"]}:5432/postgres"
    PASSWORD            = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["password"]
    USERNAME            = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["username"]
  }

  name = var.glue-connection-name

  physical_connection_requirements {
    availability_zone      = "eu-north-1a"
    security_group_id_list = ["sg-0bb777573b4c44864"]
    subnet_id              = "subnet-04c0c3337404ca35a"
  }
}

#Creating glue catalog database to store parsed tables of the data source
resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = var.glue-catalog-db-name
}

#Creating glue crawler to crawl the data source for schemas/tables
resource "aws_glue_crawler" "glue_crawler_postgres" {
  database_name = aws_glue_catalog_database.glue_catalog_database.name
  name          = var.glue-crawler-name
  role          = var.aws-glue-role
  table_prefix = "input_table_"
  jdbc_target {
    connection_name = aws_glue_connection.glue_connection.name
    path            = "postgres/public/persons"
  }
}

#Creating glue job to run ETL job over a datasource
resource "aws_glue_job" "glue_job" {
  name     = var.glue-job-name 
  role_arn = var.aws-glue-role
  glue_version = "3.0"

  command {
    script_location = var.script-location
    python_version = "3"
  }

  default_arguments = {
    "--job-language" = "python"
    "--enable-glue-datacatalog" = "true"
    "--TempDir" = var.tempdir
    "--spark-event-logs-path" = var.spark-logs
    "--enable-metrics" = "true"
    "--enable-job-insights" = "true"
    "--enable-spark-ui" = "true"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--enable-continuous-cloudwatch-log" = "true"
  }  

  connections = [aws_glue_connection.glue_connection.name]
}


#####data block#####
#Retrieve secrets for database credentials
data "aws_secretsmanager_secret" "secret-name" {
  name = var.rds-secret-name
}
data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.secret-name.id
}
