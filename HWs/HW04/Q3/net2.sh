USERNAME="0150261535"
PASSWORD="Ho13811381"



# Function to log in to 2net
login() {
  curl "https://net2.sharif.edu/login" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
  -H "Accept-Language: en-US,en;q=0.9,fa-IR;q=0.8,fa;q=0.7,de;q=0.6" \
  -H "Cache-Control: max-age=0" \
  -H "Connection: keep-alive" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Cookie: _ga=GA1.2.361965621.1717781814; _ga_X20DTCZT6F=GS1.2.1717781815.1.0.1717781815.0.0.0" \
  -H "Origin: https://net2.sharif.edu" \
  -H "Referer: https://net2.sharif.edu/login" \
  -H "Sec-Fetch-Dest: document" \
  -H "Sec-Fetch-Mode: navigate" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "Sec-Fetch-User: ?1" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0" \
  -H "sec-ch-ua: \"Firefox\";v=\"101\", \"Not/A)Brand\";v=\"99\", \"Gecko\";v=\"101\"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: \"Windows\"" \
  --data-raw "username=${USERNAME}&password=${PASSWORD}";
}

# Check connection every 10 seconds and re-login if needed
export counter=1
while [ true ]
do
  echo "Checking connection..."
  if ! curl "https://net2.sharif.edu/login" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
  -H "Accept-Language: en-US,en;q=0.9,fa-IR;q=0.8,fa;q=0.7,de;q=0.6" \
  -H "Cache-Control: max-age=0" \
  -H "Connection: keep-alive" \
  -H "Cookie: _ga=GA1.2.361965621.1717781814; _ga_X20DTCZT6F=GS1.2.1717781815.1.0.1717781815.0.0.0" \
  -H "Referer: https://net2.sharif.edu/login" \
  -H "Sec-Fetch-Dest: document" \
  -H "Sec-Fetch-Mode: navigate" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "Sec-Fetch-User: ?1" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0" \
  -H "sec-ch-ua: \"Firefox\";v=\"101\", \"Not/A)Brand\";v=\"99\", \"Gecko\";v=\"101\"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: \"Windows\"" | grep -q "logged"; then
    
    echo "Connection checked you are not logged in ...."
    echo "Trying to login ..."
    login
  else
    echo "You have already logged in."
  fi
  counter=$((counter+1))
  sleep 10
done
