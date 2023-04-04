# aws-terraform-glue


## Steps

### Intall terraform in local environment
Exapmle guide link (Ubuntu) : https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli


### Clone the git repo and navigate into the repo
```git clone https://github.com/qburst-jithink/terraform.git```


If you are using the repository for the first time, then please start with terraform init in project root directory:

```terraform init```

### Replace access keys and secret keys with your own keys

### To check what changes the script can apply to your aws environment:

```terraform plan```

### To create the planned resources:

```terraform apply```

### To destroy all the created resources:

```terraform destroy```


### Running ETL over datasource
Once essential components(glue datasource connection, catlog database, crawler, glue job)
are created run the crawler to detect schema/table and then once completed start the glue job.

### End result
Transformed file can be found at the s3 location specified in the ETL script.

