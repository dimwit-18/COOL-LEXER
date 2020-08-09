
lexer grammar CoolLexer;

tokens{
	ERROR,
	TYPEID,
	OBJECTID,
	BOOL_CONST,
	INT_CONST,
	STR_CONST,
	LPAREN,
	RPAREN,
	COLON,
	ATSYM,
	SEMICOLON,
	COMMA,
	PLUS,
	MINUS,
	STAR,
	SLASH,
	TILDE,
	LT,
	EQUALS,
	LBRACE,
	RBRACE,
	DOT,
	DARROW,
	LE,
	ASSIGN,
	CLASS,
	ELSE,
	FI,
	IF,
	IN,
	INHERITS,
	LET,
	LOOP,
	POOL,
	THEN,
	WHILE,
	CASE,
	ESAC,
	OF,
	NEW,
	ISVOID,
	NOT
}

/*
  DO NOT EDIT CODE ABOVE THIS LINE
*/

@members{

	/*
		YOU CAN ADD YOUR MEMBER VARIABLES AND METHODS HERE
	*/

	/**
	* Function to report errors.
	* Use this function whenever your lexer encounters any erroneous input
	* DO NOT EDIT THIS FUNCTION
	*/
	public void reportError(String errorString){
		setText(errorString);
		setType(ERROR);
	}

    /**
    * Function to process string and input within unclosed double quotes (")
    */
	public void processString(){
		Token t = _factory.create(_tokenFactorySourcePair, _type, _text, _channel, _tokenStartCharIndex, getCharIndex()-1, _tokenStartLine, _tokenStartCharPositionInLine);
		String text = t.getText();	
		//write your code to test strings here
		
        StringBuilder str = new StringBuilder(0);
		int len = text.length();
		int len_count = 0;

		/* boolean flags each for one kind of error */
        boolean nullflag = false;
		boolean esc_nullflag = false;
        boolean unescaped = false;
		boolean eof = false;
		boolean toolong = false;
		boolean backslash = false;

		/* check for eof, unescaped, backslash errors but don't report yet */
		if ((text.charAt(len - 1) != '\"' && text.charAt(len - 1) != '\n' && text.charAt(len - 1) != '\\') || len == 1)
			eof = true;
		else if (text.charAt(len - 1) == '\n') 
			unescaped = true;

		/* assume the last backslash is unescaped */
		else if (text.charAt(len - 1) == '\\')
			backslash = true;

		/* process special escaped characters, and make semantically equivalent string */
		for (int i = 1; i < len - 1; ) {
			if (text.charAt(i) == '\\') {
				if (i + 1 < len && text.charAt(i+1) == 'n')
					str.append('\n');
				else if (i + 1 < len && text.charAt(i+1) == 't')
					str.append('\t');
				else if (i + 1 < len && text.charAt(i+1) == 'f')
					str.append('\f');
				else if (i + 1 < len && text.charAt(i+1) == 'b')
					str.append('\b');
				else if (i + 1 < len && text.charAt(i+1) == '\"'){
					str.append('\"');
					if (i == len - 2) {
						eof = true;
					}
				}
				else if (i + 1 < len && text.charAt(i+1) == '\\'){
					str.append('\\');
					/* last backslash is not unescaped */
					if (i == len - 2) {
						eof = true;
						backslash = false;
					}
				}
                else if (i + 1 < len && text.charAt(i+1) == '\n'){
                    str.append('\n');
					if (i == len - 2) {
						eof = true;
						unescaped = false;
					}
				}
				else if (i + 1 < len && text.charAt(i+1) == '\u0000' && nullflag == false){
					esc_nullflag = true;
					break;
				}
				else if (i + 1 < len)
					str.append(text.charAt(i+1));
				i += 2;
			}
			else if (text.charAt(i) == '\u0000' && esc_nullflag == false){
				nullflag = true;
				break;
			}
			else {
				str.append(text.charAt(i));
				i++;
			}
			len_count += 1;
			if (len_count > 1024)
				toolong = true;
			if (len_count > 1025) 
				break;
		}

		/* reporting errors according to the preference */
		if (nullflag) {
            reportError("String contains null character.");
            return;
        }
		if (esc_nullflag) {
			reportError("String contains escaped null character.");
			return;
		}
		if (backslash && len_count < 1026) {
			reportError("backslash at end of file");
			return;
		}
		if (unescaped && len_count < 1026)  {
            reportError("Unterminated string constant");
            return;
        }
		if (toolong) {
			reportError("String constant too long");
			return;
		}
		if (eof) {
			reportError("EOF in string constant");
			return;
		}

		String fstr = str.toString();
		setText(fstr);
		return;
	}

    /**
    * Function to report ERROR for invalid characters 
    */
    public void unsupported_chars(){
        Token t = _factory.create(_tokenFactorySourcePair, _type, _text, _channel, _tokenStartCharIndex, getCharIndex()-1, _tokenStartLine, _tokenStartCharPositionInLine);
		String text = t.getText(); 
        reportError(text);
    }
}

