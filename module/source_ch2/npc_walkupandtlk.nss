void main()
{
        object oPC = GetEnteringObject();

        // replace this tag string with the tag string of your NPC.
        object oNPC = GetNearestObjectByTag("NPC_Tag_goes_here");

        // make sure we found the NPC.  May be dead, etc.
        if (GetIsObjectValid(oNPC)) {

                // check to make sure NPC isn't already talking to somebody.
                if (!IsInConversation(oNPC)) {

                        // stop whatever we were already doing.
                        AssignCommand(oNPC, ClearAllActions());

                        // walk NPC to the PC.  If you want NPC to run change FALSE to TRUE.
                        AssignCommand(oNPC, ActionMoveToObject(oPC, FALSE));
                        // start talking to PC.
                        AssignCommand(oNPC, ActionStartConversation(oPC));
                }
        }

        // if you want this script to only run the first time anybody
        // sets it off, uncomment the line below:
        //DestroyObject(OBJECT_SELF);
}

