//::///////////////////////////////////////////////
//:: Debug Command include
//:: prc_inc_chat_pow.nss
//::///////////////////////////////////////////////

/*
Command summary:

~~pow [value]
    Set Power Attack to the specified value
[value can be 0-5 for Power Attack, 0-24 for Improved Power Attack]

~~pow [value] [q1|q2|q3] 
    Set Power Attack for the specified quickslot to the specified value
[value can be 0-5 for Power Attack, 0-24 for Improved Power Attack]
*/

#include "prc_inc_chat"
#include "inc_persist_loca"

const string CMD_POWER_ATTACK = "pow-erattack";

const string QS1_VAR_NAME = "PRC_PowerAttackQuickselect_2797";
const string QS2_VAR_NAME = "PRC_PowerAttackQuickselect_2798";
const string QS3_VAR_NAME = "PRC_PowerAttackQuickselect_2799";

int PowerAttack_ProcessChatCommand_Help(object oPC, string sCommand)
{
    string sCommandName = GetStringWord(sCommand, 2);
    int nLevel = sCommandName != "";
    int bResult = FALSE;

    if (!nLevel)
    {
        HelpText(oPC, "=== PRC POWER ATTACK COMMANDS");
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_POWER_ATTACK) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== POWER ATTACK COMMAND: " + CMD_POWER_ATTACK);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_POWER_ATTACK + " <ONE:q1|q2|q3>");
        if (nLevel)
            HelpText(oPC, "   Prints the current setting for the specified quickslot.");
        HelpText(oPC, "~~" + CMD_POWER_ATTACK + " <ONE:q1|q2|q3> <value>");
        if (nLevel)
            HelpText(oPC, "   Set the specified quickslot to the given value.");
        HelpText(oPC, "");
    }
    
    //TODO: add a command to set the power attack value correctly without the quickslot
    //To work correctly with the existing power attack code, the effects need to be added within a spell so that the 
    //spell id can be recorded and later used to remove them.
    
    return bResult;
}

int PowerAttack_ProcessChatCommand(object oPC, string sCommand)
{
    int bResult = FALSE;
    
    string sCommandName = GetStringWord(sCommand, 1);
    string sNewValue = GetStringWord(sCommand, 2);
    int nNewValue = StringToInt(sNewValue);

    if(GetStringMatchesAbbreviation(sCommandName, CMD_POWER_ATTACK))
    {
        bResult = TRUE;

        string sQuickslot = GetStringWord(sCommand, 2);
        string sNewValue = GetStringWord(sCommand, 3);
        if (sNewValue == "")
        {
            if (sQuickslot == "q1")
                HelpText(oPC, "Power Attack Quickslot 1: " + IntToString(GetPersistantLocalInt(oPC, QS1_VAR_NAME)));
            else if (sQuickslot == "q2")
                HelpText(oPC, "Power Attack Quickslot 2: " + IntToString(GetPersistantLocalInt(oPC, QS2_VAR_NAME)));
            else if (sQuickslot == "q3")
                HelpText(oPC, "Power Attack Quickslot 3: " + IntToString(GetPersistantLocalInt(oPC, QS3_VAR_NAME)));
            else
                HelpText(oPC, "Invalid Power Attack Quickslot Number: " + sQuickslot);
        }
        else
        {
            int nNewValue = StringToInt(sNewValue);
            if (sNewValue != IntToString(nNewValue))
                HelpText(oPC, "Power Attack value is not a number: " + sNewValue);
            else if (nNewValue < 0)
                HelpText(oPC, "Value is too small for Power Attack: " + sNewValue);
            else if (!GetHasFeat(FEAT_POWER_ATTACK, oPC))
                HelpText(oPC, "Power Attack feat required for value: " + sNewValue);
            else if (nNewValue > 5 && !GetHasFeat(FEAT_IMPROVED_POWER_ATTACK, oPC))
                HelpText(oPC, "Improved Power Attack feat required for value: " + sNewValue);
            else if (nNewValue > 24)
                HelpText(oPC, "Value is too large for Improved Power Attack: " + sNewValue);
            else
            {
                if (sQuickslot == "q1")
                {
                    SetPersistantLocalInt(oPC, QS1_VAR_NAME, nNewValue);
                    HelpText(oPC, "Power Attack Quickslot 1 set to: " + IntToString(nNewValue));
                }
                else if (sQuickslot == "q2")
                {
                    SetPersistantLocalInt(oPC, QS2_VAR_NAME, nNewValue);
                    HelpText(oPC, "Power Attack Quickslot 2 set to: " + IntToString(nNewValue));
                }
                else if (sQuickslot == "q3")
                {
                    SetPersistantLocalInt(oPC, QS3_VAR_NAME, nNewValue);
                    HelpText(oPC, "Power Attack Quickslot 3 set to: " + IntToString(nNewValue));
                }
                else
                    HelpText(oPC, "Invalid Power Attack Quickslot Number: " + sQuickslot);
            }
        }
    }

    return bResult;
}
