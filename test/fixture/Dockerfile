FROM busybox:1.36
RUN mkdir /www && echo ok > /www/index.html
CMD ["httpd", "-f", "-p", "8080", "-h", "/www"]
