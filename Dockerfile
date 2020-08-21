FROM bde2020/hadoop-base:2.0.0-hadoop3.2.1-java8

ARG HIVE_VERSION=3.1.2

ENV HIVE_VERSION=${HIVE_VERSION:-3.1.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION

WORKDIR /opt


#COPY apache-hive-${HIVE_VERSION}-bin.tar.gz /opt
#COPY sources.list /etc/apt/

RUN apt-get update && apt-get install -y wget procps && \
        wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	tar -xzf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv apache-hive-$HIVE_VERSION-bin hive && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz && \
	rm  -f ./hive/lib/guava-19.0.jar && \
        wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar && \
	cp ./hadoop-${HADOOP_VERSION}/share/hadoop/hdfs/lib/guava-27.0-jre.jar ./hive/lib/ && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#COPY postgresql-42.2.14.jar $HIVE_HOME/lib/postgresql-jdbc.jar

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10000
EXPOSE 10002

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh
