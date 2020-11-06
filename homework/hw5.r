library(dplyr)
library(gbm)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(ggfortify)
library(factoextra)

nice_names <- function(df){
  names(df) <- names(df) %>% str_replace_all("[^a-zA-Z0-9]+","_") %>%
    str_replace_all("[_]+$","") %>%
    str_replace_all("^[_]+","") %>%
    tolower();
  df
};

info <- timetk::tk_tbl(data.table::fread("500_Person_Gender_Height_Weight_Index.csv", header=T, stringsAsFactors=T)) %>%
  drop_na() %>% 
  nice_names() %>%
  mutate(female=gender=='Female',train=runif(nrow(.))<0.75) %>%
  filter(height > 0 & weight > 0);

form <- female ~ height +
  weight +
  I(height^2) +
  I(weight^2) +
  height:weight;

model.gbm <- gbm(form,
                 distribution="bernoulli",
                 info %>% filter(train),
                 n.trees = 200,
                 interaction.depth = 5,
                 shrinkage=0.1);
summary(model.gbm,plot=FALSE)

test <- info %>% filter(!train);
test$female.p.gbm <- predict(model.gbm, test, type="response");
p1 <- ggplot(test, aes(female.p.gbm)) + geom_density()

info1 <- timetk::tk_tbl(data.table::fread("datasets_26073_33239_weight-height.csv", header=T, stringsAsFactors=T)) %>%
  drop_na() %>% 
  nice_names() %>%
  mutate(female=gender=='Female',train=runif(nrow(.))<0.75) %>%
  filter(height > 0 & weight > 0);

model.gbm1 <- gbm(female ~ height +
                   weight +
                   I(height^2) +
                   I(weight^2) +
                   height:weight,
                 distribution="bernoulli",
                 info1 %>% filter(train),
                 n.trees = 200,
                 interaction.depth = 5,
                 shrinkage=0.1);
summary(model.gbm1,plot=FALSE)

test1 <- info1 %>% filter(!train);
test1$female.p.gbm <- predict(model.gbm1, test1, type="response");
p2 <- ggplot(test1, aes(female.p.gbm)) + geom_density()

grid.arrange(p1, p2, ncol=2)

c(sum((test$female.p.gbm>0.5)==test$female)/nrow(test),
  sum(FALSE==test$female)/nrow(test),
  sum((test1$female.p.gbm>0.5)==test1$female)/nrow(test1),
  sum(FALSE==test1$female)/nrow(test1));



info2 <- timetk::tk_tbl(data.table::fread("datasets_38396_60978_charcters_stats.csv", header=T, stringsAsFactors=T)) %>%
  drop_na() %>% 
  nice_names() %>%
  mutate(train=runif(nrow(.))<0.75) 

#we can see that there are some irregularities with a total of 5, and we remove them 
info2

info2 <- info2 %>% filter(total > 5)

#PCA
#seems we only needs pc1
pcs <- prcomp(info2[,3:9]);
summary(pcs);

#I think not. The features are already in Percentile. 
#Some of them are out of limitation but I think it is still in the scale.
#Use durability as an example
data.frame(min=sapply(info2[,3:9],min),max=sapply(info2[,3:9],max))
top5 <- info2 %>% top_n(5,durability)
top5[with(top5, order(-durability)), ]

#create a new column like total and write the result of comparison in compare
#show the top 5 of compare and it seems they are equal (no value 1)
sum <- transform(info2, sum=rowSums(info2[,c(3,4,5,6,7,8)]))
sum$compare <- ifelse(sum$total == sum$sum, 0, 1)
sum %>% top_n(5,compare)

#no
#if we check the pca of the data, 
#we can see that PC1 take accounts for most of PC1 which has most importance
#which means "total" is the principle component of the data, and make other features useless
pcs1 <- prcomp(info2[,3:8]);
summary(pcs1)
pcs
pcs1

#I don't know why I can't use the code in lecture 10 so I use another
pca.plot <- autoplot(pcs, data = info2, colour = 'alignment')

#plot the distance
lowd <- timetk::tk_tbl(data.table::fread("lowd.csv"))
(ggplot(lowd,aes(X1,X2)) + geom_point(aes(color=factor(Alignment))))


#Q5
#I hope this code can work. I cannot run it because I cannot install caret.
#I have spend 10 hours setting the environment today and another 10 hours yesterday.
#Now it is 10 PM and after breakfast I have nothing.
#I cannot spend another 10 hours on it.
library(caret);

trainIndex <- createDataPartition(info$female, p = .8, 
                                  list = FALSE, 
                                  times = 1)

info$female <- factor(info$female);

train_ctrl <- trainControl(method = "repeatedcv",number=50,repeats=5);
gbmFit1 <- train(form, data = info %>% slice(trainIndex), 
                 method = "gbm", 
                 trControl = train_ctrl,
                 verbose = FALSE)
summary(gbmFit1);

rmarkdown::render('HW5.Rmd', output_format='pdf_document')
