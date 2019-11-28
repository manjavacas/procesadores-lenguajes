/***********************************/
/*             PL - Lab            */
/*                                 */   
/*     Manjavacas Lucas, Antonio   */
/*     Márquez Villalta, Rubén     */     
/*     Pedregal Hidalgo, Diego     */
/*     Velasco Mata, Alberto       */
/***********************************/

import java_cup.runtime.Symbol;

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
        ILLEGAL("Error: Illegal character '%s' at %d:%d\n"),
        INVALID_TIMER("Error: Invalid timer format '%s' at %d:%d\n"),
        STRING_END_EXPECTED("Error: %sUnclosed string starting at %d:%d\n"),
        COMMENT_START_EXPECTED("Error: %sUnexpected end of comment at %d:%d\n"),
        COMMENT_END_EXPECTED("Error: %sUnclosed comment starting at %d:%d\n");


        String message;
        private Error(String errorMessage) {
            message = errorMessage;
        }

        public String toString() {
            return message;
        }
    }

    public static void error(Error e, String content, int l, int c) {
        System.out.printf(e.toString(), content != null ? content : "", l+1, c+1);
    }

    /** DEBUG **/
    public static void debugLog(String debug) {
        System.out.print(debug);
    }
    /** DEBUG **/
}



%%
%class gachaneitor
%standalone
%unicode

%line
%column

%cup

/* ------------ ESTADOS ------------*/
%state STRING
%state COMMENT


/* -------- DECLARACIONES --------- */
%{
    private StringBuilder cadena = new StringBuilder();
    private int initLine = -1, initColumn = -1;
%}


NL  = \n | \r | \r\n
BLANCO = " "
TAB =  \t

%%
<YYINITIAL> {
    // ID o PalabraReservada
    [:jletter:][:jletterdigit:]*    {
            if(Utils.isKeyword(yytext()))
                Utils.debugLog(Utils.getToken(yytext()));
            else
                Utils.debugLog("<ID>[" + yytext() + "] ");
        }

    :       { Utils.debugLog("<:> "); }
    \(      { Utils.debugLog("<(> "); }
    \)      { Utils.debugLog("<)> "); }
    \{      { Utils.debugLog("<{> "); }
    \}      { Utils.debugLog("<}> "); }
    ,       { Utils.debugLog("<,> "); }
    ;       { Utils.debugLog("<;> "); }
    ([:digit:]+h)?[:digit:]+m               { Utils.debugLog("<DURACION>[" + yytext() + "] "); }
    [:digit:]+(°|º)?C                       { Utils.debugLog("<TEMP>[" + yytext() + "] "); }
    [:digit:][:digit:]:[:digit:][:digit:]   { Utils.debugLog("<TEMPORIZADOR>[" + yytext() + "] "); }
    [:digit:]*:[:digit:]*                   { Utils.error(Utils.Error.INVALID_TIMER, yytext(), yyline, yycolumn); }
    [:digit:]+                              { Utils.debugLog("<NUMERO>[" + yytext() + "] "); }

    // Limpiamos el buffer de la cadena y cambiamos de estado
    \"  { cadena.setLength(0); initLine = yyline; initColumn = yycolumn; yybegin(STRING); }

    // Comentarios
    "//".*{NL}      { /* (one line comment) ignore */ }
    "/*"        { initLine = yyline; initColumn = yycolumn; yybegin(COMMENT); }
    "*/"        { Utils.error(Utils.Error.COMMENT_START_EXPECTED, null, yyline, yycolumn); }

    {NL}				{/* ignore */ /**DEBUG**/Utils.debugLog("\n");/**DEBUG**/}
    {TAB}				{/* ignore */}
    {BLANCO}			{/* ignore */}
    . { Utils.error(Utils.Error.ILLEGAL, yytext(), yyline, yycolumn); }
}

<STRING> {
    \"  { Utils.debugLog("<CADENA>[" + cadena.toString() + "] "); yybegin(YYINITIAL);  }
    .   { cadena.append(yytext()); }
    \n  { cadena.append(yytext()); }
    <<EOF>>    { Utils.error(Utils.Error.STRING_END_EXPECTED, null, initLine, initColumn); return YYEOF; }
}

<COMMENT> {
    "*/"    { yybegin(YYINITIAL); }
    .       {/* ignore */}
    \n      {/* ignore */}
    <<EOF>> { Utils.error(Utils.Error.COMMENT_END_EXPECTED, null, initLine, initColumn); return YYEOF; }
}