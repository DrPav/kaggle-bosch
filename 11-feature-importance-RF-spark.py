from pyspark.sql import SparkSession
from pyspark.sql.types import StringType, IntegerType, FloatType, StructField, StructType

spark = SparkSession.builder \
           .master('local[2]') \
           .appName('My App') \
           .config('spark.sql.warehouse.dir', 'file:///C:/tmp/spark-warehouse') \
           .getOrCreate()
           
df = spark.read.csv("data-transformed/sampled-data-joined.csv", header = True)

import sys
orig_stdout = sys.stdout
fs = open('spark output.txt', 'w')
sys.stdout = fs

df.show()

sys.stdout = orig_stdout
fs.close()