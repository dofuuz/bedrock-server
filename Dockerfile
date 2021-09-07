# Docker image for Minecraft Bedrock dedicated server
# https://github.com/dofuuz/bedrock-server

FROM ubuntu:20.04

# update packages and install dependencies
RUN apt-get update \
    && apt-get install -y unzip curl nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run_bedrock.sh /opt

RUN mkdir /opt/bedrock \
    && chmod +x /opt/run_bedrock.sh

VOLUME /opt/bedrock

EXPOSE 19132/udp 19133/udp

WORKDIR /opt/bedrock
CMD ../run_bedrock.sh
