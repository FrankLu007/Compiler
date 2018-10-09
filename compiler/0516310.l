%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<%s>\n", #t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
int lpara = 0;
char buf[MAX_LINE_LENGTH];
%}

KW ["while"|"do"|"if"|"else"|"true"|"false"|"for"|"int"|"print"|"const"|"read"|"boolean"|"bool"|"void"|"float"|"double"|"string"|"continue"|"break"|"return"]
digit [0-9]
letter [a-zA-Z]
pragma ["#pragma"]

%%

" " {}
"//"|{pragma} {
    LIST;
    while((yytext = yymore()) != "\n") LIST;
    REJECT; 
}
"/*" {
    LIST;
    while((yytext = yymore()) != "*/")
    {
        LIST;
        if(Opt_Source && yytext == '\n')
        {
            printf("%d:%s\n", linenum, buf);
            ++linenum;
            buf[0] = '\0';
        }
    }
}
0|[1-9]{digit}+ {

}
"("  {
    tokenString("delim", "("); 
    lpara++;
}
")" {
    if(lpara)
    {
        tokenString("delim", ")");
        lpara--;
    }
    else 
    {
        fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
        exit(1);
    }
}

KW {
    tokenString("KW", yytext);
}

\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}

. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}

%%

int main( int argc, char **argv )
{
    if (argc >= 2)
    {
        yyin = fopen( argv[1], "r" );
        if ( NULL == yyin ) {
            fprintf( stderr, "Cannot open: %s\n", argv[1] );
            exit(-1);
        }
    }
    else
    {
        yyin = stdin;
    }
    yylex();

    if (Opt_Statistic)
    {
        // Print frequency table
    }

    exit(0);
}