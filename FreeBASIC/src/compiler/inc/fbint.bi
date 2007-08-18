#ifndef __FBINT_BI__
#define __FBINT_BI__

''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2007 The FreeBASIC development team.
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.

''
'' internal compiler definitions
''

#include once "inc\fb.bi"

const FB_MAXINTNAMELEN		= 1 + FB_MAXNAMELEN + 1 + 1 + 2
const FB_MAXINTLITLEN		= FB_MAXLITLEN + 32

const FB_MAXGOTBITEMS		= 64

''
const FB_INITSYMBOLNODES	= 8000
const FB_INITFIELDNODES		= 16
const FB_INITDEFARGNODES	= 500
const FB_INITDEFTOKNODES	= 1000
const FB_INITDIMNODES		= 400
const FB_INITLIBNODES		= 20
const FB_INITFWDREFNODES	= 500
const FB_INITVARININODES	= 1000
const FB_INITINCFILES		= 256
const FB_INITSTMTSTACKNODES	= 128

''
const FB_INTEGERSIZE		= 4
const FB_POINTERSIZE		= 4
const FB_LONGSIZE			= FB_POINTERSIZE

'' array descriptor
type FB_ARRAYDESC
    data			as any ptr
	ptr				as any ptr
    size			as integer
    element_len		as integer
    dimensions		as integer
end type

const FB_ARRAYDESCLEN		= len( FB_ARRAYDESC )

const FB_ARRAYDESC_DATAOFFS = offsetof( FB_ARRAYDESC, data )

type FB_ARRAYDESCDIM
	elements		as integer
	lbound			as integer
	ubound			as integer
end type

const FB_ARRAYDESC_DIMLEN	= len( FB_ARRAYDESCDIM )
const FB_ARRAYDESC_LBOUNDOFS= offsetof( FB_ARRAYDESCDIM, lbound )
const FB_ARRAYDESC_UBOUNDOFS= offsetof( FB_ARRAYDESCDIM, ubound )

'' string descriptor
type FB_STRDESC
	data			as zstring ptr
	len				as integer
	size			as integer
end type

const FB_STRDESCLEN			= len( FB_STRDESC )

'' DATA stmt internal format
enum FB_DATASTMT_ID
	FB_DATASTMT_ID_NULL		= &h0000
	FB_DATASTMT_ID_WSTR		= &h8000                '' start point
	FB_DATASTMT_ID_LINK		= &hffff
	FB_DATASTMT_ID_OFFSET	= &hfffe

	FB_DATASTMT_ID_ZSTR		= &h0001				'' used by AST only
	FB_DATASTMT_ID_CONST	= &h0002				'' /
end enum

type FB_DATADESC
	id				as short
	union
		zstr 		as zstring ptr
		wstr 		as wstring ptr
		sym			as any ptr
		next 		as FB_DATADESC ptr
	end union
end type

const FB_DATASTMT_PREFIX	= "_{fbdata}_"


'' print modes (same as in rtlib/fb.h)
enum FBPRINTMASK
	FB_PRINTMASK_NEWLINE	= &h00000001
	FB_PRINTMASK_PAD        = &h00000002
	FB_PRINTMASK_ISLAST		= &h80000000
end enum

'' file constants (same as in rtlib/fb.h)
enum FBFILEMODE
	FB_FILE_MODE_BINARY
	FB_FILE_MODE_RANDOM
	FB_FILE_MODE_INPUT
	FB_FILE_MODE_OUTPUT
	FB_FILE_MODE_APPEND
end enum

enum FBFILEACCESS
	FB_FILE_ACCESS_ANY
	FB_FILE_ACCESS_READ
	FB_FILE_ACCESS_WRITE
	FB_FILE_ACCESS_READWRITE
end enum

enum FBFILELOCK
	FB_FILE_LOCK_SHARED
	FB_FILE_LOCK_READ
	FB_FILE_LOCK_WRITE
	FB_FILE_LOCK_READWRITE
end enum

enum FBOPENKIND
    FB_FILE_TYPE_FILE
    FB_FILE_TYPE_CONS
    FB_FILE_TYPE_ERR
    FB_FILE_TYPE_PIPE
    FB_FILE_TYPE_SCRN
    FB_FILE_TYPE_LPT
    FB_FILE_TYPE_COM
    FB_FILE_TYPE_QB
end enum

