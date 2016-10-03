#12 plot importances
library(dplyr)
library(ggplot2)
df = read.csv("11-importances-output.csv") 
p = ggplot(df, aes(x = reorder(var, importance), y = importance)) + geom_bar(stat = "identity")
p + coord_flip()

#filter to importance >0
df2 = df %>% filter(importance > 0)
p = ggplot(df2, aes(x = reorder(var, importance), y = importance)) + geom_bar(stat = "identity")
p + coord_flip()

#Look at top 50
df2 = df2 %>% arrange(desc(importance))
df2[1:100,]

hist(df$importance, breaks = 50)

#How many have importance above 0.0002
df2[df2$importance > 0.0002, "importance"] %>% length()
#922
#How many have importance above 0.0003
df2[df2$importance > 0.0003, "importance"] %>% length()
#744
#How many have importance above 0.0004
df2[df2$importance > 0.0004, "importance"] %>% length()
#628
df2$var[1:1000] %>% as.character()

#Aggregate up to the Line and station
df$line.station = substr(df$var, 1, 6)

agg = df %>% group_by(line.station) %>% summarise(importance = sum(importance))
p = ggplot(agg, aes(x = reorder(line.station, importance), y = importance)) + geom_bar(stat = "identity")
p + coord_flip()