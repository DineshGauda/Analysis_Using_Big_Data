
# coding: utf-8

# In[98]:


import re
import pdb
from numpy import *
from pandas import *
import pyspark
from pyspark.sql.functions import split
from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)


# In[99]:


tipDF = spark.read.csv("gs://pda-yelp-bucket/input/tip/tip.csv",header='true')
tipDF.show()


# In[100]:


tipDF=tipDF.select('business_id','business_name','text')


# In[ ]:


tipDF.columns
tipDF.select('business_id').count()


# In[103]:


from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col, lower, regexp_replace
from pyspark.ml.feature import Tokenizer, StopWordsRemover

# Clean text
tipDF = tipDF.select('business_id', 'business_name', (lower(regexp_replace('text', "[^a-zA-Z\\s]", "")).alias('text')))

tipDF.show(5)


# In[130]:


businessDF = spark.read.csv("gs://pda-yelp-bucket/input/business/business.csv",header='true')
businessDF = businessDF.select('business_id', 'city')
businessDF.show(5)


# In[131]:


food_list=['pasta','pizza','burger','banana cream pie','salad','truffle','salmon steak','steak','chips','sizzler','icecream','spaghetti','ice cream','salad','chinese','dimsum','pie','fries','noodle','pudding','pancake','brownie','sushi','eggroll','bacon and eggs','french toast','porridge','biryani','apple pie','hamburger','clam chowder','barbecue','taco','fajita','salmon','meatloaf','macaroni','crabcake','sandwich','popcorn','waffle','enchiladas','lobster','buffalo wing','cookie','soups','nacho','hot dog','cheeseburger','soup']


# In[132]:


new_df = businessDF.join(tipDF, on=['business_id'], how='left_outer')
new_df.show(5)


# In[133]:


import pyspark.sql.functions as psf
new_df.filter(psf.col('text').rlike('(^|\s)(' + '|'.join(food_list) + ')(\s|$)')).show(5)


# In[136]:


final_df=new_df.withColumn(
        'top_dishes', 
        psf.regexp_extract('text', '(?=^|\s)(' + '|'.join(food_list) + ')(?=\s|$)', 0))\


# In[137]:


final_df = final_df.select('business_id', 'business_name', 'city', 'text', 'top_dishes')
final_df.show(5)


# In[138]:


final_df = final_df.select('business_id', 'business_name', 'city', 'top_dishes')
outputpath="gs://pda-yelp-bucket/output/topDishes/"


# In[139]:


final_df.coalesce(1).write.save(outputpath,sep=",",mode="append",format="csv",header="TRUE")

