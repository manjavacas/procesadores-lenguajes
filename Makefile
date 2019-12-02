
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


all: jflex cup java

builddir:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"

jflex: builddir Gachaneitor.lex
	jflex -d $(BUILD_DIR) Gachaneitor.lex

cup: builddir Gachaneitor.cup
	cup -destdir $(BUILD_DIR) Gachaneitor.cup

java: builddir $(BUILD_DIR)$(OS_SEP)Lexer.java $(BUILD_DIR)$(OS_SEP)parser.java $(BUILD_DIR)$(OS_SEP)sym.java
	javac -d $(BUILD_DIR) -encoding utf8 "$(BUILD_DIR)$(OS_SEP)Lexer.java" "$(BUILD_DIR)$(OS_SEP)parser.java" "$(BUILD_DIR)$(OS_SEP)sym.java"


run-lexer: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor.Lexer recipe.txt

run: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor.parser recipe.txt


error-lexer: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor.Lexer recipe-error.txt

error: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH);$(BUILD_DIR)" gachaneitor.parser recipe-error.txt


clean:
	$(RM) $(BUILD_DIR)