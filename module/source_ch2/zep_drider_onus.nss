//::///////////////////////////////////////////////
//:: NW_C2_DIMDOOR.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
     Creature randomly hops around
     to enemies during combat.
*/
//:://////////////////////////////////////////////
//:: Created By:  Brent
//:: Created On:  January 2002
//:://////////////////////////////////////////////
//:: Renamed drider_onuserdef 02/24/03 for Drider Demo v1.0
//:: Modified By Luna_C with invaluable help from Tallihnn on the Bioware scripting forum.
//:: Be sure to use this with the drider_spawn script in the onspawn script slot!
//:://////////////////////////////////////////////
void JumpToWeakestEnemy(object oTargetVictim)
{
     object oTargetVictim = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    location lTargetVictim = GetLocation((oTargetVictim));
    // * won't jump if closer than 4 meters to victim
    if ((GetDistanceToObject(oTargetVictim) > 4.0)   && (GetObjectSeen(oTargetVictim) == TRUE))
    {
        ClearAllActions();
        effect eVis = EffectDisappearAppear (lTargetVictim);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, OBJECT_SELF, 2.0);
        DelayCommand(2.5,ActionAttack(oTargetVictim));
    }
}
void main()
{
    // * During Combat try teleporting around
    if (GetUserDefinedEventNumber() == 1003)
    {
        // * if random OR heavily wounded then teleport to next enemy
        if ((Random(100) < 50)  ||  ( (GetCurrentHitPoints() / GetMaxHitPoints()) * 100 < 50) )
        {
           JumpToWeakestEnemy(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY));
        }
    }
}

