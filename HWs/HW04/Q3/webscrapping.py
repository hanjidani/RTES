# First install bs4 and requests libraries

import requests
from bs4 import BeautifulSoup
from datetime import datetime

# Step 1: Fetch the webpage content
url = 'https://www.sharif.ir/'
response = requests.get(url)

# Step 2: Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(response.text, 'html.parser')

# Step 3: Find the news section (you need to inspect the HTML to find the correct element)
news_section = soup.find('section', {'class': 'sp-news'})  # Replace with actual class name

# Step 4: Extract news headlines
headlines = []
for news_item in news_section.find_all('div', {'class':'sp-news-item'}):  # Adjust the tag and class as per the actual HTML
    txt = news_item.find('h2').get_text(strip = True)
    headlines.append(txt)
for news_item in news_section.find_all('div', {'sp-news-announcement-item'}):  # Adjust the tag and class as per the actual HTML
    txt = news_item.find('h2').get_text(strip = True)
    headlines.append(txt)


print(headlines)

# Step 5: Save headlines to a file
with open('news.txt', 'w', encoding='utf-8') as file:
    file.write(f"Scraped on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    for headline in headlines:
        file.write(headline + '\n')

print('News headlines saved to news.txt')
