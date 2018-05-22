#####################################################################################
###### Author: Liese Schmidt 
###### Date: 18-05-2018      
###### READ-ME: Parse data without extention to .csv
######			This is useful for the labels_graph.R
###### Terminal: be in the folder where the files are which you want to parse
######			 python ../data_csv_parser.py *
#####################################################################################


import csv
import sys
csv.field_size_limit(sys.maxsize)


if len(sys.argv) == 1:
    print("TEST: Input files to process")

for file in sys.argv[1:]:
    data = list(csv.reader(open(file, 'r'), delimiter='\t'))
    new = []
    for line in data:
        new.append([  part  for part in line ])

    with open(file + '.csv', 'wb') as resultFile:
        wr = csv.writer(resultFile, dialect='excel', quotechar='"', quoting=csv.QUOTE_ALL)
        wr.writerows(new)
