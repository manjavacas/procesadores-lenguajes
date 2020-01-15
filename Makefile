
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

all: jflex cup java

$(BUILD_DIR):
ifdef OS
	@IF NOT EXIST "$(BUILD_DIR)" mkdir "$(BUILD_DIR)";
else
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir "$(BUILD_DIR)"; fi
endif

jflex: $(BUILD_DIR) Gachaneitor.lex
	jflex -d $(BUILD_DIR) Gachaneitor.lex

cup: $(BUILD_DIR) Gachaneitor.cup
	cup -destdir $(BUILD_DIR) Gachaneitor.cup

java: $(BUILD_DIR) $(BUILD_DIR)$(OS_SEP)Lexer.java $(BUILD_DIR)$(OS_SEP)parser.java $(BUILD_DIR)$(OS_SEP)sym.java
	javac -d $(BUILD_DIR) -encoding utf8 "$(BUILD_DIR)$(OS_SEP)Lexer.java" "$(BUILD_DIR)$(OS_SEP)parser.java" "$(BUILD_DIR)$(OS_SEP)sym.java"

run-lexer: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH)$(CP_SEP)$(BUILD_DIR)" gachaneitor.Lexer recipe.txt

run: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH)$(CP_SEP)$(BUILD_DIR)" gachaneitor.parser recipe.txt


error-lexer: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH)$(CP_SEP)$(BUILD_DIR)" gachaneitor.Lexer recipe-error.txt

error: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp "$(CLASSPATH)$(CP_SEP)$(BUILD_DIR)" gachaneitor.parser recipe-error.txt


clean:
	$(RM) $(BUILD_DIR)