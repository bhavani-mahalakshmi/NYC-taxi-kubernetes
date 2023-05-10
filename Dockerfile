# Base image: ubuntu:22.04
FROM ubuntu:22.04

# ARGs
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG TARGETPLATFORM=linux/amd64,linux/arm64
ARG DEBIAN_FRONTEND=noninteractive

# neo4j 5.5.0 installation and some cleanup
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' > /etc/apt/sources.list.d/neo4j.list && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y nano unzip neo4j=1:5.5.0 python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# TODO: Complete the Dockerfile

## Step 1 - Loading the data
#Git installation
RUN apt-get update && apt-get install -y git

#Creating the work dir
RUN mkdir /cse511
WORKDIR /cse511

#Clone the repo
RUN git clone https://oauth2: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@github.com/CSE511-SPRING-2023/bgowrisa-project-2.git /cse511
RUN wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-03.parquet

#Installing python packages
RUN apt-get update && \
    pip3 install --upgrade pip && \
    pip3 install pandas pyarrow neo4j requests

#Setting up neo4j password
RUN neo4j-admin dbms set-initial-password project2phase1

#Setting up neo4j config
RUN sed -i 's/#server.default_listen_address=0.0.0.0/server.default_listen_address=0.0.0.0/g' /etc/neo4j/neo4j.conf && \
     sed -i 's/#dbms.security.procedures.unrestricted=my.extensions.example,my.procedures./dbms.security.procedures.unrestricted=gds./g' /etc/neo4j/neo4j.conf && \
     sed -i 's/#dbms.security.procedures.allowlist=apoc.coll.,apoc.load.,gds./dbms.security.procedures.allowlist=gds./g' /etc/neo4j/neo4j.conf 

## Step 2 - Setting up neo4j GDS plugin
RUN apt-get install -y curl && \
    curl -L https://graphdatascience.ninja/neo4j-graph-data-science-2.3.1.zip -o /cse511/neo4j-gds.zip \
    && unzip /cse511/neo4j-gds.zip -d /cse511/neo4j-gds \
    && mv /cse511/neo4j-gds/*.jar /var/lib/neo4j/plugins/ \
    && rm -rf /cse511/neo4j-gds.zip /cse511/neo4j-gds \
    && mv /var/lib/neo4j/labs/*.jar /var/lib/neo4j/plugins/

# Run the data loader script
RUN chmod +x /cse511/data_loader.py && \
    neo4j start && \
    python3 data_loader.py && \
    neo4j stop

# Expose neo4j ports
EXPOSE 7474 7687

# Start neo4j service and show the logs on container run
CMD ["/bin/bash", "-c", "neo4j start && tail -f /dev/null"]