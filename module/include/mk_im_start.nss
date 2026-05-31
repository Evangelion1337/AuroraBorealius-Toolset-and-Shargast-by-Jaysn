#include "mk_inc_craft"
#include "mk_inc_generic"

int StartingConditional()
{
    int nAction = MK_GenericDialog_GetAction(TRUE);

    object oPC = GetPCSpeaker();

    float fFacing = GetFacing(oPC);
    float fDistance = 3.5f;
    float fPitch = 75.0f;

//    string sToken="";

    switch (nAction)
    {
    case X2_CI_MODMODE_ARMOR:
        fFacing += 180.0;
//        sToken = "armor";
        break;
    case X2_CI_MODMODE_WEAPON:
        fFacing += 90.0;
//        sToken = "weapon";
        break;
    case MK_CI_MODMODE_CLOAK:
        fFacing += 315.0;
//        sToken = "cloak";
        break;
    case MK_CI_MODMODE_HELMET:
        fFacing += 180.0;
//        sToken = "helmet";
        break;
    case MK_CI_MODMODE_SHIELD:
        fFacing += 180.0;
 //       sToken = "shield";
        break;
    default:
        return FALSE;
    }

    CISetCurrentModMode(oPC, nAction);

    StoreCameraFacing();
    if (fFacing > 359.0)
    {
        fFacing -=359.0;
    }
    SetCameraFacing(fFacing, fDistance, fPitch, CAMERA_TRANSITION_TYPE_FAST);

    int nSlot = MK_GetCurrentInventorySlot(oPC);
    object oItem = GetItemInSlot(nSlot, oPC);
    object oBackup = MK_CopyItem(oItem,IPGetIPWorkContainer(),TRUE);
    CISetCurrentModBackup(oPC, oBackup);
    CISetCurrentModItem(oPC, oItem);

//    SendMessageToPC(oPC, "Backup: "+GetDescription(oBackup));
//    SendMessageToPC(oPC, "Item  : "+GetDescription(oItem));

//    SetCustomToken(MK_TOKEN_COPYFROM, sToken);

    MK_GenericDialog_CleanUp();

    MK_GenericDialog_SetCondition(22, GetLocalInt(oPC, "MK_ENABLE_RENAME_ITEMS"));
    MK_GenericDialog_SetCondition(23, GetLocalInt(oPC, "MK_ENABLE_EDIT_DESCRIPTION"));

    //* TODO: Light model to make changes easier to see
    effect eLight = EffectVisualEffect( VFX_DUR_LIGHT_WHITE_20);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eLight,oPC);

    //* Immobilize player while crafting
    effect eImmob = EffectCutsceneImmobilize();
    eImmob = ExtraordinaryEffect(eImmob);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eImmob,oPC);

    MK_SetCustomTokenByItemTypeName(oPC);

    return TRUE;
}
