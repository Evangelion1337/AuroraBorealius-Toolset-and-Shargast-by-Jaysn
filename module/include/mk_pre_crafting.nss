#include "mk_inc_init"
#include "mk_inc_craft"
#include "mk_inc_body"
#include "mk_inc_generic"

int StartingConditional()
{
    MK_init();

    object oPC = GetPCSpeaker();

    CISetCurrentModItem(oPC, OBJECT_INVALID);
    CISetCurrentModBackup(oPC, OBJECT_INVALID);

    CISetCurrentModMode(oPC, X2_CI_MODMODE_INVALID);

    int bOk=FALSE;
    string sVarName;
    int i;
    for (i=1; i<=24; i++)
    {
    // 01-10: modify items (armor, helmet, cloak, shield, weapon)
    // !!! 02,04,06,08,10 are using the previous 01,03,05,07,09 calculation !!!
    // 11-17: modify body,
    // 19   : save/restore body
    // 20   : riding
    // 23   : character description
    // 24   : glowing eyes
        switch (i)
        {
        case 2:
        case 4:
        case 6:
        case 8:
        case 10:
            bOk = !bOk;
            break;
        case 21:
        case 22:
            bOk = FALSE;
            break;
        default:
            sVarName = "MK_DISABLE_CRAFT_" + MK_IntToString(i, 2, "0");
            bOk = (GetLocalInt(oPC, sVarName)!=1);

            if (bOk)
            {
                int nSlot=-1;
                switch (i)
                {
                case 1:
                    nSlot = INVENTORY_SLOT_CHEST;
                    break;
                case 3:
                    nSlot = INVENTORY_SLOT_HEAD;
                    break;
                case 5:
                    nSlot = INVENTORY_SLOT_CLOAK;
                    break;
                case 7:
                    nSlot = INVENTORY_SLOT_LEFTHAND;
                    break;
                case 9:
                    nSlot = INVENTORY_SLOT_RIGHTHAND;
                    break;
                }

                if (nSlot!=-1)
                {
                    object oItem = GetItemInSlot(nSlot, oPC);

                    bOk = MK_GetIsAllowedToModifyItem(oPC,oItem);

                    switch (i)
                    {
                    case 7:
                        bOk = bOk && MK_GetIsShield(oItem);
                        break;
                    case 9:
                        bOk = bOk && MK_GetIsModifiableWeapon(oItem)
                                  && (!IPGetIsIntelligentWeapon(oItem));
                        break;
                    }
                }
            }
            break;
        }
//        SendMessageToPC(oPC, "Bedingung "+IntToString(i)+" = "+IntToString(bOk));

        MK_GenericDialog_SetCondition(i, bOk);
    }

    return TRUE;
}
