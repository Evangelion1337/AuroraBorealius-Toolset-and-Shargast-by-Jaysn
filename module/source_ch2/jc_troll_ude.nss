/*
 *  version 1.2 by Lorinton September 17 2003
 *
 *  A complete rewrite after discovering that a recent patch was causing the
 *  previous version to crash the server.
 *
 *  The heartbeat UDE controls regeneration and returning to consciousness.
 *  The on damaged UDE controls death and being damaged to unconsciousness.
 *
 */

#include "nw_i0_generic"

// If you would like to enable the debug messages which are in the code
// uncomment the SpeakString function in DebugSpeak.
void DebugSpeak( string sMessage )
{
//    SpeakString( sMessage );
}

// This function is called from the on damaged (1006) UDE when permanent damage
// equals or exceeds the trolls maximum hitpoints.
void KillTroll( object oTroll = OBJECT_SELF )
{
    effect eAcid, eFire, eVisual;

    // Create a fire or acid visual effect and kill the troll.
    DebugSpeak( "Killing " + GetName( oTroll ));
    if( GetLocalInt( oTroll, "bAcid" ))
        eAcid = EffectVisualEffect( VFX_IMP_ACID_L );
    if( GetLocalInt( oTroll, "bFire" ))
        eFire = EffectVisualEffect( VFX_IMP_FLAME_M );
    eVisual = EffectLinkEffects( eAcid, eFire );
    ApplyEffectToObject( DURATION_TYPE_INSTANT, eVisual, oTroll );

    SetImmortal( oTroll, FALSE );

    ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectDeath(), oTroll );
}

// This function is called from the on damaged UDE.
// Fire and acid damage will be summed to the troll's permanent damage.
// All other damage types will be summed to the troll's temporary damage.
int CalculateTrollDamage()
{
    int iAcidDamage, iFireDamage, iDamage, iTemp;

    // Get the most recent fire damage
    iFireDamage = GetDamageDealtByType( DAMAGE_TYPE_FIRE );
    if( iFireDamage > 0 )
        SetLocalInt( OBJECT_SELF, "bFire", TRUE );
    else
    {
        iFireDamage = 0;
        SetLocalInt( OBJECT_SELF, "bFire", FALSE );
    }

    // Get the most recent acid damage
    iAcidDamage = GetDamageDealtByType( DAMAGE_TYPE_ACID );
    if( iAcidDamage > 0)
        SetLocalInt( OBJECT_SELF, "bAcid", TRUE );
    else
    {
        iAcidDamage = 0;
        SetLocalInt( OBJECT_SELF, "bAcid", FALSE );
    }

    // Get the most recent damage (all types combined)
    iDamage = GetTotalDamageDealt();

    // Calculate the new permanent damage from fire and acid and then add it to
    // the existing permenant damage.
    iTemp = iFireDamage + iAcidDamage;
    DebugSpeak( "Troll new permanent damage = " + IntToString( iTemp ));
    // If the troll took permanent damage while unconscious it will be killed.
    if( iTemp > 0 && GetLocalInt( OBJECT_SELF, "Troll_unconscious" ))
        KillTroll();
    SetLocalInt( OBJECT_SELF, "Troll_PermDamage", GetLocalInt( OBJECT_SELF, "Troll_PermDamage" ) + iTemp );

    // Calculate the new temporary damage and then add it to the existing temporary
    // damage.
    // iTemp still holds the new permanent damage
    iTemp = iDamage - iTemp;
    DebugSpeak( "Troll temp damage = " + IntToString( iTemp ));
    SetLocalInt( OBJECT_SELF, "Troll_TempDamage", GetLocalInt( OBJECT_SELF, "Troll_TempDamage" ) + iTemp );

    return iDamage;
}

// Regenerate temporary damage
void HealTroll()
{
    int iHeal, iPermDamage, iTempDamage, iMaxHPs = GetMaxHitPoints();
    effect eHeal;

    iTempDamage = GetLocalInt ( OBJECT_SELF, "Troll_TempDamage" );
    iPermDamage = GetLocalInt ( OBJECT_SELF, "Troll_PermDamage" );

    DebugSpeak( "Permanent and temporary damage = " + IntToString( iPermDamage ) +
        ", " + IntToString( iTempDamage ));

    // Reduce temporary damage by the lesser of five hitpoints or the troll's
    // temporary damage.
    iHeal = ( iTempDamage < 5 ) ? iTempDamage : 5;
    iTempDamage -= iHeal;
    DebugSpeak( "Troll regeneration = " + IntToString( iHeal ));
    SetLocalInt( OBJECT_SELF, "Troll_TempDamage", iTempDamage );

    /*
    // Sound effect of troll regenerating (one each depending if
    // troll is "dead" or still standing
    if (GetLocalInt (OBJECT_SELF, "bTrollDown") == TRUE)
        PlaySound("al_na_sludggrat2");  // Sound for dead troll regenerating
    else
        PlaySound("as_mg_telepin1"); // Sound for living troll regenerating
    */

    // Only heal if the regeneration places the troll into positive hitpoints.
    if(( iTempDamage + iPermDamage ) < iMaxHPs )
    {
        DebugSpeak( "Troll healing = " + IntToString( iHeal ));
        eHeal = EffectHeal( iHeal );
        ApplyEffectToObject( DURATION_TYPE_INSTANT , eHeal, OBJECT_SELF );
    }
}

