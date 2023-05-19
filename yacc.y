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
struct nodo *crearNodoInstruccion(InstruccionesTipo);
struct nodo *crearNodoExpresion(ExpresionesTipo);


typedef int TipoToken;
typedef enum {TipoInstruccion, TipoExpresion} NodoTipo;
typedef enum {TipoIF, TipoREPEAT, TipoASIGNACION, TipoREAD, TipoWRITE} InstruccionesTipo;
typedef enum {TipoOPERADOR, TipoCONSTANTE, TipoIDENTIFICADOR} ExpresionesTipo;


struct dataType {
   char * identificador;
   int primera;
   int usos[MAX_USOS];
   int asignaciones[MAX_USOS];
   int contUsos;
   int contAsignaciones;
} tabla[TABLE_SIZE];


typedef struct nodo{
   struct nodo *hermano;
   struct node *hijos[MAXHIJOS];
   int numeroLinea;
   NodoTipo tipoNodo;
   union{
      enum InstruccionesTipo tipoInstruccion;
      enum ExpresionesTipo tipoExpresion;
   }tipo;
   union{
      TipoToken operador;
      int valor;
      char *identificador;
   } atributos;
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
                           root = $$;
                        }

secuencia_intrucciones  : secuencia_intrucciones TOKEN_PUNTO_COMA intruccion
                        {
                           struct nodo *temp = $1;
                           if(temp != NULL)
                           {
                              while(temp->hermano != NULL)
                                 temp = temp->hermano;
                              temp->hermano = $3;
                           }
                           else
                           {
                              $$=$3;
                           }
                        }
                        | intruccion
                        {
                           $$ = $1;
                        }

intruccion              : intruccion_if
                        | intruccion_repeat
                        | intruccion_asignacion
                        | intruccion_read
                        | intruccion_write
                        | error /*Erorr por hacer*/

intruccion_if           : TOKEN_SI expresion TOKEN_VERDADERO secuencia_intrucciones TOKEN_FIN_SI
                           {
                              $$ = crearNodoInstruccion(TipoIF);
                              $$->hijos[0] = $2;
                              $$->hijos[1] = $4;
                           }
                        | TOKEN_SI expresion TOKEN_VERDADERO secuencia_intrucciones TOKEN_FALSO secuencia_intrucciones TOKEN_FIN_SI
                           {
                              $$ = crearNodoInstruccion(TipoIF);
                              $$->hijos[0] = $2;
                              $$->hijos[1] = $4;
                              $$->hijos[2] = $6;
                           }

intruccion_repeat       : TOKEN_REPETIR secuencia_intrucciones TOKEN_HASTA expresion
                           {
                              $$ = crearNodoInstruccion(TipoREPEAT);
                              $$->hijos[0] = $2;
                              $$->hijos[1] = $4;
                           }

intruccion_asignacion   : TOKEN_IDENTIFICADOR TOKEN_ASIGNACION expresion  
                           {
                              add(strdup($1), yylineno, 'A'); //Agregamos al arbol sintactico

                              $$ = crearNodoInstruccion(TipoASIGNACION);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                                                         
                           }

intruccion_read         : TOKEN_LEER TOKEN_IDENTIFICADOR 
                           {
                              add(strdup($2), yylineno, 'A'); // Agregamos a la tabla de simbolos
                              $$ = crearNodoInstruccion(TipoREAD);
                              $$->hijos[0] = $2;                             
                           }

intruccion_write        : TOKEN_ESCRIBIR expresion
                           {
                              $$ = crearNodoInstruccion(TipoWRITE);
                              $$->hijos[0] = $2;
                           }

expresion               : expresion_simple TOKEN_MENOR_QUE expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                              printf("Expresion menor que \n");
                              printf("Hijo 1: %s \n", $$->atributos.valor);
                              printf("Hijo 2: %d \n", $3->tipo.tipoExpresion);
                              printf("Operador: %s \n", $2);
                           }
                        | expresion_simple TOKEN_MAYOR_QUE expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple TOKEN_IGUAL expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple TOKEN_DIFERENTE expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple TOKEN_MENOR_IGUAL expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple TOKEN_MAYOR_IGUAL expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                           }

expresion_simple        : expresion_simple TOKEN_SUMA termino
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | expresion_simple TOKEN_RESTA termino
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | termino
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                           }

termino                 : termino TOKEN_MULT factor
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | termino TOKEN_DIV factor
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                              $$->hijos[1] = $3;
                              $$->atributos.operador = $2;
                           }
                        | factor
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $1;
                           }
factor                  : TOKEN_PARENTESIS_IZQUIERDO expresion TOKEN_PARENTESIS_DERECHO
                           {
                              $$ = crearNodoExpresion(TipoOPERADOR);
                              $$->hijos[0] = $2;
                           }
                        | TOKEN_DIGITO
                           {
                              $$ = crearNodoExpresion(TipoCONSTANTE);
                              $$->atributos.valor = atoi($1);
                           }
                        | TOKEN_IDENTIFICADOR  
                           {
                              add(strdup($1), yylineno, 'U'); // Agregamos a la tabla de simbolos

                              $$ = crearNodoExpresion(TipoIDENTIFICADOR);
                              $$->atributos.identificador = $1;                           
                           }
						| TOKEN_CADENA 
                          

 

%%


int yyerror(char *s) {

    char mensaje[100];

    if ( !strcmp( s, "syntax error" ) )
      strcpy( mensaje, "Error de sintaxis" );
    else
      strcpy( mensaje, s );

    printf("Error:  %d", mensaje);
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

      printf("\n\n\n");
      printf("Arbol sintactico \n");
      
      // while(root != NULL)
      // {
         
      //    if(root->tipoNodo == TipoExpresion)
      //       printf("%d \n", root->tipo.tipoExpresion);
      //    else
      //       root = root->hijos[0];
      //       printf("%d \n", root->tipoNodo);

      // }

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

struct nodo *crearNodoInstruccion(InstruccionesTipo tipo)
{
   struct nodo *nuevoNodo = (struct nodo *)malloc(sizeof(struct nodo));
   nuevoNodo->tipoNodo = TipoInstruccion;
   nuevoNodo->tipo.tipoInstruccion = tipo;
   nuevoNodo->hermano = NULL;
   nuevoNodo->tipo.tipoInstruccion = tipo;
   for(int i = 0; i < MAXHIJOS; i++)
      nuevoNodo->hijos[i] = NULL;
   return nuevoNodo;
}

struct nodo *crearNodoExpresion(ExpresionesTipo tipo)
{
   struct nodo *nuevoNodo = (struct nodo *)malloc(sizeof(struct nodo));
   nuevoNodo->tipoNodo = TipoExpresion;
   nuevoNodo->tipo.tipoExpresion = tipo;
   nuevoNodo->hermano = NULL;
   nuevoNodo->tipo.tipoExpresion = tipo;
   for(int i = 0; i < MAXHIJOS; i++)
      nuevoNodo->hijos[i] = NULL;
   return nuevoNodo;
}
