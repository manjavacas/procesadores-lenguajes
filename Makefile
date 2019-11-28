
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

all: jflex java

builddir:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"

jflex: builddir Gachaneitor.lex
	jflex -d $(BUILD_DIR) Gachaneitor.lex

java: builddir $(BUILD_DIR)$(OS_SEP)gachaneitor.java
	javac -d $(BUILD_DIR) -encoding utf8 "$(BUILD_DIR)$(OS_SEP)gachaneitor.java"

run: $(BUILD_DIR)$(OS_SEP)gachaneitor.class recipe.txt
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor recipe.txt

error: $(BUILD_DIR)$(OS_SEP)gachaneitor.class recipe-error.txt
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor recipe-error.txt

clean:
	$(RM) $(BUILD_DIR)$(OS_SEP)*.java
	$(RM) $(BUILD_DIR)$(OS_SEP)*~
	$(RM) $(BUILD_DIR)$(OS_SEP)*.class