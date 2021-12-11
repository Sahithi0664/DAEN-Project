import requests
from bs4 import BeautifulSoup
import pandas as pd

def extract(page):
    headers = {'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36'}
    url = f'https://www.indeed.com/jobs?q=Senior%20Security%20Analyst&l=Washington%2C%20DC&start={page}&vjk=8b08b74089f29794'
    r = requests.get(url, headers)
    soup = BeautifulSoup(r.content,'html.parser')
    return soup
    #return r.status_code
#print(extract(0))


def transform(soup):
    divs = soup.find_all('div', class_ = 'job_seen_beacon')
    for item in divs:
        title = item.find('h2').text.strip()
        company = item.find('span', class_ = 'companyName').text.strip()
        try:
            salary = item.find('span', class_ = 'salary-snippet').text.strip()
        except:
            salary = ''
        summary = item.find('div', class_ = 'job-snippet').text.strip()
        location = item.find('div',class_ = 'companyLocation').text.strip().replace('\n','')
        #print(location)
        job = {
            'title':title,
            'company':company,
            'salary':salary,
            'summary': summary,
            'location':location
        }
        joblist.append(job)
    return

joblist = []

for i in range(0,1000,10):
    print(f'Getting page,{i}')
    c = extract(i)
    transform(c)

df = pd.DataFrame(joblist)
print(df.head())
df.to_csv('job.csv')