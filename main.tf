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
#We can directly assign string values for access and secret keys or we can 
#store keys with a variable file (creds.tf)
    access_key = element(var.creds,0) #replace >> element(var.creds,0) with access key
    secret_key = element(var.creds,1) #replace >> element(var.creds,1) with secret key
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
    availability_zone      = data.aws_db_instance.rds.availability_zone
    security_group_id_list = data.aws_db_instance.rds.vpc_security_groups
    subnet_id              = element(tolist(data.aws_db_subnet_group.db-subnet-group.subnet_ids),0)
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

#Retrieve RDS instance 
data "aws_db_instance" "rds" {
  db_instance_identifier = var.rds-instance
}
data "aws_db_subnet_group" "db-subnet-group" {
  name = data.aws_db_instance.rds.db_subnet_group
}
