%token TOKEN_SI TOKEN_VERDADERO TOKEN_FALSO TOKEN_FIN_SI TOKEN_REPETIR TOKEN_HASTA TOKEN_LEER TOKEN_ESCRIBIR TOKEN_DIGITO TOKEN_IDENTIFICADOR TOKEN_CADENA TOKEN_PUNTO_COMA TOKEN_PARENTESIS_IZQUIERDO TOKEN_PARENTESIS_DERECHO
%token TOKEN_DIFERENTE TOKEN_IGUAL TOKEN_MENOR_IGUAL TOKEN_MAYOR_IGUAL TOKEN_MENOR_QUE TOKEN_MAYOR_QUE TOKEN_ASIGNACION
%token TOKEN_SUMA TOKEN_RESTA 
%token TOKEN_MULT TOKEN_DIV

%{
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#define MAX_ID_SIZE 100


extern yyin;
#pragma warning(disable: 4013 6385 6001 4996)
%}
%%

programa                : secuencia_intrucciones

secuencia_intrucciones  : secuencia_intrucciones TOKEN_PUNTO_COMA intruccion
                        | intruccion

intruccion              : intruccion_if
                        | intruccion_repeat
                        | intruccion_asignacion
                        | intruccion_read
                        | intruccion_write
                        | error /*Erorr por hacer*/

intruccion_if           : TOKEN_SI expresion TOKEN_VERDADERO secuencia_intrucciones TOKEN_FIN_SI
                        | TOKEN_SI expresion TOKEN_VERDADERO secuencia_intrucciones TOKEN_FALSO secuencia_intrucciones TOKEN_FIN_SI

intruccion_repeat       : TOKEN_REPETIR secuencia_intrucciones TOKEN_HASTA expresion

intruccion_asignacion   : TOKEN_IDENTIFICADOR TOKEN_ASIGNACION expresion

intruccion_read         : TOKEN_LEER TOKEN_IDENTIFICADOR

intruccion_write        : TOKEN_ESCRIBIR expresion

expresion               : expresion_simple TOKEN_MENOR_QUE expresion_simple
                        | expresion_simple TOKEN_MAYOR_QUE expresion_simple
                        | expresion_simple TOKEN_IGUAL expresion_simple
                        | expresion_simple TOKEN_DIFERENTE expresion_simple
                        | expresion_simple TOKEN_MENOR_IGUAL expresion_simple
                        | expresion_simple TOKEN_MAYOR_IGUAL expresion_simple
                        | expresion_simple

expresion_simple        : expresion_simple TOKEN_SUMA termino
                        | expresion_simple TOKEN_RESTA termino
                        | termino

termino                 : termino TOKEN_MULT factor
                        | termino TOKEN_DIV factor
                        | factor

factor                  : TOKEN_PARENTESIS_IZQUIERDO expresion TOKEN_PARENTESIS_DERECHO
                        | TOKEN_DIGITO
                        | TOKEN_IDENTIFICADOR 
						| TOKEN_CADENA 

       

%%

int yyerror(char *s) {
 
    char mensaje[100];
 
    if ( !strcmp( s, "syntax error" ) )
       strcpy( mensaje, "Error de sintaxis" );
    else
       strcpy( mensaje, s );
 
    printf("Error:  %s", mensaje);
   
 
    return 0;
 }
 

 
int main(int argc, char * argv[])
{
    	++argv;
    	--argc;  
    	if (argc > 0)
            yyin = fopen( argv[0], "r" );
    	else
            yyin = stdin;
    
    	yyparse();
        printf("Programa reconocido");
    	return 0;
}