void main()
{
    int iSum, iPermDamage, iTempDamage, iMaxHPs = GetMaxHitPoints();
    float fDuration;

    switch ( GetUserDefinedEventNumber () )
    {
        case EVENT_HEARTBEAT:
            DebugSpeak( "Event 1001..." );
            iTempDamage = GetLocalInt ( OBJECT_SELF, "Troll_TempDamage" );
            // Use iPermDamage as a temporary variable that holds the sum of
            // temporary and permanent damage
            iSum = iTempDamage + GetLocalInt( OBJECT_SELF, "Troll_PermDamage" );
            if( iSum == 0 )
                return;
            if( iSum < iMaxHPs && GetLocalInt( OBJECT_SELF, "Troll_unconscious" ))
            {
                // Return the troll to consciousness as it has regenerated to
                // positive hitpoints.
                DebugSpeak( "Returning the troll to consciousness..." );
                SetCommandable( TRUE, OBJECT_SELF );
                // Force the troll up off the ground as DetermineCombatRound()
                // won't unless it has an attack target.
                ActionForceMoveToLocation( GetLocation( OBJECT_SELF ));
                SetLocalInt( OBJECT_SELF, "Troll_unconscious", FALSE );
                DelayCommand( 0.5, DetermineCombatRound() );
            }
            if( iTempDamage > 0 )
            {
                HealTroll();
            }
            break;
        case EVENT_DAMAGED:
            // Sort new damage into permanent and temporary damage.
            DebugSpeak( "Event 1006..." );
            if( CalculateTrollDamage() )
            {
                iTempDamage = GetLocalInt ( OBJECT_SELF, "Troll_TempDamage" );
                iPermDamage = GetLocalInt( OBJECT_SELF, "Troll_PermDamage" );
                iSum = iTempDamage + iPermDamage;
                if( iPermDamage >= iMaxHPs )
                {
                    // Permanent damage has reached or exceeded the troll's maximum
                    // hitpoints so kill the troll.
                    DebugSpeak( "Killing the troll..." );
                    KillTroll();
                }
                else if( iSum >= iMaxHPs )
                {
                    // Force the troll to lie down unconcious until it regenerates to
                    // positive hitpoints.
                    DebugSpeak( "Forcing the troll to be unconcious..." );
                    // Play the dead animation for the time it will take to regenerate from the
                    // current hitpoints to positive hitpoints.
                    // At 5 hitpoints/round with a 6 second round this is 1.2 seconds per HP.
                    fDuration = ( 2.0 * IntToFloat( iSum - iMaxHPs ));
                    DebugSpeak( "Playing dead animation for " + FloatToString( fDuration ));
                    SetCommandable( TRUE, OBJECT_SELF );
                    ClearAllActions();
                    PlayAnimation( ANIMATION_LOOPING_DEAD_FRONT, 1.0, fDuration );
                    SetLocalInt( OBJECT_SELF, "Troll_unconscious", TRUE );
                    DelayCommand( 0.05, SetCommandable( FALSE, OBJECT_SELF ));
                }
                // If the troll is unconscious and damaged by a PC with a torch, allow them
                // them use it to kill the troll.
                // Rather than force them to take an action in the middle of combat which
                // might cause AoO's and be against their will, just assume they did so.
                if( GetLocalInt( OBJECT_SELF, "Troll_unconscious" ) &&
                    GetBaseItemType( GetItemInSlot( INVENTORY_SLOT_LEFTHAND, GetLastAttacker() )) ==
                    BASE_ITEM_TORCH )
                {
                    DebugSpeak( GetName( GetLastAttacker() ) + " killing troll with torch..." );
                    SetLocalInt( OBJECT_SELF, "bFire", TRUE );
                    object oTroll = OBJECT_SELF;
                    AssignCommand( GetLastAttacker(), KillTroll( oTroll ) );
                }
            }
            break;
    }
}
