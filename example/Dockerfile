ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG JAVA_VERSION
FROM fuljo/spark-driver:${SPARK_VERSION}-hadoop${HADOOP_VERSION}-java${JAVA_VERSION}
ARG JAVA_VERSION

# Application information
ENV APP_NAME=app
ENV APP_DIR=/usr/src/${APP_NAME}
ENV APP_MAIN_CLASS=com.fuljo.example.WordCount
ENV APP_ARGS=""

# Install Maven
RUN apk add --no-cache openjdk${JAVA_VERSION} maven

# Enter the application directory
WORKDIR ${APP_DIR}

# Copy the POM and resolve dependencies
COPY pom.xml ./
RUN mvn dependency:resolve && \
    mvn verify

# Copy and build the source code, determine name of the JAR and persist it at runtime
COPY . ${APP_DIR}
RUN mvn clean package \
 && BUILD_DIR=$(mvn help:evaluate -Dexpression=project.build.directory -q -DforceStdout) \
 && JAR_NAME=$(mvn help:evaluate -Dexpression=project.build.finalName -q -DforceStdout) \
 && echo APP_JAR_LOCATION="$BUILD_DIR/$JAR_NAME.jar" > .env

# Run the submit script
CMD ["/bin/bash", "/driver.sh"]