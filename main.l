%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#include<math.h>
	#include "main.tab.h"

%}

variable		[a-zA-Z]*
digit			[0-9]
heading			"connect ".*
cmnt			[#].*
mul_cmnt 		"##"[^##]*"##"

%%

"initializing program :"	{printf("\nProgram main function started\n"); return STARTPROGRAM;}
"begin-"			{printf(" starting block \n"); return CBS;}
"-end"				{printf(" ending block \n"); return CBE;}
"="					{printf(" assigning value");}
"add"				{printf(" addition operator"); return PLUS;}
"++"				{printf(" increment"); return INCREMENT;}
"sub"      			{printf(" subtracgtion operator"); return MINUS;}
"--"				{printf(" decrement"); return DECREMENT;}
"mul"				{printf(" multiplication operator"); return MUL;}
"div"   			{printf(" division operator"); return DIV;}
"mod"    			{printf(" modulo operator"); return MOD;}
"lte"				{printf(" less than equal??"); return LTE;}
"gte"				{printf(" greater than equal??"); return GTE;}
"isEqual"			{printf(" is equal??"); return EQL;}
"isNotEqual"		{printf(" NotEqual operator"); return NEQL;}
"Not"				{printf(" Not operator"); return NOT;}
"case"				{printf(" case \n"); return CASE;}
"switch"			{printf(" switch operator \n"); return SWITCH;}
"default"			{printf(" default case"); return DEFAULT;}
"show :"			{printf(" show output"); return SHOW;} 
"when"				{printf(" conditional operator \n"); return IF;}
"or"				{printf(" else\n"); return ELSE;}
"eor"				{printf(" else if \n"); return ELIF;}
"loop"				{return LOOP;}
"till"				{printf(" while loop \n"); return WHILE;}
"fact"				{printf(" calculate factorial"); return FACTORIAL;}
"evenodd"			{return EVENODD;}
"int"  				{printf(" an integer var"); return INT;}
"ch" 				{printf(" an char var"); return CHAR;}
"float"				{printf(" an float var"); return FLOAT;}
"array"				{printf(" an array"); return ARRAY;}
"<int>"				{printf(" an integer array"); return ARRINT;}
"<float>"			{printf(" an float array"); return ARRFLOAT;}
"<ch>"				{printf(" an char array"); return ARRCHAR;}
"min" 				{return MIN;}
"max" 				{return MAX;}
"isprime"			{return ISPRIME;}
"exp" 				{printf(" power function"); return POW;}
"func"				{printf("\nFunction Declaration\n"); return FUNCTION;}
{heading}			{printf("\nHeader file found: "); ECHO; printf("\n");}
{cmnt}				{printf("\nSingle line comment found: "); ECHO;printf("\n");}
{mul_cmnt}			{printf("\nMulti line comment found: "); ECHO;printf("\n");}
[<>=,():;^]			{return yytext[0];}
{digit}+			{int n = atoi(yytext); printf("a number %d",n); return NUMBER;}
{variable}			{printf("%s",yytext); strcpy(yylval.text, yytext); return VAR;}
[ ]*	    		{}
[\n]*				{}
[\t]*				{}
.					{printf("\nUnknown syntax: %s\n", yytext);}

%%