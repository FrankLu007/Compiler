%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<%s>\n", t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
int status_pragrma = 0;
char *str = "";
char buf[MAX_LINE_LENGTH];
%}

KW ("while"|"do"|"if"|"else"|"true"|"false"|"for"|"int"|"print"|"const"|"read"|"boolean"|"bool"|"void"|"float"|"double"|"string"|"continue"|"break"|"return")
digit [0-9]
delimiter ("("|")"|"["|"]"|"{"|"}"|";"|",")
letter [a-zA-Z]
token ("+"|"-"|"*"|"/"|"%"|"="|"<="|"<"|"=="|">"|">="|"&&"|"||"|"!")
pragma (#pragma)
integer (0|[1-9]{digit}*)
float ({integer}\.{digit}+)
scientific (({float}|{double})[Ee]("+"|"-"){digit}+)
id (({letter}|_)(_|{letter}|{digit})*)

%START pragma comment string
%%

[ \t]+ {LIST;}
{pragma} {
	LIST;
	status_pragrma = 1;
	BEGIN pragma;
}
{delimiter} {
	tokenString("delim", yytext);
}
["//"].* {
    LIST;
}
{token} {
	token(yytext);
}
"/*" {
    LIST;
    BEGIN comment;
}
{float} {
	tokenString("float", yytext);
}
{integer} {
	tokenString("integer", yytext);
}

{KW} {
    tokenString("KW", yytext);
}

\" {
	LIST;
	BEGIN string;
}
\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}
{id} {
	tokenString("id", yytext);
}
. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}
<pragma>"source on" {
	LIST;
	Opt_Source = 1;
}
<pragma>"source off" {
	LIST;
	Opt_Source = 0;
}
<pragma>"token on" {
	LIST;
	Opt_Token = 1;
}
<pragma>"token off" {
	LIST;
	Opt_Token = 0;
}
<pragma>"statistic on" {
	LIST;
	Opt_Statistic = 1;
}
<pragma>"statistic off" {
	LIST;
	Opt_Statistic = 0;
}
<pragma>\n {
	LIST;
	status_pragrma = 0;
	if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
}
<pragma>"//" {
	yyless(2);
	BEGIN INITIAL;
}
<pragma>. {
	fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}
<comment>. LIST;
<comment>\n {
	LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}
<comment>"*/" {
	LIST;
	if(status_pragrma) BEGIN pragma;
	BEGIN INITIAL;
}
<string>\\\" {
	LIST;
	strcat(str, yytext);
}
<string>\" {
	tokenString("string", str);
	*str = "";
}
<string>. {
	LIST;
	strcat(str, yytext);
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