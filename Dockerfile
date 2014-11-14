############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM c12e/debian
MAINTAINER CognitiveScale (bill@cognitivescale.com)

# Update the default application repository sources list
RUN apt-get update

# Install supervisord
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor /data /logs

# Install OrientDB dependencies
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-orientdb-on-an-ubuntu-12-04-vps
RUN apt-get -y install git ant maven

ENV ORIENTDB_VERSION 2.0-M2

# Build OrientDB cleaning up afterwards
RUN cd  && \
    git clone https://github.com/orientechnologies/orientdb.git --single-branch --depth 1 --branch $ORIENTDB_VERSION && \
    git clone https://github.com/orientechnologies/orientdb-lucene.git && \
    cd orientdb && \
    ant clean installg && \
    cd ../orientdb-lucene && \
    mvn assembly:assembly && \
    cd ~ && \
    mv ~/releases/orientdb-community-${ORIENTDB_VERSION} /opt && \
    rm -rf /opt/orientdb-community-${ORIENTDB_VERSION}/databases/* ~/orientdb && \
    mv ~/orientdb-lucene/target/orientdb-lucene-${ORIENTDB_VERSION}-dist.jar \
      /opt/orientdb-community-${ORIENTDB_VERSION}/plugins && \
    ln -s /opt/orientdb-${ORIENTDB_VERSION} /opt/orientdb

# use supervisord to start orientdb
ADD supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 2424
EXPOSE 2480

# Set the user to run OrientDB daemon
USER root

# Default command when starting the container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
