/***********************************/
/*             PL - Lab            */
/*                                 */   
/*     Manjavacas Lucas, Antonio   */
/*     Márquez Villalta, Rubén     */     
/*     Pedregal Hidalgo, Diego     */
/*     Velasco Mata, Alberto       */
/***********************************/

%%
%class gachaneitor
%standalone
%unicode

%line
%column


NL  = \n | \r | \r\n
BLANCO = " "
TAB =  \t

%%
<YYINITIAL> {

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
[:jletter:][:jletterdigit:]*            { System.out.print("[" + yytext() + "]"); }
\"([:jletterdigit:]|{NL}|{BLANCO}|{TAB})*\"     { System.out.print("[" + yytext() + "]"); }


{NL}				{/* ignore */}
{TAB}				{/* ignore */}
{BLANCO}			{/* ignore */}
. { System.out.println("Illegal[" + yytext() + "]"); }

}