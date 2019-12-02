
grammar gachaneitor;

menu : 'menu' ID '{' nombre (ingrediente)+ (plato)+ '}' ;
plato : 'plato' ID '{' cabecera (ingrediente)* (instruccion)* '}' ;
cabecera : 'info' '{' nombre usuario raciones tiempo_total (calorias)? (tipo)? (cocina)? '}' ;

nombre : 'nombre' ':' ID ';' ;
usuario : 'usuario' ':' CADENA ';' ;
raciones : 'racion' ':' NUMERO ';' ;
tiempo_total : 'tiempo' ':' DURACION ';' ;
calorias : 'calorias' ':' NUMERO ';' ;
tipo : 'tipo' ':' CADENA ';' ;
cocina : 'cocina' ':' CADENA ';' ;

instruccion : (programar | anadir | calentar | remover | accion_usuario | sacar) ';' ;
programar : 'programar' '(' temperatura ',' velocidad ',' temporizador (',' 'inverso')? ')' ;
calentar : 'calentar' '(' temperatura ',' temporizador ')' ;
remover : 'remover' '(' velocidad ',' temporizador (',' 'inverso')? ')' ;
accion_usuario : '"' CADENA '"' ;
anadir : 'anadir' '(' (ingrediente | CADENA) ')' ;
sacar : 'sacar' '(' CADENA ')' ;

temperatura : (temp | 'varoma') ;
velocidad : (numero | 'cuchara' | 'espiga' | turbo) ;
ingrediente : cantidad CADENA ';' ;
cantidad : (numero ('l' | 'ml' | 'g' | 'cucharada' | 'ud') | 'al_gusto') ;

ID : [a-zA-Z] [a-zA-Z0-9]* ;
CADENA : '"' ([a-zA-Z0-9]|BLANCO)* '"' ;
DURACION : (NUMERO 'h')? NUMERO 'm' ;
TEMPORIZADOR : DIGITO DIGITO ':' DIGITO DIGITO ;
TEMP : NUMERO ('º')? 'C' ;
DIGITO : [0-9] ;
NUMERO : (DIGITO)+ ;
BLANCO : [ \t\n\r] ;






