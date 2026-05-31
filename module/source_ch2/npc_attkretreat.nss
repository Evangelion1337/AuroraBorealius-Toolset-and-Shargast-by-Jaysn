void main()
{
object oPC = GetLastPerceived();
object oNPC = OBJECT_SELF;
object oWP = GetWaypointByTag("WP_RUN_" + GetTag(oNPC)); //This is the waypoint the NPC will run to. The waypoint must be tagged "WP_RUN_TagOfNPC".
location lHome = GetLocation(oWP);
int nLevel = 5; //Put the level of the PC here. If the PC is equal or above this level, the NPC runs.

    if (GetTag(GetArea(oPC)) == "TagOfPrivateArea") //If the PC is in the area tagged, the NPC acts.
    {
        if (GetIsPC(oPC))
        {
            if (GetLevelByPosition(1, oPC) >= nLevel ||
                GetLevelByPosition(2, oPC) >= nLevel ||
                GetLevelByPosition(3, oPC) >= nLevel)
            {
            AssignCommand(oNPC, ClearAllActions());
            DelayCommand(0.2, AssignCommand(oNPC, ActionSpeakString("Help! Bandits!")));
            DelayCommand(0.1, AssignCommand(oNPC, ActionMoveToLocation(lHome, TRUE)));
            }
            else
            {
            DelayCommand(0.2, AssignCommand(oNPC, ActionSpeakString("Die thief!")));
            DelayCommand(0.1, AssignCommand(oNPC, ActionAttack(oPC)));
            }
        }
    }
}

