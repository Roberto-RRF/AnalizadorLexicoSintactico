%token SI VERDADERA FIN_SI FALSO REPETIR HASTA LEER ESCRIBIR PARENIZQUIERDO PARENDERECHO SEPARADOR ASIGNACION IDENTIFICADOR NUMERO
%left DESIGUAL IGUAL MENORIGUAL MAYORIGUAL MENORQUE MAYORQUE
%left SUMA RESTA 
%left MULTIPLICACION DIVISION

%{
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX_HIJOS 3

typedef int TipoToken;
typedef enum {Tipo_Instruccion, Tipo_Expresion} NodoTipo;
typedef enum {Tipo_Si, Tipo_Repetir, Tipo_Escribir, Tipo_Leer, Tipo_Asignacion} Instrucciones_Tipo;
typedef enum {Tipo_Operador, Tipo_Constante, Tipo_Identificador} Expresion_Tipo
char* operadores[]={"<",">","==","!=","<=",">=","+","-","*","/"};

struct NodoDelArbol {
	struct NodoDelArbol* hijos[MAX_HIJOS];
	struct NodoDelArbol* hermano;
	int Num_Linea;
	NodoTipo tipodelnodo;

	union {
		Instrucciones_Tipo Instruccion;
		Expresion_Tipo Expresion;
	} Tipo;
	
	union {
		TipoToken Operador;
		int valor;
		char *nombre;
	} Atributos;
};

typedef struct NodoDelArbol NodoArbol;

NodoArbol* NuevoNodoInstruccion(Instrucciones_Tipo tipodelnodo);
NodoArbol* NuevoNodoExpresion(Expresion_Tipo tipodelnodo);

int direccion = 0;
NodoArbol *ArbolSalvado = NULL;

void add(char);
void insert_type();
int search(char *, char);
void insert_type();

struct dataType {
	char * id_name;
      int linea_lee[10];
      int linea_utiliza[10];
      int linea_asigna[10];
} symbol_table[40];

int count=0;
int contador_lee=1;
int contador_utiliza=1;
int contador_asigna=1;
int q;
char type[10];

extern int num_lineas;
extern yyin;
extern yytext;

#pragma warning(disable: 4013 6385 6001 4996)
#define YYSTYPE NodoArbol*

%}


%%

programa                : secuencia_intrucciones { ArbolSalvado = $1; }

secuencia_intrucciones  : secuencia_intrucciones SEPARADOR intruccion  {NodoArbol* t = $1;
												if (t)
												{
													while (t->hermano)
														t=-t>hermano;
													t->hermano=$3;
													$$=$1;		
												}
												else
													$$=$3;
												}
                        | intruccion {$$=$1;}

intruccion              : intruccion_if {$$=$1;}
                        | intruccion_repeat {$$=$1;}
                        | intruccion_asignacion {$$=$1;}
                        | intruccion_read {$$=$1;}
                        | intruccion_write {$$=$1;}

intruccion_if           : SI expresion VERDADERA secuencia_intrucciones FIN_SI { $$ = NuevoNodoInstruccion(Tipo_Si);
														$$->hijos[0] = $2;
														$$->hijos[1] = $4;
													}

                        | SI expresion VERDADERA secuencia_intrucciones FALSO secuencia_intrucciones FIN_SI { $$ = NuevoNodoInstruccion(Tipo_Si);
														$$->hijos[0] = $2;
														$$->hijos[1] = $4;
														$$->hijos[2] = $6;
													}


intruccion_repeat       : REPETIR secuencia_intrucciones HASTA expresion { $$ = NuevoNodoInstruccion(Tipo_Repetir);
														$$->hijos[0] = $2;
														$$->hijos[1] = $4;
													}

intruccion_asignacion   : IDENTIFICADOR { add('A') } ASIGNACION expresion { $$ = NuevoNodoInstruccion(Tipo_Asignacion);
														$$->hijos[0] = $4;
														$$->Atributos.nombre = (char *) malloc ((size_t)strlen(cadena) + (size_t)2);
														strcpy ($$->Atributos.nombre, cadena);
														$$->Num_Linea = linea; //Que es cadena y linea 
														//extern char* cadena, extern linea
													}

