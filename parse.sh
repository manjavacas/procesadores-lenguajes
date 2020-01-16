export CUP_RUNTIME="./lib/java-cup-11b-runtime.jar"
export BUILD_DIR="./build/"

java -cp "$CLASSPATH:$CUP_RUNTIME:$BUILD_DIR" gachaneitor.parser $@