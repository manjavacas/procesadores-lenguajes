/***********************************/
/*             PL - Lab            */
/*                                 */   
/*     Manjavacas Lucas, Antonio   */
/*     Márquez Villalta, Rubén     */     
/*     Pedregal Hidalgo, Diego     */
/*     Velasco Mata, Alberto       */
/***********************************/

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Stack;

import java.lang.StringBuilder;

class Utils {
    /*** KEYWORD HANDLING ***/

    private static final String[] keywords = {
        "menu", "plato", "cabecera", "nombre", "usuario",
        "raciones", "tiempo", "calorias", "tipo", "cocina",
        "programar", "calentar", "remover", "anadir", "sacar", "varoma",
        "cuchara", "espiga", "turbo",
        "l", "ml", "cucharada", "g", "ud", "al_gusto"
    };
    private static final ArrayList<String> velocidadKeywords = new ArrayList<>(Arrays.asList(
        "cuchara", "espiga", "turbo"
    ));
    private static final ArrayList<String> medidasKeywords = new ArrayList<>(Arrays.asList(
        "l", "ml", "cucharada", "g", "ud", "al_gusto"
    ));
    
    public static boolean isKeyword(String cadena) {
        for(int i = 0; i < keywords.length; i++)
            if(keywords[i].equals(cadena))
                return true;
        return false;
    }

    public static String getToken(String keyword) {
        if(velocidadKeywords.contains(keyword))
            return "<VELOCIDAD>[" + keyword + "] ";
        else if(medidasKeywords.contains(keyword)) {
            return "<MEDIDA>[" + keyword + "] ";
        }
        for(int i = 0; i < keywords.length; i++) {
            if(keywords[i].equals(keyword))
                return "<" + keywords[i].toUpperCase() + "> ";
        }
        return "NOT_A_KEYWORD[" + keyword + "] ";
    }


    /*** ERROR HANDLING ***/
    public enum Error {
        LEX_ERR_COMMENT("comment"),
        LEX_ERR_UNEXPECTED_PARENTHESIS("unexpected parenthesis"),
        LEX_ERR_EXPECTED_PARENTHESIS("expected parenthesis"),
        LEX_ERR_UNEXPECTED_BRACKET("unexpected bracket"),
        LEX_ERR_EXPECTED_BRACKET("excpected bracket");


        String message;
        private Error(String errorMessage) {
            message = errorMessage;
        }

        public String toString() {
            return message;
        }
    }

    private static class LocatedError {
        public Error error;
        public int line, column;
        public LocatedError(Error error, int line, int column) {
            this.error = error;
            this.line = line;
            this.column = column;
        }
    }

    private static ArrayList<LocatedError> errors = new ArrayList<>();
    public static void addError(Error e, int l, int c) {
        errors.add(new LocatedError(e, l+1, c+1));
    }
    public static void printErrors() {
        System.out.println();
        for(LocatedError e : errors)
            System.out.printf("Error: %s (line: %d, column: %d)\n",
                e.error.toString(),
                e.line, e.column);
    }
}



%%
%class gachaneitor
%standalone
%unicode

%line
%column

/* ------------ ESTADOS ------------*/
%state CADENA
%state COMENTARIO


/* -------- DECLARACIONES --------- */
%{
    private StringBuilder cadena = new StringBuilder();
    private Stack<Character> balance = new Stack<>();
%}

%eof{
    if(!balance.empty()) {
        Utils.addError(Utils.Error.LEX_ERR_EXPECTED_BRACKET, yyline, yycolumn);
    }
    Utils.printErrors();
%eof}

NL  = \n | \r | \r\n
BLANCO = " "
TAB =  \t

%%
<YYINITIAL> {
    // ID o PalabraReservada
    [:jletter:][:jletterdigit:]*    {
            if(Utils.isKeyword(yytext()))
                System.out.print(Utils.getToken(yytext()));
            else
                System.out.print("<ID>[" + yytext() + "] ");
        }

    :       { System.out.print("<:> "); }
    \(      { System.out.print("<(> "); balance.push('('); }
    \)      { 
                System.out.print("<)> ");
                if(balance.empty())
                    Utils.addError(Utils.Error.LEX_ERR_UNEXPECTED_PARENTHESIS, yyline, yycolumn);
                else {
                    char c = balance.pop();
                    if(c == '{') {
                        /* ERROR */
                        Utils.addError(Utils.Error.LEX_ERR_EXPECTED_BRACKET, yyline, yycolumn);
                    }
                }
            }
    \{      { System.out.print("<{> "); balance.push('{'); }
    \}      { 
                System.out.print("<}> ");
                if(balance.empty())
                    Utils.addError(Utils.Error.LEX_ERR_UNEXPECTED_BRACKET, yyline, yycolumn);
                else {
                    char c = balance.pop();
                    if(c == '(') {
                        Utils.addError(Utils.Error.LEX_ERR_EXPECTED_PARENTHESIS, yyline, yycolumn);
                    }
                }
            }
    ,       { System.out.print("<,> "); }
    ;       {
                System.out.print("<;> ");
                if(balance.peek() == '(') {
                    Utils.addError(Utils.Error.LEX_ERR_EXPECTED_PARENTHESIS, yyline, yycolumn);
                    while(balance.peek() == '(') balance.pop();
                }
            }
    ([:digit:]+h)?[:digit:]+m               { System.out.print("<DURACION>[" + yytext() + "] "); }
    [:digit:]+(°|º)?C                       { System.out.print("<TEMP>[" + yytext() + "] "); }
    [:digit:][:digit:]:[:digit:][:digit:]   { System.out.print("<TEMPORIZADOR>[" + yytext() + "] "); }
    [:digit:]+                              { System.out.print("<NUMERO>[" + yytext() + "] "); }

    // Limpiamos el buffer de la cadena y cambiamos de estado
    \"  { cadena.setLength(0); yybegin(CADENA); }

    // Comentarios
    "//".*{NL}      { /* (one line comment) ignore */ }
    "/*"        { yybegin(COMENTARIO); }

    {NL}				{/* ignore */ /**DEBUG**/System.out.println();/**DEBUG**/}
    {TAB}				{/* ignore */}
    {BLANCO}			{/* ignore */}
    . { System.out.println("<ILLEGAL_CHARACTER>[" + yytext() + "] "); }
}

<CADENA> {
    \"  { System.out.print("<CADENA>[" + cadena.toString() + "] "); yybegin(YYINITIAL);  }
    .   { cadena.append(yytext()); }
    <<EOF>>    {/* ERROR */ return YYEOF;}
}

<COMENTARIO> {
    "*/"    { yybegin(YYINITIAL); }
    .       {/* ignore */}
    \n      {/* ignore */}
    <<EOF>> {/* ERROR */ return YYEOF;}
}