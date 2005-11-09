''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
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


'' misc helpers
''
''

option explicit
option escape

#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\ir.bi"
#include once "inc\lex.bi"

type FBHLPCTX
	tmpcnt		as uinteger
end type


''globals
	dim shared ctx as FBHLPCTX

	dim shared deftypeTB( 0 to (90-65+1)-1 ) as integer

	dim shared suffixTB( 0 to FB_SYMBOLTYPES-1 ) as zstring * 1+1 => _
	{ _
				"v", _							'' void
				"b", "a", _                     '' byte, ubyte
				"c", _                          '' char
				"s", "r", _                     '' short, ushort
				"w", _                          '' wchar
				"i", "j", _                     '' integer, uinteger
				"e", _                          '' enum
				"~", _                          '' bitfield
				"l", "m", _                     '' longint, ulongint
				"f", "d", _                     '' single, double
				"t", "x", _                     '' var-len string, fix-len string
				"u", _                     		'' udt
				"n", _							'' function
				"z", _                          '' fwd-ref
				"p" _                           '' pointer
	}


'':::::
sub hlpInit
    dim i as integer

	''
	for i = 0 to (90-65+1)-1
		deftypeTB(i) = FB_SYMBTYPE_INTEGER
	next

	''
	for i = 0 to FB_SYMBOLTYPES-1
		if( len( suffixTB(i) ) = 0 ) then
			suffixTB(i) = chr( CHAR_ALOW + i )
		end if
	next

	''
	ctx.tmpcnt	= 0

end sub

'':::::
sub hlpEnd

end sub

'':::::
function hMatch( byval token as integer ) as integer

	function = FALSE
	if( lexGetToken( ) = token ) then
		function = TRUE
		lexSkipToken( )
	end if

end function

'':::::
function hHexUInt( byval value as uinteger ) as zstring ptr static
    static as zstring * 8 + 1 res
    dim as zstring ptr p
    dim as integer lgt, maxlen

	static hexTB(0 to 15) as integer = { asc( "0" ), asc( "1" ), asc( "2" ), asc( "3" ), _
									  	 asc( "4" ), asc( "5" ), asc( "6" ), asc( "7" ), _
										 asc( "8" ), asc( "9" ), asc( "A" ), asc( "B" ), _
										 asc( "C" ), asc( "D" ), asc( "E" ), asc( "F" ) }

	maxlen = 4
	if( value > 65535 ) then
		maxlen = 8
	end if

	p = @res + 8-1
	lgt = 0

	do
		*p = hexTB( value and &h0000000F )

		lgt +=1
		if( lgt = maxlen ) then
			exit do
		end if

		p -= 1
		value shr= 4
	loop

	function = p

end function

'':::::
function hMakeTmpStr( byval islabel as integer ) as zstring ptr static
	static as zstring * 8 + 3 + 1 res

	if( islabel ) then
		res = ".Lt_" + *hHexUInt( ctx.tmpcnt )
	else
		res = "Lt_" + *hHexUInt( ctx.tmpcnt )
	end if

	ctx.tmpcnt += 1

	function = @res

end function

'':::::
function hFloatToStr( byval value as double, _
					  byref typ as integer ) as string static

    dim as integer expval

	'' x86 little-endian assumption
	expval = cptr( integer ptr, @value )[1]

	select case expval
	'' -|+ infinite?
	case &h7FF00000UL, &hFFF00000UL
		if( typ = FB_SYMBTYPE_DOUBLE ) then
			typ = FB_SYMBTYPE_LONGINT
			if( expval >= 0 ) then
				function = "0x7FF0000000000000"
			else
				function = "0xFFF0000000000000"
			end if
		else
			typ = FB_SYMBTYPE_INTEGER
			if( expval >= 0 ) then
				function = "0x7F800000"
			else
				function = "0xFF800000"
			end if
		end if

	'' -|+ NaN? Quiet-NaN's only
	case &h7FF80000UL, &hFFF80000UL
		if( typ = FB_SYMBTYPE_DOUBLE ) then
			typ = FB_SYMBTYPE_LONGINT
			function = "0x7FF8000000000000"
		else
			typ = FB_SYMBTYPE_INTEGER
			function = "0x7FF00000"
		end if

	case else
		function = str( value )
	end select

