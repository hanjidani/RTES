#!/bin/bash

# Variables
SERVICE_NAME="scrape_news"
SCRIPT_NAME="scrape_news.py"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_PATH="/usr/local/bin/${SCRIPT_NAME}"
NEWS_FILE="/var/log/news.txt"  # Ensure this path is writable by the service

# Create the Python script
echo "Creating Python script..."
cat << 'EOF' > ${SCRIPT_PATH}
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
EOF

# Make the script executable
chmod +x ${SCRIPT_PATH}
echo "Python script created at ${SCRIPT_PATH}"

# Create the systemd service file
echo "Creating systemd service..."
cat << EOF > ${SERVICE_FILE}
[Unit]
Description=Run ${SCRIPT_NAME} at startup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 ${SCRIPT_PATH}
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service to run at startup
systemctl enable ${SERVICE_NAME}.service

# Start the service immediately
systemctl start ${SERVICE_NAME}.service

# Check the status of the service
systemctl status ${SERVICE_NAME}.service

echo "Systemd service ${SERVICE_NAME} created and started successfully."