''
const FB_MAINSCOPE = 0
const FB_MAINPROCNAME = "__FB_MAINPROC__"
const FB_MODLEVELNAME = "__FB_MODLEVELPROC__"
const FB_GLOBCTORNAME = "_GLOBAL__I"
const FB_GLOBDTORNAME = "_GLOBAL__D"

const FB_INSTANCEPTR = "THIS"

''
''
''

'' some chars
const CHAR_NULL   	= 00, _
      CHAR_BELL		= 07, _
      CHAR_BKSPC	= 08, _
      CHAR_TAB    	= 09, _
      CHAR_LF  	  	= 10, _
      CHAR_VTAB 	= 11, _
      CHAR_FORMFEED = 12, _
      CHAR_CR  	  	= 13, _
      CHAR_SPACE  	= 32, _
      CHAR_0   		= 48, _
      CHAR_1    	= 49, _
      CHAR_3    	= 51, _
      CHAR_7  		= 55, _
      CHAR_9   		= 57, _
      CHAR_AUPP    	= 65, _
      CHAR_ALOW  	= 97, _
      CHAR_BUPP    	= 66, _
      CHAR_BLOW    	= 98, _
      CHAR_DUPP    	= 68, _
      CHAR_DLOW  	= 100, _
      CHAR_EUPP    	= 69, _
      CHAR_ELOW    	= 101, _
      CHAR_FUPP    	= 70, _
      CHAR_FLOW    	= 102, _
      CHAR_HUPP    	= 72, _
      CHAR_HLOW    	= 104, _
      CHAR_LUPP    	= 76, _
      CHAR_LLOW  	= 108, _
      CHAR_OUPP    	= 79, _
      CHAR_OLOW    	= 111, _
      CHAR_UUPP    	= 85, _
      CHAR_ULOW  	= 117, _
      CHAR_ZUPP    	= 90, _
      CHAR_ZLOW  	= 122, _
	  CHAR_NLOW		= 110, _
	  CHAR_RLOW		= 114, _
	  CHAR_TLOW		= 116, _
      CHAR_LPRNT  	= 40, _
      CHAR_RPRNT  	= 41, _
      CHAR_COMMA 	= 44, _
      CHAR_DOT    	= 46, _
      CHAR_PLUS   	= 43, _
      CHAR_MINUS  	= 45, _
      CHAR_RSLASH  	= 92, _
      CHAR_CARET   	= 42, _
      CHAR_SLASH   	= 47, _
      CHAR_CART   	= 94, _
      CHAR_EQ     	= 61, _
      CHAR_LT     	= 60, _
      CHAR_GT     	= 62, _
      CHAR_AMP		= 38, _
      CHAR_UNDER	= 95, _
      CHAR_EXCL		= 33, _
      CHAR_SHARP	= 35, _
      CHAR_DOLAR	= 36, _
      CHAR_PERC		= 37, _
      CHAR_QUOTE	= 34, _
      CHAR_APOST	= 39, _
      CHAR_TIMES	= 42, _
      CHAR_STAR		= CHAR_TIMES, _
      CHAR_COLON	= 58, _
      CHAR_SEMICOLON= 59, _
      CHAR_AT		= 64, _
      CHAR_QUESTION	= 63, _
      CHAR_TILD		= 126, _
      CHAR_ESC		= 27, _
      CHAR_LBRACE	= 123, _
      CHAR_RBRACE	= 125, _
      CHAR_LBRACKET	= 91, _
      CHAR_RBRACKET	= 93


'' assuming it won't ever be used inside lit strings
const FB_INTSCAPECHAR		= CHAR_ESC


