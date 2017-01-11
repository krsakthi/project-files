import pandas as pd
import re
import unicodedata
import nltk
from nltk import *
from nltk.corpus import stopwords
from nltk import word_tokenize
from nltk.stem.wordnet import WordNetLemmatizer
from nltk import stem
from nltk import RegexpParser
import numpy as np
from nltk.corpus import stopwords
from nltk import pos_tag

#load data from csv to dataframe
def load_data():
    osha_data = pd.read_excel("E:/NUS-SEM2/Text Mining/project/osha.xlsx",header=None,names=['caseId','title','summary','keyWords','otherCols'])
    return osha_data

#Preporcessing steps;
def preporcessing(osha_data):
    #Removal of unicode from each col in the data
    osha_data['caseId'] = osha_data['caseId'].apply(
        lambda x: unicodedata.normalize('NFKD',unicode(x)).encode('ascii','ignore'))
    osha_data['title'] = osha_data['title'].apply(
        lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))
    osha_data['summary'] = osha_data['summary'].apply(
        lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))
    osha_data['keyWords'] = osha_data['keyWords'].apply(
        lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))
    osha_data['otherCols'] = osha_data['otherCols'].apply(
        lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))


    #changing to lower case if the summary column has all upper case values
    osha_data['summary'] = osha_data['summary'].apply(lambda x: x.lower() if x.isupper() else x)
    # changing the stop words in title col to lower case so that pos tagging is done correctly
    stop = stopwords.words('english')

    for index,row in osha_data.iterrows():
        lowerString = ''
        for words in row['title'].split(" "):
            if words.lower() in stop:
                lowerString = lowerString + ' ' + words.lower()
            else:
                lowerString = lowerString + ' ' + words
        osha_data['title'].loc[index] = lowerString.strip()

    return osha_data



#To pos tagging for the cols
def pos_tagging(osha_data,input_col,output_col):
    osha_data[output_col] = osha_data[input_col].apply(lambda x: nltk.pos_tag(word_tokenize(str(x))))
    return osha_data


#To extract certain pattern from the pos tagged string , chunk matched pattern and extract the string from those pattern
def chunkerParser(osha_data,output_col,pos_col,regexPat):
    #pattern to identify unwanted pattern such as ' " \
    unwantedPat = r'[\"\',\[\]]'
    chunkParser = nltk.RegexpParser(regexPat)
    chunked = []
    i = 0
    for activities in osha_data[pos_col]:
        treeleaf = ""
        chunked.append(chunkParser.parse(activities))
        for ch in chunked[i]:
            if str(ch).split(' ', 1)[0] == "(Chunk":
                wrapped = "(ROOT " + str(ch) + " )"  # Add a "root" node at the top
                trees = nltk.Tree.fromstring(wrapped, read_leaf=lambda x: x.split("/")[0])
                #extact the strings for the matched pattern
                for tree in trees:
                    treeleaf = str(treeleaf) + str(tree.leaves())
                #joining with ; to identify multiple matched patterns
                treeleaf = treeleaf + ';'
        # substitue the unwanted pattern with empty char
        osha_data.loc[i,output_col] = re.sub(unwantedPat,'', treeleaf)
        i += 1
    return osha_data


#Question 5
#To identify as single or multiple victims
def extract_no_empolyee(osha_data):
    print('Logger: entering extract number of employee')
    # Most of columns have Employee#1 and #2. To extract the count of those pattern below regex is used.
    employee_count = re.compile(r"#\d")
    osha_data['emp_count'] = osha_data['summary'].apply(lambda x: len(set(re.findall(employee_count, x))))
    # Singular and purlar words can be identified from the title and summary column with a set of predefined keywords as shown in the below pattern
    singular_word = re.compile(r'employee|worker|mechanic|electrician|firefighter|driver|engineer|operator|technician|owner|owner\'s|employee\'s|worker\'s|mechanic\'s|electrician\'s|firefighter\'s|technician\'s|operator\'s|driver\'s',re.IGNORECASE)
    #other_singular_word = re.compile(r'mechanic|electrician|firefighter|driver|engineer',re.IGNORECASE)
    pural_word = re.compile(r'employees|workers|mechanics|electricians|firefighters|drivers|operators|oweners' ,re.IGNORECASE)
    for index,row in osha_data['emp_count'].iteritems():
        if row < 1:
            #Extract the pattern from summary col
            summary_str = str(osha_data.loc[index,'summary']).lower()
            #Extract the pattern from title col
            title_str = str(osha_data.loc[index,'title']).lower()
            if(len(pural_word.findall(title_str)) > 0):
                osha_data.loc[index,'emp_count'] = 2
            elif(len(singular_word.findall(title_str)) > 0):
                osha_data.loc[index, 'emp_count'] = 1
            elif(len(pural_word.findall(summary_str)) > 0):
                osha_data.loc[index,'emp_count'] = 2
            elif(len(singular_word.findall(summary_str)) > 0):
                osha_data.loc[index,'emp_count'] = 1
            #else:
                #print(index, osha_data.loc[index, 'emp_count'])
    print("Number of records for which single or multiple victims is not tagged: ",osha_data.ix[osha_data['emp_count'] == 0, 'emp_count'].count())
    print("Logger: Exiting extract number of employee")
    return osha_data

