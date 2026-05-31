void main()
{

    object oPC = GetFirstPC();				// The variable oPC = the first PC in the party
    location lLocation = GetLocation(oPC);		// This gets oPC's location
    object FilcherJump = GetObjectByTag("Filcher");	// This gets the waypoint or the Filcher to jump to after he steals


    int randomizer = d6(1);				// The variable randomizer = the roll of 1d4

    if (randomizer == 6)				// If the d4 = 4
    {

        CreateObject(OBJECT_TYPE_CREATURE, "etherealfilcher", lLocation, TRUE);		// Create a Filcher with the resref "etherealfilcher"

        object oFilcher = GetObjectByTag("EtherealFilcher");				// Assign the Ethereal Filcher to the variable oFilcher

        AssignCommand(oFilcher, TakeGoldFromCreature(50, GetFirstPC(), FALSE));	// Make the filcher steal some gold from the first PC

        AssignCommand(oFilcher, ActionJumpToObject(FilcherJump, TRUE));			// Make the Filcher jump to the waypoint contained in FilcherJump

        AssignCommand(oPC, SpeakString("An Ethereal Filcher has stolen your gold!", TALKVOLUME_TALK));		// Put a one-liner string on top of the player's head notifying them that they've been robbed

    }
}
