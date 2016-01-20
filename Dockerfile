FROM alpine:3.2
COPY entry.sh /entry.sh
COPY print.sh /print.sh
RUN chmod +x /entry.sh /print.sh
ENTRYPOINT ["/entry.sh"]
