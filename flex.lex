%{
    #include "yacc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <malloc.h>
    #include <string.h>

    #pragma warning(disable: 4996 6011 6385 4013)


   char cadena[255];
   int linea = 1;
%}

%option yylineno
LETRA       [a-zA-Z]
ID          {LETRA}([_]|[a-zA-Z0-9])*
DIGITO [0-9]+
ESPACIO [\t]+
CADENA "\""([^\"\n])*\"""
SALTO   [\n]
%%


"SI"             {return TOKEN_SI;}
"VERDADERA"      {return TOKEN_VERDADERO;}
"FALSA"          {return TOKEN_FALSO;}
"FIN_SI" 		 {return TOKEN_FIN_SI;}
"REPETIR"        {return TOKEN_REPETIR;} 
"HASTA"          {return TOKEN_HASTA;}
"LEER"           {return TOKEN_LEER;}
"ESCRIBIR"       {return TOKEN_ESCRIBIR;}
{ID}	         {return TOKEN_IDENTIFICADOR}
\+  	         {return TOKEN_SUMA;}
\-			     {return TOKEN_RESTA;}
\* 			     {return TOKEN_MULT;}
\/ 			     {return TOKEN_DIV;}
\=\= 			 {return TOKEN_IGUAL;}
\!\= 			 {return TOKEN_DIFERENTE;}
\<\= 			 {return TOKEN_MENOR_IGUAL;}
\>\= 			 {return TOKEN_MAYOR_IGUAL;}
\;			     {return TOKEN_PUNTO_COMA;}
\(			     {return TOKEN_PARENTESIS_IZQUIERDO;}
\) 			     {return TOKEN_PARENTESIS_DERECHO;}
\< 			     {return TOKEN_MENOR_QUE;}
\> 			     {return TOKEN_MAYOR_QUE;}
\=     		     {return TOKEN_ASIGNACION;}
{DIGITO}         {return TOKEN_DIGITO;}
{SALTO}			 ; /* ignorar saltos de linea */
{ESPACIO}        ; /* ignorar espacios en blanco */
{CADENA}		 {return TOKEN_CADENA;}


"{"             {   
                    int c;
                    do {
                        c = input();
                        if (c == '\n') ++linea;
                    } while (c != EOF && c != '}');

                    if (c == '}') {
                        //printf("Comentario Completo %d\n", yylineno);
                        /* Ignorar todo lo que se encuentre después del comentario */
                        yytext = "";
                        yyleng = 0;
                    } else {
                        printf("Error: comentario no terminado en línea %d\n", yylineno);
                    }
                }

            

%%

int yywrap(void) {
   return 1;
}