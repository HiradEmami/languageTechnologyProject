#------------------------------------
__author__ ='Hirad Emami Alagha'
#------------------------------------

#required libs
import numpy as np
import os
import random as rd
import math as math
import sys

############################################
#               Global Parameters          #
############################################

PRIMARY_DIRECTORY = 'Treebanks'
PRIMARY_OUTPUT_DIRECTORY = 'GeneratedData'
TREEBANK_TO_IMPORT = sys.argv[1]
TEST_PERCENTAGE = 0.1




#function for importing the UD file and reading the sentences
def read_file(argFile):
    # reading all the lines in the file
    lines = argFile.readlines()
    # Creating an empty list for the sentences and their infos
    sentences = []
    # Counter for the number of sentences
    num_sentences = count_sentences(argLines=lines)
    #creating the sentence list
    first_sentence = True
    count=0
    for i in lines:
        if i.startswith("# sent_id"):
            count += 1
            if not first_sentence:
                sentences.append(sentence_info)
            else:
                first_sentence = False
            sentence_info = []
            sentence_info.append(i)
        else:
            sentence_info.append(i)
    #appending the last sentence
    sentences.append(sentence_info)

    return sentences,num_sentences


################################
#   Counting Sentences in the file #
################################
def count_sentences(argLines):
    num_sentences = 0
    for i in argLines:
        # The marker of the sentence starts with # sent_id
        if i.startswith("# sent_id "):
            num_sentences += 1
    return num_sentences


####################################
#   Validating the sentence lists   #
####################################
def validate(developer_sentences,train_sentences,num_sentence_1,num_sentence_2):
    accepted_developer = False
    accepted_train = False
    #validating developer sentences
    developer_first_id = int(find_sentence_id(sentences=developer_sentences,index=0))
    developer_last_id = int(find_sentence_id(sentences=developer_sentences, index=len(developer_sentences) - 1))
    developer_total_sentences=developer_last_id - developer_first_id+1

    train_total_sentences = int(find_sentence_id(sentences=train_sentences,index=len(train_sentences)-1))
    if len(developer_sentences) == num_sentence_1 and num_sentence_1 == developer_total_sentences:
        print("Developer Sentences Validated")
        accepted_developer=True
    else:
        print("Failed to Validate the Developer Sentences")
    if len(train_sentences) == num_sentence_2 and  num_sentence_2 == train_total_sentences:
        print("Training Sentences Validated")
        accepted_train=True
    else:
        print("Failed to Validate the Training Sentences")
    return accepted_developer,accepted_train

##################################################################
#   Finding the Id of the sentence given the index in the list   #
##################################################################
def find_sentence_id(sentences,index):
    temp1=sentences[index][0].split(' = ')
    temp2=temp1[1].split('\n')
    id=int(temp2[0])
    return id



################################
#   The Primary load Function  #
################################
def load_files(worldFOlder):
    #creating the complete path to folder
    path=PRIMARY_DIRECTORY  + "/" + worldFOlder
    #counting number of files found and terminating uppon missing files
    num_files = len(os.listdir(path))
    if num_files <1:
        print("Files are missing!")
        return None
    #reading the files
    print('Reading input Files from ' + path + " folder:")
    input_files= []
    for i, file in enumerate(os.listdir(path)):
        if file.endswith('.conllu'):
            inputFile=  path+"/"+file
            input_files.append(inputFile)
    print("_________Files Imported_________")

    developer_sentences,num_sentence_1 = read_file(open(input_files[0],'r'))
    train_sentences,num_sentence_2 = read_file(open(input_files[1],'r'))

    print("_________Loading Sentences Completed_________")
    print("_________Loading Sentences Completed_________")
#    accepted_developer, accepted_train= validate(developer_sentences=developer_sentences,
#                                                 train_sentences=train_sentences,num_sentence_1=num_sentence_1,
#                                                 num_sentence_2=num_sentence_2)
#    if accepted_train and accepted_developer:
#        print("_________All data imported successfully_________")
#    else:
#        print("_________Error in importing _________")
#        return [],[]

    return developer_sentences, train_sentences


def save_results(train_train, train_test, dev_train, dev_test):
#The primary Directory for files is a folder called Generated_data

        #The output folder to save all the information of the world is saved as:
        #world+(the user-given name)+ width + height + number of obstacles
        outputDirect = PRIMARY_OUTPUT_DIRECTORY+'/'+str(TREEBANK_TO_IMPORT)

        #if the primary path of PRIMARY_OUTPUT_DIRECTORY does not exist create a new folder
        if not os.path.exists(PRIMARY_OUTPUT_DIRECTORY):
            print("creating The primary folder under " + PRIMARY_OUTPUT_DIRECTORY)
            os.makedirs(PRIMARY_OUTPUT_DIRECTORY)
            print(" The Folder for all saved worlds is created! \n The directory is : " + PRIMARY_OUTPUT_DIRECTORY)
        else:
             print("Creating new Save File!")

        # if the main path of particular treebank does not exist create a new folder
        if not os.path.exists(outputDirect):
            print("creating The primary folder under " + outputDirect)
            os.makedirs(outputDirect)
        else:
            print("The new world is saved in MARL/: " + outputDirect)

        #call function to save the files
        save_file(outputDirect=outputDirect,argName="train_train",argList=train_train)
        save_file(outputDirect=outputDirect,argName="train_test",argList=train_test)
        save_file(outputDirect=outputDirect,argName="dev_test",argList=dev_test)
        save_file(outputDirect=outputDirect,argName="dev_train",argList=dev_train)


#the save function that specifically saves the world, this function is also used for visualization
def save_file(outputDirect,argName,argList):
    # saving the main grid
    file_1 = open(outputDirect + "/"+argName, 'w')
    # the primary loop for grid
    for i in range(len(argList)):
        for j in range(len(argList[i])):
            # writing the values of cells
            file_1.write(str(argList[i][j]))
    # closing the file
    file_1.close()

def generate_data(argList):
    np.random.shuffle(argList)
    test_counter = int(math.ceil(TEST_PERCENTAGE*len(argList)))
    test_set = []
    train_set = []
    for i in range(test_counter):
        test_set.append(argList[i])
    for i in range(test_counter,len(argList)):
        train_set.append(argList[i])
    return test_set, train_set


if __name__ == '__main__':

    developer_sentences, train_sentences = load_files(TREEBANK_TO_IMPORT)

    if not developer_sentences or not train_sentences:
        print("Failed to import! ")


    print("______GENERATING DATA_______")
    train_test,train_train= generate_data(train_sentences)
    dev_test,dev_train = generate_data(developer_sentences)
    print("______GENERATING DATA COMPLETED_______")
    print("Total sentences in Training: "+str(len(train_sentences)))
    print("Training set of Training: " + str(len(train_train)))
    print("Testing set of Training: " + str(len(train_test)))
    print("############################")
    print("Total sentences in Developer: "+str(len(developer_sentences)))
    print("Training set of developer: " + str(len(dev_train)))
    print("Testing set of developer: " + str(len(dev_test)))
    print("______Saving Data_______")
    save_results(dev_test=dev_test, dev_train=dev_train,
                 train_test=train_test,train_train=train_train)
    print("______Saved the Data_______")
    print("______BYEEEEEEEEEE LOL :D_______")

