import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node PostgreSQL table
PostgreSQLtable_node1 = glueContext.create_dynamic_frame.from_catalog(
    database="glue_catalog_database_terraform",
    table_name="input_table_postgres_public_persons",
    transformation_ctx="PostgreSQLtable_node1",
)

# Script generated for node ApplyMapping
ApplyMapping_node2 = ApplyMapping.apply(
    frame=PostgreSQLtable_node1,
    mappings=[
        ("firstname", "string", "firstname", "string"),
        ("address", "string", "address", "string"),
        ("city", "string", "city", "string"),
        ("personid", "int", "personid", "int"),
        ("lastname", "string", "lastname", "string"),
    ],
    transformation_ctx="ApplyMapping_node2",
)

# Script generated for node S3 bucket
S3bucket_node3 = glueContext.write_dynamic_frame.from_options(
    frame=ApplyMapping_node2,
    connection_type="s3",
    format="glueparquet",
    connection_options={
        "path": "s3://sample-rds-glue-bucket/teraform/output/out_persons/",
        "partitionKeys": [],
    },
    format_options={"compression": "snappy"},
    transformation_ctx="S3bucket_node3",
)

job.commit()
