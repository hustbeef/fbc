/* file device */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fb.h"

/*:::::*/
int fb_DevFileClose( struct _FB_FILE *handle )
{
    FILE *fp;

    FB_LOCK();

    fp = (FILE*) handle->opaque;

    if( fp != NULL ) {
        fclose( fp );
    }

	handle->opaque = NULL;

    FB_UNLOCK();

	return fb_ErrorSetNum( FB_RTERROR_OK );
}
