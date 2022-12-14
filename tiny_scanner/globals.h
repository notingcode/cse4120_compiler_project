/****************************************************/
/* File: globals.h                                  */
/* Global types and vars for TINY compiler          */
/* must come before other include files             */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef YYPARSER

/* the name of the following file may change */
#include "cm.tab.h"

/* ENDFILE is implicitly defined by Yacc/Bison,
 * and not included in the tab.h file
 */
#define ENDFILE 0
#endif

/* MAXRESERVED = the number of reserved words */
#define MAXRESERVED 8

typedef int TokenType;

// typedef enum
// /* book-keeping tokens */
// {
//    ENDFILE,
//    ERROR,
//    /* reserved words */
//    IF,
//    ELSE,
//    RETURN,
//    WHILE,
//    /* reserved words for data type*/
//    INT,
//    VOID,
//    /* multicharacter tokens */
//    ID,
//    NUM,
//    /* special symbols */
//    ASSIGN,
//    EQ,
//    NEQ,
//    LT,
//    LTE,
//    GT,
//    GTE,
//    PLUS,
//    MINUS,
//    TIMES,
//    OVER,
//    LPAREN,
//    RPAREN,
//    LSQUAREB,
//    RSQUAREB,
//    LCURLY,
//    RCURLY,
//    SEMICOLON,
//    COMMA,
//    COMMENT,
//    COMMENT_ERROR
// } TokenType;

extern FILE *source;  /* source code text file */
extern FILE *listing; /* listing output text file */
extern FILE *code;    /* code text file for TM simulator */

extern int lineno; /* source line number for listing */

/**************************************************/
/***********   Syntax tree for parsing ************/
/**************************************************/

typedef enum
{
   StmtK,
   ExpK,
   DeclK,
   TypeK
} NodeKind;
typedef enum
{
   IfK,
   LoopK,
   RetK,
   CompK
} StmtKind;
typedef enum
{
   OpK,
   AssignK,
   ConstK,
   IdK,
   ArrIdK,
   CallK,
   SimpleK
} ExpKind;
typedef enum
{
   FuncK,
   VarK,
   ArrVarK,
   ParamK,
   ArrParamK
} DeclKind;
typedef enum
{
   TypeNameK
} TypeKind;

/* ExpType is used for type checking */
typedef enum
{
   Void,
   Integer
} ExpType;

#define MAXCHILDREN 3

struct arrayAttr
{
   char *name;
   int size;
};

typedef struct treeNode
{
   struct treeNode *child[MAXCHILDREN];
   struct treeNode *sibling;
   int lineno;
   NodeKind nodekind;
   union
   {
      StmtKind stmt;
      ExpKind exp;
      DeclKind decl;
      TypeKind type;
   } kind;
   union
   {
      TokenType type;
      TokenType op;
      int val;
      char *name;
      struct arrayAttr arrAttr;
   } attr;
   ExpType type; /* for type checking of exps */
} TreeNode;

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

/* EchoSource = TRUE causes the source program to
 * be echoed to the listing file with line numbers
 * during parsing
 */
extern int EchoSource;

/* TraceScan = TRUE causes token information to be
 * printed to the listing file as each token is
 * recognized by the scanner
 */
extern int TraceScan;

/* TraceParse = TRUE causes the syntax tree to be
 * printed to the listing file in linearized form
 * (using indents for children)
 */
extern int TraceParse;

/* TraceAnalyze = TRUE causes symbol table inserts
 * and lookups to be reported to the listing file
 */
extern int TraceAnalyze;

/* TraceCode = TRUE causes comments to be written
 * to the TM code file as code is generated
 */
extern int TraceCode;

/* Error = TRUE prevents further passes if an error occurs */
extern int Error;
#endif
