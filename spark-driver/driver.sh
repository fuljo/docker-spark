#!/bin/bash

# Load JAR location and other variables that may have been set
if [ -f .env ]; then
  source .env
fi

echo "Jar Location: $APP_JAR_LOCATION"

# Add option for class to run
if [ "$APP_MAIN_CLASS" != "" ]; then
  # If a main class is specified explicitly, run that
  SPARK_CONF_OPTS+="--class $APP_MAIN_CLASS "
  # Otherwise the main class specified in the JAR is ran
fi

# Add event logging configuration options
if [ "${SPARK_EVENTLOG_ENABLED}" ]; then
  # Enable logging
  SPARK_CONF_OPTS+="--conf spark.eventLog.enabled=true"
  # Specify directory
  if [ "${SPARK_EVENTLOG_DIR}" ]; then
    SPARK_CONF_OPTS+="--conf spark.eventLog.dir=$SPARK_EVENTLOG_DIR"
  fi
fi

set -x
# Submit application to the master
"${SPARK_HOME}"/bin/spark-submit \
  --master "$SPARK_MASTER_URL" \
  --deploy-mode client \
  $SPARK_CONF_OPTS \
  "$APP_JAR_LOCATION" $APP_ARGS
set +x

