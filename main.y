%{
	/* C Declarations */
	#include<stdio.h>
	#include<stdlib.h>
	#include<math.h>
	#include<string.h>
	#define maxn 1000007
	char valname[1009][1009];
	int data[1009], switch_data[maxn+1];
	int idx = 1;
	int isDeclared(char *now) {
		for(int i=1; i<idx; i++) {
			if(strcmp(valname[i], now) == 0) {
				return i; 
			}
		}
		return 0;
	}
	int addNewVal(char *now){
		if(isDeclared(now)) return 0;
		strcpy(valname[idx], now);
		data[idx]=0;
		idx++;
	}
	int getVal(char *now) {
		return data[isDeclared(now)];
	}
	int setVal(char *now, int v) {
		int id = isDeclared(now);
		data[id] = v;
	}
%}

/* Bison Declarations */
%union{
	char text[1009];
	int val;
}
%token<val>NUMBER
%token<text>VAR
%token STARTPROGRAM IF PLUS MINUS MUL DIV MOD INCREMENT DECREMENT LTE GTE EQL NEQL NOT ELSE ELIF INT FLOAT CHAR CBS CBE LOOP WHILE EVENODD SHOW SIN COS TAN LOG FACTORIAL CASE DEFAULT SWITCH MIN MAX GCD LCM ISPRIME POW POWMOD MULMOD FUNCTION ARRAY ARRINT ARRFLOAT ARRCHAR CLASS
%type<val>statement
%type<val>function_statement
%type<val>expression
%nonassoc IF
%nonassoc ELIF
%nonassoc ELSE
%left PLUS MINUS
%left MUL DIV

/* Grammar Rules */

%%

program : STARTPROGRAM '(' ')' ':' CBS line CBE {printf("\nSuccesful Compilation\n");}
	;

line: 
	| line statement
	;

statement: ';'

	| declaration ';'	{  }

	| expression ';'	{$$ = $1;}
	
	| VAR '=' expression ';' { 
		printf("\nValue of the variable: %d\n",$3);
		setVal($1, $3); //data[$1]=$3;
		$$ = $3;
	} 

	| IF '(' expression ')' CBS statement CBE {
		if($3) {
			printf("\nvalue of expression in IF: %d\n",$6);
		}
		else{
			printf("\ncondition value zero in IF block\n");
		}
	}

	| IF '(' expression ')' CBS statement CBE ELSE CBS statement CBE  {
		if($3){
			printf("value of expression in IF: %d\n",$6);
		}
		else{
			printf("value of expression in ELSE: %d\n",$10);
		}
	}

	| IF '(' expression ')' CBS statement CBE ELIF '(' expression ')' CBS statement CBE ELSE CBS statement CBE {
		if($3) {
			printf("\nValue of expression in IF: %d\n", $6);
		}
		else if($10) {
			printf("\nValue of expression in ELIF: %d\n", $13);
		}
		else{
			printf("\nValue of expression in ELSE: %d\n", $17);
		}
	}

	| SWITCH '(' expression ')' CBS casenumber CBE {
		printf("\nSwitch Case Declared\n");
		if(switch_data[$3]) printf("\nChoosen case number is : %d and the value is: %d\n", $3, switch_data[$3]);
		else printf("\nChoosen case number is: Default and the value is: %d\n", $3, switch_data[$3]);
		memset(switch_data, 0, sizeof(switch_data));
	}

	| LOOP '(' expression '<' expression ')' CBS statement CBE {
	    for(int i=$3 ; i<$5 ; i++) {printf("\nCounter in the loop: %d\n", i);}	
	}

	| LOOP '(' expression LTE expression ')' CBS statement CBE {
	    for(int i=$3 ; i<=$5 ; i++) {printf("\nCounter in the loop: %d\n", i);}	
	}

	| LOOP '(' expression '>' expression ')' CBS statement CBE {
	    for(int i=$5 ; i<$3 ; i++) {printf("\nCounter in the loop: %d\n", i);}		
	}

	| LOOP '(' expression GTE expression ')' CBS statement CBE {
	    for(int i=$5 ; i<=$3 ; i++) {printf("\nCounter in the loop: %d\n", i);}		
	}

	| LOOP '(' expression ',' expression ',' expression ')' CBS statement CBE {
	    if($3 <= $5) {
	    	for(int i=$3 ; i<$5 ; i+=$7) {printf("\nCounter in the loop: %d\n", i);}	
	    }
	    else {
	    	for(int i=$3 ; i>$5 ; i-=$7) {printf("\nCounter in the loop: %d\n", i);}	
	    }
	}

	| SHOW '(' expression ')' ';' {
		printf("\nPrint Function: %d\n",$3);
	}

	| FUNCTION VAR '(' function_line ')' CBS function_line CBE {
		printf("\nFunction Declared\n");
	}

	| ARRAY ARRINT VAR '(' NUMBER ')' ';' {
		printf("\nInterger Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| ARRAY ARRFLOAT VAR '(' NUMBER ')' ';' {
		printf("\nFloating Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| ARRAY ARRCHAR VAR '(' NUMBER ')' ';' {
		printf("\nCharacter Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| CLASS VAR CBS statement CBE ';' {
		printf("\nClass Declared\n");
	}

	| FACTORIAL '(' NUMBER ')' ';' {
		int fact = 1;
		for(int i=1; i<=$3; i++) {
			fact *= i;
		}
		printf("\nFactorial of %d is: %d\n", $3, fact);
	}

	| EVENODD '(' NUMBER ')' ';' {
		if($3 % 2 == 0) {
			printf("Number : %d is Even\n",$3);
		}
		else {
			printf("Number is :%d is Odd\n",$3);
		}
	}

	| MIN '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		printf("\nMin of (%d, %d) is: ", n1, n2);
		if(n1 < n2) printf("%d\n", n1);
		else printf("%d\n", n2);
	}

	| MAX '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		printf("\nMax of (%d, %d) is: ", n1, n2);
		if(n1 > n2) printf("%d\n", n1);
		else printf("%d\n", n2);
	}

	| ISPRIME '(' NUMBER ')' ';' {
		int n1 = $3, fl = 1;
		for(int i=2; i<=n1/2; i++) {
			if(n1 % i == 0) {
				fl = 0;
				break;
			}
		}
		if(fl) printf("\n%d is a Prime number.\n", n1);
		else printf("\n%d is Not a prime number\n", n1);
	}

	| POW '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		int res = pow(n1, n2);
		printf("\n%d Power %d is: %d\n", n1, n2, res);
	}
	;


