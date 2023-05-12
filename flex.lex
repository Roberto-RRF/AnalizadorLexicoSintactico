%{
    #include "yacc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <malloc.h>
    #include <string.h>

    #pragma warning(disable: 4996 6011 6385 4013)


   
%}

%option yylineno
LETRA       [a-zA-Z]
ID          {LETRA}([_]|[a-zA-Z0-9])*
DIGITO [0-9]+
ESPACIO [\t]+
CADENA "\""([^\"\n])*\"""
SALTO   [\n]
%%


"SI"             {yylval.chain = strdup(yytext); return TOKEN_SI;}
"VERDADERA"      {yylval.chain = strdup(yytext); return TOKEN_VERDADERO;}
"FALSA"          {yylval.chain = strdup(yytext); return TOKEN_FALSO;}
"FIN_SI" 		 {yylval.chain = strdup(yytext); return TOKEN_FIN_SI;}
"REPETIR"        {yylval.chain = strdup(yytext); return TOKEN_REPETIR;} 
"HASTA"          {yylval.chain = strdup(yytext); return TOKEN_HASTA;}
"LEER"           {yylval.chain = strdup(yytext); return TOKEN_LEER;}
"ESCRIBIR"       {yylval.chain = strdup(yytext); return TOKEN_ESCRIBIR;}
\+  	         {yylval.chain = strdup(yytext); return TOKEN_SUMA;}
\-			     {yylval.chain = strdup(yytext); return TOKEN_RESTA;}
\* 			     {yylval.chain = strdup(yytext); return TOKEN_MULT;}
\/ 			     {yylval.chain = strdup(yytext); return TOKEN_DIV;}
\=\= 			 {yylval.chain = strdup(yytext); return TOKEN_IGUAL;}
\!\= 			 {yylval.chain = strdup(yytext); return TOKEN_DIFERENTE;}
\<\= 			 {yylval.chain = strdup(yytext); return TOKEN_MENOR_IGUAL;}
\>\= 			 {yylval.chain = strdup(yytext); return TOKEN_MAYOR_IGUAL;}
\;			     {yylval.chain = strdup(yytext); return TOKEN_PUNTO_COMA;}
\(			     {yylval.chain = strdup(yytext); return TOKEN_PARENTESIS_IZQUIERDO;}
\) 			     {yylval.chain = strdup(yytext); return TOKEN_PARENTESIS_DERECHO;}
\< 			     {yylval.chain = strdup(yytext); return TOKEN_MENOR_QUE;}
\> 			     {yylval.chain = strdup(yytext); return TOKEN_MAYOR_QUE;}
\=     		     {yylval.chain = strdup(yytext); return TOKEN_ASIGNACION;}

{ID}	         {
                    yylval.chain = strdup(yytext);
                    return TOKEN_IDENTIFICADOR;
                 }
{DIGITO}         {
                    yylval.chain = strdup(yytext);
                    return TOKEN_DIGITO;
                 }
{SALTO}			 ; /* ignorar saltos de linea */
{ESPACIO}        ; /* ignorar espacios en blanco */
{CADENA}		 {
                    yylval.chain = strdup(yytext);
                    return TOKEN_CADENA;
                 }


"{"             {   
                    int c;
                    do {
                        c = input();
                        if (c == '\n');
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