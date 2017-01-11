import random
import sklearn
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cross_validation import train_test_split
from sklearn.svm import SVC
from sklearn import cross_validation
from sklearn.metrics import confusion_matrix
from sklearn import preprocessing
from sklearn import metrics
import unicodedata
import string
import nltk
import numpy as np
from nltk import pos_tag
from nltk.corpus import stopwords
import csv
from nltk import PorterStemmer
import random
import sklearn
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cross_validation import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import confusion_matrix
from sklearn.ensemble import VotingClassifier
from sklearn import preprocessing
from sklearn import metrics
import unicodedata
import string
import nltk
from nltk import pos_tag
from nltk.corpus import stopwords
from nltk import word_tokenize
from sklearn.metrics import accuracy_score
from sklearn.metrics import accuracy_score
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn import metrics
from scipy.sparse import csr_matrix



def load_data():
    osha_data = pd.read_excel("C:\Users\Pravin\Downloads\osha.xlsx")
    osha_data['otherCols'] = osha_data['Summary2'].str.replace('FatCause:', '@@')
    
    location_df = osha_data['otherCols'].apply(lambda x: pd.Series(x.split('@@')))
    osha_data['Cause'] = location_df[1]
    osha_data = osha_data.sort(['Cause'], ascending=[True])

    osha_data['Cause'][0:5] = 'zz'
    osha_data['Cause'].fillna('zz', inplace=True)
    osha_data = osha_data.sort(['Cause'], ascending=[True])
    osha_data['Cause'][3558:16323] = 'zz'
    
    return osha_data

def preprocess_data(osha_data):
    #Remove the unicoding of data
    osha_data['Cause'] = osha_data['Cause'].apply(
        lambda x: unicodedata.normalize('NFKD',unicode(x)).encode('ascii','ignore'))
    osha_data['title'] = osha_data['title'].apply(
        lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))
   
    osha_data['title'] = osha_data['title'].apply(
        lambda x: x.translate(string.maketrans("", ""), string.punctuation))
   
    osha_data['title'] = osha_data['title'].apply(lambda x: x.lower())
   
    #Stop word removal
    stop = stopwords.words('english')
    
   

    osha_data['title'] = osha_data['title'].apply(lambda x:' '.join([words for words in str(x).split(" ") if words not in stop]))
   
    #lematization
    wnl = nltk.WordNetLemmatizer()
    osha_data['title']=osha_data['title'].apply(lambda x: word_tokenize(x))
   
    osha_data['title'] = osha_data['title'].apply(lambda x:" ".join(wnl.lemmatize(t) for t in x))
    


    return osha_data

def create_tfidf_matrix(labelled):
    y = [data[5] for data in labelled]  
    corpus1 = [data[1] for data in labelled]
    vectorizer = TfidfVectorizer(min_df=1)
    title_case = vectorizer.fit_transform(corpus1)
    
    title_case.todense()
    y = y [0:3557]  
  


    return y,titlecase

def train_svm(X, y):
    """
    Create and train the Support Vector Machine.
    """
    svm = SVC(C=1000000.0, gamma=0.0, kernel='rbf')
    svm.fit(X, y)
    return svm

osha_data = load_data()

#osha_data.rename(columns= lambda x: x.strip())
#osha_data.head(1)
#osha_data.unique.columns
osha_data.groupby(['Cause']).count()
osha_data.ix[osha_data['Cause']=="Others",'Cause']="Other"
osha_data = preprocess_data(osha_data)

labelled=[]
for row in osha_data.iterrows():
    index,data = row
    labelled.append(data.tolist())

#splitting into train and test data    
y,title_case = create_tfidf_matrix(labelled)
x=  title_case[0:3557,:].toarray()   
x1=  title_case[3558:16323,:].toarray() 

#print labelled



#svm model building
svm_sum = train_svm(x,y)
pred_sum = svm_sum.predict(x1)
b = pred_sum.tolist()
osha_data['Cause'][3558:16323] = b

#document which contains the generalised cause    

final = pd.read_excel("C:\\Users\\Pravin\\Downloads\\generalised_cause.xlsx")


import pandasql as ps


q2 = """
    SELECT 
    osha_data.*, 
    final.Cause1   
    FROM osha_data INNER JOIN final ON osha_data.Cause = final.Cause ;
    """

q3 =  ps.sqldf(q2, locals())



q3.to_csv("classification.csv", sep='\t', encoding='utf-8')
