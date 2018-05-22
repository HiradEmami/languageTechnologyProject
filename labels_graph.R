###################################################################################################
###### Author: Liese Schmidt 
###### Date: 18-05-2018      
###### READ-ME: This R file makes a graph of the percentage of each UD-label per data
######          There are some parts you have to change if you want to do this for other data
###################################################################################################
#rm(list=ls(all=T)) ## Clear all 
library(stringr)

######
  #folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-Alpino/"  # path to folder   
  #folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-LassySmall/"  # path to folder   
  #folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-EWT/"  # path to folder   
  folder <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-PUD/"  # path to folder   

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

#### Get info of all data in one table #####
  # data_names # Which datanames do we have?

  ## Get info for each data
  info_dev_train <- info_data(dev_train)
  info_dev_test <- info_data(dev_test)
  info_train_test <- info_data(train_test)
  info_train_train <- info_data(train_train)
  
  ## Make table with all info
  whichInfo<-c("sentences", "row", "column")
  info_all <- data.frame(whichInfo,info_dev_test,info_dev_train, info_train_test,info_train_train) ## make table of info

  #Delete numbers prefixes  
  dev_test[,8]<-gsub("([0-9]+:)", "", dev_test[,8], perl=TRUE)
  dev_train[,8]<-gsub("([0-9]+:)", "", dev_train[,8], perl=TRUE)
  train_test[,8]<-gsub("([0-9]+:)", "", train_test[,8], perl=TRUE)
  train_train[,8]<-gsub("([0-9]+:)", "", train_train[,8], perl=TRUE)
  
  

#### Get UD_label table
  ## Get UD_labels for each data
  UD_dev_test <- as.data.frame(table(dev_test[,8])) # column 8 are the UD-labels
  UD_dev_train <- as.data.frame(table(dev_train[,8])) # column 8 are the UD-labels
  UD_train_test <- as.data.frame(table(train_test[,8])) # column 8 are the UD-labels
  UD_train_train <- as.data.frame(table(train_train[,8])) # column 8 are the UD-labels
  
  ## Delete empty label. Empty label means that this was a row with the whole sentence in the original
  UD_dev_test<-subset(UD_dev_test, Var1!="")
  UD_dev_train<-subset(UD_dev_train, Var1!="")
  UD_train_test<-subset(UD_train_test, Var1!="")
  UD_train_train<-subset(UD_train_train, Var1!="")
  
  
  
  
  ## Make table with all UD_labels, 0 if not excisted
  UD_table<-Reduce(function(x,y) merge(x, y, by = "Var1", all.x = TRUE, all.y = TRUE),
         list(UD_dev_test,UD_dev_train,UD_train_test,UD_train_train))
  colnames(UD_table)<- c("label", "dev_test","dev_train","train_test","train_train")
  UD_table[is.na(UD_table)] <- 0 ## Replace NA with 0

#### Make percentage of UD_labels, for a balanced graph
  UD_table$percentage_dev_test<-prop.table(UD_table$dev_test)
  UD_table$percentage_dev_train<-prop.table(UD_table$dev_train)
  UD_table$percentage_train_test<-prop.table(UD_table$train_test)
  UD_table$percentage_train_train<-prop.table(UD_table$train_train)

#### Make graph of n datafiles
  n = 4 ## number of datafiles
  combined_percentage <- rbind(UD_table$percentage_dev_test,UD_table$percentage_dev_train,UD_table$percentage_train_test,UD_table$percentage_train_train)
  barplot(combined_percentage,beside=T, main=titlegraph,names.arg=UD_table$label,las=2, col=rainbow(n))
  ## legend is to big
  #legend("topright", legend = c("dev_test","dev_train","train_test","train_train"), fill=rainbow(n), ncol = 1,cex = 0.9)