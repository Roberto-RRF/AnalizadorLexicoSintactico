
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TOKEN_SI = 258,
     TOKEN_VERDADERO = 259,
     TOKEN_FALSO = 260,
     TOKEN_FIN_SI = 261,
     TOKEN_REPETIR = 262,
     TOKEN_HASTA = 263,
     TOKEN_LEER = 264,
     TOKEN_ESCRIBIR = 265,
     TOKEN_DIGITO = 266,
     TOKEN_IDENTIFICADOR = 267,
     TOKEN_CADENA = 268,
     TOKEN_PUNTO_COMA = 269,
     TOKEN_PARENTESIS_IZQUIERDO = 270,
     TOKEN_PARENTESIS_DERECHO = 271,
     TOKEN_DIFERENTE = 272,
     TOKEN_IGUAL = 273,
     TOKEN_MENOR_IGUAL = 274,
     TOKEN_MAYOR_IGUAL = 275,
     TOKEN_MENOR_QUE = 276,
     TOKEN_MAYOR_QUE = 277,
     TOKEN_ASIGNACION = 278,
     TOKEN_SUMA = 279,
     TOKEN_RESTA = 280,
     TOKEN_MULT = 281,
     TOKEN_DIV = 282
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


