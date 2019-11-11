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
            return "VELOCIDAD";
        else if(medidasKeywords.contains(keyword)) {
            return "MEDIDA";
        }
        for(int i = 0; i < keywords.length; i++) {
            if(keywords[i].equals(keyword))
                return keywords[i].toUpperCase();
        }
        return "INVALID";
    }
}



%%
%class gachaneitor
%standalone
%unicode

%line
%column
%state USER_INSTR


NL  = \n | \r | \r\n
BLANCO = " "
TAB =  \t

%%
<YYINITIAL> {

[:jletter:][:jletterdigit:]*            {
        if(Utils.isKeyword(yytext()))
            System.out.print(Utils.getToken(yytext()));
        else
            System.out.print("[" + yytext() + "]");
    }

:       { System.out.print("[:]"); }
\(      { System.out.print("[(]"); }
\)      { System.out.print("[)]"); }
\{      { System.out.print("[{]"); }
\}      { System.out.print("[}]"); }
,       { System.out.print("[,]"); }
;       { System.out.print("[;]"); }
([:digit:]+h)?[:digit:]+m               { System.out.print("[" + yytext() + "]"); }
[:digit:]+(°|º)?C                       { System.out.print("[" + yytext() + "]"); }
[:digit:][:digit:]:[:digit:][:digit:]   { System.out.print("[" + yytext() + "]"); }
[:digit:]+                              { System.out.print("[" + yytext() + "]"); }

\"([:jletterdigit:]|{NL}|{BLANCO}|{TAB})*\"     { System.out.print("[" + yytext() + "]"); }


{NL}				{/* ignore */}
{TAB}				{/* ignore */}
{BLANCO}			{/* ignore */}
. { System.out.println("Illegal[" + yytext() + "]"); }

}