/*
	WRITE ALL LEXER RULES BELOW
*/

/*
    PROTECTED RULES
*/
fragment LOWER_CASE : [a-z];
fragment UPPER_CASE : [A-Z];
fragment LETTER     : LOWER_CASE | UPPER_CASE;
fragment DIGIT      : [0-9];
fragment TRUE       : ('t')('r'|'R')('u'|'U')('e'|'E');
fragment FALSE      : ('f')('a'|'A')('l'|'L')('s'|'S')('e'|'E');
/* body of the string */
fragment STR_BODY   : (~([\n"]|'\\') | '\\'(.)); 

/*
    COMMENTS AND WHITESPACES
*/
WHITESPACE          :  ('\n'|'\t'|'\r'|'\f'|'\u000b'|' ')+-> skip; 
SINGLE_LINE_COMMENT :  (('--')(~'\n')*?('\n') | ('--')(~'\n')*?(EOF) )-> skip;
EOF_COMMENT         :  ('(*')(EOF) { reportError("EOF in comment"); };
START_MULTI_COMMENT :  ('(*') -> skip, pushMode(MULTI_COMMENT);
END_MULTI_COMMENT   :  '*)' { reportError("Unmatched *)"); };

/* 
   OPERATORS, BRACES AND PARANTHESIS
*/
LBRACE    : '{';
RBRACE    : '}';
LPAREN    : '(';
RPAREN    : ')';
COMMA     : ',';
DOT       : '.';
COLON     : ':';
SEMICOLON : ';';
ASSIGN    : '<-';
PLUS      : '+';
MINUS     : '-';
STAR      : '*';
SLASH     : '/';
EQUALS    : '=';
LT        : '<';
LE        : '<=';
DARROW    : '=>';
ATSYM     : '@';
TILDE     : '~';

/* 
    RESERVED WORDS
*/
CLASS    : ('c'|'C')('l'|'L')('a'|'A')('s'|'S')('s'|'S');
INHERITS : ('i'|'I')('n'|'N')('h'|'H')('e'|'E')('r'|'R')('i'|'I')('t'|'T')('s'|'S');
NEW      : ('n'|'N')('e'|'E')('w'|'W');
ISVOID   : ('i'|'I')('s'|'S')('v'|'V')('o'|'O')('i'|'I')('d'|'D');
NOT      : ('n'|'N')('o'|'O')('t'|'T');
LET      : ('l'|'L')('e'|'E')('t'|'T');
IN       : ('i'|'I')('n'|'N');
OF       : ('o'|'O')('f'|'F');
IF       : ('i'|'I')('f'|'F');
THEN     : ('t'|'T')('h'|'H')('e'|'E')('n'|'N');
ELSE     : ('e'|'E')('l'|'L')('s'|'S')('e'|'E');
FI       : ('f'|'F')('i'|'I');
CASE     : ('c'|'C')('a'|'A')('s'|'S')('e'|'E');
ESAC     : ('e'|'E')('s'|'S')('a'|'A')('c'|'C');
WHILE    : ('w'|'W')('h'|'H')('i'|'I')('l'|'L')('e'|'E');
LOOP     : ('l'|'L')('o'|'O')('o'|'O')('p'|'P');
POOL     : ('p'|'P')('o'|'O')('o'|'O')('l'|'L');

/* 
    IDENTIFIERS, CONSTANTS, INVALID STRINGS AND TOKENS
*/
BOOL_CONST        : TRUE | FALSE ;
INT_CONST         : DIGIT+;

/* always recognize backslash in pairs. i.e \ and it's next char except in case it is the final char */
STR_CONST         : ('"')(STR_BODY)*?(('"')|('\n')|(('\\')?(EOF))) {processString();}; 
TYPEID            : (UPPER_CASE)(LETTER|DIGIT|'_')*;
OBJECTID          : (LOWER_CASE)(LETTER|DIGIT|'_')*;
ERROR             : (.) { unsupported_chars(); };

/* 
    MULTI-COMMENT MODE FOR MULTIPLE LINE COMMENTS
*/
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
