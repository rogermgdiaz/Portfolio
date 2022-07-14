#!/usr/bin/env python
# coding: utf-8

# In[1]:


#first we need to install beautifulsoup and import some modules
from bs4 import BeautifulSoup
import requests
import time
import datetime
import csv


# In[2]:


#Now it's time to connect it
URL = 'https://coinmarketcap.com/es/currencies/bitcoin/'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.49","Accept-Encoding":"gzip,deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8","DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers= headers)

soup1 = BeautifulSoup(page.content, "html.parser") 
soup2 = BeautifulSoup(soup1.prettify(),'html.parser')


# In[11]:


#get some information 

coin = soup2.find('h1',{'class':'priceHeading'}).get_text()
price = soup2.find('div',{'class':'priceValue'}).get_text()
date_time = datetime.datetime.now()
print(coin)
print(price)
print(date_time)


# In[12]:


#cleaning some data


coin = coin.strip()
price = price.strip()
print(coin)
print(price)
print(date_time)


# In[21]:


#importing csv
header = ['coin', 'price','date_time']
data = [coin, price, date_time]

with open('web_scraper_project.csv','w', newline='',encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[22]:


#using panda to see the data
import pandas as pd
df = pd.read_csv(r'C:\Users\roger\web_scraper_project.csv')
print(df)


# In[23]:


#now let's automate
def check_price():
    URL = 'https://coinmarketcap.com/es/currencies/bitcoin/'

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.49","Accept-Encoding":"gzip,deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8","DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

    page = requests.get(URL, headers= headers)

    soup1 = BeautifulSoup(page.content, "html.parser") 
    soup2 = BeautifulSoup(soup1.prettify(),'html.parser')
    coin = soup2.find('h1',{'class':'priceHeading'}).get_text()
    price = soup2.find('div',{'class':'priceValue'}).get_text()
    date_time = datetime.datetime.now()
    coin = coin.strip()
    price = price.strip()
    header = ['coin', 'price','date_time']
    data = [coin, price, date_time]

    with open('web_scraper_project.csv','a+', newline='',encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
    


# In[24]:


import pandas as pd
df = pd.read_csv(r'C:\Users\roger\web_scraper_project.csv')
print(df)


# In[29]:


#set the tempo and run 
while(True):
    check_price()
    time.sleep(30)


# In[30]:


import pandas as pd
df = pd.read_csv(r'C:\Users\roger\web_scraper_project.csv')
print(df)


# In[ ]:


def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('example@example.com', 'Password')
    
    Subject = "The bitcoin price reach your goal"
    body = "hey the bitcoin is now at the price we have been waiting for. Now is your chance to buy'
    
    msg = f'Subject: {subject}\n\n{body}'
    
    Server.sendmail(
        'example@example.com',
        msg
    )
    
    if(price < 20.000):
        send_mail()
    

