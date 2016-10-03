#Transform data to be logical if was on production line and station
library(data.table)
library(dplyr)
library(tidyr)

transformBinary <- function(x){
  #Take a vector and return 0 if its value is NA or return 1 otherwise
  x[is.na(x)] = 0
  x[x!=0] = 1
  return(as.integer(x))
}
df = fread("data-sampled/train_date.csv") %>% 
  gather(feature, value, L0_S0_D1:L3_S51_D4263)

x_dates = df
# #Check there are no negative values or zeros
# min(x_dates$value, na.rm = T) > 0
#PASS
# #Check the length of the station number does not go above 99
# stations = strsplit(x = unique(x_dates$feature),split = "_", fixed = T) %>% lapply(function(x) x[[2]]) %>% as.character()
# max(nchar(stations)) == 3
# #PASS

x_dates$line.station = substr(x_dates$feature, 1, 6)
x_dates$value = transformBinary(x_dates$value)
x_dates = x_dates %>% 
  group_by(Id, line.station) %>% 
  summarise(value = sum(value))
x_dates$value = transformBinary(x_dates$value)
x_dates = spread(x_dates, line.station, value, fill = 0)

#How many unique
u = x_dates[, 2:53] %>% unique()
length(u$L0_S0_)
#2353
#So there are 2.5k processes in this data set of 71l objects
means = apply(x_dates[, 2:53], 2, mean)
means = data.frame(line.station = as.character(names(means)), pct.used = means)
library(ggplot2)
ggplot(means, aes(x=line.station, y=pct.used)) +
  geom_bar(stat='identity') +
  coord_flip() + labs(title = "Usage of stations (52) from train Dates")

#Add on Response for exporting
y = fread("data-sampled/train_numeric.csv", select=c("Id", "Response"))

write.csv(left_join(x_dates, y), "data-transformed/05-for-bayes-sample.csv", row.names = F)
rm(x_dates, u, y)
gc()

#Do the same for numeric train data
#========================================
df = fread("data-sampled/train_numeric.csv") %>% 
  gather(feature, value, L0_S0_F0:L3_S51_F4262)

x_numeric = df
# #Check there are no negative values or zeros
# min(x_numeric$value, na.rm = T) > 0
#FAIL (the minimum is -1)
# #Check the length of the station number does not go above 99
# stations = strsplit(x = unique(x_numeric$feature),split = "_", fixed = T) %>% lapply(function(x) x[[2]]) %>% as.character()
# max(nchar(stations)) == 3
# #PASS

x_numeric$line.station = substr(x_numeric$feature, 1, 6)
x_numeric$value = x_numeric$value + 2 #make all above zero so transformBinarry works correctly
x_numeric$value = transformBinary(x_numeric$value)
x_numeric = x_numeric %>% 
  group_by(Id, line.station) %>% 
  summarise(value = sum(value))
x_numeric$value = transformBinary(x_numeric$value)
x_numeric = spread(x_numeric, line.station, value, fill = 0)

#How many unique
u = x_numeric[, 2:51] %>% unique()
length(u$L0_S0_)
#2351 # One less than in the dates df
#So there are 2.5k processes in this data set of 71k objects
means_numeric = apply(x_numeric[, 2:51], 2, mean)
means_numeric = data.frame(line.station = as.character(names(means_numeric)), 
                           pct.used = means_numeric)
require(ggplot2)
ggplot(means_numeric, aes(x=line.station, y=pct.used)) +
  geom_bar(stat='identity') +
  coord_flip() + labs(title = "Usage of stations (51) from train Numeric")

#write.csv(x_numeric, "data-transformed/05-for-bayes-sample.csv", row.names = F)
rm(df, x_numeric, u)
gc() # Garbage collector

#Do the same for categorical train data
#========================================

x_cat = fread("data-sampled/train_categorical.csv")
id = x_cat$Id
x_cat = x_cat[, 2:2141, with = F] #Remove col 1 = Id

transformCat <- function(x){
  x[x!= ""] = "1"
  x[x == ""] = "0"
  x = as.integer(x)
  x = as.logical(x)
  return(x)
}
x_cat = apply(x_cat, 2, transformCat)
x_cat = data.table(Id = id, x_cat)
x_cat = gather(x_cat, feature, value, L0_S1_F25:L3_S49_F4240)



#There are more columns for categorical data frame
#All were imported as character


# #Check the length of the station number does not go above 99
# stations = strsplit(x = unique(x_cat$feature),split = "_", fixed = T) %>% lapply(function(x) x[[2]]) %>% as.character()
# max(nchar(stations)) == 3
# #PASS

x_cat$line.station = substr(x_cat$feature, 1, 6)
x_cat$feature <- NULL # save memory
x_cat$line.station = factor(x_cat$line.station) #save memory


x_cat = x_cat %>% 
  group_by(Id, line.station) %>% 
  summarise(value = sum(value))
x_cat$value = transformBinary(x_cat$value)
x_cat = spread(x_cat, line.station, value, fill = 0)

#How many unique
u = x_cat[, 2:35] %>% unique()
length(u$L0_S1_)
#121
#So there are 121 processes in this data set of 71k objects
means_cat = apply(x_cat[, 2:34], 2, mean)
means_cat = data.frame(line.station = as.character(names(means_cat)), pct.used = means_cat)
require(ggplot2)
ggplot(means_cat, aes(x=line.station, y=pct.used)) +
  geom_bar(stat='identity') +
  coord_flip() + labs(title = "Usage of stations (33) from train Categorical")

#write.csv(x_cat, "data-transformed/05-for-bayes-sample.csv", row.names = F)
rm(x_cat, u)
