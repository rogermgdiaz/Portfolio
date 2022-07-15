#!/usr/bin/env python
# coding: utf-8

# In[12]:


#In this part we just go to coinmarketcap, search the API documentation and follow some initial recommendations.

from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json

url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {
  'start':'1',
  'limit':'10',
  'convert':'USD'
}
headers = {
  'Accepts': 'application/json',
  'X-CMC_PRO_API_KEY': 'aa227ee4-15ba-49ab-8d5b-fca569c57102',
}

session = Session()
session.headers.update(headers)

try:
  response = session.get(url, params=parameters)
  data = json.loads(response.text)
  print(data)
except (ConnectionError, Timeout, TooManyRedirects) as e:
  print(e)


# In[2]:


type(data)


# In[25]:


#we import pandas to normalize the table and make it more readable
import pandas as pd
pd.set_option('display.max_rows',None)


# In[13]:



df = pd.json_normalize(data['data'])
df['timestamp'] = pd.to_datetime('now')
df


# In[31]:


# here we define the function that we are going to automatize 
def  cmc_api():
    global df
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    parameters = {
      'start':'1',
      'limit':'10',
      'convert':'USD'
    }
    headers = {
      'Accepts': 'application/json',
      'X-CMC_PRO_API_KEY': 'aa227ee4-15ba-49ab-8d5b-fca569c57102',
    }

    session = Session()
    session.headers.update(headers)

    try:
      response = session.get(url, params=parameters)
      data = json.loads(response.text)
      print(data)
    except (ConnectionError, Timeout, TooManyRedirects) as e:
      print(e)
    
    df2 = pd.json_normalize(data['data'])
    df2['timestamp'] = pd.to_datetime('now')
    df = df.append(df2)
    
    if not os.path.isfile(r'C:\Users\roger\OneDrive\Escritorio\GATITO\portfolio\proyectos\API python\cryptoAPI.csv'):
        df.to_csv(r'C:\Users\roger\OneDrive\Escritorio\GATITO\portfolio\proyectos\API python\cryptoAPI.csv',header='column_names')
    else:
        df.to_csv(r'C:\Users\roger\OneDrive\Escritorio\GATITO\portfolio\proyectos\API python\cryptoAPI.csv',mode='a', header=False)


# In[32]:


import os
from time import time
from time import sleep

#and here it is our API working and of course importing a csv with the information, this can be useful for a deeper exploration in SQl

for i in range(333): 
    cmc_api()
    print('API Runner completed')
    sleep(2)
exit()


# In[33]:


#read csv in jupyter
dfcsv = pd.read_csv(r'C:\Users\roger\OneDrive\Escritorio\GATITO\portfolio\proyectos\API python\cryptoAPI.csv)


# In[37]:


#Show numbers in a complete way and not in scientific notation
pd.set_option('display.float_format',lambda x:'%.5f'% x)


# In[38]:


df


# In[40]:


#Here is an exploration and preparation of data to visualize it later on. 
df2= df.groupby('name', sort=False)[['quote.USD.percent_change_1h','quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d']].mean()


# In[42]:


df3= df2.stack()
df3


# In[43]:


df4 = df3.to_frame(name='values')
df4


# In[45]:


df4.count()


# In[62]:


index= pd.Index(range(60))


df5 = df4.reset_index()
df5


# In[63]:


df6=df5.rename(columns ={ 'level_1':'percent_change'})
df6


# In[64]:


df6['percent_change']=df6['percent_change'].replace(['quote.USD.percent_change_1h','quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d'],['1h','24h','7d','30d','60d','90d'])


# In[65]:


#after all the process before, now it's time to import seaborn and matplot to visualize
import seaborn as sns
import matplotlib.pyplot as plt


# In[66]:


#a good VIZ if you ask me 
sns.catplot(x='percent_change',y='values',hue='name',data=df6, kind='point')


# In[69]:


dfbitcoin= df[['name','quote.USD.price','timestamp']]
dfbitcoin= dfbitcoin.query("name== 'Bitcoin'")
dfbitcoin


# In[73]:


sns.lineplot(x='timestamp', y='quote.USD.price', data = dfbitcoin)

