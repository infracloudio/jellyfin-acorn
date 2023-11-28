FROM nginx
COPY aws-config.sh aws-config.sh
CMD bash -c "./aws-config.sh && nginx -g 'daemon off;'"