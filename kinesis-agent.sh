#!/bin/bash
sudo yum update -y
sudo yum remove java-1.7.0-openjdk -y
sudo yum install java-1.8.0 -y
sudo yum install aws-kinesis-agent -y


sudo yum install git -y

wget http://media.sundog-soft.com/AWSBigData/LogGenerator.zip
unzip LogGenerator.zip
chmod a+x LogGenerator.py
sudo mkdir /var/log/cadabra

sudo cat  <<EOF > ~/agent.json
{
  "cloudwatch.emitMetrics": true,

  "flows": [
    {
      "filePattern": "/var/log/cadabra/*log",
      "deliveryStream":"PurchaseLogs"
    },
    {
      "filePattern": "/var/log/cadabra/*.log",
      "kinesisStream": "amnidhiorders",
      "partitionKeyOption": "RANDOM",
      "dataProcessingOptions": [
         {
            "optionName": "CSVTOJSON",
            "customFieldNames": ["InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "Customer", "Country"]
         }
      ]
    }
  ]
}
EOF

sudo cp ~/agent.json /etc/aws-kinesis/

sudo service aws-kinesis-agent start

sudo chkconfig aws-kinesis-agent on

sudo ./LogGenerator.py 500000
