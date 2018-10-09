%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<\"%s\">\n", t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
int status_pragrma = 0;
int idn = 0;
int idnum[MAX_LINE_LENGTH];
char *idname[MAX_LINE_LENGTH];
char *str;
char buf[MAX_LINE_LENGTH];
%}

KW ("while"|"do"|"if"|"else"|"true"|"false"|"for"|"int"|"print"|"const"|"read"|"boolean"|"bool"|"void"|"float"|"double"|"string"|"continue"|"break"|"return")
digit [0-9]
delimiter ("("|")"|"["|"]"|"{"|"}"|";"|",")
letter [a-zA-Z]
token ("+"|"-"|"*"|"/"|"%"|"="|"<="|"<"|"=="|">"|">="|"&&"|"||"|"!")
pragma ("#pragma")
integer (0|[1-9]{digit}*)
float ({digit}+\.{digit}+)
scientific (({float}|{digit}+)("E"|"e")("+"|"-"|""){digit}+)
id ((_|{letter})(_|{letter}|{digit})*)

%START pragma comment string
%%

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
<comment>"*/" {
	LIST;
	if(status_pragrma) BEGIN pragma;
	else BEGIN INITIAL;
}
<comment>. LIST;
<string>\" {
	tokenString("string", str);
	free(str);
	BEGIN INITIAL;
}
<string>\\{letter} {
	LIST;
	strcat(str, yytext);
}
<string>\\. {
	LIST;
	strcat(str, yytext+1);
}
<string>. {
	LIST;
	strcat(str, yytext);
}
[ \t]+ LIST;
"//".* LIST;
<INITIAL>\" {
	LIST;
	str = (char*)malloc(sizeof(char)*MAX_LINE_LENGTH);
	for(int i = 0 ; i < MAX_LINE_LENGTH ; i++) str[i] = 0;
	BEGIN string;
}
<INITIAL>{token} {
	token(yytext);
}
"/*" {
    LIST;
    BEGIN comment;
}
<INITIAL>{pragma} {
	LIST;
	status_pragrma = 1;
	BEGIN pragma;
}
<INITIAL>{delimiter} {
	tokenString("delim", yytext);
}
<INITIAL>{float} {
	tokenString("float", yytext);
}
<INITIAL>{integer} {
	tokenString("integer", yytext);
}

<INITIAL>{KW} {
    tokenString("KW", yytext);
}
\n {
    LIST;
    
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
    if(status_pragrma)
    {
    	status_pragrma = 0;
    	BEGIN INITIAL;
    }
}
<INITIAL>{id} {
	tokenString("id", yytext);
	int find = 1;
	for(int i = 0 ; i < idn ; i++) 
	{
		if(!strcmp(idname[i], yytext))
		{
			find = 0;
			idnum[i]++;
			break;
		}
	}
	if(find)
	{
		idnum[idn] = 1;
		idname[idn] = malloc(sizeof(yytext));
		for(int i = 0 ; i < sizeof(yytext) ; i++) idname[idn][i] = 0;
		strcat(idname[idn++], yytext);
	}
}
<INITIAL>{scientific} {
	tokenString("scientific", yytext);
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
        for(int i = 0 ; i < idn ; i++) printf("%s %d\n", idname[i], idnum[i]);
    }

    exit(0);
}