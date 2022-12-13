/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

static int yyerror(char * message);
static int yylex(void);
%}

%token IF ELSE RETURN WHILE
%token INT VOID
%token ID NUM
%token ASSIGN EQ NEQ LT LTE GT GTE PLUS MINUS TIMES OVER
%token LPAREN LSQUAREB LCURLY RPAREN RSQUAREB RCURLY SEMICOLON COMMA
%token ERROR C_COMMENT COMMENT_ERROR ENDFILE

/* %nonassoc RPAREN 
%nonassoc ELSE */

%start program

%% /* Grammar for C- lang */

program     : declList
                 { savedTree = $1;} 
            ;

declList    : declList declaration
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; }
                     else $$ = $2;
                 }
            | declaration { $$ = $1; }
            ;

declaration : variableDeclaration { $$ = $1; }
            | functionDeclaration { $$ = $1; }
            ;

variableDeclaration : typeSpecifier identifier SEMICOLON
                  { $$ = newDeclNode(VarK);
                    $$->attr.name = savedName;
                    $$->lineno = lineno;
                    $$->child[0] = $1;
                  }
            | typeSpecifier identifier 
                  { $$ = newDeclNode(ArrVarK);
                    $$->attr.arrAttr.name = savedName;
                    $$->lineno = lineno;
                    $$->child[0] = $1;
                  }
              LSQUAREB NUM 
                  { $$ = $3;
                    $$->attr.arrAttr.size = atoi(tokenString); 
                  }
              RSQUAREB SEMICOLON
                  { $$ = $6; }
            ;

functionDeclaration : typeSpecifier identifier
                  { $$ = newDeclNode(FuncK);
                    $$->attr.name = savedName;
                    $$->lineno = lineno;
                  }
                    LPAREN params RPAREN compoundStmt
                  { $$ = $3;
                    $$->child[0] = $1;
                    $$->child[1] = $5;
                    $$->child[2] = $7;
                  }
            ;

localDecl : localDecl variableDeclaration
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; }
                     else $$ = $2;
                 }
            | empty { $$ = $1; }
            ;

stmtSeq    : stmtSeq stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; }
                     else $$ = $2;
                 }
            | empty { $$ = $1; }
            ;

stmt        : expressionStmt { $$ = $1; }
            | compoundStmt { $$ = $1; }
            | ifStmt { $$ = $1; }
            | loopStmt { $$ = $1; }
            | returnStmt { $$ = $1; }
            ;

expressionStmt : exp SEMICOLON
                  { $$ = $1; }
            | SEMICOLON { $$ = NULL; }
            ;

compoundStmt : LCURLY localDecl stmtSeq RCURLY
                  { $$ = newStmtNode(CompK);
                    $$->child[0] = $2;
                    $$->child[1] = $3;
                  }
            ;

ifStmt     : IF LPAREN exp RPAREN stmt
                  { $$ = newStmtNode(IfK);
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                  }
            | IF LPAREN exp RPAREN stmt ELSE stmt
                  { $$ = newStmtNode(IfK);
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                    $$->child[2] = $7;
                  }
            ;

loopStmt : WHILE LPAREN exp RPAREN stmtSeq
                 { $$ = newStmtNode(LoopK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
            ;

returnStmt : RETURN SEMICOLON
                { $$ = newStmtNode(RetK); }
            | RETURN exp SEMICOLON
                { $$ = newStmtNode(RetK);
                  $$->child[0] = $2;
                }

identifier  : ID
                  { savedName = copyString(tokenString); }
            ;

typeSpecifier : INT
                  { $$ = newTypeNode(TypeNameK);
                    $$->attr.type = INT;
                  }
            | VOID
                  { $$ = newTypeNode(TypeNameK);
                    $$->attr.type = VOID;
                  } 
            ;

params      : paramList { $$ = $1; }
            | VOID
                  { $$ = newTypeNode(TypeNameK);
                    $$->attr.type = VOID;
                  }
            ;

paramList   : paramList COMMA param
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | param { $$ = $1; }
            ;

param       : typeSpecifier identifier
                  { $$ = newDeclNode(VarK);
                    $$->attr.name = savedName;
                    $$->child[0] = $1;
                  }
            | typeSpecifier identifier LSQUAREB RSQUAREB
                  { $$ = newDeclNode(ArrVarK);
                    $$->attr.arrAttr.name = savedName;
                    $$->attr.arrAttr.size = -1;
                  }
            ;

variable    : identifier
                { $$ = newExpNode(IdK);
                  $$->attr.name = savedName;
                }
            | identifier 
                { $$ = newExpNode(ArrIdK);
                  $$->attr.name = savedName;
                }
              LSQUAREB exp RSQUAREB
                { $$ = $2;
                  $$->child[0] = $4; 
                }
            ;
exp         : variable ASSIGN exp
                { $$ = newExpNode(AssignK);
                  $$->attr.name = savedName;
                  $$->child[0] = $1;
                  $$->child[1] = $3;
                }
            | simpleExp { $$ = $1; }
            ;

simpleExp  : addExp relop addExp
                 { $$ = $2;
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                 }
            | addExp { $$ = $1; }
            ;

relop       : LT
                { $$ = newExpNode(OpK);
                  $$->attr.op = LT;
                }
            | LTE
                { $$ = newExpNode(OpK);
                  $$->attr.op = LTE;
                }
            | GT
                {
                  $$ = newExpNode(OpK);
                  $$->attr.op = GT;
                }
            | GTE
                { $$ = newExpNode(OpK);
                  $$->attr.op = GTE;
                }
            | EQ
                { $$ = newExpNode(OpK);
                  $$->attr.op = EQ;
                }
            | NEQ
                { $$ = newExpNode(OpK);
                  $$->attr.op = NEQ;
                }
            ;

addExp      : addExp addop term
                { $$ = $2;
                  $$->child[0] = $1;
                  $$->child[1] = $3;
                }
            | term { $$ = $1; }
            ;

term        : term mulop factor 
                 { $$ = $2;
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                 }
            | factor { $$ = $1; }
            ;

factor      : LPAREN exp RPAREN
                  { $$ = $2; }
            | variable
                  { $$ = $1; }
            | call
                  { $$ = $1; }
            | NUM
                  { $$ = newExpNode(ConstK);
                    $$->attr.val = atoi(tokenString);
                    $$->lineno = lineno;
                  }
            ;

addop       : PLUS
                { $$ = newExpNode(OpK);
                  $$->attr.op = PLUS;
                }
            | MINUS
                { $$ = newExpNode(OpK);
                  $$->attr.op = MINUS;
                }
            ;

mulop       : TIMES
                { $$ = newExpNode(OpK);
                  $$->attr.op = TIMES;
                }
            | OVER
                {
                  $$ = newExpNode(OpK);
                  $$->attr.op = OVER;
                }
            ;

call        : identifier
                { $$ = newExpNode(CallK);
                  $$->attr.name = savedName;
                }
              LCURLY args RCURLY
                { $$ = $2;
                  $$->child[0] = $4;
                }
            ;

args        : argSeq { $$ = $1; }
            | empty { $$ = $1; }
            ;

argSeq      : argSeq COMMA exp
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | exp { $$ = $1; }
            ;

empty       : { $$ = NULL; }
            ;
%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ 
  int token = getToken(); 
  while (token == C_COMMENT)
    token = getToken();
  return token;
}

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

