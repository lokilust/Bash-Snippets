#!/bin/bash
# Author: Alexander Epstein https://github.com/alexanderepstein
checkInternet()
{
  echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    return 0
  else
    echo "Error: no active internet connection" >&2
    return 1
  fi
}

getStockInformation()
{
  symbol=$1
  stockInfo=$(curl -s  "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=KPCCCRJVMOGN9L6T") > /dev/null
  export PYTHONIOENCODING=utf8
  echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['02. Exchange Name']" > /dev/null 2>&1 || { echo "Not a valid stock symbol" ; exit 1; }
  exchangeName=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['02. Exchange Name']")
  latestPrice=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['03. Latest Price']")
  open=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['04. Open (Current Trading Day)']")
  high=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['05. High (Current Trading Day)']")
  low=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['06. Low (Current Trading Day)']")
  close=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['07. Close (Previous Trading Day)']")
  priceChange=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['08. Price Change']")
  priceChangePercentage=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['09. Price Change Percentage']")
  volume=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['10. Volume (Current Trading Day)']")
  lastUpdated=$(echo $stockInfo | python -c "import sys, json; print json.load(sys.stdin)['Realtime Global Securities Quote']['11. Last Updated']")
}
printStockInformation()
{
  echo
  echo $symbol stock info
  echo "============================================="
  echo Exchange Name: $exchangeName
  echo Latest Price: $latestPrice
  if [[ $open != "--" ]];then echo "Open (Current Trading Day): $open"; fi
  if [[ $high != "--" ]];then echo "High (Current Trading Day): $high"; fi
  if [[ $low != "--" ]];then echo "Low (Current Trading Day): $low"; fi
  echo "Close (Previous Trading Day): $close"
  echo "Price Change: $priceChange"
  if [[ $priceChangePercentage != "%" ]];then echo "Price Change Percentage: $priceChangePercentage"; fi
  if [[ $volume != "--" ]];then echo "Volume (Current Trading Day): $volume"; fi
  echo "Last Updated: $lastUpdated"
  echo "============================================="
  echo
}

checkInternet || exit 1
getStockInformation $1
printStockInformation
