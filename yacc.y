%{
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#define MAX_ID_SIZE 100
#define TABLE_SIZE 100
#define MAX_USOS 10
#define MAXHIJOS 3



void add(char, int, char);
int hash(char *key);
struct nodo *crearNodo();

typedef int TipoToken;
typedef enum {TipoInstruccion, TipoExpresion} NodoTipo;
typedef enum {TipoIF, TipoREPEAT, TipoASIGNACION, TipoREAD, TipoWRITE} InstruccionesTipo;
typedef enum {TipoOPERADOR, TipoConstante, TipoIDENTIFICADOR} ExpresionesTipo;


struct dataType {
   char * identificador;
   int primera;
   int usos[MAX_USOS];
   int asignaciones[MAX_USOS];
   int contUsos;
   int contAsignaciones;
} tabla[TABLE_SIZE];


struct nodo{
   struct nodo *hermano;
   struct node *hijos[MAXHIJOS];
   char *valor;
   enum NodoTipo tipo;
   union{
      enum InstruccionesTipo tipoInstruccion;
      enum ExpresionesTipo tipoExpresion;
   };
};


int contadorVariables = -1;
struct nodo *root;


extern yyin;
extern yytext;
extern yylineno;

#pragma warning(disable: 4013 6385 6001 4996)



%}







%union {
   char* chain;
   struct nodo *nodo;
}

%token <chain> TOKEN_SI TOKEN_VERDADERO TOKEN_FALSO TOKEN_FIN_SI TOKEN_REPETIR TOKEN_HASTA TOKEN_LEER TOKEN_ESCRIBIR TOKEN_DIGITO TOKEN_IDENTIFICADOR TOKEN_CADENA TOKEN_PUNTO_COMA TOKEN_PARENTESIS_IZQUIERDO TOKEN_PARENTESIS_DERECHO
%token <chain> TOKEN_DIFERENTE TOKEN_IGUAL TOKEN_MENOR_IGUAL TOKEN_MAYOR_IGUAL TOKEN_MENOR_QUE TOKEN_MAYOR_QUE TOKEN_ASIGNACION
%token <chain> TOKEN_SUMA TOKEN_RESTA 
%token <chain> TOKEN_MULT TOKEN_DIV

%type <nodo> programa secuencia_intrucciones intruccion intruccion_if intruccion_repeat intruccion_asignacion intruccion_read intruccion_write expresion expresion_simple termino factor







%%



programa                : secuencia_intrucciones
                        {
                           root = crearNodo();
                           root->valor = "Inicio del programa";
                           $$ = root;
                        }

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

      printf("\n\n\n\n\n");
      printf("Arbol sintactico \n");
      while(root)
      {
         printf("%s \n", root->valor);
         root = root->hermano;
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


// Funcion que crea un nodo vacio 
struct nodo *crearNodo()
{
   struct nodo *nuevoNodo = (struct nodo *)malloc(sizeof(struct nodo));
   nuevoNodo->valor = NULL;
   nuevoNodo->tipo = 0;
   nuevoNodo->hermano = NULL;
   for(int i = 0; i < MAXHIJOS; i++)
      nuevoNodo->hijos[i] = NULL;
   return nuevoNodo;
}
