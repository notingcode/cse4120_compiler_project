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

%right RPAREN ELSE

%start program

%% /* Grammar for C- lang */

program     : declaration-list
                 { savedTree = $1;} 
            ;

declaration-list    : declaration-list declaration
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

declaration : var-declaration { $$ = $1; }
            | fun-declaration { $$ = $1; }
            ;

var-declaration : type-specifier identifier SEMICOLON
                  { $$ = newDeclNode(VarK);
                    $$->attr.name = savedName;
                    $$->lineno = lineno;
                    $$->child[0] = $1;
                  }
            | type-specifier identifier 
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

type-specifier : INT
                  { $$ = newTypeNode(TypeNameK);
                    $$->attr.type = INT;
                  }
            | VOID
                  { $$ = newTypeNode(TypeNameK);
                    $$->attr.type = VOID;
                  } 
            ;

fun-declaration : type-specifier identifier
                  { $$ = newDeclNode(FuncK);
                    $$->lineno = lineno;
                    $$->attr.name = savedName;
                  }
                    LPAREN params RPAREN compound-stmt
                  { $$ = $3;
                    $$->child[0] = $1;
                    $$->child[1] = $5;
                    $$->child[2] = $7;
                  }
            ;

params      : paramList { $$ = $1; }
            | VOID { $$ = NULL; }
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

param       : type-specifier identifier
                  { $$ = newDeclNode(VarK);
                    $$->attr.name = savedName;
                    $$->child[0] = $1;
                  }
            | type-specifier identifier LSQUAREB RSQUAREB
                  { $$ = newDeclNode(ArrVarK);
                    $$->attr.arrAttr.name = savedName;
                    $$->attr.arrAttr.size = -1;
                  }
            ;

compound-stmt : LCURLY local-declarations statement-list RCURLY
                  { $$ = newStmtNode(CompK);
                    $$->child[0] = $2;
                    $$->child[1] = $3;
                  }
            ;

local-declarations : local-declarations var-declaration
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

statement-list    : statement-list statement
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

statement   : expression-stmt { $$ = $1; }
            | compound-stmt { $$ = $1; }
            | selection-stmt { $$ = $1; }
            | iteration-stmt { $$ = $1; }
            | return-stmt { $$ = $1; }
            ;

expression-stmt : expression SEMICOLON
                  { $$ = $1; }
            | SEMICOLON { $$ = NULL; }
            ;

selection-stmt     : IF LPAREN expression RPAREN statement
                  { $$ = newStmtNode(IfK);
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                  }
            | IF LPAREN expression RPAREN statement ELSE statement
                  { $$ = newStmtNode(IfK);
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                    $$->child[2] = $7;
                  }
            ;

iteration-stmt : WHILE LPAREN expression RPAREN statement-list
                 { $$ = newStmtNode(LoopK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
            ;

return-stmt : RETURN SEMICOLON
                { $$ = newStmtNode(RetK); }
            | RETURN expression SEMICOLON
                { $$ = newStmtNode(RetK);
                  $$->child[0] = $2;
                }

expression  : var ASSIGN expression
                { $$ = newExpNode(AssignK);
                  $$->attr.name = savedName;
                  $$->child[0] = $1;
                  $$->child[1] = $3;
                }
            | simple-expression { $$ = $1; }
            ;

var    : identifier
                { $$ = newExpNode(IdK);
                  $$->attr.name = savedName;
                }
            | identifier 
                { $$ = newExpNode(ArrIdK);
                  $$->attr.name = savedName;
                }
              LSQUAREB expression RSQUAREB
                { $$ = $2;
                  $$->child[0] = $4; 
                }
            ;

identifier  : ID
                  { savedName = copyString(tokenString); }
            ;

simple-expression  : additive-expression relop additive-expression
                 { $$ = $2;
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                 }
            | additive-expression { $$ = $1; }
            ;

relop       : LTE
                { $$ = newExpNode(OpK);
                  $$->attr.op = LTE;
                }
            | LT
                { $$ = newExpNode(OpK);
                  $$->attr.op = LT;
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

additive-expression : additive-expression addop term
                        { $$ = $2;
                          $$->child[0] = $1;
                          $$->child[1] = $3;
                        }
                    | term { $$ = $1; }
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

term        : term mulop factor 
                 { $$ = $2;
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                 }
            | factor { $$ = $1; }
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

factor      : LPAREN expression RPAREN
                  { $$ = $2; }
            | var
                  { $$ = $1; }
            | call
                  { $$ = $1; }
            | NUM
                  { $$ = newExpNode(ConstK);
                    $$->attr.val = atoi(tokenString);
                    $$->lineno = lineno;
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

args        : arg-list { $$ = $1; }
            | empty { $$ = $1; }
            ;

arg-list      : arg-list COMMA expression
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | expression { $$ = $1; }
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

