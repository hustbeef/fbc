/* NOW function */

#include <time.h>
#include "fb.h"

/*:::::*/
FBCALL double fb_Now( void )
{
    double      dblTime, dblDate;
	time_t 		rawtime;
  	struct tm	*ptm;

    /* guard by global lock because time/localtime might not be thread-safe */
    FB_LOCK();
    time( &rawtime );
    ptm = localtime( &rawtime );
    dblDate = fb_DateSerial( 1900 + ptm->tm_year, 1 + ptm->tm_mon, ptm->tm_mday );
    dblTime = fb_TimeSerial( ptm->tm_hour, ptm->tm_min, ptm->tm_sec );
    FB_UNLOCK();

    return dblDate + dblTime;
}
