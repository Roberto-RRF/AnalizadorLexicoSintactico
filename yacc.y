%{
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#define MAX_ID_SIZE 100
#define TABLE_SIZE 100
#define MAX_USOS 10
#define MAXHIJOS 



void add(char, int, char);
int hash(char *key);
extern int numerodeLinea

typedef int TipoToken;
typedef enum {TipoInstruccion, TipoExpresion} NodoTipo;
typedef enum {TipoIF, TipoREPEAT, TipoASIGNACION, TipoREAD, TipoWRITE} InstruccionesTipo;
typedef enum {TipoOPERADOR, TipoConstante, TipoIDENTIFICADOR} ExpresionesTipo;

typedef enum {Void, Integer, Boolean} TiposdeExpresionesyNodosdelLenguaje;

tydef struct NodoArbol
{
   NodoArbol * hijos[MAXHIJOS];
   NodoArbol * hermano;
   int numerodeLinea;
   NodoTipo tipodelnodo;
   union
   {
      InstruccionesTipo instruccion;
      ExpresionesTipo expresion;
   } tipo;
   union 
   {
      TipoToken operador;
      int valor;
      char * nombre;
   } atributos;
   TiposdeExpresionesyNodosdelLenguaje TipoLenguajedelNodo;
   
   

}

NodoArbol * NuevoNodoInstruccion(InstruccionesTipo tipodelNodo)
{
   NodoArbol * t=(NodoArbol *)malloc(sizeof(NodoArbol))
   int i;
   if (t==NULL)
      fprintf(salidas, "Memoria agotada al compilar la linea %d\n", numerodeLinea);

   else
   {
      for (i=0;i<MAXHIJOS;i++)
         t->hijos[i]=NULL;
      t->hermano=NULL;
      t->tipodelnodo=TipoInstruccion;
      t->tipo.instruccion=tipodelnodo;
      t->numerodeLinea=numerodeLinea;
   }
   return t;
}

NodoArbol * NuevoNodoExpresion(ExpresionesTipo tipodelNodo)
{
   NodoArbol * t=(NodoArbol *)malloc(sizeof(NodoArbol))
   int i;
   if (t==NULL)
      fprintf(salidas, "Memoria agotada al compilar la linea %d\n", numerodeLinea);

   else
   {
      for (i=0;i<MAXHIJOS;i++)
         t->hijos[i]=NULL;
      t->hermano=NULL;
      t->tipodelnodo=TipoExpresion
      t->tipo.expresion=tipodelnodo;
      t->numerodeLinea=numerodeLinea;
   }
   return t;
}

int contadorVariables = -1;


extern yyin;
extern yytext;
extern yylineno;

#pragma warning(disable: 4013 6385 6001 4996)



%}







%union {
   char* chain;
}

%token <chain> TOKEN_SI TOKEN_VERDADERO TOKEN_FALSO TOKEN_FIN_SI TOKEN_REPETIR TOKEN_HASTA TOKEN_LEER TOKEN_ESCRIBIR TOKEN_DIGITO TOKEN_IDENTIFICADOR TOKEN_CADENA TOKEN_PUNTO_COMA TOKEN_PARENTESIS_IZQUIERDO TOKEN_PARENTESIS_DERECHO
%token <chain> TOKEN_DIFERENTE TOKEN_IGUAL TOKEN_MENOR_IGUAL TOKEN_MAYOR_IGUAL TOKEN_MENOR_QUE TOKEN_MAYOR_QUE TOKEN_ASIGNACION
%token <chain> TOKEN_SUMA TOKEN_RESTA 
%token <chain> TOKEN_MULT TOKEN_DIV







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

intruccion_asignacion   : TOKEN_IDENTIFICADOR TOKEN_ASIGNACION expresion  {add(strdup($1), yylineno, 'A');}

intruccion_read         : TOKEN_LEER TOKEN_IDENTIFICADOR {add(strdup($2), yylineno, 'A');}

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
                        | TOKEN_IDENTIFICADOR  {add(strdup($1), yylineno, 'U');}
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


      // Imprimimos el arbol sintactico
      printf("Tabla de simbolos \n");      
      printf("Identificador \t Primera \t Usos \t\t Asignaciones \n");
      for(unsigned int i = 0; i <TABLE_SIZE ; i++)
      {
         if(tabla[i].identificador)
         {
            printf("%s \t\t %d \t\t", tabla[i].identificador, tabla[i].primera);
            for(unsigned int j = 0; j < tabla[i].contUsos; j++)
            {
               if(tabla[i].usos[j])
                  printf("%d, ", tabla[i].usos[j]);
            }
            printf("\t\t\t");
            for(unsigned int j = 0; j < tabla[i].contAsignaciones; j++)
            {
               if(tabla[i].asignaciones[j])
                  printf("%d, ", tabla[i].asignaciones[j]);
            }
         printf("\n");
         }
      }




    	return 0;
}



void add(char *identificador, int linea, char caso)
{
   int indice = hash(identificador);
   if(!tabla[indice].identificador)
   {
      tabla[indice].identificador = identificador;
      tabla[indice].primera = linea;
      tabla[indice].contUsos = 0;
      tabla[indice].contAsignaciones = 0;
      if(caso=='U')
      {
         
         tabla[indice].usos[0] = linea;
         tabla[indice].contUsos++;
      }
      if(caso=='A')
      {
         
         tabla[indice].asignaciones[0] = linea;
         tabla[indice].contAsignaciones++;
      }
      
   }
   else
   {
      if(caso=='U')
      {
         tabla[indice].usos[tabla[indice].contUsos] = linea;
         tabla[indice].contUsos++;
      }

      if(caso=='U')
      {
         tabla[indice].usos[tabla[indice].contAsignaciones] = linea;
         tabla[indice].contAsignaciones++;
      }
   }
      
   
}

int hash(char *key)
{
    size_t size = strlen(key);
    long sum = 0;
    long mul = 1;
    for (size_t i = 0; i < size; i++)
    {
        mul = (i % 4 == 0) ? 1 : mul << 8;
        sum = sum + key[i] * mul;
    }
    return (int)(sum % TABLE_SIZE);
}