/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { case IF: fprintf(listing,"%-20s%-20s\n","IF",tokenString); break;
    case ELSE: fprintf(listing,"%-20s%-20s\n","ELSE",tokenString); break;
    case RETURN: fprintf(listing,"%-20s%-20s\n","RETURN",tokenString); break;
    case WHILE: fprintf(listing,"%-20s%-20s\n","WHILE",tokenString); break;
    case INT: fprintf(listing,"%-20s%-20s\n","INT",tokenString); break;
    case VOID: fprintf(listing,"%-20s%-20s\n","VOID",tokenString); break;
    case ASSIGN: fprintf(listing,"%-20s%-20s\n","ASSIGN",tokenString); break;
    case LT: fprintf(listing,"%-20s%-20s\n","LT",tokenString); break;
    case LTE: fprintf(listing,"%-20s%-20s\n","LTE",tokenString); break;
    case GT: fprintf(listing,"%-20s%-20s\n","GT",tokenString); break;
    case GTE: fprintf(listing,"%-20s%-20s\n","GTE",tokenString); break;
    case NEQ: fprintf(listing,"%-20s%-20s\n","NEQ",tokenString); break;
    case EQ: fprintf(listing,"%-20s%-20s\n","EQ",tokenString); break;
    case LPAREN: fprintf(listing,"%-20s%-20s\n","LPAREN",tokenString); break;
    case RPAREN: fprintf(listing,"%-20s%-20s\n","RPAREN",tokenString); break;
    case LSQUAREB: fprintf(listing,"%-20s%-20s\n","LSQUAREB",tokenString); break;
    case RSQUAREB: fprintf(listing,"%-20s%-20s\n","RSQUAREB",tokenString); break;
    case LCURLY: fprintf(listing,"%-20s%-20s\n","LCURLY",tokenString); break;
    case RCURLY: fprintf(listing,"%-20s%-20s\n","RCURLY",tokenString); break;
    case SEMICOLON: fprintf(listing,"%-20s%-20s\n","SEMICOLON",tokenString); break;
    case COMMA: fprintf(listing,"%-20s%-20s\n","COMMA",tokenString); break;
    case PLUS: fprintf(listing,"%-20s%-20s\n","PLUS",tokenString); break;
    case MINUS: fprintf(listing,"%-20s%-20s\n","MINUS",tokenString); break;
    case TIMES: fprintf(listing,"%-20s%-20s\n","TIMES",tokenString); break;
    case OVER: fprintf(listing,"%-20s%-20s\n","OVER",tokenString); break;
    case ENDFILE: fprintf(listing,"%-20s%-20s\n","EOF",tokenString); break;
    case NUM:
      fprintf(listing,
          "%-20s%-20s\n","NUM",tokenString);
      break;
    case ID:
      fprintf(listing,
          "%-20s%-20s\n","ID",tokenString);
      break;
    case ERROR:
      fprintf(listing,
          "%-20s%-20s\n","ERROR",tokenString);
      break;
    case COMMENT_ERROR:
      fprintf(listing,
          "%-20s%-20s\n","COMMENT_ERROR",tokenString);
      break;
    default: /* should never happen */
      fprintf(listing,"Unknown token: %d\n",token);
  }
}

void printOpToken(TokenType token)
{
  switch (token)
    {
    case LTE:
      fprintf(listing,"<=\n");
      break;
    case LT:
      fprintf(listing,"<\n");
      break;
    case GTE:
      fprintf(listing,">=\n");
      break;
    case GT:
      fprintf(listing,">\n");
      break;
    case EQ:
      fprintf(listing,"==\n");
      break;
    case NEQ:
      fprintf(listing,"!=\n");
      break;
    case PLUS:
      fprintf(listing,"+\n");
      break;
    case MINUS:
      fprintf(listing,"-\n");
      break;
    case TIMES:
      fprintf(listing,"*\n");
      break;
    case OVER:
      fprintf(listing,"/\n");
      break;
    default:
      fprintf(listing,"Not assigned OP token\n");
      break;
    }
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    t->lineno = lineno;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

TreeNode * newDeclNode(DeclKind kind)
{
  TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing, "Out of memory error at line %d\n",lineno);
  else
    {
      for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
      t->sibling = NULL;
      t->nodekind = DeclK;
      t->kind.decl = kind;
      t->lineno = lineno;
    }
  return t;
}

TreeNode * newTypeNode(TypeKind kind)
{
  TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing, "Out of memory error at line %d\n",lineno);
  else
    {
      for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
      t->sibling = NULL;
      t->nodekind = TypeK;
      t->kind.type = kind;
      t->lineno = lineno;
    }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strncpy(t,s,n);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    fprintf(listing," ");
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind==StmtK)
    { switch (tree->kind.stmt) {
        case IfK:
          fprintf(listing,"If\n");
          break;
        case LoopK:
          fprintf(listing,"While\n");
          break;
        case RetK:
          fprintf(listing,"Return\n");
          break;
        case CompK:
          fprintf(listing,"Compound Statement\n");
          break;
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind==ExpK)
    { switch (tree->kind.exp) {
        case OpK:
          fprintf(listing,"Simple Expression\n");
          printSpaces();
          fprintf(listing,"  Operator : ");
          printOpToken(tree->attr.op);
          break;
        case ConstK:
          fprintf(listing,"Constant : %d\n",tree->attr.val);
          break;
        case IdK:
          fprintf(listing,"Variable : %s\n",tree->attr.name);
          break;
        case ArrIdK:
          fprintf(listing,"Array ID : %s\n",tree->attr.name);
          break;
        case CallK:
          fprintf(listing,"Call to %s\n",tree->attr.name);
          break;
        case AssignK:
          fprintf(listing,"Assign : =\n");
          break;
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind==DeclK)
    { switch (tree->kind.decl){
        case FuncK:
          fprintf(listing,"Function Declare : %s\n",tree->attr.name);
          break;
        case VarK:
          fprintf(listing,"Variable Declare : %s\n",tree->attr.name);
          break;
        case ArrVarK:
          if(tree->attr.arrAttr.size < 0)
            fprintf(listing,"Array Variable Declare : %s\n",tree->attr.arrAttr.name);
          else
            fprintf(listing,"Array Variable Allocate : %s of size %d\n",tree->attr.arrAttr.name,tree->attr.arrAttr.size);
          break;
        default:
          fprintf(listing,"Unknown Declaration Node Kind\n");
          break;
      }
    }
    else if (tree->nodekind==TypeK)
    { switch (tree->kind.type){
        case TypeNameK:
          fprintf(listing,"Type : ");
          switch (tree->attr.type){
            case INT:
              fprintf(listing,"int\n");
              break;
            case VOID:
              fprintf(listing,"void\n");
              break;
            default:
              fprintf(listing,"Unknown Variable Type\n");
              break;
          }
          break;
        default:
          fprintf(listing,"Unknown Type Node Kind\n");
          break;
      }
    }
    else fprintf(listing,"Unknown node kind\n");
    for (i=0;i<MAXCHILDREN;i++)
         printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
