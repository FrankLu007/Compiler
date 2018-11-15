%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}
%token SEMICOLON
%token INT
%token INT_V
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
%token FLOAT
%token FLOAT_V
%token DOUBLE
%token STRING
%token CONTINUE
%token BREAK
%token RETURN
%token ID
%token NUM
%token STRING
%token STRING_V
%right '=' '!'
%left OR AND EQUAL NOTEQUAL GREATEREQUAL LESSEQUAL EQUAL '>' '<'
%nonassoc ELSE
%%

program : declaration funct_defi decl_and_def_list;
decl_and_def_list : decl_and_def_list funct_decl
      | decl_and_def_list var_decl
      | decl_and_def_list const_decl
      | decl_and_def_list funct_defi
      |
      ;
declaration : declaration const_decl
                 | declaration var_decl
                 | declaration funct_decl
                 | 
                 ;
funct_defi : type ID '(' argument_list ')' MOVS | void_defi;
void_defi : VOID ID '(' argument_list ')' MOVS;
state : MOVS 
          | simple
          | cond
          | while
          | for
          | control
          ;
MOVS : '{' _MOVS '}';
simple : simple_content SEMICOLON;


simple_content : var '=' ex
               | PRINT ex
               | READ var
               | ex
               ;
cmp : '<' | '>' | EQUAL | NOTEQUAL | GREATEREQUAL | LESSEQUAL | EQUAL;
op : '+' | '-' | '*' | '/' | '%';
ex : ex OR ex
   | ex AND ex
   | '!' ex
   | ex cmp ex
   | ex op ex
   | '-' ex %prec '*'
   | '(' ex ')' %prec '*'
   | value
   | var
   | funct_call
   ;

funct_call : ID '(' express ')' ;

express : _express | ;

_express : _express ',' ex | ex ;

var : ID | array_reference ;

array_reference : ID arr_reference_square
                ;

arr_reference_square : arr_reference_square square_ex
                     | square_ex
                     ;
square_ex : '[' ex ']'
                  ;

cond : IF '(' ex ')' MOVS ELSE MOVS 
     | IF '(' ex ')' MOVS
     ;

while : WHILE '(' ex ')' MOVS
      | DO MOVS WHILE '(' ex ')' SEMICOLON
      ;

for : FOR '(' for_ex SEMICOLON for_ex SEMICOLON for_ex ')' MOVS ;

control : RETURN ex SEMICOLON
     | BREAK SEMICOLON
     | CONTINUE SEMICOLON
     ;

for_ex : ID '=' ex | ex ;

_MOVS : _MOVS const_decl
      | _MOVS var_decl
      | _MOVS state
      | 
      ;

const_decl : CONST type const_list SEMICOLON ;

const_list : const_list ',' const | const ;

const : ID '=' value
      ;

value : INT_LIT
      | STRING_LIT
      | FLOAT_LIT
      | SCIENTIFIC
      | TRUE
      | FALSE
      ;

var_decl : type identifier_list SEMICOLON ;

type : INT
     | DOUBLE
     | FLOAT
     | STRING
     | BOOL
     ; 

identifier_list : identifier_list ',' identifier
                | identifier
                ;

identifier : identifier_no_initial
           | identifier_with_initial
           ;

identifier_no_initial : ID
                      | ID array
                      ;
identifier_with_initial : ID '=' ex
                        | ID array '=' initial_array
                        ;

initial_array : '{' express '}'
              ;

array : array '[' INT_LIT ']'
      | '[' INT_LIT ']'
      ;

funct_decl : type ID '(' argument_list ')' SEMICOLON | void_decl;

void_decl : VOID ID '(' argument_list ')' SEMICOLON;

argument_list : nonEmptyArgumentList
              |
              ;
nonEmptyArgumentList : nonEmptyArgumentList ',' argument
                     | argument
                     ;
argument : type identifier_no_initial;

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