%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#include<math.h>

%}

variable		[a-z]+
digit			[0-9]
heading			"connect ".*
cmnt			[;].*
mul_cmnt 		"(*"[^*)]*"*)"

%%

"initializing program :"	{printf("\nProgram main function started\n");}
"begin-"			{printf(" starting block \n");}
"-end"				{printf(" ending block \n");}
"="					{printf(" assigning value");}
" add "				{printf(" addition operator");}
"+add"				{printf(" increment");}
" sub "      		{printf(" subtracgtion operator");}
"-sub"				{printf(" decrement");}
" mul "				{printf(" multiplication operator");}
" div "   			{printf(" division operator");}
" mod "    			{printf(" modulo operator");}
" lte "				{printf(" less than equal??");}
" gte "				{printf(" greater than equal??");}
" isEqual "			{printf(" is equal??");}
" isNot "			{printf(" Not operator");}
"case"				{printf(" case \n");}
"switch"			{printf(" switch operator \n");}
"default"			{printf(" default case");}
"show :"			{printf(" show output");} 
"when"				{printf(" conditional operator \n");}
"eor"				{printf(" else if \n");}
"or"				{printf(" else\n");}
"till"				{printf(" while loop \n");}
"fact"				{printf(" calculate factorial");}
"integer"  			{printf(" an integer var");}
"ch" 				{printf(" an char var");}
"float"				{printf(" an float var");}
"array"				{printf(" an array");}
"<integer>"			{printf(" an integer array");}
"<float>"			{printf(" an float array");}
"<ch>"				{printf(" an char array");}
"exp" 				{printf(" power function");}
"func"				{printf("\nFunction Declaration\n");}
{heading}			{printf("\nHeader file found: "); ECHO; printf("\n");}
{cmnt}				{printf("\nSingle line comment found: "); ECHO;printf("\n");}
{mul_cmnt}			{printf("\nMulti line comment found: "); ECHO;printf("\n");}
{digit}+			{int n = atoi(yytext); printf("a number %d",n);}
{variable}			{printf("%s",yytext);}
[ ]*	    		{printf(" -space- ");}
[\n]*				{printf(" newline \n");}
[\t]*				{printf(" -tab- ");}
[a-zA-Z] 			{printf("%s\n", yytext);}
.					{printf("\nnot matching with predefined syntax: %s\n", yytext);}

%%

int yywrap(){}
int main(){
   yyin = freopen("input.txt","r",stdin);
   yyout = freopen("output.txt","w",stdout);
   yylex();
}