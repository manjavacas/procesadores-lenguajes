
ifdef OS
   RM = del /Q
   BUILD_DIR = .\build
   OS_SEP = \\
else
   ifeq ($(shell uname), Linux)
      RM = rm -f
	  BUILD_DIR = ./build
	  OS_SEP = /
   endif
endif


all: jflex cup java

builddir:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"

jflex: builddir Gachaneitor.lex
	jflex -d $(BUILD_DIR) Gachaneitor.lex

cup: builddir Gachaneitor.cup
	cup -destdir $(BUILD_DIR) Gachaneitor.cup

java: builddir $(BUILD_DIR)$(OS_SEP)gachaneitor.java $(BUILD_DIR)$(OS_SEP)parser.java $(BUILD_DIR)$(OS_SEP)sym.java
	javac -d $(BUILD_DIR) -encoding utf8 "$(BUILD_DIR)$(OS_SEP)gachaneitor.java" "$(BUILD_DIR)$(OS_SEP)parser.java" "$(BUILD_DIR)$(OS_SEP)sym.java"


run: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor.class $(BUILD_DIR)$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor recipe.txt

error: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor.class $(BUILD_DIR)$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor recipe-error.txt


clean:
	$(RM) $(BUILD_DIR)$(OS_SEP)*.java
	$(RM) $(BUILD_DIR)$(OS_SEP)*~
	$(RM) $(BUILD_DIR)$(OS_SEP)*.class