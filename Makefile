
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
JFLEX_VERSION = 1.7.0
CUP_VERSION = 11b

JFLEX = @java -Xmx128m -jar .$(OS_SEP)lib$(OS_SEP)jflex-full-$(JFLEX_VERSION).jar
CUP = @java -Xmx128m -jar .$(OS_SEP)lib$(OS_SEP)java-cup-$(CUP_VERSION).jar

CUP_RUNTIME = .$(OS_SEP)lib$(OS_SEP)java-cup-$(CUP_VERSION)-runtime.jar
RUN_CLASSPATH = "$(CLASSPATH)$(CP_SEP)$(CUP_RUNTIME)$(CP_SEP)$(BUILD_DIR)"


all: jflex cup java

$(BUILD_DIR):
ifdef OS
	@IF NOT EXIST "$(BUILD_DIR)" mkdir "$(BUILD_DIR)";
else
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir "$(BUILD_DIR)"; fi
endif

jflex: $(BUILD_DIR) Gachaneitor.lex
	${JFLEX} -d $(BUILD_DIR) Gachaneitor.lex

cup: $(BUILD_DIR) Gachaneitor.cup
	${CUP} -destdir $(BUILD_DIR) Gachaneitor.cup

java: $(BUILD_DIR) $(BUILD_DIR)$(OS_SEP)Lexer.java $(BUILD_DIR)$(OS_SEP)parser.java $(BUILD_DIR)$(OS_SEP)sym.java
	javac -cp "$(CLASSPATH)$(CP_SEP)$(CUP_RUNTIME)" -d $(BUILD_DIR) -encoding utf8 "$(BUILD_DIR)$(OS_SEP)Lexer.java" "$(BUILD_DIR)$(OS_SEP)parser.java" "$(BUILD_DIR)$(OS_SEP)sym.java"

run-lexer: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp $(RUN_CLASSPATH) gachaneitor.Lexer recipe.txt

run: recipe.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	java -cp $(RUN_CLASSPATH) gachaneitor.parser recipe.txt


error-lexer: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp $(RUN_CLASSPATH) gachaneitor.Lexer recipe-error.txt

error: recipe-error.txt $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)Lexer.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)parser.class $(BUILD_DIR)$(OS_SEP)gachaneitor$(OS_SEP)sym.class
	@java -cp $(RUN_CLASSPATH) gachaneitor.parser recipe-error.txt


clean:
	$(RM) $(BUILD_DIR)