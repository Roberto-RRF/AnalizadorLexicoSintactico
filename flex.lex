%{
    //#include "YACCCompila.tab.h"
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
"VERDADERA"      {return TOKEN_VERDADERA;}
"FALSA"          {return TOKEN_FALSA;}
"FIN_SI" 		 {return TOKEN_FIN_SI;}
"REPETIR"        {return TOKEN_REPETIR;}
"HASTA"          {return TOKEN_HASTA;}
"LEER"           {return TOKEN_LEER;}
"ESCRIBIR"       {return TOKEN_ESCRIBIR;}
"+" 		     {return TOKEN_MAS;}
"-" 			 {return TOKEN_MENOS;}
"*" 			 {return TOKEN_MULT;}
"/" 			 {return TOKEN_DIV;}
"==" 			 {return TOKEN_IGUAL;}
"!=" 			 {return TOKEN_DIFERENTE;}
"<=" 			 {return TOKEN_MENOR_IGUAL;}
">=" 			 {return TOKEN_MAYOR_IGUAL;}
";" 			 {return TOKEN_PUNTO_COMA;}
"(" 			 {return TOKEN_PATENTESIS_ABIERTO;}
")" 			 {return TOKEN_PATENTESIS_CERRADO;}
"<" 			 {return TOKEN_MENOR;}
">" 			 {return TOKEN_MAYOR;}
"=" 			 {return TOKEN_ASIGNACION;}
{DIGITO}         {return TOKEN_DIGITO;}
{ID}			 {return TOKEN_ID;}
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
                        printf("Comentario Completo %d\n", yylineno);
                        /* Ignorar todo lo que se encuentre después del comentario */
                        yytext = "";
                        yyleng = 0;
                    } else {
                        printf("Error: comentario no terminado en línea %d\n", yylineno);
                    }
                }

 /* cualquier otra cosa es un error */
. yyerror("caracter invalido");               

%%

int yywrap(void) {
   return 1;
}