end function

'':::::
function hGetDefType( byval symbol as string ) as integer static
    dim c as integer
    dim p as zstring ptr

    p = strptr( symbol )

	c = *p

	'' to upper
	if( (c >= 97) and (c <= 122) ) then
		c -= (97 - 65)
	end if

	function = deftypeTB(c - 65)

end function

'':::::
sub hSetDefType( byval ichar as integer, _
				 byval echar as integer, _
				 byval typ as integer ) static
    dim i as integer

	if( ichar < 65 ) then
		ichar = 65
	elseif( ichar > 90 ) then
		ichar = 90
	end if

	if( echar < 65 ) then
		echar = 65
	elseif( echar > 90 ) then
		echar = 90
	end if

	if( ichar > echar ) then
		swap ichar, echar
	end if

	for i = ichar to echar
		deftypeTB(i-65) = typ
	next i

end sub

'':::::
function hFBrelop2IRrelop( byval op as integer ) as integer static

    select case as const op
    case FB_TK_EQ
    	op = IR_OP_EQ
    case FB_TK_GT
    	op = IR_OP_GT
    case FB_TK_LT
    	op = IR_OP_LT
    case FB_TK_NE
    	op = IR_OP_NE
    case FB_TK_LE
    	op = IR_OP_LE
    case FB_TK_GE
    	op = IR_OP_GE
    end select

    function = op

end function

