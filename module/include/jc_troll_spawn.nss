/*
 *  jc_troll_9
 *
 *  version 1.2 by Lorinton September 17 2003
 *
 *  On spawn script for regenerating trolls.
 *  Assign the script to the troll's on spawn event replacing the default
 *  nw_c2_default9 script.
 *
 *  The on damaged and heartbeat user defined events MUST be enabled.
 *
 */

#include "nw_i0_generic"

void main()
{
    SetSpawnInCondition( NW_FLAG_DAMAGED_EVENT );
    SetSpawnInCondition( NW_FLAG_HEARTBEAT_EVENT );

    // Set the troll to immortal so that we can script a requirement for fire and
    // acid damage to kill the troll.
    SetImmortal( OBJECT_SELF, TRUE );

    // Run the standard spawn script.
    // Change the name to whatever custom script you use if not using the default script.
    ExecuteScript( "nw_c2_default9", OBJECT_SELF );
}
