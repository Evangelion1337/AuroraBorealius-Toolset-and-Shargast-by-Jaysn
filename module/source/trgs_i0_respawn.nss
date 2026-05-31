#include "trgs_i0_user"

// The main script of the system.
// oOpener = The player (for level-appropriate generation)
// oChest = The container the items go to, also what is
// checked for respawn integers.
// TREASURECLASS = Quality of treasure spawned. See TREASURECLASS.
// TREASURETYPE = Kind of treasure spawned. See TREASURETYPE.
// RESPAWN_METHOD = Determines to who and at what time this chest offers loot. RESPAWNMETHOD_*
// RESPAWN_DELAY = How long in real-life minutes it takes for respawning methods to re-fill.
//
// Default value = Low value amounts of gp, scrolls, potions, and other consumables.
void DoTreasureGeneration( object oOpener, object oChest=OBJECT_SELF, int TREASURECLASS=0, int TREASURETYPE=5, int RESPAWN_METHOD=DEFAULT_RESPAWN_METHOD, int RESPAWN_DELAY_IN_MINUTES=DEFAULT_RESPAWN_DELAY );

// Compares the chest's 4 locals to see whether or not it can generate treasure.
int CheckHaveIBeenLooted( object oChest, object oOpener, int NOW );

// This is actually a function with more uses than just the scope of this
// system. It accurately collects the number of minutes since the game began,
// taking into consideration the module's Minutes Per Hour setting.
//
// NOTE: This means that if your module advances time frequently, chests will be
// lootable more often.
int ReturnTreasureMinuteNow();

////////////////////////////////////////////////////////////////////////////////

// Private wrapper function
//
// Returns the minute since the start of the module
// oChest will be lootable again. If this time has
// not been set, this function returns 0.
int GetTreasureRespawnMinute( object oChest, object oOpener=OBJECT_INVALID )
{
    return ( GetIsObjectValid( oOpener ) ?
        GetLocalInt( oChest, MINUTE_KEY + GetName( oOpener ) + GetPCPlayerName( oOpener ) ) :
        GetLocalInt( oChest, MINUTE_KEY ) );
}

void DoTreasureGeneration( object oOpener, object oChest=OBJECT_SELF, int TREASURECLASS=0, int TREASURETYPE=5, int RESPAWN_METHOD=DEFAULT_RESPAWN_METHOD, int RESPAWN_DELAY_IN_MINUTES=DEFAULT_RESPAWN_DELAY )
{
    int    NOW         = ReturnTreasureMinuteNow();
    string PLAYER      = GetName( oOpener ) + GetPCPlayerName( oOpener );

    if ( CheckHaveIBeenLooted( oChest, oOpener, NOW ) )
        return;

    // Generate your goodies
    GenerateMyTreasure( oChest, oOpener, TREASURECLASS, TREASURETYPE );

    // Flag the current method
    switch( RESPAWN_METHOD )
    {
        case RESPAWNMETHOD_ONE_SHOT_NO_RETURN:
            SetLocalInt( oChest, ONE_SHOT, TRUE );
        break;
        case RESPAWNMETHOD_ONE_SHOT_AND_RETURN:
            SetLocalInt( oChest, MINUTE_KEY, NOW + RESPAWN_DELAY_IN_MINUTES );
            SetLocalInt( oChest, ONE_SHOT + AND_RETURN, TRUE );
        break;
        case RESPAWNMETHOD_CONTINUOUS_NO_RETURN:
            SetLocalInt( oChest, CONTINUOUS + PLAYER, TRUE );
        break;
        case RESPAWNMETHOD_CONTINUOUS_AND_RETURN:
            SetLocalInt( oChest, MINUTE_KEY + PLAYER, NOW + RESPAWN_DELAY_IN_MINUTES );
            SetLocalInt( oChest, CONTINUOUS + PLAYER + AND_RETURN, TRUE );
        break;
        default:
            SetLocalInt( oChest, ONE_SHOT, TRUE );
        break;
    }
}

int CheckHaveIBeenLooted( object oChest, object oOpener, int NOW )
{
    string PLAYER = GetName( oOpener ) + GetPCPlayerName( oOpener );
    // Unflag any respawning methods if the set date has been passed.
    if ( NOW >= GetTreasureRespawnMinute( oChest ) )
            DeleteLocalInt( oChest, ONE_SHOT + AND_RETURN );
    if ( NOW >= GetTreasureRespawnMinute( oChest, oOpener ) )
            DeleteLocalInt( oChest, CONTINUOUS + PLAYER + AND_RETURN );

    // Do not generate treasure for this chest if ANY of the respawn methods have
    // been flagged regardless of present method.
    return ( GetLocalInt( oChest, ONE_SHOT )
        ||   GetLocalInt( oChest, ONE_SHOT + AND_RETURN )
        ||   GetLocalInt( oChest, CONTINUOUS + PLAYER )
        ||   GetLocalInt( oChest, CONTINUOUS + PLAYER + AND_RETURN ) );
}

int ReturnTreasureMinuteNow()
{
    int iMinutesPerGameHour = ( FloatToInt( HoursToSeconds( 1 ) / 60 ) );
    int iMinuteKey = ( ( GetCalendarYear() * 8760 * iMinutesPerGameHour ) +
                       ( GetCalendarDay()  * 24 * iMinutesPerGameHour ) +
                       ( GetTimeHour()     * iMinutesPerGameHour ) +
                       GetTimeMinute() );
    // Don't even bother trying to make sense of the above digits,
    // trial and error and NWN Lexicon says this will work!
    return iMinuteKey;
}
