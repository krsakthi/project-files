# -*- coding: utf-8 -*-
"""
Created on Sun Oct 23 11:08:26 2016

@author: Sakthi
"""

#####Import libraries

from __future__ import print_function
import numpy as np
import pandas as pd
import nltk
import unicodedata
from bs4 import BeautifulSoup
import re
import os
import codecs
from sklearn import feature_extraction
import mpld3
import matplotlib.pyplot as plt
import matplotlib as mpl
from sklearn.manifold import MDS
from sklearn.decomposition import TruncatedSVD
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import Normalizer
from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np
from sklearn.metrics import silhouette_score
from sklearn.metrics.pairwise import cosine_similarity
from nltk.cluster import GAAClusterer
from gensim import corpora, models, similarities 
from nltk.stem.snowball import SnowballStemmer
from pandas import ExcelWriter


def load_data():
    df = pd.read_excel('C:\Users\Pravin\Downloads\osha.xlsx')

# Remove all the encoding, escape and special characters

    df['title'] = df['title'].apply(lambda x: unicodedata.normalize('NFKD', unicode(x)).encode('ascii', 'ignore'))

    dflist=[]
    for item in df['title'].iteritems():
        dflist.append(item[1])
    
        return df


def tokenize_and_stem(text):
    stopwords = nltk.corpus.stopwords.words('english')
    stemmer = SnowballStemmer("english")
    # first tokenize by sentence, then by word to ensure that punctuation is caught as it's own token
    tokens = [word for sent in nltk.sent_tokenize(text) for word in nltk.word_tokenize(sent)]
    filtered_tokens = []
    # filter out any tokens not containing letters (e.g., numeric tokens, raw punctuation)
    for token in tokens:
        if re.search('[a-zA-Z]', token):
            filtered_tokens.append(token)
    stems = [stemmer.stem(t) for t in filtered_tokens]
    return stems


def tokenize_only(text):
    # first tokenize by sentence, then by word to ensure that punctuation is caught as it's own token
    tokens = [word.lower() for sent in nltk.sent_tokenize(text) for word in nltk.word_tokenize(sent)]
    filtered_tokens = []
    # filter out any tokens not containing letters (e.g., numeric tokens, raw punctuation)
    for token in tokens:
        if re.search('[a-zA-Z]', token):
            filtered_tokens.append(token)
    return filtered_tokens


df = load_data()
totalvocab_stemmed = []
totalvocab_tokenized = []
for i in dflist:
    allwords_stemmed = tokenize_and_stem(i)
    totalvocab_stemmed.extend(allwords_stemmed)
    
    allwords_tokenized = tokenize_only(i)
    totalvocab_tokenized.extend(allwords_tokenized)
    
vocab_frame = pd.DataFrame({'words': totalvocab_tokenized}, index = totalvocab_stemmed)
print ('there are ' + str(vocab_frame.shape[0]) + ' items in vocab_frame')



################################################################################################
# Create a TF-IDF Vectorizer by ignoring words with Document Frequency above 0.9 and below 0.05

tfidf_vectorizer1 = TfidfVectorizer(max_df=0.8, max_features=200000,
                                 min_df=0.04, stop_words='english',
                                 use_idf=True, tokenizer=tokenize_and_stem, ngram_range=(1,3))

len(dflist)
# Creating the tf-idf matrix
tfidf_matrix1 = tfidf_vectorizer1.fit_transform(dflist)

# TDM Matrix (100 * 2727)
print(tfidf_matrix1.shape)

# Fitting a K-Means Model and evaluating its performance


from sklearn.cluster import KMeans
num_clusters = 11
km2 = KMeans(n_clusters=num_clusters, random_state=23)
km2.fit(tfidf_matrix1)
clusters2 = km2.labels_.tolist()

# Evaluating the performance of the clustering algorithm. We check the silhouette score of the KMeans. -1 
# represents extremely poor clusters while +1 represents extremely good clusters
array1 = np.array(clusters2)
silhouette_score(tfidf_matrix1, array1, metric='euclidean', sample_size=None, random_state=None)




################################################################################################
# What happens if we apply dimensionality reduction to the tf-idf and use the dimensionally reduced
# feature space for our clustering?
# We see a sharp increase in cluster performance

svd = TruncatedSVD(2)
lsa = make_pipeline(svd, Normalizer(copy=False))
X = lsa.fit_transform(tfidf_matrix1)
km_svd = KMeans(n_clusters=num_clusters, random_state=23)
km_svd.fit(X)

clusters_svd = km_svd.labels_.tolist()
array_svd = np.array(clusters_svd)
silhouette_score(X, array_svd, metric='euclidean', sample_size=None, random_state=None)

############################################################################################
# Let's see what these clusters are made up of

# Creating the function which will "get features" from the tf-idf
accidentterms = tfidf_vectorizer1.get_feature_names()

# Now to view the movies in each cluster

# Create a dataframe which will hold all the movies and their cluster memberships
Accident = { 'title': dflist, 'cluster': clusters_svd }

AccidentCause = pd.DataFrame(Accident, index = [clusters_svd] , columns = ['title', 'cluster'])



# Check the number of members of each cluster
AccidentCause['cluster'].value_counts()


print("Top 12 terms per cluster:")
print()
order_centroids = km_svd.cluster_centers_.argsort()[:, ::-1]
for i in range(num_clusters):
    print("Cluster %d words:" % i, end='')
    for ind in order_centroids[i, :12]:
        print(' %s' % vocab_frame.ix[accidentterms[ind].split(' ')].values.tolist()[0][0].encode('utf-8', 'ignore'), end=',')
    print()
    print()
    print("Cluster %d titles:" % i, end='')
    for title in AccidentCause.ix[i]['title'].values.tolist():
        print(' %s,' % title, end='')
    print()
    print()
    



writer = ExcelWriter('G:\Osha_Clusering.xlsx')
AccidentCause.to_excel(writer,'sheet1')
writer.save()