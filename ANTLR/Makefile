
ifdef OS
   RM = del /Q /S
   OS_SEP = \\
   CP_SEP = ;
else
   ifeq ($(shell uname), Linux)
      RM = rm -rf
	  OS_SEP = /
	  CP_SEP = :
   endif
endif

BUILD_DIR = .$(OS_SEP)build
ANTLR4_VERSION = 4.7.2

ANTLR4_LIB = .$(OS_SEP)lib$(OS_SEP)antlr-$(ANTLR4_VERSION)-complete.jar
ANTLR4 = @java -Xmx128m -jar $(ANTLR4_LIB)

RUN_CLASSPATH = "$(CLASSPATH)$(CP_SEP)$(ANTLR4_LIB)$(CP_SEP)$(BUILD_DIR)"

all: antlr java

$(BUILD_DIR):
ifdef OS
	@IF NOT EXIST "$(BUILD_DIR)" mkdir "$(BUILD_DIR)";
else
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir "$(BUILD_DIR)"; fi
endif

antlr: $(BUILD_DIR) Gachaneitor.g4
	$(ANTLR4) -encoding utf-8 -o $(BUILD_DIR) Gachaneitor.g4

java: $(BUILD_DIR) $(BUILD_DIR)$(OS_SEP)GachaneitorParser.java Gachaneitor.java GachaneitorWalker.java
	javac -cp "$(CLASSPATH)$(CP_SEP)$(ANTLR4_LIB)" -d $(BUILD_DIR) Gachaneitor*.java $(BUILD_DIR)$(OS_SEP)*.java


run: $(BUILD_DIR)$(OS_SEP)Gachaneitor.class
	@java -cp $(RUN_CLASSPATH) Gachaneitor recipe.txt

run-gui:
	@java -cp $(RUN_CLASSPATH) org.antlr.v4.gui.TestRig Gachaneitor menu -gui recipe.txt


clean:
	$(RM) $(BUILD_DIR)