'' tokens
enum FB_TOKEN
	FB_TK_EOF					= 256
	FB_TK_EOL
	FB_TK_STMTSEP
	FB_TK_COMMENT
	FB_TK_REM

	FB_TK_NUMLIT
	FB_TK_STRLIT
	FB_TK_STRLIT_ESC
	FB_TK_STRLIT_NOESC
	FB_TK_ID

	FB_TK_IF
	FB_TK_THEN
	FB_TK_ELSE
	FB_TK_ELSEIF
	FB_TK_SELECT
	FB_TK_CASE
	FB_TK_IS
	FB_TK_WHILE
	FB_TK_UNTIL
	FB_TK_WEND
	FB_TK_CONTINUE
	FB_TK_EXIT
	FB_TK_DO
	FB_TK_LOOP
	FB_TK_WITH
	FB_TK_FOR
	FB_TK_STEP
	FB_TK_NEXT
	FB_TK_TO
	FB_TK_SCOPE
	FB_TK_NAMESPACE
	FB_TK_USING

	FB_TK_AND
	FB_TK_OR
	FB_TK_XOR
	FB_TK_EQV
	FB_TK_IMP
	FB_TK_NOT
	FB_TK_MOD
	FB_TK_SHL
	FB_TK_SHR
	FB_TK_EQ
	FB_TK_GT
	FB_TK_LT
	FB_TK_NE
	FB_TK_LE
	FB_TK_GE
	FB_TK_DBLEQ

	FB_TK_EXTERN
	FB_TK_STATIC
	FB_TK_DIM
	FB_TK_VAR
	FB_TK_REDIM
	FB_TK_COMMON
	FB_TK_SHARED
	FB_TK_PRESERVE

	FB_TK_ENDIF
	FB_TK_DEFINED

	FB_TK_INCLUDE
	FB_TK_DYNAMIC

	FB_TK_BASE
	FB_TK_EXPLICIT
	FB_TK_BYVAL
	FB_TK_BYREF

	FB_TK_DEFBYTE
	FB_TK_DEFUBYTE
	FB_TK_DEFSHORT
	FB_TK_DEFUSHORT
	FB_TK_DEFINT
	FB_TK_DEFUINT
	FB_TK_DEFLNG
	FB_TK_DEFULNG
	FB_TK_DEFLNGINT
	FB_TK_DEFULNGINT
	FB_TK_DEFSNG
	FB_TK_DEFDBL
	FB_TK_DEFSTR

	FB_TK_DECLARE
	FB_TK_CONST
	FB_TK_TYPE
	FB_TK_UNION
	FB_TK_ENUM
	FB_TK_CLASS
	FB_TK_END
	FB_TK_EXPORT
	FB_TK_IMPORT
	FB_TK_OPTION
	FB_TK_ASM
	FB_TK_SUB
	FB_TK_FUNCTION
	FB_TK_CONSTRUCTOR
	FB_TK_DESTRUCTOR
	FB_TK_OPERATOR
	FB_TK_PROPERTY

	FB_TK_BYTE
	FB_TK_UBYTE
	FB_TK_SHORT
	FB_TK_USHORT
	FB_TK_INTEGER
	FB_TK_UINT
	FB_TK_LONG
	FB_TK_ULONG
	FB_TK_LONGINT
	FB_TK_ULONGINT
	FB_TK_SINGLE
	FB_TK_DOUBLE
	FB_TK_STRING
	FB_TK_ZSTRING
	FB_TK_WSTRING
	FB_TK_ANY
	FB_TK_PTR
	FB_TK_POINTER
	FB_TK_UNSIGNED
	FB_TK_AS

	FB_TK_TYPEOF

	FB_TK_PUBLIC
	FB_TK_PRIVATE
	FB_TK_PROTECTED
	FB_TK_PASCAL
	FB_TK_CDECL
	FB_TK_STDCALL
	FB_TK_ALIAS
	FB_TK_LIB
	FB_TK_OVERLOAD
	FB_TK_NEW
	FB_TK_DELETE

	FB_TK_LET
	FB_TK_RETURN
	FB_TK_GOTO
	FB_TK_GOSUB

	FB_TK_CALL

	FB_TK_VARPTR
	FB_TK_STRPTR
	FB_TK_PROCPTR
	FB_TK_SADD

	FB_TK_FIELDDEREF
	FB_TK_CBYTE
	FB_TK_CUBYTE
	FB_TK_CSHORT
	FB_TK_CUSHORT
	FB_TK_CINT
	FB_TK_CUINT
	FB_TK_CLNG
	FB_TK_CULNG
	FB_TK_CLNGINT
	FB_TK_CULNGINT
	FB_TK_CSNG
	FB_TK_CDBL
	FB_TK_CSIGN
	FB_TK_CUNSG
	FB_TK_CPTR
	FB_TK_CAST

	FB_TK_LSET
	FB_TK_ASC
	FB_TK_CHR
	FB_TK_WCHR
	FB_TK_STR
    FB_TK_CVD
    FB_TK_CVS
    FB_TK_CVI
    FB_TK_CVL
    FB_TK_CVSHORT
	FB_TK_CVLONGINT
    FB_TK_MKD
    FB_TK_MKS
    FB_TK_MKI
    FB_TK_MKL
    FB_TK_MKSHORT
	FB_TK_MKLONGINT
	FB_TK_WSTR
	FB_TK_MID
	FB_TK_INSTR
	FB_TK_TRIM
	FB_TK_RTRIM
	FB_TK_LTRIM
	FB_TK_RESTORE
	FB_TK_READ
	FB_TK_DATA
	FB_TK_ABS
	FB_TK_SGN
	FB_TK_FIX
	FB_TK_FRAC
	FB_TK_SIN
	FB_TK_ASIN
	FB_TK_COS
	FB_TK_ACOS
	FB_TK_TAN
	FB_TK_ATN
	FB_TK_SQR
	FB_TK_LOG
	FB_TK_EXP
	FB_TK_INT
	FB_TK_ATAN2
	FB_TK_PRINT
    FB_TK_LPRINT
	FB_TK_LEN
	FB_TK_SIZEOF
	FB_TK_PEEK
	FB_TK_POKE
	FB_TK_SWAP
	FB_TK_OPEN
	FB_TK_CLOSE
	FB_TK_SEEK
	FB_TK_PUT
	FB_TK_GET
	FB_TK_ACCESS
	FB_TK_WRITE
	FB_TK_LOCK
	FB_TK_INPUT
	FB_TK_OUTPUT
	FB_TK_BINARY
	FB_TK_RANDOM
	FB_TK_APPEND
	FB_TK_ENCODING
    FB_TK_NAME
	FB_TK_SPC
	FB_TK_TAB
	FB_TK_LINE
	FB_TK_VIEW
	FB_TK_UNLOCK
    FB_TK_WIDTH
    FB_TK_COLOR
	FB_TK_FIELD
	FB_TK_ERASE
	FB_TK_LBOUND
	FB_TK_UBOUND
	FB_TK_VA_FIRST

	FB_TK_ON
	FB_TK_ERROR
	FB_TK_LOCAL
	FB_TK_ERR
	FB_TK_RESUME
	FB_TK_IIF

	FB_TK_PSET
	FB_TK_PRESET
	FB_TK_POINT
	FB_TK_CIRCLE
	FB_TK_WINDOW
	FB_TK_PALETTE
	FB_TK_SCREEN
	FB_TK_SCREENRES
	FB_TK_PAINT
	FB_TK_DRAW
	FB_TK_IMAGECREATE

	FB_TOKENS = FB_TK_IMAGECREATE - FB_TK_EOF
