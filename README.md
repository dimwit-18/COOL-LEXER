# COOL-LEXER
Lexical Analyser using ANTLR for Cool programming language (A language made for making study of compilers easy)

                                          # COOL Compiler #

-------------------------------- 
                                           LEXICAL ANALYSIS                                      
--------------------------------

## NOTE ## 

In case of errors in strings, the error message corresponding to the string is reported at the line where the string begins.

## Overall Structure ##

Cool.g4 file contains three main sections
1. Tokens
2. Members
3. Rules

The Tokens part includes the tokens (along with their return values) that are to be generated during the lexical analysis. The tokens for Cool programming language are those given to us in the skeleton code and are not altered.

Members contain publicly available functions that can be called to perform an action when an input matches a certain rule. Two functions are already declared in the skeleton code.
1. errorReport() to report errors (if any) to the parser and one to process a string. This function is not edited as per the instructions.
2. processString() to process strings.
In addition to these I declared another function:
3. unsupported_chars() to process a invalid character(a character that doesn't match any of the rules) as an error string containing the character should be returned and a simple call to errorReport() function wouldn't be suffice.

The lexer grammar is composed of lexer rules, optionally broken into multiple mode. These lexical modes allow us to split a single lexer grammar into multiple sublexers. 
I have here used two modes :
1. default mode 
2. MULTI_COMMENT mode
Lexer rules specify token definitions or rules that can aid in recognizing tokens. All rules should be in uppercase. There are many helper rules I used here that I am gonna explain in following subheadings. Rules that aid tokens are generally hidden with the help of keyword fragment or protected. Also note that these fragment rules cannot call upon an action. It is useful to note that ANTLR first checks for the rule that matches the longest input. If there are more than one rules matching the longest input, then the rule which is defined first is considered.

## Tokens ##

The tokens are already given with the skeleton code and are not modified.

## Members ##

### reportError() ###

Can be used to Report errors and passes them on to the parser. This function is not modified as per given instructions.

### processString() ###

This function first processes strings (both terminated and unterminated). The following pairs of consecutive characters in a string are semantically considered as a single character in Cool. This processing must be made.
1. \n
2. \t
3. \b
4. \f
5. \\\
6. \\"
7. escaped newline.
Note that '\' is an escape character in Java too. Hence, if we want to compare a character with '\' we have to use another \.
```java
Ex :   if (text.charAt(i) == '\\') 
		if (i + 1 < len && text.charAt(i+1) == 'n')
			str.append('\n');
```
If there are no errors then the string can safely be tokenized as STR_CONST. Except EOF in the string error which is taken care of in rules section, all other errors are processed here. We use boolean flags to detect these errors and we report them as per the compiler provided to us (which usually reports the error encountered first except for some edge cases).
Errors processed here are :
1. null/escaped null characters : checks if any character in string equals '\u0000' (UNICODE for null). Reported as error if there is a null character by calling reportError(). Same is the case with escaped null characters.
2. string constant too long : str.length()>1024 is not accepted. Reported as error  by calling reportError()
3. unterminated string : If there is any unescaped new line before closed double quotes (") is encountered.
4. EOF in string : if EOF is encountered by the with no closing double quote or unescaped enter.
5. backslash at end of file : checks if there is an unescaped backslash at end of file and then reports it as error

### unsupported_chars() ###

This function returns an errorstring containing the erroroneous character(token).

## Rules ##

### Designing rules for reserved words ###

A rule for reserved word is simply concatenation of all the letters it contains. Since reserved words are case insensitive, a letter of the reserved word can be either uppercase or lowercase.
```java
Ex :- IF : ('i'|'I')('f'|'F');
```

### Designing rules for operators, braces and paranthesis ###

A rule for this is simply the token with corresponding operator/brace/paranthesis enclose in single quotes.
```java
Ex : ASSIGN : '<-';
```

### Helper rules and whitespaces ###

Before proceeding forward we are also gonna define some helper rules that would be useful for us later. These helper rules include LOWER_CASE, UPPER_CASE, LETTER, DIGIT, TRUE, FALSE. What they mean is trivial from their names. 
Note that first letter in TRUE and FALSE are lowercase.
```java
Ex : fragment TRUE : ('t')('r'|'R')('u'|'U')('e'|'E');
```

WHITESPACE as per cool specifications include blank (ascii 32), \n (newline, ascii 10), \f (form feed, ascii 12), \r (carriage return, ascii 13), \t (tab, ascii 9), \v (vertical tab, ascii 11).Note that WHITESPACE does not aid in any token generation. It is simply used to skip whitespaces. Whenever a whitespace is encountered, skip command is triggered. 

STR_BODY fragment rule is discussed in strings.

### Designing rules for Identifiers ###

now we know that OBJECTID starts with a lowercase letter followed by a letter or digit or underscore. Similarlly TYPEID starts with an uppercase letter followed by a letter or digit or underscore. Constructing their rules is now simple.
```java
Ex : TYPEID : (UPPER_CASE)(LETTER|DIGIT|'_')*;
```

### Designing rules for constants ###

Any sequence of numbers (DIGIT+) is an INT_CONST. A BOOL_CONST is either TRUE or FALSE. 

### Strings: ###

Let's first define out our string body with the help of STR_BODY helper rule. We know that our string body can't contain unescaped newline, unescaped " and a single unmatched backslash. So our helper rule is : 
```java
fragment STR_BODY   : (~([\n"]|'\\') | '\\'(.)); 
```

__Valid__ : 

__NOTE__ : We never match an escape character alone unless we have no choice like in the case of unescaped backslash at the end of file. We always match escape character along with it's successor and the reason is that way the escape characters are correcly matched and we would have no errors.

When an ' " ' is encountered, the input can be matched with either STR_CONST or ERROR. For an input to match to this STR_CONST, it should end with an '"' and contain any character in between other than non-escaped newlines (in this case it classifies as an unterminated string and hence should not be matched to STR_CONST). The string then should be processed as if the typed input consists of consecutive characters such as '\' and 'n', semantically it equals to only one character i.e. '\n'. Hence processString() function is called which takes care of this issue. Also this function checks for any null characters (which are not supported) and if the string constant is too long (cannot be greater than 1024).
Therefore rule for STR_CONST is:
```java
STR_CONST  : ('"') STR_BODY*?('"') { processString(); };
```

__invalid__ :

__null character__ : When a string matches with STR_CONST, the string is processed by processString, where the string is also checked for any null character. If there is a null character/escaped null character, then reportError() function is called with argument "String contains null/escaped null character" and the lexing then resumes from
1. next line if the string also contains an unescaped newline
2. otherwise after the end of double quotes(")

__String size too long__ : Cool doesn't support string sizes greater than 1024 and hence they are reported as errors too. The lexical analysis then resumes from 
1. next line if the string also contains an unescaped newline
2. otherwise after the end of double quotes(")

__unterminated string__ : This obviously cannot be captured by 
STR_CONST. we use ERROR token to capture it. The rule is pretty simple. Any input starting with a double quote ('"'), terminating with an unescaped newline and containing any sequence of characters except unescaped '"' and an unescaped newline matches this rule. There upon the same processString() function is called which checks for unescaped newline and if any, calls reportError() function with argument as "Unterminated string constant" and then lexing resumes from the next line.
Therefore, rule for this is :
```java
ERROR : ('"')STR_BODY*?('\n') { processString(); };
```

__EOF in string__ : the rule for this is similar to the above rule except that in this case we also catch an unescaped backslash if any.
Therefore, rule for this is :
```java
ERROR : ('"')STR_BODY*?('\\')?(EOF)  { processString(); };
```
We can combine all the above rules for string to make a single rule for capturing all strings :
```java
STR_CONST         : ('"')(STR_BODY)*?(('"')|('\n')|(('\\')?(EOF))) { processString(); };
```
### Designing rules for comments ###

A single line comment is simply -- followed by any character and ends with either a newline or an EOF. Therefore the rule is :
```java
SINGLE_LINE_COMMENT : (('--')(~'\n')*?('\n') | ('--')(~'\n')*?(EOF) )-> skip ;
```

For a multi-line comment, note that we also have to check if the comments are nested properly. This can be done with the help of stack or creating another sublexer by defining another mode (just like functions). Whenever '(\*' is encountered, we use pushmode to change the grammar to our newly defined MULTI_COMMENT mode. Now if another '(\*' is encountered, then we use push into another mode MULTI_LINE_COMMENT1. This is done so as to handle the cases of (\*(\*....\*)(EOF) which should give EOF in comment.

Therefore mode and rules for multiline comments are :
```java
EOF_COMMENT         :  ('(*')(EOF) { reportError("EOF in comment"); };
START_MULTI_COMMENT :  ('(*') -> skip, pushMode(MULTI_COMMENT);
END_MULTI_COMMENT   : '*)' { reportError("Unmatched *)"); } ;

mode MULTI_COMMENT;
NESTED_EOF_COM : '(*'(EOF) { reportError("EOF in comment"); };
NESTED_COMMENT : '(*' -> skip, pushMode(MULTI_COMMENT1);
END_COMMENT    : '*)' -> skip, popMode;
TEXT           : (.) -> skip;
ERR            : (.)(EOF) { reportError("EOF in comment"); };

mode MULTI_COMMENT1;
NESTED_EOF_COM1 : '(*'(EOF) { reportError("EOF in comment"); };
NESTED_COMMENT1 : '(*' -> skip, pushMode(MULTI_COMMENT1);
END_COMMENT_EOF : '*)'(EOF) { reportError("EOF in comment"); };
END_COMMENT1    : '*)' -> skip, popMode;
TEXT1           : (.) -> skip;
ERR1 			: (.)(EOF) { reportError("EOF in comment"); };
```
### NOTE1 : (.)\*? is used which is non-greedy unlike (.)\* which is greedy and might match maximum input to a token at once.

## Testing ##

The generated lexer has been tested with wide variety of test cases along with the all kinds of error handling cases. All the errors have been thoroughly checked with the cool compiler provided to us.
