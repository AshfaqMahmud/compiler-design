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

"iniating program"	{printf("\nProgram main function started\n"); return STARTPROGRAM;}
"begin-"			{printf(" starting block ");}
"-end"				{printf(" ending block ");}
" add "				{printf(" addition operator ");}
"+add"				{printf(" increment ");}
" sub "      		{printf(" subtracgtion operator ");}
"-sub"				{printf(" decrement ");}
" mul "				{printf(" multiplication operator ");}
" div "   			{printf(" division operator ");}
" mod "    			{printf(" modulo operator ");}
" lte "				{printf(" less than equal?? ");}
" gte "				{printf(" greater than equal?? ");}
" isEqual "			{printf(" is equal?? ");}
" isNot "			{printf(" Not operator ");}
"case"				{printf(" case ");}
"switch"			{printf(" switch operator ");}
"default"			{printf(" default case ");}
"show"				{printf(" show output ");} 
"when"				{printf(" conditional operator ");}
"eor"				{printf(" else ");}
"or"				{printf(" else if ");}
"till"				{printf(" while loop ");}
"fact"				{printf(" calculate factorial ");}
"integer"  			{printf(" an integer var ");}
"ch" 				{printf(" an char var ");}
"float"				{printf(" an float var ");}
"array"				{printf(" an array ");}
"<integer>"			{printf(" an integer array ");}
"<float>"			{printf(" an float array ");}
"<ch>"				{printf(" an char array ");}
"exp" 				{printf(" power function ");}
"func"				{printf("\nFunction Declaration\n");}
{heading}			{printf("\nHeader file found: "); ECHO; printf("\n");}
{cmnt}				{printf("\nSingle line comment found: "); ECHO;printf("\n");}
{mul_cmnt}			{printf("\nMulti line comment found: "); ECHO;printf("\n");}
[<>=,():;^]			{return yytext[0];}
{digit}+			{yylval.val = atoi(yytext); printf("a number");}
{variable}			{strcpy(yylval.text, yytext); printf("a var");}
[ ]*	    		{printf(" white space ")}
[\n]*				{printf(" new line ")}
[\t]*				{printf(" tab space found ")}
.					{printf("\nnot matching with predefined syntax: %s\n", yytext);}

%%