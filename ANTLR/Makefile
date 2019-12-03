


ifdef OS
   RM = del /Q /S
   BUILD_DIR = .\build
   OS_SEP = \\
else
   ifeq ($(shell uname), Linux)
      RM = rm -rf
	  BUILD_DIR = ./build
	  OS_SEP = /
   endif
endif


all: gachaneitor

builddir:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"


gachaneitor: builddir $(BUILD_DIR)$(OS_SEP)Gachaneitor.class

$(BUILD_DIR)$(OS_SEP)GachaneitorParser.java: Gachaneitor.g4
	antlr4 -encoding utf-8 -o $(BUILD_DIR) Gachaneitor.g4

$(BUILD_DIR)$(OS_SEP)Gachaneitor.class: $(BUILD_DIR)$(OS_SEP)GachaneitorParser.java Gachaneitor.java GachaneitorWalker.java
	javac -d $(BUILD_DIR) Gachaneitor*.java $(BUILD_DIR)$(OS_SEP)*.java

run: $(BUILD_DIR)$(OS_SEP)Gachaneitor.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" Gachaneitor recipe.txt

/*run-gui:
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" org.antlr.v4.gui.TestRig Gachaneitor menu -gui recipe.txt*/



clean:
	$(RM) $(BUILD_DIR)