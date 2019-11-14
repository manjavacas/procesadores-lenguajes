
ifdef OS
   RM = del /Q
else
   ifeq ($(shell uname), Linux)
      RM = rm -f
   endif
endif

all: jflex java

jflex: Gachaneitor.lex
	jflex Gachaneitor.lex


java: gachaneitor.java
	javac -encoding utf8 gachaneitor.java

run: gachaneitor.class recipe.txt
	java gachaneitor recipe.txt

error: gachaneitor.class recipe-error.txt
	java gachaneitor recipe-error.txt

clean:
	$(RM) *.java
	$(RM) *~
	$(RM) *.class