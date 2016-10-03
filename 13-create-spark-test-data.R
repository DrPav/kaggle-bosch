#Create data with only 500 cols for spark test
#Removie quotes in writing out as original file does not have quotes
library(data.table)
files = list.files("data-raw")

for(file in files){
  filename = paste0("data-raw/", file)
  first_row = fread(filename, nrows = 1)  
  df = fread(filename, nrows = 500, na.strings = NULL,
             colClasses = rep("character", length(first_row)))
  new_filename = paste0("data-spark-test/", file)
  write.csv(df, new_filename, row.names = F, quote = FALSE)
}

# #Testing
# readLines("data-raw/train_categorical.csv", n = 2)
# readLines("data-spark-test/train_categorical.csv", n = 2)
# #Looks the same
# readLines("data-raw/train_numeric.csv", n = 2)
# readLines("data-spark-test/train_numeric.csv", n = 2)
# #Looks the same
# #PASS