'':::::
function hFileExists( byval filename as string ) as integer static
    dim f as integer

    f = freefile

	if( open( filename, for input, as #f ) = 0 ) then
		function = TRUE
		close #f
	else
		function = FALSE
	end if

end function

'':::::
function hReplace( byval orgtext as string, _
			 	   byval oldtext as string, _
			  	   byval newtext as string ) as string static

    dim as integer oldlen, newlen, p
    dim as string text, remtext

	oldlen = len( oldtext )
	newlen = len( newtext )

	text = orgtext
	p = 0
	do
		p = instr( p+1, text, oldtext )
	    if( p = 0 ) then
	    	exit do
	    end if

		remtext = mid( text, p + oldlen )
		text = left( text, p-1 )
		text += newtext
		text += remtext
		p += newlen
	loop

	function = text

end function

'':::::
function hEscapeStr( byval text as string ) as zstring ptr static
    static as zstring ptr res = NULL
    static as integer res_len = 0
    dim as integer c, octlen, lgt
    dim as zstring ptr src, dst, src_end

	octlen = 0

	lgt = len( text )
	ALLOC_TEMP_STR( res, res_len, lgt*2 )

	src = strptr( text )
	dst = res

	src_end = src + lgt
	do while( src < src_end )
		c = *src
		src += 1

		select case c
		case CHAR_RSLASH, CHAR_QUOTE
			*dst = CHAR_RSLASH
			dst += 1

		case FB_INTSCAPECHAR
			*dst = CHAR_RSLASH
			dst += 1

			if( src >= src_end ) then exit do
			c = *src
			src += 1

			'' octagonal?
			if( c >= 1 and c <= 3 ) then
				octlen = c
				if( src >= src_end ) then exit do
				c = *src
				src += 1
			end if

		case 0 to 31, 128 to 255
			*dst = CHAR_RSLASH
			dst += 1

			if( c < 8 ) then
				c += CHAR_0

			elseif( c < 64 ) then
				*dst = CHAR_0 + (c shr 3)
				dst += 1
				c = CHAR_0 + (c and 7)

			else
				dst[0] = CHAR_0 + (c shr 6)
				dst[1] = CHAR_0 + ((c and &b00111000) shr 3)
				dst += 2
				c = CHAR_0 + (c and 7)
			end if

		end select

		*dst = c
		dst += 1

		'' add quote's when the octagonal escape ends
		if( octlen > 0 ) then
			octlen -= 1
			if( octlen = 0 ) then
				dst[0] = CHAR_QUOTE
				dst[1] = CHAR_QUOTE
				dst += 2
			end if
		end if
	loop

	'' null-term
	*dst = 0

	function = res

end function

'':::::
function hEscapeWstr( byval text as wstring ptr ) as zstring ptr static
    static as zstring ptr res = NULL
    static as integer res_len = 0
    dim as integer char, c, lgt, i, wstrlen
    dim as wstring ptr src, src_end
    dim as zstring ptr dst

	wstrlen = irGetDataSize( IR_DATATYPE_WCHAR )

	'' up to 4 ascii chars can be used p/ unicode char (\ooo)
	lgt = len( *text )
	ALLOC_TEMP_STR( res, res_len, lgt * (1+3) * wstrlen )

	src = text
	dst = res

	src_end = src + lgt
	do while( src < src_end )
		char = *src
		src += 1

		'' internal espace char?
		if( char = FB_INTSCAPECHAR ) then
			if( src >= src_end ) then exit do
			char = *src
			src += 1

			'' octagonal? convert to integer..
			'' note: it can be up to 6 digits due wchr()
			'' when evaluated at compile-time
			if( (char >= 1) and (char <= 6) ) then
				i = char
				char = 0

				if( src + i >= src_end ) then exit do
				do while( i > 0 )
					char = (char * 8) + (*src - CHAR_0)
					src += 1
					i -= 1
				loop

			else

			    '' remap char as they will become a octagonal seq
			    select case as const char
			    case asc( "r" )
			    	char = CHAR_CR

			    case asc( "l" ), asc( "n" )
			    	char = CHAR_LF

			    case asc( "t" )
			    	char = CHAR_TAB

			    case asc( "b" )
			    	char = CHAR_BKSPC

			    case asc( "a" )
			    	char = CHAR_BELL

			    case asc( "f" )
			    	char = CHAR_FORMFEED

			    case asc( "v" )
			    	char = CHAR_VTAB

			    '' unicode 16-bit
			    case asc( "u" )
			    	'' x86 little-endian assumption
			    	char = 0
			    	if( src + 4 >= src_end ) then exit do
			    	for i = 1 to 4
			    		c = (*src - CHAR_0)
			    		src +=1

                		if( c > 9 ) then
							c -= (CHAR_AUPP - CHAR_9 - 1)
                		end if
                		if( c > 16 ) then
                  			c -= (CHAR_ALOW - CHAR_AUPP)
                		end if

						char = (char shl 4) or c
                    next

                end select
			end if

		end if

		'' convert every char to octagonal form as GAS can't
		'' handle unicode literal strings
		for i = 1 to wstrlen
			*dst = CHAR_RSLASH
			dst += 1

			'' x86 little-endian assumption
			c = char and 255
			if( c < 8 ) then
				dst[0] = CHAR_0 + c
				dst += 1

			elseif( c < 64 ) then
				dst[0] = CHAR_0 + (c shr 3)
				dst[1] = CHAR_0 + (c and 7)
				dst += 2

			else
				dst[0] = CHAR_0 + (c shr 6)
				dst[1] = CHAR_0 + ((c and &b00111000) shr 3)
				dst[2] = CHAR_0 + (c and 7)
				dst += 3
			end if

        	char shr= 8
		next

	loop

	'' null=term
	*dst = 0

	function = res

end function

'':::::
function hUnescapeStr( byval text as string ) as string static
    dim as integer c
    dim as string res
    dim as zstring ptr src, dst, src_len

	if( not env.opt.escapestr ) then
    	return text
    end if

	res = text

	src = strptr( text )
	dst = strptr( res )

	src_len = src + len( text )
	do while( src < src_len )

		c = *src
		src += 1

		if( c = FB_INTSCAPECHAR ) then
			*dst = CHAR_RSLASH
		end if

		dst += 1
	loop

	function = res

end function

'':::::
function hEscapeToChar( byval text as string ) as zstring ptr static
    static as zstring ptr res = NULL
    static as integer res_len = 0
    dim as integer char, lgt, i
    dim as zstring ptr src, dst, src_len

	if( not env.opt.escapestr ) then
    	return strptr( text )
    end if

	lgt = len( text )
	ALLOC_TEMP_STR( res, res_len, lgt )

	src = strptr( text )
	dst = res

	src_len = src + lgt
	do while( src < src_len )
		char = *src
		src += 1

		if( char = FB_INTSCAPECHAR ) then

			if( src >= src_len ) then exit do
			char = *src
			src += 1

			'' octagonal? convert to integer..
			if( (char >= 1) and (char <= 3) ) then
				i = char
				char = 0
				do while( i > 0 )
					char = (char * 8) + (*src - CHAR_0)
					src += 1
					i -= 1
				loop

			else
			    '' remap char
			    select case as const char
			    case asc( "r" )
			    	char = CHAR_CR

			    case asc( "l" ), asc( "n" )
			    	char = CHAR_LF

			    case asc( "t" )
			    	char = CHAR_TAB

			    case asc( "b" )
			    	char = CHAR_BKSPC

			    case asc( "a" )
			    	char = CHAR_BELL

			    case asc( "f" )
			    	char = CHAR_FORMFEED

			    case asc( "v" )
			    	char = CHAR_VTAB

			    end select

			end if

		end if

		*dst = char
		dst += 1

	loop

	'' null-term
	*dst = 0

	function = res

end function


'':::::
function hEscapeToCharW( byval text as wstring ptr ) as wstring ptr static
    static as wstring ptr res = NULL
    static as integer res_len = 0
    dim as integer char, lgt, i
    dim as wstring ptr src, dst, src_len

	if( not env.opt.escapestr ) then
    	return text
    end if

	lgt = len( *text )
	ALLOC_TEMP_WSTR( res, res_len, lgt )

	*res = *text

	src = text
	dst = res

	src_len = src + lgt
    do while( src < src_len )
    	char = *src
    	src += 1

    	if( char = FB_INTSCAPECHAR ) then

			if( src >= src_len ) then exit do
			char = *src
			src += 1

			'' octagonal? convert to integer..
			'' note: it can be up to 6 digits due wchr()
			'' when evaluated at compile-time
			if( (char >= 1) and (char <= 6) ) then
				i = char
				char = 0
				do while( i > 0 )
					char = (char * 8) + (*src - CHAR_0)
					src += 1
					i -= 1
				loop

			else
			    '' remap char
			    select case as const char
			    case asc( "r" )
			    	char = CHAR_CR

			    case asc( "l" ), asc( "n" )
			    	char = CHAR_LF

			    case asc( "t" )
			    	char = CHAR_TAB

			    case asc( "b" )
			    	char = CHAR_BKSPC

			    case asc( "a" )
			    	char = CHAR_BELL

			    case asc( "f" )
			    	char = CHAR_FORMFEED

			    case asc( "v" )
			    	char = CHAR_VTAB

			    end select
			end if

		end if

		*dst = char
		dst += 1

    loop

    '' null-term
    *dst = 0

    function = res

end function

'':::::
sub hUcase( byval src as string, _
		    byval dst as string ) static

    dim as integer i, c
    dim as zstring ptr s, d

	s = strptr( src )
	d = strptr( dst )

	for i = 1 to len( src )
		c = *s

		if( c >= 97 ) then
			if( c <= 122 ) then
				c -= (97 - 65)
			end if
		end if

		*d = c

		s += 1
		d += 1
	next i

	'' null-term
	*d = 0

end sub


'':::::
sub hClearName( byval src as string ) static
    dim i as integer
    dim p as zstring ptr

	p = strptr( src )

	for i = 1 to len( src )

		select case as const *p
		case CHAR_AUPP to CHAR_ZUPP, CHAR_ALOW to CHAR_ZLOW, CHAR_0 to CHAR_9, CHAR_UNDER

		case else
			*p = CHAR_ZLOW
		end select

		p += 1
	next

end sub

'':::::
function hCreateName( byval symbol as string, _
					  byval typ as integer = INVALID, _
					  byval preservecase as integer = FALSE, _
					  byval addunderscore as integer = TRUE, _
					  byval clearname as integer = TRUE ) as zstring ptr static

    static sname as zstring * FB_MAXINTNAMELEN+1

	if( addunderscore ) then
		sname = "_"
		sname += symbol
	else
		sname = symbol
	end if

	if( not preservecase ) then
		hUcase( sname, sname )
	end if

    if( clearname ) then
    	hClearName( sname )
    end if

    if( typ <> INVALID ) then
    	if( typ > FB_SYMBTYPE_POINTER ) then
    		typ = FB_SYMBTYPE_POINTER
    	end if
    	sname += suffixTB( typ )
    end if

	function = @sname

end function

'':::::
function hCreateProcAlias( byval symbol as string, _
						   byval argslen as integer, _
						   byval mode as integer ) as zstring ptr static

    static sname as zstring * FB_MAXINTNAMELEN+1


	select case as const fbGetNaming()
    case FB_COMPNAMING_WIN32, FB_COMPNAMING_CYGWIN
        dim addat as integer

        if( env.clopt.nounderprefix ) then
            sname = symbol
        else
            sname = "_"
            sname += symbol
        end if

        if( env.clopt.nostdcall ) then
            addat = FALSE
        else
            addat = (mode = FB_FUNCMODE_STDCALL)
        end if

        if( addat ) then
            if( instr( symbol, "@" ) = 0 ) then
            	sname += "@"
            	sname += str( argslen )
            end if
        end if

	case FB_COMPNAMING_LINUX
		sname = symbol

	case FB_COMPNAMING_DOS, FB_COMPNAMING_XBOX
        sname = "_"
        sname += symbol

    end select

	function = @sname

end function

'':::::
function hCreateOvlProcAlias( byval symbol as string, _
					    	  byval argc as integer, _
					    	  byval arg as FBSYMBOL ptr ) as zstring ptr static
    dim as integer i, typ
    static as zstring * FB_MAXINTNAMELEN+1 aname

    aname = symbol
    aname += "__ovl_"

    for i = 0 to argc-1
    	aname += "_"

		'' by descriptor?
		if( symbGetArgMode( arg ) = FB_ARGMODE_BYDESC ) then
			aname += "d"
		end if

    	typ = symbGetType( arg )
    	do while( typ >= FB_SYMBTYPE_POINTER )
    		aname += "p"
    		typ -= FB_SYMBTYPE_POINTER
    	loop

    	aname += suffixTB( typ )
    	if( (typ = FB_SYMBTYPE_USERDEF) or _
    		(typ = FB_SYMBTYPE_ENUM) ) then
    		aname += symbGetOrgName( symbGetSubType( arg ) )
    	end if

    	'' next
    	arg = symbGetArgNext( arg )
    next

	function = @aname

end function


'':::::
function hCreateDataAlias( byval symbol as string, _
						   byval isimport as integer ) as string static

	select case as const fbGetNaming()
    case FB_COMPNAMING_WIN32, FB_COMPNAMING_CYGWIN
        if( isimport ) then
            function = "__imp__" + symbol
        else
            function = "_" + symbol
        end if

    case FB_COMPNAMING_DOS, FB_COMPNAMING_XBOX
		function = "_" + symbol

    case FB_COMPNAMING_LINUX
		function = symbol

    end select

end function

'':::::
function hStripUnderscore( byval symbol as string ) as string static

	select case as const fbGetNaming()
    case FB_COMPNAMING_WIN32, FB_COMPNAMING_CYGWIN
	    if( not env.clopt.nostdcall ) then
			function = mid( symbol, 2 )
		else
			function = symbol
		end if

    case FB_COMPNAMING_DOS, FB_COMPNAMING_XBOX
    	function = mid( symbol, 2 )

    case FB_COMPNAMING_LINUX
    	function = symbol

    end select

end function

'':::::
function hStripExt( byval filename as string ) as string static
    dim p as integer, lp as integer

	lp = 0
	do
		p = instr( lp+1, filename, "." )
	    if( p = 0 ) then
	    	exit do
	    end if
	    lp = p
	loop

	if( lp > 0 ) then
		function = left$( filename, lp-1 )
	else
		function = filename
	end if

end function

'':::::
function hStripPath( byval filename as string ) as string static
    dim as integer lp, p_found, p(1 to 2)

	lp = 0
	do
		p(1) = instr( lp+1, filename, "\\" )
		p(2) = instr( lp+1, filename, "/" )
        if p(1)=0 or (p(2)>0 and p(2)<p(1)) then
            p_found = p(2)
        else
            p_found = p(1)
        end if
	    if( p_found = 0 ) then
	    	exit do
	    end if
	    lp = p_found
	loop

	if( lp > 0 ) then
		function = mid( filename, lp+1 )
	else
		function = filename
	end if

end function

'':::::
function hStripFilename ( byval filename as string ) as string static
    dim as integer lp, p_found, p(1 to 2)

	lp = 0
	do
		p(1) = instr( lp+1, filename, "\\" )
		p(2) = instr( lp+1, filename, "/" )
        if p(1)=0 or (p(2)>0 and p(2)<p(1)) then
            p_found = p(2)
        else
            p_found = p(1)
        end if
	    if( p_found = 0 ) then
	    	exit do
	    end if
	    lp = p_found
	loop

	if( lp > 0 ) then
		function = left( filename, lp )
	else
		function = ""
	end if

end function

'':::::
function hGetFileExt( fname as string ) as string static
    dim as integer p, lp
    dim as string res

	lp = 0
	do
		p = instr( lp+1, fname, "." )
		if( p = 0 ) then
			exit do
		end if
		lp = p
	loop

    if( lp = 0 ) then
    	function = ""
    else
    	res = lcase( mid( fname, lp+1 ) )
        if instr( res, "\\" ) > 0 or instr( res, "/" ) > 0 then
            '' We had a folder with a "." inside ...
            function = ""
        elseif( len(res) > 0 ) then
	    	'' . or .. dirs?
	    	if( res[0] = asc( "\\" ) or res[0] = asc( "/" ) ) then
	    		function = ""
	    	else
	    		function = res
	    	end if
        end if
    end if

end function

'':::::
function hRevertSlash( byval s as string ) as string static
    dim as integer i
    dim as string res

	res = s

	for i = 0 to len( s )-1
		if( res[i] = CHAR_RSLASH ) then
			res[i] = CHAR_SLASH
		end if
	next i

	function = res

end function

'':::::
function hToPow2( byval value as uinteger ) as uinteger static
    dim n as uinteger

	static pow2tb(0 to 63) as uinteger = {  0,  0,  0, 15,  0,  1, 28,  0, _
										   16,  0,  0,  0,  2, 21, 29,  0, _
    									    0,  0, 19, 17, 10,  0, 12,  0, _
    									    0,  3,  0,  6,  0, 22, 30,  0, _
    									   14,  0, 27,  0,  0,  0, 20,  0, _
    									   18,  9, 11,  0,  5,  0,  0, 13, _
    									   26,  0,  0,  8,  0,  4,  0, 25, _
    									   0,   7, 24,  0, 23,  0, 31,  0 }

	'' don't check if it's zero
	if( value = 0 ) then
		return 0
	end if

	'' (n^(n-1)) * Harley's magic number
	n = ((value-1) xor value) * (7*255*255*255)

    '' extract bits <31:26>
    n = pow2tb(n shr 26)				'' translate into bit count - 1

    '' is this really a power of 2?
    if( value - (1 shl n) = 0 ) then
    	function = n
    else
    	function = 0
    end if

end function

'':::::
function hJumpTbAllocSym( ) as any ptr static
	static as zstring * FB_MAXNAMELEN+1 sname
	dim as FBARRAYDIM dTB(0)
	dim as FBSYMBOL ptr s

	sname = *hMakeTmpStr( )

	s = symbAddVarEx( @sname, NULL, FB_SYMBTYPE_UINT, NULL, 0, _
					  FB_INTEGERSIZE, 1, dTB(), FB_ALLOCTYPE_SHARED+FB_ALLOCTYPE_JUMPTB, _
					  FALSE, FALSE, FALSE )

	symbSetVarEmited( s, TRUE )

	function = s

end function

'':::::
function hGetWstrNull( ) as zstring ptr
    static as integer isset = FALSE
    static as zstring * FB_INTEGERSIZE*3+1 nullseq
    dim as integer i

    if( not isset ) then
    	isset = TRUE
    	nullseq = ""
    	for i = 1 to irGetDataSize( IR_DATATYPE_WCHAR )
    		nullseq += "\\0"
    	next
	end if

	function = @nullseq

end function
