#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then set -a; . ./.env; set +a; fi

./gradlew bootJar -q
JAR=$(find build/libs -maxdepth 1 -type f -name "*.jar" ! -name "*-plain.jar" -print -quit)

if [[ -n "$JAR" ]]; then
    exec java -XX:TieredStopAtLevel=1 -Xms128m -Xmx256m -jar "$JAR"
else
    echo "ERROR: executable JAR not found"
    exit 1
fi   
