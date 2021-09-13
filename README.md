# Apache Spark images for Docker

Non-official Docker images to:
- Set up a [Standalone](https://spark.apache.org/docs/latest/spark-standalone.html) Apache Spark cluster with
    - A master node
    - Multiple workers
    - A history server
- Package and run Spark-enabled Java applications inside the cluster

Two images are featured:
- [`fuljo/spark-base`](https://hub.docker.com/r/fuljo/spark-base) can be configured to run as a master, worker or history server
- [`fuljo/spark-driver`](https://hub.docker.com/r/fuljo/spark-driver) can be used to derive an image to run an application

We also provide an example of a WordCount application.

This project aims at providing a local development/testing environment which is fast to set up and use. It hasn't been tested with Kubernetes or cloud environments.

## Supported tags
The following tags are common to both images.
Full tags are in the form `${SPARK_VERSION}-hadoop${HADOOP_VERSION}-java${JAVA_VERSION}`.

- `3.1.2-hadoop3.2-java11`, `3-java11`, `3`, `latest`
- `3.1.2-hadoop3.2-java8`, `3-java8`

Currently, I am building and releasing the images manually, so I do not guarantee to provide the latest Spark version.
So, if you need an updated version of the image which is not available yet, feel free to open an issue.
If the project gains popularity, I will consider automating the build process as new versions of Spark are released.

## Base image
Multiple instances of the `fuljo/spark-base` image suffice to run the cluster, since it can be configured to run as a master, worker or history server. The images can be further customized with the following environment variables.

- `SPARK_MODE = master | worker | history-server` : Determines what to run

Options for the master:
- `SPARK_MASTER_HOST` : Bind the master to a specific hostname or IP address, for example the name of the service.
- `SPARK_MASTER_PORT` : Start the master on a different port (default: 7077).
- `SPARK_MASTER_WEBUI_PORT` : Port for the master web UI (default: 8080). The web UI can be accessed from the host at `http://localhost:8080`
- `SPARK_MASTER_OPTS` : Additional config properties in the form `-Dx=y`.

Options for the workers:
- `SPARK_MASTER_URL` : Connect to the master at this address (default spark://spark-master:7077)
- `SPARK_WORKER_CORES` : Total number of cores to allow Spark applications to use on the machine (default: all available cores).
- `SPARK_WORKER_MEMORY` : Total amount of memory to allow Spark applications to use on the machine, e.g. 1000m, 2g (default: total memory minus 1 GiB)
- `SPARK_WORKER_PORT` : Start the Spark worker on a specific port (default: random).
- `SPARK_WORKER_WEBUIPORT` : Port for the worker web UI (default: 8081).
- `SPARK_WORKER_DIR` : Directory to run applications in, which will include both logs and scratch space (default: SPARK_HOME/work).
- `SPARK_WORKER_OPTS` : Additional config properties in the form `-Dx=y`.

Options for the history server:
- `SPARK_HISTORY_WEBUI_PORT` : Port for the web UI (default: 18080).
- `SPARK_HISTORY_FS_LOGDIRECTORY` : Directory where to read logged events (default: tmp/spark-events).
- `SPARK_HISTORY_OPTS` : Additional config properties in the form `-Dx=y`.

## Driver image
This image shall be used as a base for running your java application. Here is an example Dockerfile:
```Dockerfile
FROM fuljo/spark-driver

# Application information
ENV APP_NAME=app
ENV APP_DIR=/usr/src/${APP_NAME}
ENV APP_MAIN_CLASS=com.fuljo.example.WordCount
ENV APP_JAR_LOCATION=${APP_DIR}/word-count-1.0-SNAPSHOT.jar
ENV APP_ARGS=""

WORKDIR ${APP_DIR}

# Copy the pre-packaged application with dependencies
COPY word-count-1.0-SNAPSHOT.jar .

# Submit the application to the cluster
CMD ["/bin/bash", "/driver.sh"]
```

The configuration options for this image are:
- `APP_MAIN_CLASS` : Class-path of the main class. If empty, the main class of the JAR will be executed.
- `APP_JAR_LOCATION` : Absolute path of the JAR file to execute.
- `SPARK_MASTER_URL` : Connect to the master at this address (default spark://spark-master:7077)
- `SPARK_EVENTLOG_ENABLED` : If set, it enables logging of spark events, which can be viewed with the history server.
- `SPARK_EVENTLOG_DIR` : Directory where spark events are saved (default: tmp/spark-events).

In the `example` folder you can find a slightly more complex example, where we copy the source code inside the image, and we build the JAR using Maven.

## Running with Docker Compose
We suggest using Docker Compose to set up the cluster and running your application. Here is `example/docker-compose.yml`:
```yml
version: '3'

services:
  spark-master:
    image: fuljo/spark-base
    environment:
      - SPARK_MODE=master
      - SPARK_MASTER_HOST=spark-master
      - SPARK_MASTER_PORT=7077
    volumes:
      - events:/tmp/spark-events
    ports:
      - "8080:8080"
      - "7077:7077"
  spark-worker:
    image: fuljo/spark-base
    depends_on:
      - spark-master
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
    volumes:
      - ./data:/opt/spark/work/data
      - events:/tmp/spark-events
  spark-history:
    image: fuljo/spark-base
    depends_on:
      - spark-master
      - spark-worker
    environment:
      - SPARK_MODE=history-server
      - SPARK_EVENTLOG_ENABLED=1
    volumes:
      - events:/tmp/spark-events
    ports:
      - "18080:18080"
  spark-driver:
    image: fuljo/word-count-spark
    build: .
    depends_on:
      - spark-master
      - spark-worker
    environment:
      - APP_ARGS=/opt/spark/work/data/in.txt
      - SPARK_EVENTLOG_ENABLED=1
    volumes:
      - ./data:/opt/spark/work/data
      - events:/tmp/spark-events
volumes:
  events: {}
```

Notice that:
- We used a named volume `events`, so that the history server can see the events logged by the other nodes.
- We bound the local directory `example/data` inside both the worker and the driver. Failing to do so will prevent the application from finding the text document it has to work on.

You can run this with:
```sh
docker compose up
```
and if you want more workers:
```sh
docker compose --scale spark-worker=<num_workers> up
```

## Contributing
If you find bugs or want to request new features, please open an issue.

If you have a contribution you want to merge into the master branch, please open a pull request explaining what changes you have made.

## Credits
This project is highly inspired from Big Data Europe's [docker-spark](https://github.com/big-data-europe/docker-spark).

## License
This project is distributed under the MIT license.