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

import java.lang.StringBuilder;

class Utils {
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
}



%%
%class gachaneitor
%standalone
%unicode

%line
%column

/* ------------ ESTADOS ------------*/
%state CADENA


/* -------- DECLARACIONES --------- */
%{
    private StringBuilder cadena = new StringBuilder();
%}

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
    \(      { System.out.print("<(> "); }
    \)      { System.out.print("<)> "); }
    \{      { System.out.print("<{> "); }
    \}      { System.out.print("<}> "); }
    ,       { System.out.print("<,> "); }
    ;       { System.out.print("<;> "); }
    ([:digit:]+h)?[:digit:]+m               { System.out.print("<DURACION>[" + yytext() + "] "); }
    [:digit:]+(°|º)?C                       { System.out.print("<TEMP>[" + yytext() + "] "); }
    [:digit:][:digit:]:[:digit:][:digit:]   { System.out.print("<TEMPORIZADOR>[" + yytext() + "] "); }
    [:digit:]+                              { System.out.print("<NUMERO>[" + yytext() + "] "); }

    // Limpiamos el buffer de la cadena y cambiamos de estado
    \"  { cadena.setLength(0); yybegin(CADENA); }


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
