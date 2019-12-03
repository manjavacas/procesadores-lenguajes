
grammar Gachaneitor;



menu : 'menu' ID '{' nombre (ingrediente)+ (plato)+ '}' ;
plato : 'plato' ID '{' cabecera (ingrediente)* (instruccion)* '}' ;
cabecera : 'info' '{' nombre usuario raciones tiempo_total (calorias)? (tipo)? (cocina)? '}' ;

nombre : 'nombre' ':' CADENA ';' ;
usuario : 'usuario' ':' ID ';' ;
raciones : 'raciones' ':' NUMERO ';' ;
tiempo_total : 'tiempo' ':' DURACION ';' ;
calorias : 'calorias' ':' NUMERO ';' ;
tipo : 'tipo' ':' CADENA ';' ;
cocina : 'cocina' ':' CADENA ';' ;

instruccion : (programar | anadir | calentar | remover | accion_usuario | sacar) ';' ;
programar : 'programar' '(' temperatura ',' velocidad ',' TEMPORIZADOR (',' 'inverso')? ')' ;
calentar : 'calentar' '(' temperatura ',' TEMPORIZADOR ')' ;
remover : 'remover' '(' velocidad ',' TEMPORIZADOR (',' 'inverso')? ')' ;
accion_usuario : CADENA ;
anadir : 'anadir' '(' (ingrediente | CADENA | ID) ')' ;
sacar : 'sacar' '(' CADENA ')' ;

temperatura : (TEMP | 'varoma') ;
velocidad : (NUMERO | 'cuchara' | 'espiga' | 'turbo') ;
ingrediente : cantidad ID ';' ;
cantidad : (NUMERO ('l' | 'ml' | 'g' | 'cucharada' | 'ud') | 'al_gusto') ;

ID : [a-zA-Z] [a-zA-Z0-9]* ;
CADENA : '"' ([a-zA-Z0-9]|BLANCO)* '"';
DURACION : (NUMERO 'h')? NUMERO 'm' ;
TEMPORIZADOR : DIGITO DIGITO ':' DIGITO DIGITO ;
TEMP : NUMERO ('º')? 'C' ;
NUMERO : (DIGITO)+ ;
DIGITO : [0-9] ;

ONE_LINE_COMMENT: '//' (~[\n])* '\n' -> skip ;
MULTILINE_COMMENT: '/*'  (~'*')* '*/' -> skip ;


WS : [ \t\r\n]+ -> skip ;
BLANCO : [ \t\n\r] ;






