#include "mk_inc_generic"

#include "mk_inc_body"
#include "mk_inc_craft"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nAction = MK_GenericDialog_GetAction();
    //GetLocalInt(OBJECT_SELF, "MK_ACTION");

    switch (MK_GetBodyPartToBeModified(oPC))
    {
    case MK_CRAFTBODY_ERROR:
        if ((nAction>0) && (nAction<=MK_CRAFTBODY_NUMBER_OF_BODYPARTS))
        {
            // So the cancel script restores the body
            CISetCurrentModMode(oPC, MK_CI_MODMODE_BODY);

            MK_SetBodyPartToBeModified(oPC, nAction);
            MK_SaveBodyPart(oPC);

            switch (nAction)
            {
            case MK_CRAFTBODY_PORTRAIT:
                {
                    int nMaxCustomId = MK_GetMaxPortraitId(TRUE);
                    MK_GenericDialog_SetCondition(3,nMaxCustomId>0);
                    MK_GenericDialog_SetCondition(4,nMaxCustomId>0);
                }
                break;
            case MK_CRAFTBODY_HORSE:
                // Set custom tokens to special horse names
                MK_InitializeHorseSelection(oPC);
                break;
            case MK_CRAFTBODY_BODY:
                {
                    int nBodyPart;
                    for (nBodyPart=0; nBodyPart<=17; nBodyPart++)
                    {
                        int nMaxBodyPartID = MK_GetMaxBodyPartID(nBodyPart);
                        MK_GenericDialog_SetCondition(nBodyPart, nMaxBodyPartID>0);
                    }
                }
                break;
            }
        }
        else if (nAction==MK_CRAFTBODY_SAVERESTORE)
        {
            MK_SetBodyPartToBeModified(oPC, nAction);
            MK_SaveBody(oPC, 0);
        }
        break;
    case MK_CRAFTBODY_PORTRAIT:
        if ((nAction>=1) && (nAction<=4))
        {
            MK_NewPortrait(oPC, nAction);
            ClearAllActions();
            // So we have the proper portrait in the dialog as well
            ActionPauseConversation();
            ActionWait(GetLocalFloat(OBJECT_SELF, "MK_PORTRAIT_DELAY"));
            ActionResumeConversation();
        }
        break;
    case MK_CRAFTBODY_BODY:
        MK_SetSubPartToBeModified(oPC,
            GetLocalInt(OBJECT_SELF,"X2_TAILOR_CURRENT_PART"));
        break;
    case MK_CRAFTBODY_COLOR:
        if ((nAction>=10) && (nAction<=13))
        {
            MK_SetSubPartToBeModified(oPC, nAction-10);
        }
        break;
    case MK_CRAFTBODY_HORSE:
        {
            int nHorse=-1;
            switch (nAction)
            {
            case 3:
                nHorse = GetLocalInt(oPC, MK_VAR_CURRENT_HORSE);
                break;
            case 4:
                nHorse = MK_HORSE_1;
                break;
            case 5:
                nHorse = MK_HORSE_2;
                break;
            case 6:
                nHorse = MK_HORSE_3;
                break;
            case 7:
                nHorse = MK_HORSE_4;
                break;
            case 8:
                nHorse = MK_HORSE_5;
                break;
            case 20:
                nHorse = 0;
                break;
            }
            if (nHorse!=-1)
            {
                MK_CreatureMountHorse(oPC,nHorse);
            }
        }
        break;
    case MK_CRAFTBODY_SAVERESTORE:
        if ((nAction>=1) && (nAction<=10))
        {
            // Save Body
            MK_SaveBody(oPC, nAction);
        }
        else if ((nAction>=11) && (nAction<=20))
        {
            // Restore Body
            MK_RestoreBody(oPC, nAction-10);
        }
        break;
    }

    int bIsModified = MK_GetIsBodyModified(oPC);

    switch (MK_GetBodyPartToBeModified(oPC))
    {
    case MK_CRAFTBODY_SAVERESTORE:
        {
            int bUsedAny=FALSE;
            int nSlot;
            for (nSlot=1; nSlot<=MK_CRAFTBODY_NUMBER_OF_SLOTS; nSlot++)
            {
                int bUsed = MK_GetIsUsedSaveBodySlot(oPC, nSlot);
                bUsedAny = bUsedAny || bUsed;
                MK_GenericDialog_SetCondition(nSlot, !bUsed);
                MK_GenericDialog_SetCondition(10+nSlot, bUsed);
            }
            MK_GenericDialog_SetCondition(0, bUsedAny);
            MK_GenericDialog_SetCondition(22, !bIsModified);
        }
        break;
    case MK_CRAFTBODY_HORSE:
        {
            int bIsRiding = MK_GetIsRiding(oPC);
            int nCurrentHorse = GetLocalInt(oPC, MK_VAR_CURRENT_HORSE);
            int nHorse = GetCreatureTailType(oPC);
            MK_GenericDialog_SetCondition(1, bIsRiding);
            MK_GenericDialog_SetCondition(2, bIsRiding);
            MK_GenericDialog_SetCondition(3, (nCurrentHorse!=0) && (nHorse!=nCurrentHorse));
            MK_GenericDialog_SetCondition(4, (nCurrentHorse!=MK_HORSE_1) && (nHorse!=MK_HORSE_1));
            MK_GenericDialog_SetCondition(5, (nCurrentHorse!=MK_HORSE_2) && (nHorse!=MK_HORSE_2));
            MK_GenericDialog_SetCondition(6, (nCurrentHorse!=MK_HORSE_3) && (nHorse!=MK_HORSE_3));
            MK_GenericDialog_SetCondition(7, (nCurrentHorse!=MK_HORSE_4) && (nHorse!=MK_HORSE_4));
            MK_GenericDialog_SetCondition(8, (nCurrentHorse!=MK_HORSE_5) && (nHorse!=MK_HORSE_5));
            MK_GenericDialog_SetCondition(20, bIsRiding);
        }
        MK_SetBodyPartTokens(oPC);
        break;
    default:
        MK_SetBodyPartTokens(oPC);
        break;
    }

    MK_GenericDialog_SetCondition(21,
        (bIsModified ? 1 : 0) );

    return TRUE;
}
