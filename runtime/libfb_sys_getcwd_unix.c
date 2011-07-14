/* get current dir for Linux */

#include <stdlib.h>
#include <string.h>
#include "fb.h"

#include <unistd.h>
#define MAX_PATH	1024

/*:::::*/
int fb_hGetCurrentDir ( char *dst, int maxlen )
{
	if ( getcwd( dst, maxlen ) != NULL )
		return strlen( dst );
	return 0;
}
