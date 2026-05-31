//::///////////////////////////////////////////////
//:: FileName at_005
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 9/6/2004 8:44:01 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

void main()
{
    object oPC = GetPCSpeaker();

    object oItem;
    oItem = GetItemPossessedBy(oPC, "GrizzleyQuartz");

    if (GetIsObjectValid(oItem))
    DestroyObject(oItem);

    // Give the speaker some gold
    RewardPartyGP(150, GetPCSpeaker());

    // Give the speaker some XP
    RewardPartyXP(150, GetPCSpeaker());

    // Give the speaker the items
    CreateItemOnObject("biagokey", GetPCSpeaker(), 1);

}







