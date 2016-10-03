from pyspark.sql import SparkSession, Row
from pyspark.sql.types import StringType, IntegerType, FloatType, StructField, StructType

spark = SparkSession.builder \
           .master('local[2]') \
           .appName('My App') \
           .config('spark.sql.warehouse.dir', 'file:///C:/tmp/spark-warehouse') \
           .getOrCreate()
           
def makeSchema(filename, sparkType):
    #http://stackoverflow.com/questions/1904394/read-the-first-line-of-a-file-using-python
    with open(filename, 'r') as f:
        first_line = f.readline().strip()
        headers = first_line.split(",")
        
    for i in range(0, len(headers)):
        headers[i] = headers[i].strip('"')
        
    csv_struct = StructType([StructField("Id", IntegerType(), False)])
    for col_name in headers:
        if (col_name != "Id"):
            csv_struct = csv_struct.add(col_name, sparkType(), True)
    return csv_struct
    
def getTimeData(row):
    id = row.Id
    d = row.asDict() # since Row is read only
    del d['Id']

    m = float("inf")
    for key in d:
        if d[key] != -1:
            if d[key] < m:
                m = d[key]
    min = m
    
    m = float("-inf")
    for key in d:
        if d[key] !=  -1:
            if d[key] > m:
                m = d[key]
    max = m
    
    return Row(Id = id, date_min = min, date_max = max, date_duration = round(max-min, 3) )
   

#Create the schemas
#Read the header line in pandas and loop through the columns except "Id"
#True false indicates if it can be NULL
file_train_numeric = "data-spark-test/train_numeric.csv"
file_train_categorical = "data-spark-test/train_categorical.csv"
file_train_date = "data-spark-test/train_date.csv"

train_num = spark.read.csv(file_train_numeric, header = True, schema = makeSchema(file_train_numeric, FloatType )).na.fill(-99)
train_cat = spark.read.csv(file_train_categorical, header = True, schema = makeSchema(file_train_categorical, StringType)).replace("","X")
train_date = spark.read.csv(file_train_date, header = True, schema = makeSchema(file_train_date, FloatType )).na.fill(-1)
response = train_num.select('Id', train_num.Response.cast("integer"))
train_num = train_num.drop("Response")
   
date_features_rdd = train_date.rdd.map(getTimeData)
date_features = spark.createDataFrame(date_features_rdd)


#Show first few rows and columns of each
train_cat[train_cat.columns[1:8]].show()
train_num[train_num.columns[1:8]].show()
train_date[train_date.columns[1:8]].show()
date_features.show()
response.show()











