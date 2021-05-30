ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG JAVA_VERSION

# Choose how to run the container: master | worker | history-server
ENV SPARK_MODE="master"

# Reachable address outside the containers, used for links in web UIs
ENV SPARK_PUBLIC_DNS=localhost

# Master options
ENV SPARK_MASTER_HOST=spark-master
ENV SPARK_MASTER_PORT=7077
ENV SPARK_MASTER_WEBUI_PORT=8080
# ENV SPARK_MASTER_OPTS=""

# Worker options
ENV SPARK_MASTER_URL=spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}
# ENV SPARK_WORKER_CORES=""
# ENV SPARK_WORKER_MEMORY=""
# ENV SPARK_WORKER_PORT=""
ENV SPARK_WORKER_WEBUIPORT=8081
# ENV SPARK_WORKER_DIR=""
# ENV SPARK_WORKER_OPTS=""

# History Server options
ENV SPARK_HISTORY_WEBUI_PORT=18080
# ENV SPARK_HISTORY_FS_LOGDIRECTORY=""
# ENV SPARK_HISTORY_OPTS=""

# Generic options for all daemons
# ENV SPARK_CONF_DIR=""
# ENV SPARK_LOG_DIR=""
# ENV SPARK_LOG_MAX_FILES=""
# ENV SPARK_PID_DIR=""
# ENV SPARK_IDENT_STRING=""
# ENV SPARK_NICENESS=""

# Expose relevant ports
EXPOSE ${SPARK_MASTER_PORT}
EXPOSE ${SPARK_MASTER_WEBUI_PORT}
EXPOSE ${SPARK_WORKER_WEBUIPORT}
EXPOSE ${SPARK_HISTORY_WEBUI_PORT}

# Prevent the container from exiting immediately
ENV SPARK_NO_DAEMONIZE=1

# These are intended for internal use only
ENV SPARK_ARCHIVE=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ENV SPARK_HOME=/opt/spark

# Install dependencies, spark (with integrated hadoop) and create user
RUN apk add --no-cache curl bash procps coreutils openjdk${JAVA_VERSION}-jre \
 && wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_ARCHIVE} \
 && mkdir -p /opt/spark \
 && tar -xvf ${SPARK_ARCHIVE} --strip-components 1 -C ${SPARK_HOME} \
 && rm ${SPARK_ARCHIVE}

# Copy scripts
COPY ./run.sh ./

# Run scripts
CMD ["/bin/bash", "./run.sh"]