end enum

'' single char tokens
const FB_TK_DIRECTIVECHAR		= CHAR_DOLAR	'' $
const FB_TK_DECLSEPCHAR			= CHAR_COMMA	'' ,
const FB_TK_ASSIGN				= FB_TK_EQ		'' special case, because lex
const FB_TK_DEREFCHAR			= CHAR_CARET	'' *
const FB_TK_ADDROFCHAR			= CHAR_AT		'' @

const FB_TK_INTTYPECHAR			= CHAR_PERC
const FB_TK_LNGTYPECHAR			= CHAR_AMP
const FB_TK_SGNTYPECHAR			= CHAR_EXCL
const FB_TK_DBLTYPECHAR			= CHAR_SHARP
const FB_TK_STRTYPECHAR			= CHAR_DOLAR


'' token classes
enum FB_TKCLASS
	FB_TKCLASS_IDENTIFIER
	FB_TKCLASS_KEYWORD
	FB_TKCLASS_QUIRKWD
	FB_TKCLASS_NUMLITERAL
	FB_TKCLASS_STRLITERAL
	FB_TKCLASS_OPERATOR
	FB_TKCLASS_DELIMITER
	FB_TKCLASS_UNKNOWN
end enum

''
enum FB_MANGLING
	FB_MANGLING_BASIC
	FB_MANGLING_CDECL
	FB_MANGLING_STDCALL
	FB_MANGLING_STDCALL_MS
	FB_MANGLING_CPP
	FB_MANGLING_PASCAL
end enum

'' parameter modes
enum FB_PARAMMODE
	FB_PARAMMODE_BYVAL 			= 1				'' must start at 1! used for mangling
	FB_PARAMMODE_BYREF
	FB_PARAMMODE_BYDESC
	FB_PARAMMODE_VARARG
end enum

'' call conventions
enum FB_FUNCMODE
	FB_FUNCMODE_STDCALL			= 1             '' ditto
	FB_FUNCMODE_STDCALL_MS						'' ms/vb-style: don't include the @n suffix
	FB_FUNCMODE_CDECL
	FB_FUNCMODE_PASCAL
