#!/bin/bash

if [ "$SPARK_MODE" == "master" ]; then
  # Run as master
  "${SPARK_HOME}"/sbin/start-master.sh
elif [ "$SPARK_MODE" == "worker" ]; then
  # Run as worker
  "${SPARK_HOME}"/sbin/start-worker.sh "$SPARK_MASTER_URL"
elif [ "$SPARK_MODE" == "history-server" ]; then
  # Set web ui port
  if [ "${SPARK_HISTORY_WEBUI_PORT}" ]; then
    SPARK_HISTORY_OPTS= \
      "-Dspark.history.ui.port=${SPARK_HISTORY_WEBUI_PORT}" +
      " ${SPARK_HISTORY_OPTS}"
  fi
  # Set event log path
  if [ "${SPARK_HISTORY_FS_LOGDIRECTORY}" ]; then
    SPARK_HISTORY_OPTS= \
      "-Dspark.history.fs.logDirectory=${SPARK_HISTORY_FS_LOGDIRECTORY}" +
      " ${SPARK_HISTORY_OPTS}"
  fi
  # Run history server
  "${SPARK_HOME}"/sbin/start-history-server.sh
else
  echo "ERROR: Unrecognized SPARK_MODE \"$SPARK_MODE\" "
fi