# To extract the date in summary col.pattern is January 22 2013
def extract_date(osha_data):
    date_pattern = re.compile(r"(January|February|March|April|May|June|July|August|September|October|November|December)(\s+\d{2}\s+\d{4})",re.IGNORECASE)
    osha_data['date'] = osha_data['summary'].apply(lambda x: date_pattern.findall(x))
    return osha_data


#############################################################################################################
                                        #Main Method
#############################################################################################################
# calling load_data and preprocessing methods
#############################################################################################################
osha_data = load_data()
osha_data = preporcessing(osha_data)
# pos tag the summary col as it has the required pattern
osha_data = pos_tagging(osha_data,"summary","summary_pos")
# pos tag the title col as it has the required pattern
osha_data = pos_tagging(osha_data,"title","title_pos")

#############################################################################################################





#############################################################################################################
                                        #Question 2
#############################################################################################################
print("Logger: executing Question 2")
#Question 2: Objects that cause the accidents
#rule 1: to + verb+ noun
objectRegexPat1 = r"""Chunk: {<TO><VB.?>?<NN.*>+}"""
osha_data = chunkerParser(osha_data,"objectCause","title_pos",objectRegexPat1)
#Rule 2: prepostion + verb + noun
objectRegexPat2 = r"""Chunk: {<IN.?><VB.?>?<NN.?>+}"""
osha_data = chunkerParser(osha_data,"objectCause1","title_pos",objectRegexPat2)
# Rule 3: wh adverb +noun + verb 3 person
objectRegexPat3 = r"""Chunk: {<WRB><NN.*>*<VBZ>?}"""
osha_data = chunkerParser(osha_data,"objectCause2","title_pos",objectRegexPat3)

#join the words extracted from both the patterns
for i,row in osha_data.iterrows():
    if row['objectCause'] == "":
        row['objectCause'] = row['objectCause1']

for i,row in osha_data.iterrows():
    if row['objectCause'] == "":
        row['objectCause'] = row['objectCause2']

print("Number of rows for which Causes have been succesfully extracted are :",osha_data.ix[osha_data['objectCause'] !="", 'objectCause'].count())
del(osha_data['objectCause1'])
del(osha_data['objectCause2'])
print("Logger: Question 2 completed sucessfully")
#############################################################################################################
                                            #Question 3
#############################################################################################################
print("Logger: Executing Question 3")
#Rule for title : proper Noun
occupation_pat_title = r"""Chunk: {<NNP>}"""
osha_data = chunkerParser(osha_data,"occupation_title","title_pos",occupation_pat_title)
#Rule for summary : determiner + any form of noun
occupation_pat_summary = r"""Chunk: {<DT><NN.?>+}"""
osha_data = chunkerParser(osha_data,"occupation_summary","summary_pos",occupation_pat_summary)


osha_data["FinalOccupationTitle"]=""
for i in range(0,len(osha_data['summary'])-1):
    for word in osha_data['occupation_title'][i].split(';'):
        word = ";"+word+";"
        # identify words ending with er or ian.
        profession=re.compile(r";.*\w*er(?=;)")
        profession1=re.compile(r";.*\w*or(?=;)")
        profession2=re.compile(r";.*\w*ian(?=;)")
        if len(re.findall(profession,word)) > 0:
            osha_data["FinalOccupationTitle"].loc[i] = re.findall(profession,word)
            if (osha_data["FinalOccupationTitle"].loc[i] != '[\';the employer\']'):
                break
        elif len(re.findall(profession1,word)) > 0:
            osha_data["FinalOccupationTitle"].loc[i] = re.findall(profession1,word)
            break
        elif len(re.findall(profession2,word)) > 0:
            osha_data["FinalOccupationTitle"].loc[i] = re.findall(profession2,word)
            break

