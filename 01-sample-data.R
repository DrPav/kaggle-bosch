#Sample each dataset
library(data.table)


#Check the Ids are in the same in each dataset
# date = fread("data-raw/train_date.csv", nrows= -1, select = (c("Id")) )
# date_cols = colnames(fread("data-raw/train_date.csv", nrows= 0) )
# 
# categorical = fread("data-raw/train_categorical.csv", nrows= -1, select = (c("Id")) )
# categorical_cols = colnames(fread("data-raw/train_categorical.csv", nrows= 0) )
# 
# numeric = fread("data-raw/train_numeric.csv", nrows= -1, select = (c("Id")) )
# numeric_cols = colnames(fread("data-raw/train_numeric.csv", nrows= 0))
# 
# sum(date$Id != categorical$id) #0
# sum(date$Id != numeric$id) #0
# sum(numeric$Id != categorical$id) #0
# #PASS Ids are same accross the datasets
# 
# #Find the respose colum
# cols = fread("data-raw/train_date.csv", nrows= 0)
# 
# grep("Response", categorical_cols)
# grep("Response", date_cols)
# grep("Response", numeric_cols) # the response is in here column 970
# grep("Response", numeric_cols, value = T) #Called "Response"
# #In numeric and called Response

#Load ids and response 
numeric = fread("data-raw/train_numeric.csv", select = (c("Id", "Response")) )

# mean(numeric$Response) # 0.0058 VERY UNBALANCED PROBLEM
# length(numeric_cols) + length(categorical_cols) + length(date_cols) # 4268 raw features
# length(date$Id) #1,183,747 observations

library(caret)
set.seed(2478)
sampleIndex <- createDataPartition(numeric$Response, p = .06,
                                    list = FALSE,
                                    times = 1)
# #New length of data is (p=0.05)
# length(sampleIndex) #59k
# #Number of positive responses
# sum(numeric$Response[sampleIndex]) #343

sampleIds = numeric$Id[sampleIndex]
num_rows = length(numeric$Id)
rm(numeric)

#Load data in batches and filter only the sample
readSampleData <- function(filename, sampleIds, chunk_size){
  chunks = seq(1, num_rows, by = chunk_size)
  headers = colnames(fread(filename, nrows= 0) )
  sampleData = data.frame()
  for(chunk in chunks){
    a = fread(filename, header = F, nrows = chunk_size, skip = chunk, col.names = headers )
    a = a[(a$Id %in% sampleIds), ]
    sampleData = rbind(sampleData, a)
  }
  return(sampleData)
}

#write each to new folder
for(data_type in c("numeric", "date")){
  filename = paste0("data-raw/train_", data_type, ".csv")
  sampleData = readSampleData(filename, sampleIds, 50e3)
  outfile = paste0("data-sampled/train_", data_type, ".csv")
  write.csv(sampleData, outfile, row.names = F)
}

#Handle categorical seperatly as there are issues with reading T as logical instead of categorical
#Try reading every row as a character
readCatSampleData <- function(filename, sampleIds, chunk_size){
  chunks = seq(1, num_rows, by = chunk_size)
  headers = colnames(fread(filename, nrows= 0) )
  sampleData = data.frame()
  for(chunk in chunks){
    a = fread(filename, header = F, nrows = chunk_size, skip = chunk, col.names = headers,
              colClasses = rep("character", times = length(headers)))
    a$Id = as.numeric(a$Id)
    a = a[(a$Id %in% sampleIds), ]
    sampleData = rbind(sampleData, a)
  }
  
  return(sampleData)
}

#Sample the categorical data
filename = "data-raw/train_categorical.csv"
sampleData = readCatSampleData(filename, sampleIds, 50e3)
outfile = "data-sampled/train_categorical.csv"
write.csv(sampleData, outfile, row.names = F)


#Sample to the TEST DATA
#==============================
#Load ids and response 
numeric = fread("data-raw/test_numeric.csv", select = (c("Id")) )
library(caret)
sampleIds = numeric$Id[runif(length(numeric$Id)) < 0.1] #Take 10 percent
num_rows = length(numeric$Id)
rm(numeric)


for(data_type in c("numeric", "date")){
  filename = paste0("data-raw/test_", data_type, ".csv")
  sampleData = readSampleData(filename, sampleIds, 50e3)
  outfile = paste0("data-sampled/test_", data_type, ".csv")
  write.csv(sampleData, outfile, row.names = F)
}

rm(sampleData)
gc()

filename = "data-raw/test_categorical.csv"
sampleData = readCatSampleData(filename, sampleIds, 50e3)
outfile = "data-sampled/test_categorical.csv"
write.csv(sampleData, outfile, row.names = F)