/* file device */

#include "fb.h"

int fb_DevPipeOpen( struct _FB_FILE *handle, const char *filename, size_t filename_len )
{
    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
}