intruccion_read         : LEER IDENTIFICADOR { add('L') } { $$ = NuevoNodoInstruccion(Tipo_Leer);
										$$->Atributos.nombre = (char *) malloc ((size_t)strlen(cadena) + (size_t)2);
										strcpy ($$->Atributos.nombre, cadena);
									}

intruccion_write        : ESCRIBIR expresion { $$ = NuevoNodoInstruccion(Tipo_Escribir);
								$$->hijos[0] = $2;
							}

expresion               : expresion_simple MENORQUE expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 0;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple MAYORQUE expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 1;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple IGUAL expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 2;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple DESIGUAL expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 3;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple MENORIGUAL expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 4;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple MAYORIGUAL expresion_simple { $$ = NuevoNodoExpresion(Tipo_Operador);
												$$->Atributos.Operador = 5;
												$$->hijos[0] = $1;
												$$->hijos[1] = $3;
											}

                        | expresion_simple {$$=$1;}

expresion_simple        : expresion_simple SUMA termino { $$ = NuevoNodoExpresion(Tipo_Operador);
										$$->Atributos.Operador = 6;
										$$->hijos[0] = $1;
										$$->hijos[1] = $3;
										}

                        | expresion_simple RESTA termino { $$ = NuevoNodoExpresion(Tipo_Operador);
										$$->Atributos.Operador = 7;
										$$->hijos[0] = $1;
										$$->hijos[1] = $3;
										}

                        | termino {$$=$1;}

termino                 : termino MULTIPLICACION factor { $$ = NuevoNodoExpresion(Tipo_Operador);
										$$->Atributos.Operador = 8;
										$$->hijos[0] = $1;
										$$->hijos[1] = $3;
										}

                        | termino DIVISION factor { $$ = NuevoNodoExpresion(Tipo_Operador);
									$$->Atributos.Operador = 9;
									$$->hijos[0] = $1;
									$$->hijos[1] = $3;
									}

                        | factor {$$=$1;}

factor                  : PARENIZQUIERDO expresion PARENDERECHO { $$ = $2; }
                        | NUMERO {$$ = NuevoNodoExpresion(Tipo_Constante);
						$$->Atributos.valor = val;} //Val? extern val

                        | IDENTIFICADOR { add('U') } {$$ = NuevoNodoExpresion(Tipo_Identificador);
									$$->Atributos.nombre = (char *) malloc ((size_t)strlen(cadena) + (size_t)2);
									strcpy ($$->Atributos.nombre, cadena);
									}

       

%%

int yyerror(char *s) {

   char mensaje[100];

   if ( !strcmp( s, "syntax error" ) )
      strcpy( mensaje, "Error de sintaxis" );
   else
      strcpy( mensaje, s );

   printf("%s\n",mensaje);
   exit( 1 ); /* Sale del programa */

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
	printf("\n\n");
	printf("Tabla de simbolos \n\n");
	printf("\nIdentificador   Lineas en que se lee   Lineas en que se utiliza   Lineas en las que se asigna \n");
	printf("_____________________________________________________________________________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t\t\t", symbol_table[i].id_name);
		for (unsigned int j=1; j<=symbol_table[i].linea_lee[0]; j++) 
		{
			printf("%d ", symbol_table[i].linea_lee[j]);
		}
		printf("\t\t\t");
		for (unsigned int k=1; k<=symbol_table[i].linea_utiliza[0]; k++) 
		{
			printf("%d ", symbol_table[i].linea_utiliza[k]);
		}
		printf("\t\t\t");
		for (unsigned int l=1; l<=symbol_table[i].linea_asigna[0]; l++) 
		{
			printf("%d ", symbol_table[i].linea_asigna[l]);
		}
		printf("\n");
	}
	for(i=0;i<count;i++) {
		free(symbol_table[i].id_name);
	}
	printf("\n\n");
	printf("\t\t\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
	printtree(head); 
	printf("\n\n");
	printf("El codigo se ha leido correctamente");

    	return(0);
}

