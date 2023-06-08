%{
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#define MAX_ID_SIZE 100
#define TABLE_SIZE 251
#define MAX_USOS 100
#define MAXHIJOS 3



void add(char, int, char);
int hash(char *key);
struct nodo *crearNodoInstruccion(InstruccionesTipo);
struct nodo *crearNodoExpresion(ExpresionesTipo);
void imprimirArbol(struct nodo *, int);

void generarCodigo(struct nodo *raiz);
void generarArchivo();
void escribirLineaOperacion(char* operador, char* r, char* s, char* t, char * comentario);
void escribirLineaMemoria(char * operador, char* r, char* s, char* d, char * comentario);
void generarCodigoHermanos(struct nodo *raiz);
void generadorInstrucciones(struct nodo *raiz);
void generadorExpresiones(struct nodo *raiz);
int desplazamientoLocalidad(int desplazamiento);



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
   struct nodo *hijos[MAXHIJOS];
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




int LocalidadEscrita = 0;
int LocalidadMayorEscrita = 0;
int desplazamientoTemporal = 0;


const char nombreArchivo[] = "ArchivoGenerado.txt";

extern yyin;
extern yytext;
extern yylineno;

#pragma warning(disable: 4013 6385 6001 4996)



%}

%union {
   char* chain;
   struct nodo *node;
}

%token <chain> TOKEN_SI TOKEN_VERDADERO TOKEN_FALSO TOKEN_FIN_SI TOKEN_REPETIR TOKEN_HASTA TOKEN_LEER TOKEN_ESCRIBIR TOKEN_DIGITO TOKEN_IDENTIFICADOR TOKEN_CADENA TOKEN_PUNTO_COMA TOKEN_PARENTESIS_IZQUIERDO TOKEN_PARENTESIS_DERECHO
%token <chain> TOKEN_DIFERENTE TOKEN_IGUAL TOKEN_MENOR_IGUAL TOKEN_MAYOR_IGUAL TOKEN_MENOR_QUE TOKEN_MAYOR_QUE TOKEN_ASIGNACION
%token <chain> TOKEN_SUMA TOKEN_RESTA 
%token <chain> TOKEN_MULT TOKEN_DIV

%type <node> programa secuencia_intrucciones intruccion intruccion_if intruccion_repeat intruccion_asignacion intruccion_read intruccion_write expresion expresion_simple termino factor







%% 



programa                : secuencia_intrucciones
                        {
                           root = $1;
                        }