function_line: 
	| function_line function_statement
	;

function_statement: ';'

	| declaration ';'	{ }

	| expression ';'	{$$ = $1;}
	
	| VAR '=' expression ';' { 
		printf("\nValue of the variable: %d\n",$3);
		setVal($1, $3); //data[$1]=$3;
		$$ = $3;
	} 

	| IF '(' expression ')' CBS function_statement CBE {
		if($3) {
			printf("\nvalue of expression in IF: %d\n",$6);
		}
		else{
			printf("\ncondition value zero in IF block\n");
		}
	}

	| IF '(' expression ')' CBS function_statement CBE ELSE CBS function_statement CBE  {
		if($3){
			printf("value of expression in IF: %d\n",$6);
		}
		else{
			printf("value of expression in ELSE: %d\n",$10);
		}
	}

	| IF '(' expression ')' CBS function_statement CBE ELIF '(' expression ')' CBS function_statement CBE ELSE CBS function_statement CBE {
		if($3) {
			printf("\nValue of expression in IF: %d\n", $6);
		}
		else if($10) {
			printf("\nValue of expression in ELIF: %d\n", $13);
		}
		else{
			printf("\nValue of expression in ELSE: %d\n", $17);
		}
	}

	| SWITCH '(' expression ')' CBS casenumber CBE {
		printf("\nSwitch Case Declared\n");
		if(switch_data[$3]) printf("\nChoosen case number is : %d and the value is: %d\n", $3, switch_data[$3]);
		else printf("\nChoosen case number is: Default and the value is: %d\n", $3, switch_data[$3]);
		memset(switch_data, 0, sizeof(switch_data));
	}

	| LOOP '(' expression '<' expression ')' CBS function_statement CBE {
	    for(int i=$3 ; i<$5 ; i++) {printf("\nCounter in the loop: %d\n", i);}	
	}

	| LOOP '(' expression LTE expression ')' CBS function_statement CBE {
	    for(int i=$3 ; i<=$5 ; i++) {printf("\nCounter in the loop: %d\n", i);}
	}

	| LOOP '(' expression '>' expression ')' CBS function_statement CBE {
	    for(int i=$5 ; i<$3 ; i++) {printf("\nCounter in the loop: %d\n", i);}	
	}

	| LOOP '(' expression GTE expression ')' CBS function_statement CBE {
	    for(int i=$5 ; i<=$3 ; i++) {printf("\nCounter in the loop: %d\n", i);}
	}

	| LOOP '(' expression ',' expression ',' expression ')' CBS function_statement CBE {
	    if($3 <= $5) {
	    	for(int i=$3 ; i<$5 ; i+=$7) {printf("\nCounter in the loop: %d\n", i);}	
	    }
	    else {
	    	for(int i=$3 ; i>$5 ; i-=$7) {printf("\nCounter in the loop: %d\n", i);}	
	    }
	}

	| SHOW '(' expression ')' ';' {
		printf("\nPrint Function: %d\n",$3);
	}

	| ARRAY ARRINT VAR '(' NUMBER ')' ';' {
		printf("\nInterger Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| ARRAY ARRFLOAT VAR '(' NUMBER ')' ';' {
		printf("\nFloating Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| ARRAY ARRCHAR VAR '(' NUMBER ')' ';' {
		printf("\nCharacter Array Declared\n");
		printf("\nSize of the array is: %d\n", $5);
	}

	| FACTORIAL '(' NUMBER ')' ';' {
		int fact = 1;
		for(int i=1; i<=$3; i++) {
			fact *= i;
		}
		printf("\nFactorial of %d is: %d\n", $3, fact);
	}

	| EVENODD '(' NUMBER ')' ';' {
		if($3 % 2 == 0) {
			printf("Number : %d is Even\n",$3);
		}
		else {
			printf("Number is :%d is Odd\n",$3);
		}
	}

	| MIN '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		printf("\nMin of (%d, %d) is: ", n1, n2);
		if(n1 < n2) printf("%d\n", n1);
		else printf("%d\n", n2);
	}

	| MAX '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		printf("\nMax of (%d, %d) is: ", n1, n2);
		if(n1 > n2) printf("%d\n", n1);
		else printf("%d\n", n2);
	}

	| ISPRIME '(' NUMBER ')' ';' {
		int n1 = $3, fl = 1;
		for(int i=2; i<=n1/2; i++) {
			if(n1 % i == 0) {
				fl = 0;
				break;
			}
		}
		if(fl) printf("\n%d is a Prime number.\n", n1);
		else printf("\n%d is Not a prime number\n", n1);
	}

	| POW '(' NUMBER ',' NUMBER ')' ';' {
		int n1 = $3;
		int n2 = $5;
		int res = pow(n1, n2);
		printf("\n%d Power %d is: %d\n", n1, n2, res);
	}

	;


