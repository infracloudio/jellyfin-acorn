#!/bin/bash


# apt update
# apt install unzip -y
# apt install cron -y
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# ./aws/install


function cronjobexecution(){
    env >> /etc/environment
    cat <<EOF > cron_aws_script.sh
#!/bin/bash

val=\$AWS_S3_BUCKET

echo "bucket name is new \$val"

/usr/local/bin/aws s3 cp s3://\$AWS_S3_BUCKET /jellyfinmedia --recursive
EOF
    chmod +x cron_aws_script.sh
    echo "*/1 * * * * root /bin/bash /cron_aws_script.sh >> /cron_log.txt 2>&1" >> /etc/crontab
    #service cron start
}

rm -rf /jellfinmedia/lost+found
echo "CRONTAB_STATUS is true"
cronjobexecution

tail -f /dev/null

# if [ "$CRONTAB_STATUS" == "true" ]
# then
#     echo "CRONTAB_STATUS is true"
#     cronjobexecution
# else
#     echo "Inside the else statement"
#     aws s3 cp s3://$AWS_S3_BUCKET /jellyfinmedia --recursive
# fi
