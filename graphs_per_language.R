###################################################################################################
###### Author: Liese Schmidt 
###### Date: 18-05-2018      
###### READ-ME: Making plots of percentage of labels in treebank. For Dutch and English
###################################################################################################
rm(list=ls(all=T)) ## Clear all 
library(stringr)

###### folders
  folder_alpino <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-Alpino/"  # path to folder  
  folder_lassysmall <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_Dutch-LassySmall/"  # path to folder   
  folder_ewt <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-EWT/"  # path to folder   
  folder_pud <- "~/Dropbox/LTP/languageTechnologyProject/GeneratedData/UD_English-PUD/"  # path to folder   
  
##### Function to: read in all into one datafile.csv ####
  complete_treebank <- function(folder){
    file_list <- list.files(path=folder, pattern="*.csv") # create list of all .csv files in folder
    data_names<-str_sub(file_list, 1, str_length(file_list)-4) # create list of all .csv files without ".csv"
    # read in each .csv file in file_list and create a data frame with the same name as the .csv file
    for (i in 1:length(file_list)){
      assign(data_names[i],read.csv(paste(folder, file_list[i], sep=''),header=FALSE))
    }
    complete_treebank <- rbind(dev_test, dev_train, train_test ,train_train) 
    return(complete_treebank)
  }
  
### read all treebanks  
  complete_alpino <- complete_treebank(folder_alpino)
  complete_lassysmall <- complete_treebank(folder_lassysmall)
  complete_ewt <- complete_treebank(folder_ewt)
  complete_pud <- complete_treebank(folder_pud)
  
#### Function of information about a file, number of sentences/rows/columns ####
  info_data <- function(nameData) {
    n_sentences <- sum(nameData[,1]==1) # number of sentences
    n_rows <- nrow(nameData) # number of rows
    n_columns <- ncol(nameData) # number of column
    info_data <- c(n_sentences,n_rows,n_columns)
    return(info_data)
  }

#### Get info of all data in one table #####
  ## Get info for each data
  info_alpino <- info_data(complete_alpino)
  info_lassysmall <- info_data(complete_lassysmall)
  info_ewt <- info_data(complete_ewt)
  info_pud <- info_data(complete_pud)
  
  ## Make table with all info
  whichInfo<-c("sentences", "row", "column")
  info_all <- data.frame(whichInfo,info_alpino,info_lassysmall,info_ewt,info_pud) ## make table of info

  #Delete numbers prefixes  
  complete_alpino[,8]<-gsub("([0-9]+:)", "", complete_alpino[,8], perl=TRUE)
  complete_lassysmall[,8]<-gsub("([0-9]+:)", "", complete_lassysmall[,8], perl=TRUE)
  complete_ewt[,8]<-gsub("([0-9]+:)", "", complete_ewt[,8], perl=TRUE)
  complete_pud[,8]<-gsub("([0-9]+:)", "", complete_pud[,8], perl=TRUE)
  
#### Get UD_label table
  ## Get UD_labels for each data
  UD_alpino <- as.data.frame(table(complete_alpino[,8])) # column 8 are the UD-labels
  UD_lassysmall <- as.data.frame(table(complete_lassysmall[,8])) # column 8 are the UD-labels
  UD_ewt <- as.data.frame(table(complete_ewt[,8])) # column 8 are the UD-labels
  UD_pud <- as.data.frame(table(complete_pud[,8])) # column 8 are the UD-labels

  ## Delete empty label. Empty label means that this was a row with the whole sentence in the original
  UD_alpino<-subset(UD_alpino, Var1!="")
  UD_lassysmall<-subset(UD_lassysmall, Var1!="")
  UD_ewt<-subset(UD_ewt, Var1!="")
  UD_pud<-subset(UD_pud, Var1!="")

  ## Make table with all UD_labels, 0 if not excisted for Dutch
  UD_table_Dutch<-Reduce(function(x,y) merge(x, y, by = "Var1", all.x = TRUE, all.y = TRUE),
         list(UD_alpino,UD_lassysmall))
  colnames(UD_table_Dutch)<- c("label", "alpino","lassysmall")
  UD_table_Dutch[is.na(UD_table_Dutch)] <- 0 ## Replace NA with 0
  
  
  ## Make table with all UD_labels, 0 if not excisted for Dutch
  UD_table_English<-Reduce(function(x,y) merge(x, y, by = "Var1", all.x = TRUE, all.y = TRUE),
                         list(UD_ewt,UD_pud))
  colnames(UD_table_English)<- c("label", "ewt","pud")
  UD_table_English[is.na(UD_table_English)] <- 0 ## Replace NA with 0

#### Make percentage of UD_labels, for a balanced graph
  UD_table_Dutch$percentage_alpino<-prop.table(UD_table_Dutch$alpino)
  UD_table_Dutch$percentage_lassysmall<-prop.table(UD_table_Dutch$lassysmall)
  UD_table_English$percentage_ewt<-prop.table(UD_table_English$ewt)
  UD_table_English$percentage_pud<-prop.table(UD_table_English$pud)

#### DUTCH: Make graph of n datafiles 
  n = 2 ## number of datafiles
  combined_percentage <- rbind(UD_table_Dutch$percentage_alpino,UD_table_Dutch$percentage_lassysmall)
  barplot(combined_percentage,beside=T, main="Dutch",names.arg=UD_table_Dutch$label,las=2, col=rainbow(n))
  ## legend is to big
  legend("topleft", legend = c("alpino","lassysmall"), fill=rainbow(n), ncol = 1,cex = 0.8, bty="n")
  
  
#### ENGLISH: Make graph of n datafiles 
  n = 2 ## number of datafiles
  combined_percentage <- rbind(UD_table_English$percentage_ewt,UD_table_English$percentage_pud)
  barplot(combined_percentage,beside=T, main="Enghlish",names.arg=UD_table_English$label,las=2, col=rainbow(n))
  ## legend is to big
  legend("topleft", legend = c("ewt","pud"), fill=rainbow(n), ncol = 1,cex = 0.8, bty="n")