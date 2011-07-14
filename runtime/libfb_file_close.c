/* CLOSE function */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fb.h"

/*:::::*/
int fb_FileCloseEx( FB_FILE *handle )
{
    FB_LOCK();

    if( !FB_HANDLE_USED(handle) ) {
    	FB_UNLOCK();
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
    }

    /* close VFS handle */
    DBG_ASSERT(handle->hooks->pfnClose != NULL);
    int result = handle->hooks->pfnClose( handle );
    if (result != 0) {
        FB_UNLOCK();
        return result;
    }

    /* clear structure */
    memset(handle, 0, sizeof(FB_FILE));

    FB_UNLOCK();

	return fb_ErrorSetNum( FB_RTERROR_OK );
}

/*:::::*/
FBCALL int fb_FileClose( int fnum )
{
	/* QB quirk: CLOSE w/o arguments closes all files */
	if( fnum == 0 ) {
		fb_FileReset( );
		return fb_ErrorSetNum( FB_RTERROR_OK );
	}
    return fb_FileCloseEx( FB_FILE_TO_HANDLE(fnum) );
}

