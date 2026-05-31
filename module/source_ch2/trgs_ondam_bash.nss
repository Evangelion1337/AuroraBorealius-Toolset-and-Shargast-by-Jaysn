// Handles bashing of a chest or door so it can be bashed without removing the
// object from the world. To use this script, set the door's HP to over 1000
// with the difference becoming the door's functional HP.
// Example: A door or chest with 1015 HP will bash open after it's taken 15 damage.
//#include "trgs_i0_respawn"
void main()
{
    object oBashed = OBJECT_SELF;
    object oBasher = GetLastDamager();
    int iType = GetObjectType( oBashed );
    if ( GetCurrentHitPoints( oBashed ) <= 1000 )
    {
        SetPlotFlag( oBashed, TRUE );
        if ( !GetIsOpen( oBashed ) )
        {
            // Bust open the object
            FloatingTextStringOnCreature( "Lock destroyed!", oBasher );
            SetLocked( oBashed, FALSE );
            AssignCommand( oBasher, ClearAllActions() );
            if ( iType == OBJECT_TYPE_DOOR )
                AssignCommand( oBashed, ActionOpenDoor( oBashed ) );
            else if ( iType == OBJECT_TYPE_PLACEABLE )
                AssignCommand( oBashed, ActionPlayAnimation( ANIMATION_PLACEABLE_OPEN ) );
        }
    }
}