osha_data["FinalOccupationSummary"]=""
for i in range(0,len(osha_data['summary'])-1):
    for word in osha_data['occupation_summary'][i].split(';'):
        word = ";"+word+";"
        profession=re.compile(r";.*\w*er(?=;)")
        profession1=re.compile(r";.*\w*or(?=;)")
        profession2=re.compile(r";.*\w*ian(?=;)")
        if len(re.findall(profession,word)) > 0:
            osha_data["FinalOccupationSummary"].loc[i] = re.findall(profession,word)
            if (osha_data["FinalOccupationSummary"].loc[i] != '[\';the employer\']'):
                break
        elif len(re.findall(profession1,word)) > 0:
            osha_data["FinalOccupationSummary"].loc[i] = re.findall(profession1,word)
            break
        elif len(re.findall(profession2,word)) > 0:
            osha_data["FinalOccupationSummary"].loc[i] = re.findall(profession2,word)
            break

for i, row in osha_data.iterrows():
    if row['FinalOccupationTitle'] == "":
        row['FinalOccupationTitle'] = row['FinalOccupationSummary']

unwantedPat1 = r'[\"\',\[\];]'
osha_data['FinalOccupationTitle']=osha_data['FinalOccupationTitle'].apply(lambda x: str(re.sub(unwantedPat1,'', str(x))))
del(osha_data[occupation_title])
del(osha_data[occupation_summary])
del(osha_data[FinalOccupationSummary])
print("Number of rows for which occupation have been succesfully extracted are :",osha_data.ix[osha_data['FinalOccupationTitle'] !="", 'FinalOccupationTitle'].count())
print("Logger: Question 3 completed sucessfully")

#############################################################################################################
                                            #Question 4
#############################################################################################################
#Question 4 Common activites the victims where engaged prior to accident

#Rule 1 : verb present particple + preposition + Determiner + adjective + anytype of noun
activityRegexPat = r"""Chunk: {<VBG><IN>?<DT>?<JJ>?<NN.?>+}"""
osha_data = chunkerParser(osha_data,"activityBefore","summary_pos",activityRegexPat)
#osha_data.ix[osha_data['activityBefore'] == "", 'activityBefore'].count()

#Rule 2 : Any verb+adverb + preposition + Determiner + adjective + anytype of noun
activityRegexPat = r"""Chunk: {<VB.?><RP>?<IN>?<DT>?<JJ>?<NN.?>+}"""
osha_data = chunkerParser(osha_data,"activityBefore2","summary_pos",activityRegexPat)
#osha_data.ix[osha_data['activityBefore2'] == "", 'activityBefore2'].count()
#extract the first occurance alone
osha_data['activityBefore'] = osha_data['activityBefore'].apply(lambda x: x.split(';')[0])
osha_data['activityBefore2'] = osha_data['activityBefore2'].apply(lambda x: x.split(';')[0])

#join the words extracted from both the patterns
for i,row in osha_data.iterrows():
    if row['activityBefore'] == "":
        row['activityBefore'] = row['activityBefore2']
del(osha_data['activityBefore2'])

print("Number of rows for which activites prior to accidents have been succesfully extracted are :",osha_data.ix[osha_data['activityBefore'] !="", 'activityBefore'].count())
print("Logger: Question 4 completed sucessfully")

#############################################################################################################
                                             #Question 5
#############################################################################################################

osha_data = extract_no_empolyee(osha_data)


#############################################################################################################
                                             #Date extracter
#############################################################################################################
osha_data = extract_date(osha_data)
unwantedPatdate = r'[\"\',\[\];()]'
osha_data['date']=osha_data['date'].apply(lambda x: str(re.sub(unwantedPatdate,'', str(x))))

#############################################################################################################
                                            #Export to CSV
#############################################################################################################
#TODO remove the comments before sumbimting
'''
del(osha_data[summary_pos])
del(osha_data[title_pos])


'''
osha_data.to_csv("E:\\NUS-SEM2\\Text Mining\\project\\files\\output\\output.csv")
