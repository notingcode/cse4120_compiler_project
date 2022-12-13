/****************************************************/
/* File: tiny.l                                     */
/* Lex specification for TINY                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit          [0-9]
number         {digit}+
letter         [a-zA-Z]
identifier     {letter}+
newline        \n
whitespace     [ \t]+
comment_start  "/*"
comment_end    "*/"

%x C_COMMENT

%%

({letter}+{digit}|{digit}+{letter})({letter}|{digit})* { return ERROR; }
   
"if"                        { return IF; }
"else"                      { return ELSE; }
"return"                    { return RETURN; }
"while"                     { return WHILE; }
"int"                       { return INT; }
"void"                      { return VOID; }
"="                         { return ASSIGN; }
"=="                        { return EQ; }
"!="                        { return NEQ; }
"<"                         { return LT; }
"<="                        { return LTE; }
">"                         { return GT; }
">="                        { return GTE; }
"+"                         { return PLUS; }
"-"                         { return MINUS; }
"*"                         { return TIMES; }
"/"                         { return OVER; }
"("                         { return LPAREN; }
")"                         { return RPAREN; }
"["                         { return LSQUAREB; }
"]"                         { return RSQUAREB; }
"{"                         { return LCURLY; }
"}"                         { return RCURLY; }
";"                         { return SEMICOLON; }
","                         { return COMMA; }
        
{number}                    { return NUM; }
{identifier}                { return ID; }
{newline}                   { lineno++; }
{whitespace}                { /* skip whitespace */ }

{comment_start}             { BEGIN(C_COMMENT); }
<C_COMMENT>{comment_end}    { BEGIN(INITIAL); }
<C_COMMENT>.                { /* skip comments */ }
<C_COMMENT>{newline}        { lineno++; }
<C_COMMENT><<EOF>>          { BEGIN(INITIAL);
                              return COMMENT_ERROR; }
{comment_end}              { return COMMENT_ERROR; }
<<EOF>>                     { return ENDFILE; }

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d\t\t\t",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}