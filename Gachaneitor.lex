/***********************************/
/*             PL - Lab            */
/*                                 */   
/*     Manjavacas Lucas, Antonio   */
/*     Márquez Villalta, Rubén     */     
/*     Pedregal Hidalgo, Diego     */
/*     Velasco Mata, Alberto       */
/***********************************/
package gachaneitor;

import java_cup.runtime.Symbol;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;

import java.lang.StringBuilder;

class Utils {
    /*** KEYWORD HANDLING ***/
    
    static Map<String, Integer> keywords = new HashMap<String, Integer>();
    static {
        keywords.put("menu", sym.menu);
        keywords.put("plato", sym.plato);
        keywords.put("info", sym.info);
        keywords.put("nombre", sym.nombre);
        keywords.put("usuario", sym.usuario);
        keywords.put("raciones", sym.raciones);
        keywords.put("tiempo", sym.tiempo);
        keywords.put("calorias", sym.calorias);
        keywords.put("tipo", sym.tipo);
        keywords.put("cocina", sym.cocina);
        keywords.put("programar", sym.programar);
        keywords.put("calentar", sym.calentar);
        keywords.put("remover", sym.remover);
        keywords.put("anadir", sym.anadir);
        keywords.put("sacar", sym.sacar);
        keywords.put("varoma", sym.varoma);
        keywords.put("cuchara", sym.velocidad);
        keywords.put("espiga", sym.velocidad);
        keywords.put("turbo", sym.velocidad);
        keywords.put("inverso", sym.inverso);
        keywords.put("l", sym.medida);
        keywords.put("ml", sym.medida);
        keywords.put("cucharada", sym.medida);
        keywords.put("g", sym.medida);
        keywords.put("ud", sym.medida);
        keywords.put("al_gusto", sym.al_gusto);
    }
    private static final ArrayList<String> velocidadKeywords = new ArrayList<>(Arrays.asList(
        "cuchara", "espiga", "turbo"
    ));
    private static final ArrayList<String> medidasKeywords = new ArrayList<>(Arrays.asList(
        "l", "ml", "cucharada", "g", "ud"
    ));
    
    public static boolean isKeyword(String cadena) {
        return keywords.containsKey(cadena);
    }

    public static String getTokenName(String keyword) {
        if(velocidadKeywords.contains(keyword)) {
            return "<VELOCIDAD>[" + keyword + "] ";
        }
        if(medidasKeywords.contains(keyword)) {
            return "<MEDIDA>[" + keyword + "] ";
        }
        if(keywords.containsKey(keyword))
            return "<" + keyword.toUpperCase() + "> ";
        return "NOT_A_KEYWORD[" + keyword + "] ";
    }
    public static int getToken(String cadena) {
        if(keywords.containsKey(cadena)) {
            return keywords.get(cadena);
        }
        return -1;
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
        // System.out.print(debug);
    }
    /** DEBUG **/
}



%%
%class Lexer
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

    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }

    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}


NL  = \n | \r | \r\n
BLANCO = " "
TAB =  \t

%%
<YYINITIAL> {
    // ID o PalabraReservada
    [:jletter:][:jletterdigit:]*    {
            if(Utils.isKeyword(yytext())) {
                Utils.debugLog(Utils.getTokenName(yytext()));
                int token = Utils.getToken(yytext());

                if(token == sym.velocidad)
                    return symbol(token, yytext());
                else
                    return symbol(token);
            } else {
                Utils.debugLog("<ID>[" + yytext() + "] ");
                return symbol(sym.id, yytext());
            }
        }

    :       { Utils.debugLog("<:> "); return symbol(sym.dos_puntos); }
    \(      { Utils.debugLog("<(> "); return symbol(sym.paren_izq); }
    \)      { Utils.debugLog("<)> "); return symbol(sym.paren_der); }
    \{      { Utils.debugLog("<{> "); return symbol(sym.llave_izq); }
    \}      { Utils.debugLog("<}> "); return symbol(sym.llave_der); }
    ,       { Utils.debugLog("<,> "); return symbol(sym.coma); }
    ;       { Utils.debugLog("<;> "); return symbol(sym.punto_coma); }
    ([:digit:]+h)?[:digit:]+m               { Utils.debugLog("<DURACION>[" + yytext() + "] "); return symbol(sym.duracion); }
    [:digit:]+C                             { Utils.debugLog("<TEMP>[" + yytext() + "] "); return symbol(sym.temp, 
                                            new Integer(Integer.parseInt(yytext().split("C")[0]))); }
    [:digit:][:digit:]:[:digit:][:digit:]   { Utils.debugLog("<TEMPORIZADOR>[" + yytext() + "] "); return symbol(sym.timer, 
                                            new Integer(Integer.parseInt(yytext().split(":")[0])*60 + Integer.parseInt(yytext().split(":")[1]))); }
    [:digit:]*:[:digit:]*                   { Utils.error(Utils.Error.INVALID_TIMER, yytext(), yyline, yycolumn); return symbol(sym.timer, new String(yytext())); }
    [:digit:]+                              { Utils.debugLog("<NUMERO>[" + yytext() + "] "); return symbol(sym.number, new Integer(yytext())); }

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
    \"  { Utils.debugLog("<CADENA>[" + cadena.toString() + "] "); yybegin(YYINITIAL); return symbol(sym.string, new String(cadena.toString())); }
    .   { cadena.append(yytext()); }
    \n  { cadena.append(yytext()); }
    <<EOF>>    { Utils.error(Utils.Error.STRING_END_EXPECTED, null, initLine, initColumn); yybegin(YYINITIAL); return symbol(YYEOF); }
}

<COMMENT> {
    "*/"    { yybegin(YYINITIAL); }
    .       {/* ignore */}
    \n      {/* ignore */}
    <<EOF>> { Utils.error(Utils.Error.COMMENT_END_EXPECTED, null, initLine, initColumn); yybegin(YYINITIAL); return symbol(YYEOF); }
}
