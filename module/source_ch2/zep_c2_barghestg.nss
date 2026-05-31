//::///////////////////////////////////////////////
//:: Lycanthrope Change
//:: NW_C2_LYRAT_D
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Changes someone into a greater barghest when they are
    attacked.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 27, 2002
//:: Modified by: Eligio Sacataca for Barghest
//:://////////////////////////////////////////////

void main()
{
    // Make sure the were creature has a custom on spawn in with the line Custom User On Attacked being
    // commented in.  This becomes the Userdefined script.

    int nUser = GetUserDefinedEventNumber();

   // still needs this check otherwise it could spawn in multiple barghests if
    // attacked by multiple creatures at the same time.
    int nChange = GetLocalInt(OBJECT_SELF,"ZEP_BARGHESTFORM");

    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
    if(nUser == 1005 && nChange == 0)
    {
        // Get position and facing of Goblin and set spawn point for the Barghest
        vector vGoblin = GetPosition(OBJECT_SELF);
        float fAngle = GetFacing(OBJECT_SELF);
        location lBarghest;
        vector vChange;
        object oArea = GetArea(OBJECT_SELF);
        vChange.x = cos(fAngle) * 1.0;
        lBarghest = Location(oArea, vGoblin+vChange, fAngle);

        DelayCommand(0.9, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(OBJECT_SELF)));

        SetLocalInt(OBJECT_SELF, "ZEP_BARGHESTFORM", 1);

        // Spawn the Barghest
        CreateObject(OBJECT_TYPE_CREATURE,"zep_barghestg",lBarghest,FALSE);

        // Destroy the goblin
        DelayCommand(1.0, DestroyObject(OBJECT_SELF));
    }
}
