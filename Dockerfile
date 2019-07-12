# Use phusion/baseimage as base image.
FROM phusion/baseimage:0.11

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# update packages and install dependencies
RUN apt-get update \
    && apt-get install -y unzip libcurl4 curl libssl1.1 nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run_bedrock.sh /opt

RUN mkdir /opt/bedrock \
    && chmod +x /opt/run_bedrock.sh

VOLUME /opt/bedrock

EXPOSE 19132/udp 19133/udp

ENTRYPOINT /opt/run_bedrock.sh
