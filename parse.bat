@echo off

set CUP_RUNTIME=".\lib\java-cup-11b-runtime.jar"
set BUILD_DIR=".\build"

java -cp %CLASSPATH%;%CUP_RUNTIME%;%BUILD_DIR% gachaneitor.parser %*