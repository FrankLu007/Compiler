%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}
%token SEMICOLON
%token INT INT_V
%token WHILE
%token DO
%token IF
%token TRUE
%token FALSE
%token FOR
%token PRINT
%token CONST
%token READ
%token BOOL
%token VOID
%token FLOAT FLOAT_V
%token DOUBLE
%token STRING
%token CONTINUE
%token BREAK
%token RETURN
%token ID
%token STRING STRING_V
%right '=' '!'
%left OR AND EQUAL NOTEQUAL GREATEREQUAL LESSEQUAL EQUAL '>' '<'
%left '+' '-' '*' '/' '%'
%nonassoc ELSE
%%

program : declaration funct_def def_and_decl
        ;
def_and_decl : def_and_decl funct_decl
             | def_and_decl const_decl
             | def_and_decl var_decl
             | def_and_decl funct_def
             |
             ;
declaration : declaration const_decl
            | declaration var_decl
            | declaration funct_decl
            |
            ;
const_decl : CONST type const SEMICOLON ;
const : const ',' ID '=' value
      | ID '=' value
      ;
var_decl : type ids SEMICOLON ;
funct_decl : type ID '(' args ')' SEMICOLON
           | void_decl
           ;
void_decl : VOID ID '(' args ')' SEMICOLON
          ;
funct_def : type ID '(' args ')' MOVS
          | void_def
          ;
void_def : VOID ID '(' args ')' MOVS
         ;
type : INT | DOUBLE | FLOAT | STRING | BOOL ;
var : ID
    | ID array
    ;
id_v : ID '=' ex
     | ID array '=' '{' express '}'
     ;
ids : ids ',' var
    | ids ',' id_v
    | var
    | id_v
    ;
args: _args | ;
_args: _args ',' type var
     | type var
     ;
MOVS : '{' _MOVS '}';
_MOVS : _MOVS const_decl
      | _MOVS var_decl
      | _MOVS state
      |
      ;
express : _express 
        | 
        ;
_express : _express ',' ex
         | ex
         ;
ex : ex AND ex
   | ex OR ex
   | '!' ex
   | ex '>' ex
   | ex '<' ex
   | ex EQUAL ex
   | ex GREATEREQUAL ex
   | ex NOTEQUAL ex
   | ex LESSEQUAL ex
   | ex '+' ex
   | ex '-' ex
   | ex '*' ex
   | ex '/' ex
   | ex '%' ex
   | '-' ex %prec '*'
   | '(' ex ')' %prec '*'
   | value
   | var
   | funct_call
   ;
funct_call : ID '(' express ')'
           ;
value : INT_V
      | FLOAT_V
      | STRING_V
      | TRUE
      | FALSE
      ;
array : array '[' INT_V ']' | '[' INT_V ']';
state : MOVS
      | a_mov
      | cond
      | while
      | for
      | control
      ;
a_mov : ID array '=' ex SEMICOLON
      | ID '=' ex SEMICOLON
      | PRINT ex SEMICOLON
      | READ ex SEMICOLON
      | ex SEMICOLON
      ;
cond : IF '(' ex ')' MOVS ELSE MOVS
     | IF '(' ex ')' MOVS
     ;
while : WHILE '(' ex ')' MOVS
      | DO MOVS WHILE '(' ex ')' SEMICOLON
      ;
for : FOR '(' ex_for SEMICOLON ex_for SEMICOLON ex_for ')';
ex_for : ID '=' ex | ex ;
control : RETURN ex SEMICOLON
        | BREAK SEMICOLON
        | CONTINUE SEMICOLON
        ;

%%
int yyerror(char *msg)
{
  fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
        fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
        fprintf( stderr, "|\n" );
        fprintf( stderr, "| Unmatched token: %s\n", yytext );
  fprintf( stderr, "|--------------------------------------------------------------------------\n" );
  exit(-1);
}

int  main( int argc, char **argv )
{
        if( argc != 2 ) {
                fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
                exit(0);
        }

        FILE *fp = fopen( argv[1], "r" );

        if( fp == NULL )  {
                fprintf( stdout, "Open  file  error\n" );
                exit(-1);
        }

        yyin = fp;
        yyparse();

        fprintf( stdout, "\n" );
        fprintf( stdout, "|--------------------------------|\n" );
        fprintf( stdout, "|  There is no syntactic error!  |\n" );
        fprintf( stdout, "|--------------------------------|\n" );
        exit(0);
}