FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/ssl/certs

RUN mkdir -p /etc/ssl/certs && \
    openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/ssl/certs/inception.key \
    -out /etc/ssl/certs/inception.crt \
    -subj "/CN=yutsasak.42.fr" && \
    chmod 400 /etc/ssl/certs/inception.key

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
