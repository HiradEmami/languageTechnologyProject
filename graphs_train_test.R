###################################################################################################
###### Author: Liese Schmidt 
###### Date: 18-05-2018      
###### READ-ME: This R file makes a graph of the percentage of each UD-label per data
######          There are some parts you have to change if you want to do this for other data
###################################################################################################
rm(list=ls(all=T)) ## Clear all 
library(stringr)

######
#folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-Alpino/"  # path to folder   
folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-LassySmall/"  # path to folder   
#folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-EWT/"  # path to folder   
#folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-PUD/"  # path to folder   

#titlegraph = "O ccurance per label in English-LinES" ## Put here the name of the treebank you used
titlegraph = folder


##### Read in all .csv ####
file_list <- list.files(path=folder, pattern="*.csv") # create list of all .csv files in folder
data_names<-str_sub(file_list, 1, str_length(file_list)-4) # create list of all .csv files without ".csv"

# read in each .csv file in file_list and create a data frame with the same name as the .csv file
for (i in 1:length(file_list)){
  assign(data_names[i],read.csv(paste(folder, file_list[i], sep=''),header=FALSE))
}

#### Function of information about a file, number of sentences/rows/columns ####
info_data <- function(nameData) {
  n_sentences <- sum(nameData[,1]==1) # number of sentences
  n_rows <- nrow(nameData) # number of rows
  n_columns <- ncol(nameData) # number of column
  info_data <- c(n_sentences,n_rows,n_columns)
  return(info_data)
}

# train --> dev_train & train_train
# test --> dev_test & train_test

train <- rbind(dev_train, train_train)
test <- rbind(dev_test, train_test)

## Get info for each data
info_train <- info_data(train)
info_test <- info_data(test)

## Make table with all info
whichInfo<-c("sentences", "row", "column")
info_all <- data.frame(whichInfo,info_train, info_test) ## make table of info

#Delete numbers prefixes  
train[,8]<-gsub("([0-9]+:)", "", train[,8], perl=TRUE)
test[,8]<-gsub("([0-9]+:)", "", test[,8], perl=TRUE)

#### Get UD_label table
## Get UD_labels for each data
UD_train <- as.data.frame(table(train[,8])) # column 8 are the UD-labels
UD_test <- as.data.frame(table(test[,8])) # column 8 are the UD-labels

## Delete empty label. Empty label means that this was a row with the whole sentence in the original
UD_train<-subset(UD_train, Var1!="")
UD_test<-subset(UD_test, Var1!="")




## Make table with all UD_labels, 0 if not excisted
UD_table<-Reduce(function(x,y) merge(x, y, by = "Var1", all.x = TRUE, all.y = TRUE),
                 list(UD_train,UD_test))
colnames(UD_table)<- c("label","train","test")
UD_table[is.na(UD_table)] <- 0 ## Replace NA with 0

#### Make percentage of UD_labels, for a balanced graph
UD_table$percentage_train<-prop.table(UD_table$train)
UD_table$percentage_test<-prop.table(UD_table$test)

UD_table$percentage_train <- UD_table$percentage_train * 100
UD_table$percentage_test <- UD_table$percentage_test * 100

#### Make graph of n datafiles
n = 2 ## number of datafiles
combined_percentage <- rbind(UD_table$percentage_train,UD_table$percentage_test)
#barplot(combined_percentage,beside=T, main=titlegraph,names.arg=UD_table$label,las=2, col=rainbow(n), ylab="percentage")
barplot(combined_percentage,beside=T, main="LassySmall Treebank",names.arg=UD_table$label,las=2, col=rainbow(n), ylim=c(0,16), ylab="percentage")
## legend is to big
legend("topleft", legend = c("train","test"), fill=rainbow(n), ncol = 1,cex = 0.8, bty="n")

max(max(combined_percentage[1,]),max(combined_percentage[2,]))
