%{

#include <string.h>
#include <vector>
#include <map>
#include "AstNode.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"

using namespace std;
using namespace llvm;

int ErrorCount;
extern int CurrentLine;
typedef map<string, Symbol*> Scope;
static vector<Scope> ScopeStack;
SPMDBuilder *Builder;


int yyerror(const char *error);
int yywrap();
int yylex();

Symbol *lookupSymbol(const char *name);

%}

%error-verbose

%token TOK_IDENTIFIER
%token TOK_STRING
%token TOK_NUMBER
%token TOK_IF
%token TOK_THEN
%token TOK_ELSE
%token TOK_END
%token TOK_WHILE
%token TOK_EQUALS
%token TOK_NOT_EQUAL
%token TOK_FLOAT
%token TOK_RETURN
%token TOK_LOGICAL_AND
%token TOK_LOGICAL_OR

%left TOK_OR
%left TOK_AND
%left	'+' '-'
%left 	'*' '/' '%'

%union {
	AstNode *node;
	float numVal;
	char strval[1024];
}

%type <node> expr statement stmtseq ifstmt whilestmt assignstmt
%type <node> variable vardecl returnstmt 
%type <numVal> TOK_NUMBER
%type <strval> TOK_STRING TOK_IDENTIFIER

%%
module			:		funcdecl
				;

funcdecl		:		TOK_FLOAT TOK_IDENTIFIER '(' ')' 
						'{' enter_scope stmtseq leave_scope '}'
						{
							Builder->startFunction($2);
							$7->generate(*Builder);
							Builder->endFunction();  
						}
				;

/* Statement types */	
statement		:		ifstmt
				|		whilestmt
				|		returnstmt ';'
				|		assignstmt ';'
				|		vardecl ';'
				|		'{' enter_scope stmtseq leave_scope '}'
						{
							$$ = $3;
						}
				;

returnstmt		:		TOK_RETURN expr
						{
							$$ = new ReturnAst($2);
						}

whilestmt		:		TOK_WHILE '(' expr ')' statement
						{
							$$ = new WhileAst($3, $5);
						}

ifstmt			:		TOK_IF expr statement TOK_ELSE statement
						{
							$$ = new IfAst($2, $3, $5);
						}
				|		TOK_IF expr statement
						{
							$$ = new IfAst($2, $3, nullptr);
						}
				;

assignstmt		:		variable '=' expr
						{
							$$ = new AssignAst($1, $3);
						}
				;

vardecl			:		TOK_FLOAT TOK_IDENTIFIER
						{
							if (lookupSymbol($2))
							{
								printf("Redeclared symbol %s\n", $2);
								YYERROR;
							}
							else
							{
								Symbol *Sym = new Symbol;
								Sym->Val = nullptr;	// will be filled in later
								ScopeStack.back()[$2] = Sym;
							}

							$$ = nullptr;
						}
				|		TOK_FLOAT TOK_IDENTIFIER '=' expr
						{
							if (lookupSymbol($2))
							{
								printf("Redeclared symbol %s\n", $2);
								YYERROR;
							}
							else
							{
								Symbol *Sym = new Symbol;
								Sym->Val = nullptr;	// will be filled in later
								AstNode *Var = new VariableAst(Sym);
								ScopeStack.back()[$2] = Sym;
								$$ = new AssignAst(Var, $4);
							}
						}
				;

enter_scope		:		/* nothing */
						{
							ScopeStack.push_back(Scope());
						}
				;
				
leave_scope		:		/* nothing */
						{
							ScopeStack.pop_back();
						}
				;

stmtseq			:		statement stmtseq
						{
							$$ = new SequenceAst($1, $2);
						}
				|		statement
				;

expr			:		expr '>' expr
						{
							$$ = new CompareAst(CmpInst::FCMP_UGT, $1, $3);
						}
				|		expr '<' expr
						{
							$$ = new CompareAst(CmpInst::FCMP_ULT, $1, $3);
						}
				|		expr TOK_EQUALS expr
						{
							$$ = new CompareAst(CmpInst::FCMP_UEQ, $1, $3);
						}
				|		expr TOK_NOT_EQUAL expr
						{
							$$ = new CompareAst(CmpInst::FCMP_UNE, $1, $3);
						}
				|		expr '+' expr
						{
							$$ = new AddAst($1, $3);
						}
				|		expr '-' expr
						{
							$$ = new SubAst($1, $3);
						}
				|		expr '*' expr
						{
							$$ = new MulAst($1, $3);
						}
				|		expr '/' expr
						{
							$$ = new DivAst($1, $3);
						}
				|		'(' expr ')'
						{
							$$ = $2;
						}
				|		TOK_NUMBER
						{
							$$ = new ConstantAst($1);
						}
				|		variable
				;
	
variable		:		TOK_IDENTIFIER
						{
							Symbol *Sym = lookupSymbol($1);
							if (Sym == nullptr)
							{
								printf("Undefined variable %s\n", $1);
								YYERROR;
							}

							$$ = new VariableAst(Sym);
						}
				;

%%

int yyerror(const char *error)
{
	printf("line %d: %s\n", CurrentLine, error);
	ErrorCount = 1;
	return 0;
}

int parse(Module *TheModule)
{
	CurrentLine = 1;
	Builder = new SPMDBuilder(TheModule);
	if (yyparse())
		return 0;

	delete Builder;
	return 1;
}

Symbol *lookupSymbol(const char *name)
{
	for (vector<Scope>::reverse_iterator I = ScopeStack.rbegin(); I != ScopeStack.rend(); 
		I++)
	{
		Scope::iterator J = (*I).find(name);
		if (J != (*I).end())
			return (*J).second;
	}

	return nullptr;
}