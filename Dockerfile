FROM ubuntu

MAINTAINER shen

ENV TZ=America/New_York
ENV GOREL go1.14.13.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin

RUN apt-get update 

Run apt-get install -y --no-install-recommends \
	wget \
        curl 

Run apt-get install -y --no-install-recommends \
	net-tools \
	npm 

Run apt-get install -y --no-install-recommends \
	ssh \
	docker.io 

Run apt-get install -y --no-install-recommends \
	docker-compose \
	git 



RUN wget -q https://storage.googleapis.com/golang/$GOREL && \
    tar xfz $GOREL && \
    mv go /usr/local/go && \
    rm -f $GOREL

WORKDIR /workspace


