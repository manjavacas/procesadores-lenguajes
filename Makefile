
ifdef OS
   RM = del /Q
else
   ifeq ($(shell uname), Linux)
      RM = rm -f
   endif
endif

all: jflex

jflex: Gachaneitor.lex
	jflex Gachaneitor.lex


java: Yylex.java
	javac -encoding utf8 Yylex.java

clean:
	$(RM) *.java
	$(RM) *~
	$(RM) *.class