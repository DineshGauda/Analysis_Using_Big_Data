
# coding: utf-8

# In[143]:


sc.master
import re
from operator import add


# In[144]:


type(sc)


# In[187]:


reviewsDF = spark.read.csv("gs://pda-yelp-bucket/input/review/review.csv",header='true')
reviewsDF.show(5)


# In[188]:


reviewsDF = reviewsDF.select('review_id', 'business_id', 'business_name', 'stars', 'date', 'text')
reviewsDF.show(5)


# In[189]:


reviewsDF.select('business_id').count()


# In[147]:


from pyspark.sql import SQLContext


# In[148]:


from pyspark.sql.types import *


# In[149]:


sqlContext = SQLContext(sc)


# In[150]:


from pyspark.sql import functions as fn


# In[151]:


get_ipython().system(u'wget https://github.com/daniel-acuna/python_data_science_intro/blob/master/data/sentiments.parquet.zip?raw=true -O sentiments.parquet.zip && unzip sentiments.parquet.zip && rm sentiments.parquet.zip')


# In[153]:


sentiments_df = sqlContext.read.parquet('hdfs:///sentiments.parquet')


# In[154]:


sentiments_df.columns


# In[155]:


from pyspark.ml.feature import RegexTokenizer


# In[156]:


tokenizer = RegexTokenizer().setGaps(False)  .setPattern("\\p{L}+")  .setInputCol("text")  .setOutputCol("words")


# In[190]:


reviews_words_df = tokenizer.transform(reviewsDF)
print(reviews_words_df)


# In[191]:


reviews_words_df.show(5)


# In[192]:


reviews_word_sentiment_df = reviews_words_df.    select('review_id', fn.explode('words').alias('word')).    join(sentiments_df, 'word')
reviews_word_sentiment_df.show(5)


# In[193]:


sentiment_prediction_df = reviews_word_sentiment_df.    groupBy('review_id').    agg(fn.avg('sentiment').alias('avg_sentiment'))
sentiment_prediction_df.show(5)


# In[194]:


reviews_sentiment_df = sentiment_prediction_df.    join(reviewsDF, 'review_id')
    
reviews_sentiment_df.show(5)


# In[196]:


businessDF = spark.read.csv("gs://pda-yelp-bucket/input/business/business.csv",header='true')
businessDF = businessDF.select('business_id', 'city', 'state','latitude', 'longitude')
businessDF.show(5)


# In[197]:


reviews_business = reviews_sentiment_df.    join(businessDF, 'business_id')    
reviews_business.show(5)


# In[206]:


reviews_business.columns


# In[211]:


reviews_sentiment_score_df =  reviews_business.    groupBy('business_name', 'city').    agg(fn.mean('avg_sentiment').alias('avg_sentiment'))
reviews_sentiment_score_df.show(5)


# In[215]:


reviews_avg_rating_df =  reviews_business.    groupBy('business_name', 'city').    agg(fn.mean('stars').alias('rating'))
reviews_avg_rating_df.show(5)


# In[218]:


reviews_avg_rating_df = reviews_avg_rating_df.select('business_name', 'rating')
sentiment_rating = reviews_sentiment_score_df.    join(reviews_avg_rating_df, 'business_name')
sentiment_rating.show(5)


# In[220]:


outputpath="gs://pda-yelp-bucket/output/sentimentScore/"
sentiment_rating.coalesce(1).write.save(outputpath,sep=",",mode="append",format="csv",header="TRUE")

