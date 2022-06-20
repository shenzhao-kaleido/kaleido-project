FROM ubuntu

MAINTAINER shen

ENV TZ=America/New_York
ENV LANG C.UTF-8
ENV GO_VERSION go1.18
ENV EXTENSION linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
ENV GOSRC $GOPATH/src
# ENV APP app

RUN sudo apt install -y \
    net-tools \
    npm
RUN apt-get update -y \
  && apt-get install --no-install-recommends -yq \
    ssh \
    docker.io \
    wget \
    git \
  && wget https://storage.googleapis.com/golang/${GO_VERSION}.${EXTENSION} -o /tmp/${GO_VERSION}.${EXTENSION} \
  && tar -zxvf ${GO_VERSION}.${EXTENSION} -C /usr/local \
  && rm ${GO_VERSION}.${EXTENSION} 
RUN mkdir /workspace
WORKDIR /workspace