secuencia_intrucciones  : secuencia_intrucciones TOKEN_PUNTO_COMA intruccion
                        {
                           struct nodo *temp = $1;
                           if(temp != NULL)
                           {
                              while(temp->hermano != NULL)
                                 temp = temp->hermano;
                              
                              temp->hermano = $3;
                              $$ = $1;
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

intruccion              : intruccion_if {$$=$1;}
                        | intruccion_repeat {$$=$1;}
                        | intruccion_asignacion {$$=$1;}
                        | intruccion_read {$$=$1;}
                        | intruccion_write {$$=$1;}
                        | error {$$=NULL;}

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
                              $$->hijos[0]=$3;
                              $$->atributos.identificador = $1;
                              
                                                         
                           }

intruccion_read         : TOKEN_LEER TOKEN_IDENTIFICADOR 
                           {
                              add(strdup($2), yylineno, 'A'); // Agregamos a la tabla de simbolos
                              $$ = crearNodoInstruccion(TipoREAD);
                              $$->atributos.identificador = $2;                             
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
                              $$ = $1;
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
                              //Termino
                              $$ = $1;
                           }

termino                 : termino TOKEN_MULT factor
                           {
                              // Mult
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
                              $$ = $1;
                           }
factor                  : TOKEN_PARENTESIS_IZQUIERDO expresion TOKEN_PARENTESIS_DERECHO
                           {
                              $$ = $2;
                              
                           }
                        | TOKEN_DIGITO
                           {
                              $$ = crearNodoExpresion(TipoCONSTANTE);
                              $$->atributos.valor = atoi($1);
                           }
                        | TOKEN_IDENTIFICADOR  
                           {
                             
                              add(strdup($1), yylineno, 'U'); // Agregamos a la tabla de simbolos
                              //Identificador

                              $$ = crearNodoExpresion(TipoIDENTIFICADOR);
                              $$->atributos.identificador = $1;                           
                           }
						| TOKEN_CADENA 
                  {$$=$1;}
                          

 

%%


int yyerror(char *s) {

    char mensaje[100];

    if ( !strcmp( s, "syntax error" ) )
      strcpy( mensaje, "Error de sintaxis" );
    else
      strcpy( mensaje, s );

    printf("Error:  %d", yylineno);
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

      imprimirArbol(root, 0);      

      generarCodigo(root);


     
      
      

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

void imprimirArbol(struct nodo *raiz, int nivel) {
   if (raiz != NULL) {
      // Imprimir espacios en blanco para representar la profundidad del nodo
      for (int i = 0; i < nivel; i++) {
         printf("\t");
      }
   
      
      // Imprimir información adicional según el tipo de nodo
      switch (raiz->tipoNodo) {
         case TipoInstruccion:
            switch(raiz->tipo.tipoInstruccion) {
               case TipoASIGNACION:
                  printf("Identificador %s\n", raiz->atributos.identificador);
                  break;
               case TipoIF:
                  printf("IF\n");
                  break;
               case TipoREPEAT:
                  printf("REPEAT\n");
                  break;
               case TipoREAD:
                  printf("READ %s\n", raiz->atributos.identificador);
                  break;
               case TipoWRITE:
                  printf("WRITE\n");
                  break;
               default:
                  break;
            }
            break;
         case TipoExpresion:
            switch(raiz->tipo.tipoExpresion)
            {
               case TipoOPERADOR:
                  printf("Operador: %s\n",raiz->atributos.operador);
                  break;
               case TipoCONSTANTE:
                  printf("%d\n", raiz->atributos.valor);
                  break;
               case TipoIDENTIFICADOR:
                  printf("%s\n", raiz->atributos.identificador);
                  break;
               default:
                  break;
            }
         default:
            break;
      }
      
      // Llamar recursivamente para imprimir los hijos del nodo actual
      for (int i = 0; i < MAXHIJOS; i++) {
         struct nodo* hijo = raiz->hijos[i];
         imprimirArbol(hijo, nivel + 1);
      }

      // Llamar recursivamente para imprimir los hermanos del nodo actual
      imprimirArbol(raiz->hermano, nivel);
   }
}



void generarArchivo() {
    FILE* archivo = fopen(nombreArchivo, "w");
    // Escribimos codigo incicializacion
    escribirLineaMemoria("LD", "6", "0", "0", "", "0");
    escribirLineaMemoria("ST", "0", "0", "0", "", "1");

    if (archivo != NULL) {
        fclose(archivo);
        printf("Se ha generado el archivo %s.\n", nombreArchivo);
    } else {
        printf("No se pudo generar el archivo %s.\n", nombreArchivo);
    }
}

void escribirLineaOperacion(char* operador, char* r, char* s, char* t, char * comentario) {
    FILE* archivo = fopen(nombreArchivo, "a");
    if (archivo != NULL) {

      
      char linea[100];
      strcpy(linea, operador);
      strcat(linea, " ");
      strcat(linea, r);
      strcat(linea, ",");
      strcat(linea, s);
      strcat(linea, ",");
      strcat(linea, t);
      strcat(linea, " *");
      strcat(linea, comentario);
        
      fprintf(archivo, "%d: %s\n", LocalidadEscrita++, linea);
      fclose(archivo);

    } else {
        printf("No se pudo abrir el archivo %s para escribir la línea \"%s\".\n", nombreArchivo);
    }
}

void escribirLineaMemoria(char * operador, char* r, char* s, char* d, char * comentario ) {
    FILE* archivo = fopen(nombreArchivo, "a");
    if (archivo != NULL) {

      char linea[100];
      
      strcpy(linea, operador);
      strcat(linea, " ");
      strcat(linea, r);
      strcat(linea, ",");
      strcat(linea, s);
      strcat(linea, "(");
      strcat(linea, d);
      strcat(linea, ") *");
      strcat(linea, comentario);


        fprintf(archivo, "%d: %s\n", LocalidadEscrita++, linea);
        fclose(archivo);
    } else {
        printf("No se pudo abrir el archivo %s para escribir la línea \"%s\".\n", nombreArchivo);
    }
}



void generarCodigo(struct nodo *raiz)
{
   generarArchivo();
   generarCodigoHermanos(raiz);
   escribirLineaOperacion("HALT", "0", "0", "0", "");
}


void generarCodigoHermanos(struct nodo *raiz)
{
   if(raiz != NULL)
   {
      switch(raiz->tipoNodo)
      {
         case TipoInstruccion:
            generadorInstrucciones(raiz);
            break;
         
         case TipoExpresion:
            generadorExpresiones(raiz);
            break;
         default:
            break;
      } 
      generarCodigoHermanos(raiz->hermano);
   }
}

void generadorInstrucciones(struct nodo *raiz)
{
      switch(raiz->tipo.tipoInstruccion)
      {
         case TipoASIGNACION:
            printf("");
            generarCodigoHermanos(raiz->hijos[0]);
            int valor = hash(raiz->atributos.identificador);
            char valorString[10];
            sprintf(valorString, "%d", valor);
            escribirLineaMemoria("ST", "0", valorString, "5", "Guardamos valor en memoria");
            break;
         case TipoIF:
            printf("");
            struct nodo *aux1 = raiz->hijos[0];
            struct nodo *aux2 = raiz->hijos[1];
            struct nodo *aux3 = raiz->hijos[2]; 

            generarCodigoHermanos(aux1);
            int etiquetaResguardo1 = desplazamientoLocalidad(1);

            generarCodigoHermanos(aux2);
            int etiquetaResguardo2 = desplazamientoLocalidad(1);


            printf("IF, salto al final desde aqui\n");

            int direccionActual = desplazamientoLocalidad(0);

            LocalidadEscrita = etiquetaResguardo1;

            char direccionActualString[100];
            sprintf(direccionActualString, "%d", direccionActual);

            escribirLineaMemoria("JEQ", "0", direccionActualString, "0", "Salto al final");

            LocalidadEscrita = LocalidadMayorEscrita;

            generarCodigoHermanos(aux3);
            direccionActual = desplazamientoLocalidad(0);

            LocalidadEscrita = etiquetaResguardo2;

            sprintf(direccionActualString, "%d", direccionActual);
            escribirLineaMemoria("LDA", "7", direccionActualString, "0", "Salto al final");

            LocalidadEscrita = LocalidadMayorEscrita;           


            break;
         case TipoREPEAT:
            printf("");
            struct nodo *a1 = raiz->hijos[0];
            struct nodo *a2 = raiz->hijos[1];

            int etiquetaResguardo = desplazamientoLocalidad(0);
            generarCodigoHermanos(a1);
            generarCodigoHermanos(a2);

            char etiquetaResguardoString[100];
            sprintf(etiquetaResguardoString, "%d", etiquetaResguardo);

            escribirLineaMemoria("JEQ", "0", etiquetaResguardoString, "0", "Salto al final");
            
            break;

         case TipoREAD:
            printf("");
            // Calcular Espacio Memoria 
            int espacioMemoria = hash(raiz->atributos.identificador);
            char espacioMemoriaString[10];
            // copnvertimos a string
            sprintf(espacioMemoriaString, "%d", espacioMemoria);

            // Linea para pedir numero
            escribirLineaOperacion("IN", "0","0","0", "Guardamos numero en registro acumulador");

            // Linea para mover numero de registros a memoria
            escribirLineaMemoria("ST", "0",espacioMemoriaString, "5", "Guardamos numero en memoria");
            break;
         case TipoWRITE:
            printf("");

            struct nodo *auxiliar1 = raiz->hijos[0];

            generarCodigoHermanos(auxiliar1);

            escribirLineaOperacion("OUT", "0","0","0", "Sacamos numero de registro acumulador");

            break;
         default:
            break;
            
      }
   
}

void generadorExpresiones(struct nodo *raiz)
{
      switch(raiz->tipo.tipoExpresion)
      {
         case TipoOPERADOR:
            printf("");
            struct nodo * aux1 = raiz->hijos[0];
            struct nodo * aux2 = raiz->hijos[1];

            generarCodigoHermanos(aux1);
            escribirLineaMemoria("ST", "0","0","6", "");

            generarCodigoHermanos(aux2);
            escribirLineaMemoria("LD", "1","0","6", "" , "0");

            if(raiz->atributos.operador == "<")
            {
               escribirLineaOperacion("SUB", "0","1","1", "");
               escribirLineaMemoria("JLT", "0","2","7", "");
               escribirLineaMemoria("LDC", "0","0","1", "");
               escribirLineaMemoria("LDA", "7","1","7", "");
               escribirLineaMemoria("LDC", "0","1","0", "");
            }

            if(raiz->atributos.operador == "<=")
            {
               escribirLineaOperacion("SUB", "0","1","1", "");
               escribirLineaMemoria("JLE", "0","2","7", "" );
               escribirLineaMemoria("LDC", "0","0","1", "" );
               escribirLineaMemoria("LDA", "7","1","7", "" );
               escribirLineaMemoria("LDC", "0","1","0", "" );
            }

            if(raiz->atributos.operador == ">")
            {
               escribirLineaOperacion("SUB", "0","1","1", "");
               escribirLineaMemoria("JGT", "0","2","7", "" );
               escribirLineaMemoria("LDC", "0","0","1", "" );
               escribirLineaMemoria("LDA", "7","1","7", "" );
               escribirLineaMemoria("LDC", "0","1","0", "" );
            }

            if(raiz->atributos.operador == ">=")
            {
               escribirLineaOperacion("SUB", "0","1","1", "");
               escribirLineaMemoria("JGE", "0","2","7", "" );
               escribirLineaMemoria( "LDC", "0","0","1", "" );
               escribirLineaMemoria( "LDA", "7","1","7", "" );
               escribirLineaMemoria( "LDC", "0","1","0", "" );
            }

            if(raiz->atributos.operador == "==")
            {
               escribirLineaOperacion( "SUB", "0","1","1", "" );
               escribirLineaMemoria( "JEQ", "0","2","7", "" );
               escribirLineaMemoria("LDC", "0","0","1", "" );
               escribirLineaMemoria("LDA", "7","1","7", "");
               escribirLineaMemoria("LDC", "0","1","0", "" );
            }

            if(raiz->atributos.operador == "!=")
            {
               escribirLineaOperacion("SUB", "0","1","1", "" );
               escribirLineaMemoria("JNE", "0","2","7", "" );
               escribirLineaMemoria( "LDC", "0","0","1", "" );
               escribirLineaMemoria( "LDA", "7","1","7", "" );
               escribirLineaMemoria( "LDC", "0","1","0", "" );
            }

            if(raiz->atributos.operador == "+")
               escribirLineaOperacion("ADD", "0","1","0", "OPERADOR +" );

            if(raiz->atributos.operador == "-")
               escribirLineaOperacion("SUB", "0","1","0", "OPERAFOR -" );

            if(raiz->atributos.operador == "/")
               escribirLineaOperacion("DIV", "0","1","0", "OPERAFOR /" );

            if(raiz->atributos.operador == "*")
               escribirLineaOperacion("MUL", "0","1","0", "OPERAFOR *" );
         

            break;
         case TipoCONSTANTE:
            printf("");
            int valor = raiz->atributos.valor;
            char valorString[10];
            sprintf(valorString, "%d", valor);
            escribirLineaMemoria("LDC", "0",valorString,"1", " Cargamos constante a registros");

            break;
         case TipoIDENTIFICADOR:
            printf("");
            int direccion = hash(raiz->atributos.identificador);
            char direccionString[10];
            sprintf(direccionString, "%d", direccion);

            escribirLineaMemoria("LD", "0",direccionString,"5", " Cargamos direccion a registros");
            break;
      }
   
}

int desplazamientoLocalidad(int desplazamiento)
{
   LocalidadEscrita = LocalidadEscrita + desplazamiento;
   if(LocalidadMayorEscrita < LocalidadEscrita)
      LocalidadMayorEscrita = LocalidadEscrita;
   return LocalidadEscrita - desplazamiento;      
}

