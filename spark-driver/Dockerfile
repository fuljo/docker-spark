ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG JAVA_VERSION
FROM fuljo/spark-base:${SPARK_VERSION}-hadoop${HADOOP_VERSION}-java${JAVA_VERSION}
ARG JAVA_VERSION

# Application information (to be configured)
ENV APP_MAIN_CLASS=""
ENV APP_JAR_LOCATION=""

# Master url
# ENV SPARK_MASTER_URL is inherited from base image

# Event logging (needed by history server)
ENV SPARK_EVENTLOG_ENABLED=1
# ENV SPARK_EVENTLOG_DIR=""

# Copy scripts
COPY ./driver.sh /

# Run scripts
CMD ["/bin/bash", "/driver.sh"]