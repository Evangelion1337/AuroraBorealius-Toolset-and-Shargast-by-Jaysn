//::///////////////////////////////////////////////
//:: Sir Elric's Simple Creature Respawns - SE v1.6
//:: FileName - se_respawn_inc
//::///////////////////////////////////////////////
//:: Place any creatures from the stock or custom palette in your world.
//:: They will respawn in that exact location & wander around the area.
//:: Respawn timer set by default to 300.0f (5 mins)
//:: Adjust the timer at line 64 of se_respawn_inc
//:: Your all done, simple.
//::///////////////////////////////////////////////
//:: Tagged creatures with _NSP will not respawn eg. NW_GOBLINA_NSP
//:: Encounter creatures will not respawn - SE v1.4
//:://////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 17th February, 2004 SE v1.1
//:: Updated On: 3rd November, 2004 SE v1.6
//:://////////////////////////////////////////////

//::///////////////////////////////////////////////
//:: INSTRUCTIONS FOR FUTURE BW PATCH RELEASES ie: 1.65 and beyond.
//::///////////////////////////////////////////////
/* After a BW patch should the default nw_c2_ scripts need updating,
   to add system back in simple as 1,2,3.

Delete the old - NW_C2_DEFAULT7, NW_C2_DEFAULT9, NW_C2_HERBIVORE, & NW_C2_OMNIVORE then open the new scripts.

1. Add this include file(approx at line 17) to NW_C2_DEFAULT7
   ie. #include "se_respawn_inc"

2. Add these lines(approx at line 44) to NW_C2_DEFAULT7 -
     // Do not respawn creature if tagged with _NSP eg. NW_GOBLINA_NSP
    if (FindSubString(GetTag(OBJECT_SELF), "NSP") > -1)
    return;
    { SE_DoCreatureRespawn(); }

3. Add this line(approx at line 298,74 & 74 respectively) to NW_C2_DEFAULT9, NW_C2_HERBIVORE, & NW_C2_OMNIVORE -
   SetLocalLocation(OBJECT_SELF, "spawn", GetLocation(OBJECT_SELF));

3a.   *** Optional ***
   To set creatures to wander, open NW_C2_DEFAULT9, uncomment:
   Line 119 - SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
   Line 148 - SetAnimationCondition(NW_ANIM_FLAG_CONSTANT);

*/

void SE_RespawnObject(int nType, string sResRef, location lLoc, string sNewTag)
{
  CreateObject(nType, sResRef, lLoc, FALSE, sNewTag);
}

void SE_DoCreatureRespawn()
{
  location lLoc;
  float fFacing;
  int iEncounter = GetIsEncounterCreature(OBJECT_SELF);
  if(iEncounter)//Encounter creatures will not respawn - SE v1.4
  return;
  int nType = GetObjectType(OBJECT_SELF);
  string sRef = GetResRef(OBJECT_SELF);
  string sTag = GetTag(OBJECT_SELF);

        lLoc = GetLocalLocation(OBJECT_SELF, "spawn");
        if (GetIsObjectValid(GetAreaFromLocation(lLoc)))
          { DeleteLocalInt(OBJECT_SELF, "spawn"); }
        else
          { lLoc = GetLocation(OBJECT_SELF); }
        fFacing = GetFacing(OBJECT_SELF);
// *** SET RESPAWN TIMER IN SECONDS ie: 300 = 5 minutes ***//
  float fDelay = 600.0f;
//float fDelay = d100(10) + 300.0f;//Example for a random timer
  AssignCommand(GetModule(), DelayCommand(fDelay, SE_RespawnObject(nType, sRef, lLoc, sTag)));
}

/*void main()
{}*/