declaration: datatype ID   {printf("\nVariable Declared\n");}
     ;


datatype : INT 	{printf("\nInterger Declaration\n");}
     | FLOAT  		{printf("\nFloat Declaration\n");}
     | CHAR   		{printf("\nCharacter Declaration\n");}
     ;



ID : ID ',' VAR {
	int res = addNewVal($3);
		if(res == 0){
			printf("\nVariable already declared\n");
			exit(-1);
		}
	}

     | VAR {
		int res = addNewVal($1);
		if(res == 0){
			printf("\nVariable already declared\n");
			exit(-1);
		}
	}  
     ;

casenumber: caserule
 	| caserule defaultnum
 	;

caserule:
 	| caserule casenum
 	;

casenum: CASE NUMBER ':' expression ';' {
		printf("\nExpression value is %d of Case %d\n", $4, $2);
		switch_data[$2] = $4;
	}
 	;

defaultnum: DEFAULT ':' expression ';' {
		printf("\nExpression value is %d of Default case\n", $3);
		switch_data[maxn] = $3;
	}
 	;

expression: NUMBER 				{$$ = $1;}

	| VAR 					{$$ = getVal($1);}
	
	| expression PLUS expression	{$$ = $1 + $3;}

	| expression MINUS expression	{$$ = $1 - $3;}

	| expression MUL expression	{$$ = $1 * $3;}

	| expression '^' expression	{$$ = $1 ^ $3;}

	| expression '<' expression	{$$ = $1 < $3;}
	
	| expression '>' expression	{$$ = $1 > $3;}

	| expression LTE expression	{$$ = $1 <= $3;}
	
	| expression GTE expression	{$$ = $1 >= $3;}

	| expression EQL expression	{$$ = $1 == $3;}

	| expression NEQL expression	{$$ = $1 != $3;}

	| expression INCREMENT		{$$ = $1 + 1;}

	| expression DECREMENT		{$$ = $1 - 1;}

	| NOT expression			{$$ = !$2;}

	| '(' expression ')'		{$$ = $2;}

	| expression DIV expression {
		if($3) {$$ = $1 / $3;}
		else {$$ = 0; printf("\nDivision by Zero\n");} 	
	}

	| expression MOD expression { 
		if($3) {$$ = $1 % $3;}
		else {$$ = 0; printf("\nMod by Zero\n");} 	
	}

	;

%%

/* Additional C Codes */
int yyerror(char *s){
	printf( "%s\n", s);
}

int yywrap()
{
	return 1;
}

int main()
{
	freopen("input.txt", "r", stdin);
	//freopen("output.txt" ,"w", stdout);

	yyparse();

	return 0;
}