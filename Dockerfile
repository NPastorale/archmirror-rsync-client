FROM alpine:latest
LABEL maintainer="npastorale@gmail.com"

RUN apk update && \
    apk --no-cache add rsync bash curl

ADD rsync.sh /
ADD mirrors.txt /

RUN chmod +x /rsync.sh

CMD ["/rsync.sh"]