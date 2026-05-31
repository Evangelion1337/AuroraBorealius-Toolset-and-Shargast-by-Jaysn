//::///////////////////////////////////////////////
//:: Scarface's Socketed Items
//:: V2.4
//:: sf_sockets
//:://////////////////////////////////////////////
/*
    Written By Scarface
*/
//////////////////////////////////////////////////

#include "x2_inc_switches"
#include "sf_socket_inc"

void main() {

    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE) { return; }

    object oPC = GetItemActivator();
    object oTarget = GetItemActivatedTarget();
    object oActivated = GetItemActivated();

    if (GetIsInCombat(oPC)) {

        FloatingTextStringOnCreature("You can not use this item while in combat.", oPC);
        Repel(oPC);
        return;
    }
    if (SF_GetIsItemActivatedValid(oActivated)) {

        SF_GetHasSockets(oPC, oActivated);
        return;
    }
    if (GetItemPossessor(oTarget) != oPC) {

        FloatingTextStringOnCreature("The targeted item is not in your possession.", oPC);
        Repel(oPC);
        return;
    }

    if (GetTag(oTarget) != "sf_socket_item") {

        FloatingTextStringOnCreature("The targeted item can not be socketed.", oPC);
        Repel(oPC);
        return;
    }

    if (!SF_GetIsItemActivatedValid(oTarget)) {

        FloatingTextStringOnCreature("Invalid target.", oPC);
        Repel(oPC);
        return;
    }

    SF_SocketGemToItem(oPC, oTarget, oActivated);
}

