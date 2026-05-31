//
//  NWSit
//
//  Script to make the PC using the object sit on it.
//
//  (c) Shir'le E. Illios, 2002 (shirle@drowwanderer.com)
//
////////////////////////////////////////////////////////

void main()
{

    // Get the character using the object.
    object oPlayer = GetLastUsedBy();

    // Make certain that the character is a PC.
    if( GetIsPC( oPlayer ) )
    {

        // Get the object being sat on.
        object oChair = OBJECT_SELF;

        // If the object is valid and nobody else is currently sitting on it.
        if( GetIsObjectValid( oChair ) &&
            !GetIsObjectValid( GetSittingCreature( oChair ) ) )
        {
            // Let the player sit on the object.
            AssignCommand( oPlayer, ActionSit( oChair ) );
        }

    } // End if

} // End main