end enum

const FB_FUNCMODE_DEFAULT		= FB_FUNCMODE_STDCALL

''
enum FB_DATACLASS
	FB_DATACLASS_INTEGER                        '' must be the first
	FB_DATACLASS_FPOINT
	FB_DATACLASS_STRING
	FB_DATACLASS_UDT
	FB_DATACLASS_UNKNOWN
end enum

enum FB_DATATYPE
	FB_DATATYPE_VOID
	FB_DATATYPE_BYTE
	FB_DATATYPE_UBYTE
	FB_DATATYPE_CHAR
	FB_DATATYPE_SHORT
	FB_DATATYPE_USHORT
	FB_DATATYPE_WCHAR
	FB_DATATYPE_INTEGER
	FB_DATATYPE_UINT
	FB_DATATYPE_ENUM
	FB_DATATYPE_BITFIELD
	FB_DATATYPE_LONG
	FB_DATATYPE_ULONG
	FB_DATATYPE_LONGINT
	FB_DATATYPE_ULONGINT
	FB_DATATYPE_SINGLE
	FB_DATATYPE_DOUBLE
	FB_DATATYPE_STRING
	FB_DATATYPE_FIXSTR
	FB_DATATYPE_STRUCT
	FB_DATATYPE_NAMESPC
	FB_DATATYPE_FUNCTION
	FB_DATATYPE_FWDREF
	FB_DATATYPE_POINTER            				'' must be the last

	FB_DATATYPE_ARRAY			= &h00010000	'' used when mangling
	FB_DATATYPE_REFERENCE		= &h00100000	'' ditto (must be the last!)
end enum

const FB_DATATYPES = FB_DATATYPE_POINTER + 1


#include once "inc\hash.bi"
#include once "inc\stack.bi"
#include once "inc\symb.bi"

''
enum FB_ASMTOK_TYPE
	FB_ASMTOK_SYMB
	FB_ASMTOK_TEXT
end enum

type FB_ASMTOK
	type			as FB_ASMTOK_TYPE

	union
		sym			as FBSYMBOL ptr
		text		as zstring ptr
	end union

	next			as FB_ASMTOK ptr
end type

''
enum FBFILE_FORMAT
	FBFILE_FORMAT_ASCII
	FBFILE_FORMAT_UTF8
	FBFILE_FORMAT_UTF16LE
	FBFILE_FORMAT_UTF16BE
	FBFILE_FORMAT_UTF32LE
	FBFILE_FORMAT_UTF32BE
end enum

type FBFILE
	num				as integer
	name			as zstring * FB_MAXPATHLEN+1
	incfile			as zstring ptr
	ismain			as integer
	format			as FBFILE_FORMAT
end type

type FBTARGET_WCHAR
	type			as FB_DATATYPE
	size			as integer
	doconv			as integer					'' ok to convert literals at compile-time?
end type

type FBTARGET
	wchar			as FBTARGET_WCHAR
end type

type FBOPTION
	base			as integer					'' default= 0
	parammode		as integer					'' def    = byref
	explicit		as integer					'' def    = false
	procpublic		as integer					'' def    = true
	escapestr		as integer					'' def    = false
	dynamic			as integer					'' def    = false
end type

type FBMAIN
	node			as ASTNODE ptr
	proc			as FBSYMBOL ptr
	argc			as FBSYMBOL ptr
	argv			as FBSYMBOL ptr
	initnode		as ASTNODE ptr
end type

type FBENV
	inf				as FBFILE					'' source file
	outf			as FBFILE					'' destine file

	'' include files
	incpaths		as integer
	incfilehash		as THASH
	inconcehash		as THASH
	includerec		as integer					'' >0 if parsing an include file

	main			as FBMAIN

	langopt			as FB_LANG_OPT				'' language supported features
	clopt			as FBCMMLINEOPT				'' cmm-line options
	target			as FBTARGET					'' target specific

	opt				as FBOPTION					'' context-sensitive options
end type


#include once "inc\hlp.bi"

''
'' macros
''

'' x86 assumption!
#define FB_ROUNDLEN(lgt) ((lgt + (FB_INTEGERSIZE-1)) and not (FB_INTEGERSIZE-1))

''
'' super globals
''
common shared as FBENV env

#endif ''__FBINT_BI__
