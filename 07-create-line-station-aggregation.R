#Create the station.line aggregation on entire dataset
#Transform data to be logical if was on production line and station
library(data.table)
library(dplyr)
library(tidyr)

chunk_size = 10e3
num_rows = 1183747 #Determined form exploration analysis
filename = "data-raw/train_date.csv"
headers = colnames(fread(filename, nrows= 0) )
chunks = seq(1, num_rows, by = chunk_size)
i = 1
for(chunk in chunks){
  x_dates = fread(filename, header = F, nrows = chunk_size, skip = chunk, 
                  col.names = headers ) %>% 
  gather(feature, value, L0_S0_D1:L3_S51_D4263)

  x_dates$line.station = substr(x_dates$feature, 1, 6)
  x_dates$value = x_dates$value = x_dates$value = x_dates$value + 1
  x_dates$value[is.na(x_dates$value)] = 0
  x_dates$value[x_dates$value != 0] = 1
  x_dates = x_dates %>% 
    group_by(Id, line.station) %>% 
    summarise(value = sum(value))
  x_dates$value[x_dates$value > 0] = 1
  x_dates = spread(x_dates, line.station, value, fill = 0)
  
  file_output = paste0("data-transformed/temp/line-station-agg-", i, ".csv")
  write.csv(x_dates, file_output, row.names = FALSE)
  i = i+ 1
  rm(x_dates)
  gc()
}
number_of_files = i - 1

#Now read in each and save as a single file
all_data = data.table()
for(i in 1:number_of_files){
  filename = paste0("data-transformed/temp/line-station-agg-", i, ".csv")
  x = fread(filename)
  all_data = rbind(all_data, x)
}

write.csv(all_data, "data-transformed/train_line-station-agg.csv")
rm(all_data, x)
gc()

#REPEAT FOR TEST DATA
#==========================
#==========================
temp = fread("data-raw/test_date.csv", select = c("Id"))
chunk_size = 10e3
num_rows = length(temp$Id) 
rm(temp)
filename = "data-raw/test_date.csv"
headers = colnames(fread(filename, nrows= 0) )
chunks = seq(1, num_rows, by = chunk_size)
i = 1
for(chunk in chunks){
  x_dates = fread(filename, header = F, nrows = chunk_size, skip = chunk, 
                  col.names = headers ) %>% 
    gather(feature, value, L0_S0_D1:L3_S51_D4263)
  
  x_dates$line.station = substr(x_dates$feature, 1, 6)
  x_dates$value = x_dates$value = x_dates$value = x_dates$value + 1
  x_dates$value[is.na(x_dates$value)] = 0
  x_dates$value[x_dates$value != 0] = 1
  x_dates = x_dates %>% 
    group_by(Id, line.station) %>% 
    summarise(value = sum(value))
  x_dates$value[x_dates$value > 0] = 1
  x_dates = spread(x_dates, line.station, value, fill = 0)
  
  file_output = paste0("data-transformed/temp/test-line-station-agg-", i, ".csv")
  write.csv(x_dates, file_output, row.names = FALSE)
  i = i+ 1
  rm(x_dates)
  gc()
}
number_of_files = i - 1

#Now read in each and save as a single file
all_data = data.table()
for(i in 1:number_of_files){
  filename = paste0("data-transformed/temp/test-line-station-agg-", i, ".csv")
  x = fread(filename)
  all_data = rbind(all_data, x)
}

write.csv(all_data, "data-transformed/test_line-station-agg.csv")  