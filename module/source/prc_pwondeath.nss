//:://////////////////////////////////////////////////
//:: prc_pwondeath
/*
	PRC's onDeath catch-all.
*/
//:://////////////////////////////////////////////////
#include "se_drop_weapons"
#include "se_respawn_inc"
#include "_kb_loot_corpse"

void main()
{
    SE_DoCreatureRespawn();
	
    SE_DropHandSlot(OBJECT_SELF,INVENTORY_SLOT_LEFTHAND,180.0,TRUE);
    SE_DropHandSlot(OBJECT_SELF,INVENTORY_SLOT_RIGHTHAND,180.0,TRUE);

//--------Scarface's XP System.
   ExecuteScript("sf_xp", OBJECT_SELF);
//--------End

    LeaveCorpse();
}