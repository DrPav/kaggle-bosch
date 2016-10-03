#09 Transform NA values
#For numeric put the NA as -99
#For categorical set as factors
#For dates set as -1
#Load the datasets
library(data.table)
library(dplyr)

df_num = fread("data-sampled/train_numeric.csv")
response = df_num %>% select(Id, Response)

write.csv(response, "data-transformed/response.csv",row.names = F)

df_num %>% select(-Response) %>% 
  apply(MARGIN = 2, FUN = function(x) {
    x[is.na(x)] = -99
    return(x)
  }) %>% as.data.frame() %>% 
  write.csv("data-transformed/numeric_noNA.csv", row.names = F)

rm(df_num, response)
#===================================================================

df_cat = fread("data-sampled/train_categorical.csv") 
ids = df_cat %>% select(Id)
df_cat = df_cat %>%
  select(-Id) %>% 
  apply(MARGIN = 2, FUN = function(x){
    x[x == "" ] = "N"
    return(x)
  }) %>% as.data.frame() %>%  cbind(ids) %>%
write.csv("data-transformed/categorical_noNA.csv", row.names = F)

rm(df_cat, cols)
#=============================================================

df_date = fread("data-sampled/train_date.csv") %>% 
  apply(MARGIN = 2, FUN = function(x) {
    x[is.na(x)] = -1
    return(x)
  }) %>% as.data.frame() %>% 
  write.csv("data-transformed/date_noNA.csv", row.names = F)


