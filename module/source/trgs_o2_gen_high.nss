//::///////////////////////////////////////////////
//:: Treasure Respawn and Generation Script
//:: trgs_02_gen_low
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns consumables and gold of low value
    based on the module respawn settings.
*/
//:://////////////////////////////////////////////

#include "nw_o2_coninclude"
#include "trgs_i0_respawn"
#include "x2_inc_compon"

// To modify this script, simply change the values of DoTreasureGeneration.
// TREASURECLASS  = LOW|MEDIUM|HIGH
// TREASURETYPE   = DISPOSABLES|AMMUNITION|GOLD|EQUIPMENT
void main()
{
    craft_drop_placeable();
    DoTreasureGeneration( GetLastOpener(), OBJECT_SELF, HIGH, DISPOSABLES|GOLD );
    ShoutDisturbed();
}
