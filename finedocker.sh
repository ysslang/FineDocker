#!/usr/bin/env bash
set -e

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=$(ls -ld "$PRG")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' >/dev/null; then
    PRG="$link"
  else
    PRG=$(dirname "$PRG")/"$link"
  fi
done

# Get standard environment variables
PRGDIR=$(dirname "$PRG")

# Only set CATALINA_HOME if not already set
[ -z "$CATALINA_HOME" ] && CATALINA_HOME=$(
  cd "$PRGDIR/tomcat" >/dev/null
  pwd
)

# Copy CATALINA_BASE from CATALINA_HOME if not already set
[ -z "$CATALINA_BASE" ] && CATALINA_BASE="$CATALINA_HOME"


# ----- Execute The Requested Command -----------------------------------------

if [ "$1" = 'pause' ]; then
  shift
  if [ "$#" = 0 ]; then
    exec gosu root sleep 60
  elif [ "$1" ] >0; then
    exec gosu root sleep $1
  fi

elif [ "$1" = 'run' ] || [ "$1" = 'start' ] || [ "$1" = 'stop' ] || [ "$1" = 'jpda' ] || [ "$1" = 'debug' ] || [ "$1" = '-force' ] || [ "$1" = 'configtest' ] || [ "$1" = 'version' ]; then
  exec gosu root "$CATALINA_HOME"/bin/catalina.sh "$@"

elif [ "$1" = '--help' ] || [ "$1" = '-h' ]; then
  echo "Usage: finedocker.sh ( commands ... )"
  echo "commands including normal catalina.sh commands:"
  echo "  debug             Start Catalina in a debugger"
  echo "  debug -security   Debug Catalina with a security manager"
  echo "  jpda start        Start Catalina under JPDA debugger"
  echo "  run               Start Catalina in the current window"
  echo "  run -security     Start in the current window with security manager"
  echo "  start             Start Catalina in a separate window"
  echo "  start -security   Start in a separate window with security manager"
  echo "  stop              Stop Catalina, waiting up to 5 seconds for the process to end"
  echo "  stop n            Stop Catalina, waiting up to n seconds for the process to end"
  echo "  stop -force       Stop Catalina, wait up to 5 seconds and then use kill -KILL if still running"
  echo "  stop n -force     Stop Catalina, wait up to n seconds and then use kill -KILL if still running"
  echo "  configtest        Run a basic syntax check on server.xml - check exit code for result"
  echo "  version           What version of tomcat are you running?"
  echo "Note: Waiting for the process to end and use of the -force option require that \$CATALINA_PID is defined"
  echo ""
  echo "with other special commands:"
  echo "  pause [seconds]   Keep container running for a few seconds (default 60s)"

  exit 1

else
  exec "$@"

fi