int search(char *type, char c) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
			if (c == 'L') {
				contador_lee = symbol_table[i].linea_lee[0] + 1;
				symbol_table[i].linea_lee[contador_lee]=num_lineas;
				symbol_table[i].linea_lee[0]=contador_lee;
			}
			if (c == 'U') {
				contador_utiliza = symbol_table[i].linea_utiliza[0] + 1;
				symbol_table[i].linea_utiliza[contador_utiliza]=num_lineas;
				symbol_table[i].linea_utiliza[0]=contador_utiliza;
			}
			if (c == 'A') {
				contador_asigna = symbol_table[i].linea_asigna[0] + 1;
				symbol_table[i].linea_asigna[contador_asigna]=num_lineas;
				symbol_table[i].linea_asigna[0]=contador_asigna;
			}
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
  q=search(yytext, c);
  if(!q) {
		symbol_table[count].id_name=strdup(yytext);
		if (c == 'L') {
			symbol_table[count].linea_lee[contador_lee]=num_lineas;
			symbol_table[count].linea_lee[0]=contador_lee;
			contador_lee++;
		}
		if (c == 'U') {
			symbol_table[count].linea_utiliza[contador_utiliza]=num_lineas;
			symbol_table[count].linea_utiliza[0]=contador_utiliza;
			contador_utiliza++;
		}
		if (c == 'A') {
			symbol_table[count].linea_asigna[contador_asigna]=num_lineas;
			symbol_table[count].linea_asigna[0]=contador_asigna;
			contador_asigna++;
		}
		count++;
	}
}

NodoArbol* NuevoNodoInstruccion(Instrucciones_Tipo tipodelnodo)
{
	NodoArbol* Nodo = (NodoArbol*)malloc(sizeof(NodoArbol));
	if (!Nodo)
		printf("Memoria agotada");
	else
	{
		for (unsigned int i=0; i<MAX_HIJOS; i++)
			Nodo->hijos[i] = NULL;
		Nodo->hermano = NULL;
		Nodo->tipodelnodo=Tipo_Instruccion;
		Nodo->Tipo.Instruccion = tipodelnodo;
		Nodo->Num_Linea = linea; //linea??
	}
	return Nodo;
}

NodoArbol* NuevoNodoExpresion(Expresion_Tipo tipodelnodo)
{
	NodoArbol* Nodo = (NodoArbol*)malloc(sizeof(NodoArbol));
	if (!Nodo)
		printf("Memoria agotada");
	else
	{
		for (unsigned int i=0; i<MAX_HIJOS; i++)
			Nodo->hijos[i] = NULL;
		Nodo->hermano = NULL;
		Nodo->tipodelnodo=Tipo_Expresion;
		Nodo->Tipo.Expresion = tipodelnodo;
		Nodo->Num_Linea = linea; //linea??
	}
	return Nodo;
}

void ImprimirNodo(int contador, NodoArbol* Nodo)
{
	NodoArbol* Nodo_Nuevo = NULL;
	if (!Nodo)
		Nodo_Nuevo = ArbolSalvado;
	else 
		Nodo_Nuevo = Nodo;
	for (unsigned int j = 0; j < contador; j++)
		printf(" ");
	if (Nodo_Nuevo->tipodelnodo == Tipo_Instruccion)
	{
		int tipo = Nodo_Nuevo->Tipo.Instruccion;
		if (tipo==0)
			printf("Si: \n");
		else if (tipo==1)
			printf("Repetir: \n");
		else if (tipo==2)
			printf("Escribir: \n");
		else if (tipo==3)
			printf("Leer: %s \n", Nodo_Nuevo->Atributos.nombre);
		else if (tipo==4)
			printf("Asignar: %s \n", Nodo_Nuevo->Atributos.nombre);
		else
			printf("Error \n");
	}
	else 
	{
		int tipo = Nodo_Nuevo->Tipo.Expresion;
		if (tipo==0)
			printf("Operador: %s \n", operadores[Nodo_Nuevo->Atributos.Operador]);
		else if (tipo==1)
			printf("Constante: %d \n", Nodo_Nuevo->Atributos.valor);
		else if (tipo==2)
			printf("Identificador: %s \n", Nodo_Nuevo->Atributos.nombre);
		else
			printf("Error \n");
	}
	for (unsigned int l=0; l<MAX_HIJOS; l++)
	{
		if (Nodo_Nuevo->hijos[l])
			ImprimirNodo(contador+1, Nodo_Nuevo->hijos[l]);
	}
	if(Nodo_Nuevo->hermano)
		ImprimirNodo(contador, Nodo_Nuevo->hermano);
}

void insert_type() {
	strcpy(type, yytext);
}
