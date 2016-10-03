#Transform categorical into Binary
#Drop columns that have no variation
library(data.table)
library(dplyr)
df_cat = fread("data-transformed/categorical_noNA.csv", stringsAsFactors = T)
ids = df_cat$Id
df_cat = df_cat %>% select(-Id)
cols = colnames(df_cat)

new_df = data.frame(Id = ids)
i = 1
transformCat <- function(x){
  #Function to apply to each column
  l = levels(factor(x))
  if(length(l) != 1){
    for(level in l){
      new_col = paste0(cols[i], "_", level)
      new_col = make.names(new_col) #Transforms illegal col names
      new_df[, new_col] <<- 0
      new_df[x == level, new_col] <<- 1
    }
  }
  i <<- i + 1
  return(NA)
}

apply(df_cat, 2, transformCat)
rm(df_cat)

write.csv(new_df, "data-transformed/categorical_noNA_binary.csv", row.names = F)