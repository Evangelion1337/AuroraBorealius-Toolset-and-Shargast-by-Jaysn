//::///////////////////////////////////////////////
//:: Debug Command include
//:: prc_inc_chat_dm.nss
//::///////////////////////////////////////////////

#include "prc_alterations"
#include "prc_inc_chat"
#include "prc_inc_shifting" //For _prc_inc_EffectString, etc.
#include "prc_inc_util"
#include "psi_inc_ppoints"
/*
execute
setlocalvar
dellocalvar

set
  xp
  level
  gold
  abil
  skill
  
mod
  xp
  gold
  abilit
  skill
  
*/
const string CMD_CHK_PP   = "checkp-owerpoints";
const string CMD_CHK_SS   = "checks-pellslots";

const string CMD_EXECUTE  = "dm_exec-ute";
const string CMD_VARIABLE = "dm_var-iable";
    const string CMD_PC         = "pc";
    const string CMD_MODULE     = "mod-ule";
    const string CMD_LOCAL      = "loc-al";
    const string CMD_PERSISTANT = "per-sistant";

const string CMD_INFORMATION = "dm_info-rmation";
    const string CMD_ABILITIES   = "abil-ities";
    const string CMD_EFFECTS     = "eff-ects";
    const string CMD_PROPERTIES  = "prop-erties";
    const string CMD_SKILLS      = "skil-ls";

const string CMD_CHANGE = "dm_change";
    const string CMD_ABILITY = "abil-ity";
        const string CMD_STR = "str-ength";
        const string CMD_DEX = "dex-terity";
        const string CMD_CON = "con-stitution";
        const string CMD_INT = "int-elligence";
        const string CMD_WIS = "wis-dom";
        const string CMD_CHA = "cha-risma";
    const string CMD_LEVEL = "level";
    const string CMD_XP = "xp";
    const string CMD_GOLD = "gold";
    const string CMD_BY = "by";
    const string CMD_TO = "to";

const string CMD_SPAWN = "dm_spawn";
    const string CMD_CREATURE = "creature";
    const string CMD_ITEM = "item";

const string CMD_RELEVEL = "dm_relevel";

const string CMD_SPECIAL = "dm_special";
    const string CMD_REST = "rest";
    const string CMD_HANDLE_FORCE_REST_1 = "handle";
    const string CMD_HANDLE_FORCE_REST_2 = "force-d";
    const string CMD_HANDLE_FORCE_REST_3 = "rest-ing";

int Debug_ProcessChatCommand_Help(object oPC, string sCommand)
{
    string sCommandName = GetStringWord(sCommand, 2);
    int nLevel = sCommandName != "";
    int bResult = FALSE;

    if(!nLevel)
    {
        HelpText(oPC, "=== DM COMMANDS");
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_EXECUTE) || !nLevel)
    {
        if(nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_EXECUTE);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_EXECUTE + " <script-name>");
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_VARIABLE) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_VARIABLE);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_VARIABLE + " <optional:target> <optional:duration> <type> get <varname>");
        if (nLevel)
            HelpText(oPC, "   Print the value of the specified local variable");
        HelpText(oPC, "~~" + CMD_VARIABLE + " <optional:target> <optional:duration> <type> set <varname> <value>");
        if (nLevel)
        {
            HelpText(oPC, "   Set the value of the specified local variable and print the old value");
            HelpText(oPC, "   <target> can be one of: " + CMD_PC + ", " + CMD_MODULE + " (default:" + CMD_PC + " )");
            HelpText(oPC, "   <duration> can be one of: " + CMD_LOCAL + ", " + CMD_PERSISTANT + " (default: " + CMD_LOCAL + ")");
            HelpText(oPC, "   <type> can be one of: int, string");
        }
        HelpText(oPC, "");
    }
        
    if(GetStringMatchesAbbreviation(sCommandName, CMD_INFORMATION) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_INFORMATION);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_INFORMATION + " " + CMD_ABILITIES);
        if (nLevel)
            HelpText(oPC, "   Print the STR, DEX, CON, INT, WIS, and CHA of the PC");
        HelpText(oPC, "~~" + CMD_INFORMATION + " " + CMD_EFFECTS);
        if (nLevel)
            HelpText(oPC, "   Print all effects that have been applied to the PC");
        HelpText(oPC, "~~" + CMD_INFORMATION + " " + CMD_PROPERTIES);
        if (nLevel)
            HelpText(oPC, "   Print the item properties of all items the PC has equipped");
        HelpText(oPC, "~~" + CMD_INFORMATION + " " + CMD_SKILLS);
        if (nLevel)
            HelpText(oPC, "   Print the number of ranks that the PC has in each skill");
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_CHANGE) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_CHANGE + " <what> <ONE:to|by> <value>");
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_LEVEL + " " + CMD_TO + " <value>");
        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_LEVEL + " " + CMD_BY + " <amount>");
        if (nLevel)
        {
            HelpText(oPC, "   Adjust the PC's level as specified (must be 1-40)");
        }
        HelpText(oPC, "");

        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_XP + " " + CMD_TO + " <value>");
        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_XP + " " + CMD_BY + " <amount>");
        if (nLevel)
        {
            HelpText(oPC, "   Adjust the PC's XP as specified");
        }
        HelpText(oPC, "");

        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_GOLD + " " + CMD_TO + " <value>");
        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_GOLD + " " + CMD_BY + " <amount>");
        if (nLevel)
        {
            HelpText(oPC, "   Adjust the PC's gold as specified");
        }
        HelpText(oPC, "");
    
        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_ABILITY + " <ability-name> " + CMD_TO + " <value>     (requires NWNX funcs)");
        HelpText(oPC, "~~" + CMD_CHANGE + " " + CMD_ABILITY + " <ability-name> " + CMD_BY + " <value>     (requires NWNX funcs)");
        if (nLevel)
        {
            HelpText(oPC, "   Adjust the PC's abilities as specified");
            HelpText(oPC, "   <ability-name> can be: " + CMD_STR + ", " + CMD_DEX + ", " + CMD_CON + ", " + CMD_INT + ", " + CMD_WIS + ", or " + CMD_CHA);
        }
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_SPAWN) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_SPAWN);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_SPAWN + " " + CMD_CREATURE + " <resref>");
        if (nLevel)
        {
            HelpText(oPC, "   Spawn the specified creature in the same location as the PC.");
            HelpText(oPC, "   It will be treated as a summoned creature--i.e., under the PC's control.");
        }

        HelpText(oPC, "~~" + CMD_SPAWN + " " + CMD_ITEM + " <resref>");
        if (nLevel)
        {
            HelpText(oPC, "   Spawn the specified item in the same location as the PC");
            HelpText(oPC, "   Use: ~~" + CMD_SPAWN + " " + CMD_ITEM + "prc_target to spawn chat command target widget.");
        }
        
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_RELEVEL) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_RELEVEL + " <level>");
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_RELEVEL + " <level>");
        if (nLevel)
        {
            HelpText(oPC, "   Relevel the PC starting from the specified level.");
            HelpText(oPC, "   The final result is a PC with exactly the same XP as before,");
            HelpText(oPC, "   but with the feats, skills, etc. reselected starting with the specified level.");
        }
        HelpText(oPC, "");
    }
        
    if(GetStringMatchesAbbreviation(sCommandName, CMD_SPECIAL) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== DM COMMAND: " + CMD_SPECIAL);
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_SPECIAL + " " + CMD_REST);
        if (nLevel)
        {
            HelpText(oPC, "   Instantly rest the PC");
        }

        HelpText(oPC, "~~" + CMD_SPECIAL + " " + CMD_HANDLE_FORCE_REST_1 + " " + CMD_HANDLE_FORCE_REST_2 + " " + CMD_HANDLE_FORCE_REST_3);
        if (nLevel)
        {
            HelpText(oPC, "   Tell PRC that the module force rests PCs.");
            HelpText(oPC, "   Forced resting restores feat uses and spell uses for Bioware spellbooks,");
            HelpText(oPC, "   but does not restore spell uses for PRC conversation-based spellbooks,");
            HelpText(oPC, "   and may cause problems with some other PRC features.");
            HelpText(oPC, "   Start a detector that detects forced resting and fixes");
            HelpText(oPC, "   these issues automatically.");
        }
        HelpText(oPC, "");
    }
    
    return bResult;
}

void _prc_inc_DoLocalVar(object oTarget, object oPC, string sCommand, int nNextArg)
{
    string sDataType = GetStringWord(sCommand, nNextArg++);

    string sCommandName = GetStringWord(sCommand, nNextArg++);
    if (sCommandName != "get" && sCommandName != "set")
    {
        DoDebug("Unrecognized command (expected 'get' or 'set'): " + sCommandName);
        return;
    }

    string sVarName = GetStringWord(sCommand, nNextArg++);
    if (sVarName == "")
    {
        DoDebug("Invalid variable name: '" + sCommandName + "'");
        return;
    }

    string sVarValue = GetStringWordToEnd(sCommand, nNextArg);

    if (sDataType == "string")
    {
        string sValue = GetLocalString(oTarget, sVarName);
        DoDebug("Value: '" + sValue + "'");
        if (sCommandName == "set")
        {
            SetLocalString(oTarget, sVarName, sVarValue);
            DoDebug("New Value: '" + sVarValue + "'");
        }
    }
    else if (sDataType == "int")
    {
        int nValue = GetLocalInt(oTarget, sVarName);
        DoDebug("Value: " + IntToString(nValue));
        if (sCommandName == "set")
        {
            if(DEBUG || GetIsDM(oPC))
            {
                int nVarValue = StringToInt(sVarValue);
                if (sVarValue == IntToString(nVarValue))
                {
                    SetLocalInt(oTarget, sVarName, nVarValue);
                    DoDebug("New Value: " + sVarValue);
                }
                else
                    DoDebug("Can't set integer variable to non-integer value: " +sVarValue);
            }
            else
                DoDebug("This command only works if DEBUG = TRUE");
        }
    }
    else
    {
        DoDebug("Unrecognized data type: " + sDataType);
    }
}

void _prc_inc_DoPersistantVar(object oTarget, object oPC, string sCommand, int nNextArg)
{
    string sDataType = GetStringWord(sCommand, nNextArg++);

    string sCommandName = GetStringWord(sCommand, nNextArg++);
    if (sCommandName != "get" && sCommandName != "set")
    {
        DoDebug("Unrecognized command (expected 'get' or 'set'): " + sCommandName);
        return;
    }

    string sVarName = GetStringWord(sCommand, nNextArg++);
    if (sVarName == "")
    {
        DoDebug("Invalid variable name: '" + sCommandName + "'");
        return;
    }

    string sVarValue = GetStringWordToEnd(sCommand, nNextArg++);

    if (sDataType == "string")
    {
        string sValue = GetPersistantLocalString(oTarget, sVarName);
        DoDebug("Value: '" + sValue + "'");
        if (sCommandName == "set")
            SetPersistantLocalString(oTarget, sVarName, sVarValue);
    }
    else if (sDataType == "int")
    {
        int nValue = GetPersistantLocalInt(oTarget, sVarName);
        DoDebug("Value: " + IntToString(nValue));
        if (sCommandName == "set")
        {
            if(DEBUG || GetIsDM(oPC))
            {
                int nVarValue = StringToInt(sVarValue);
                if (sVarValue == IntToString(nVarValue))
                    SetPersistantLocalInt(oTarget, sVarName, nVarValue);
                else
                    DoDebug("Can't set integer variable to non-integer value: " +sVarValue);
            }
            else
                DoDebug("This command only works if DEBUG = TRUE");
        }
    }
    else
    {
        DoDebug("Unrecognized data type: " + sDataType);
    }
}

void _prc_inc_DumpItemProperty(string sPrefix, itemproperty iProp, object oPC)
{
    int nDurationType = GetItemPropertyDurationType(iProp);
    string sPropString = _prc_inc_ItemPropertyString(iProp);
    if(sPropString != "")
    {
        if (nDurationType == DURATION_TYPE_TEMPORARY)
            sPropString = GetStringByStrRef(57473+0x01000000) + sPropString; //"TEMPORARY: "
        DoDebug(sPrefix + sPropString);
    }
}

void _prc_inc_DumpAllItemProperties(string sPrefix, object oItem, object oPC)
{
    if(GetIsObjectValid(oItem))
    {
        itemproperty iProp = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(iProp))
        {
            _prc_inc_DumpItemProperty(sPrefix, iProp, oPC);
            iProp = GetNextItemProperty(oItem);
        }
    }
}

int _prc_inc_XPToLevel(int nXP)
{
    float fXP = IntToFloat(nXP);
    float fLevel = (sqrt(8 * fXP / 1000 + 1) + 1) / 2;
    return FloatToInt(fLevel);
}

int _prc_inc_LevelToXP(int nLevel)
{
    return (nLevel * (nLevel - 1)) * 500;
}

void DoPrintSummon(object oPC, string sResRef)
{
    object oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
    if (GetIsObjectValid(oCreature))
        HelpText(oPC, "Created creature: " + GetName(oCreature));
    else
        HelpText(oPC, "Failed to create creature--invalid resref?: " + sResRef);
}

void DoSummon(object oPC, string sResRef)
{
    effect eSummon = EffectSummonCreature(sResRef);
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eSummon, GetLocation(oPC));
    AssignCommand(oPC, DoPrintSummon(oPC, sResRef));
}

int Debug_ProcessChatCommand(object oPC, string sCommand)
{
    string sCommandName = GetStringWord(sCommand, 1);
    int bResult = FALSE;
    object oTarget = GetLocalObject(oPC, "prc_chatcmd_target");
    if(!GetIsObjectValid(oTarget))
        oTarget = oPC;


    //Handle the commands we recognize no matter what, but only execute them if DEBUG is TRUE
    if(GetStringMatchesAbbreviation(sCommandName, CMD_EXECUTE))
    {
        bResult = TRUE;
        if (DEBUG || GetIsDM(oPC))
        {
            string sScript = GetStringWord(sCommand, 2);
            HelpText(oPC, "Executing script: " + sScript);
            ExecuteScript(sScript, oTarget);
        }
        else
            HelpText(oPC, "This command only works if DEBUG = TRUE");
    }
    else if (GetStringMatchesAbbreviation(sCommandName, CMD_VARIABLE))
    {
        bResult = TRUE;
        int nNextArg = 2;
        string sVarType = GetStringWord(sCommand, nNextArg++);
        if(GetStringMatchesAbbreviation(sVarType, CMD_MODULE))
        {
            sVarType = GetStringWord(sCommand, nNextArg++);
            oTarget = GetModule();
        }
        else if(GetStringMatchesAbbreviation(sVarType, CMD_PC))
        {
            sVarType = GetStringWord(sCommand, nNextArg++);
            oTarget = oPC;
        }

        if(GetStringMatchesAbbreviation(sVarType, CMD_LOCAL))
            _prc_inc_DoLocalVar(oTarget, oPC, sCommand, nNextArg);
        else if(GetStringMatchesAbbreviation(sVarType, CMD_PERSISTANT))
            _prc_inc_DoPersistantVar(oTarget, oPC, sCommand, nNextArg);
        else
            _prc_inc_DoLocalVar(oTarget, oPC, sCommand, nNextArg);
    }
    else if(GetStringMatchesAbbreviation(sCommandName, CMD_INFORMATION))
    {
        bResult = TRUE;
        string sInfoType = GetStringWord(sCommand, 2);
        if (GetStringMatchesAbbreviation(sInfoType, CMD_ABILITIES))
        {
            HelpText(oPC, "====== ABILITIES ======");
            HelpText(oPC, "=== The first number is the base score; the second is the modified score, which includes bonuses and penalties from gear, etc.");
            HelpText(oPC, "=== STR: " + IntToString(GetAbilityScore(oTarget, ABILITY_STRENGTH, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_STRENGTH, FALSE)));
            HelpText(oPC, "=== DEX: " + IntToString(GetAbilityScore(oTarget, ABILITY_DEXTERITY, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_DEXTERITY, FALSE)));
            HelpText(oPC, "=== CON: " + IntToString(GetAbilityScore(oTarget, ABILITY_CONSTITUTION, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_CONSTITUTION, FALSE)));
            HelpText(oPC, "=== INT: " + IntToString(GetAbilityScore(oTarget, ABILITY_INTELLIGENCE, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_INTELLIGENCE, FALSE)));
            HelpText(oPC, "=== WIS: " + IntToString(GetAbilityScore(oTarget, ABILITY_WISDOM, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_WISDOM, FALSE)));
            HelpText(oPC, "=== CHA: " + IntToString(GetAbilityScore(oTarget, ABILITY_CHARISMA, TRUE)) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_CHARISMA, FALSE)));
            if (GetPersistantLocalInt(oTarget, SHIFTER_ISSHIFTED_MARKER) && GetPRCSwitch(PRC_NWNXEE_ENABLED))
            {
                int iSTR = GetPersistantLocalInt(oTarget, "Shifting_NWNXSTRAdjust");
                int iDEX = GetPersistantLocalInt(oTarget, "Shifting_NWNXDEXAdjust");
                int iCON = GetPersistantLocalInt(oTarget, "Shifting_NWNXCONAdjust");
                HelpText(oPC, "=== The first number is the base score when unshifted; the second is the modified score when unshifted.");
                HelpText(oPC, "=== STR: " + IntToString(GetAbilityScore(oTarget, ABILITY_STRENGTH, TRUE)-iSTR) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_STRENGTH, FALSE)-iSTR));
                HelpText(oPC, "=== DEX: " + IntToString(GetAbilityScore(oTarget, ABILITY_DEXTERITY, TRUE)-iDEX) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_DEXTERITY, FALSE)-iDEX));
                HelpText(oPC, "=== CON: " + IntToString(GetAbilityScore(oTarget, ABILITY_CONSTITUTION, TRUE)-iCON) + " / " + IntToString(GetAbilityScore(oTarget, ABILITY_CONSTITUTION, FALSE)-iCON));
            }
        }
        else if (GetStringMatchesAbbreviation(sInfoType, CMD_EFFECTS))
        {
            HelpText(oPC, "====== EFFECTS ======");
            effect eEffect = GetFirstEffect(oTarget);
            while(GetIsEffectValid(eEffect))
            {
                if (GetEffectType(eEffect) == EFFECT_TYPE_INVALIDEFFECT)
                {
                    //An effect with type EFFECT_TYPE_INVALID is added for each item property
                    //They are also added for a couple of other things (Knockdown, summons, etc.)
                    //Just skip these
                }
                else
                {
                    string sEffectString = _prc_inc_EffectString(eEffect);
                    if(sEffectString != "")
                        HelpText(oPC, "=== " + sEffectString);
                }
                eEffect = GetNextEffect(oTarget);
            }
        }
        else if (GetStringMatchesAbbreviation(sInfoType, CMD_PROPERTIES))
        {
            HelpText(oPC, "====== PROPERTIES ======");
            HelpText(oPC, "====== CREATURE");
            _prc_inc_DumpAllItemProperties("=== ", oTarget, oPC);
            if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                HelpText(oPC, "====== CREATURE HIDE");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget), oPC);
                HelpText(oPC, "====== RIGHT CREATURE WEAPON");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget), oPC);
                HelpText(oPC, "====== LEFT CREATURE WEAPON");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget), oPC);
                HelpText(oPC, "====== SPECIAL CREATURE WEAPON");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget), oPC);
                HelpText(oPC, "====== RIGHT HAND");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget), oPC);
                HelpText(oPC, "====== LEFT HAND");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget), oPC);
                HelpText(oPC, "====== CHEST");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget), oPC);
                HelpText(oPC, "====== HEAD");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_HEAD, oTarget), oPC);
                HelpText(oPC, "====== CLOAK");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_CLOAK, oTarget), oPC);
                HelpText(oPC, "====== ARMS");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_ARMS, oTarget), oPC);
                HelpText(oPC, "====== BELT");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_BELT, oTarget), oPC);
                HelpText(oPC, "====== BOOTS");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_BOOTS, oTarget), oPC);
                HelpText(oPC, "====== RIGHT HAND RING");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oTarget), oPC);
                HelpText(oPC, "====== LEFT HAND RING");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_LEFTRING, oTarget), oPC);
                HelpText(oPC, "====== NECK");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_NECK, oTarget), oPC);
                HelpText(oPC, "====== ARROWS");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_ARROWS, oTarget), oPC);
                HelpText(oPC, "====== BOLTS");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_BOLTS, oTarget), oPC);
                HelpText(oPC, "====== BULLETS");
                _prc_inc_DumpAllItemProperties("=== ", GetItemInSlot(INVENTORY_SLOT_BULLETS, oTarget), oPC);
            }
        }
        else if (GetStringMatchesAbbreviation(sInfoType, CMD_SKILLS))
        {
            HelpText(oPC, "====== SKILLS ======");
            HelpText(oPC, "=== The first number is the base score; the second is the modified score, which includes bonuses and penalties from gear, etc.");
            int i = 0;
            string sSkillName;
            while((sSkillName = Get2DACache("skills", "Name", i)) != "")
            {
                sSkillName = GetStringByStrRef(StringToInt(sSkillName));
                HelpText(oPC, "=== " + sSkillName + ": " + IntToString(GetSkillRank(i, oTarget, TRUE)) + " / " + IntToString(GetSkillRank(i, oTarget, FALSE)));
                i += 1;
            }
        }
        else
            HelpText(oPC, "Unrecognized information request: " + sInfoType);
    }
    else if (GetStringMatchesAbbreviation(sCommandName, CMD_CHANGE))
    {
        bResult = TRUE;
        if(!DEBUG && !GetIsDM(oPC))
            HelpText(oPC, "This command only works if DEBUG = TRUE");
        else
        {
            string sChangeWhat = GetStringWord(sCommand, 2);
            string sChangeHow = GetStringWord(sCommand, 3);
            string sNumber = GetStringWord(sCommand, 4);
            int nNumber = StringToInt(sNumber);
            if (GetStringMatchesAbbreviation(sChangeWhat, CMD_LEVEL))
            {
                if (sNumber != IntToString(nNumber))
                    HelpText(oPC, "Unrecognized level: " + sNumber);
                else
                {
                    if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                    {
                        int nCurrentLevel = _prc_inc_XPToLevel(GetXP(oTarget));
                        if (nCurrentLevel > 40)
                            nCurrentLevel = 40;
                        nNumber = nCurrentLevel + nNumber;
                        if (nNumber < 1)
                            nNumber = 1;
                        else if (nNumber > 40)
                            nNumber = 40;
                        SetXP(oTarget, _prc_inc_LevelToXP(nNumber));
                    }
                    else if (GetStringMatchesAbbreviation(sChangeHow, CMD_TO))
                    {
                        if (nNumber < 1)
                            nNumber = 1;
                        else if (nNumber > 40)
                            nNumber = 40;
                        SetXP(oTarget, _prc_inc_LevelToXP(nNumber));
                    }
                    else
                        HelpText(oPC, "Unrecognized word: " + sChangeHow);
                }
            }
            else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_XP))
            {
                if (sNumber != IntToString(nNumber))
                    HelpText(oPC, "Unrecognized xp: " + sNumber);
                else
                {
                    if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                    {
                        nNumber = GetXP(oTarget) + nNumber;
                        if (nNumber < 0)
                            nNumber = 0;
                        SetXP(oTarget, nNumber);
                    }
                    else if (GetStringMatchesAbbreviation(sChangeHow, CMD_TO))
                    {
                        if (nNumber < 0)
                            nNumber = 0;
                        SetXP(oTarget, nNumber);
                    }
                    else
                        HelpText(oPC, "Unrecognized word: " + sChangeHow);
                }
            }
            else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_GOLD))
            {
                if (sNumber != IntToString(nNumber))
                    HelpText(oPC, "Unrecognized gold amount: " + sNumber);
                else
                {
                    if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                    {
                        if (nNumber > 0)
                            GiveGoldToCreature(oTarget, nNumber);
                        else if (nNumber < 0)
                            AssignCommand(oPC, TakeGoldFromCreature(-nNumber, oTarget, TRUE));
                    }
                    else if (GetStringMatchesAbbreviation(sChangeHow, CMD_TO))
                    {
                        nNumber = nNumber - GetGold(oTarget);
                        if (nNumber > 0)
                            GiveGoldToCreature(oTarget, nNumber);
                        else if (nNumber < 0)
                            AssignCommand(oPC, TakeGoldFromCreature(-nNumber, oTarget, TRUE));
                    }
                    else
                        HelpText(oPC, "Unrecognized word: " + sChangeHow);
                }
            }
/*            else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_ABILITY))
            {
                if (!GetPRCSwitch(PRC_NWNXEE_ENABLED))
                    HelpText(oPC, "This command only works if NWNX funcs is installed");
                else
                {
                    sChangeWhat = GetStringWord(sCommand, 3);
                    sChangeHow = GetStringWord(sCommand, 4);
                    sNumber = GetStringWord(sCommand, 5);
                    nNumber = StringToInt(sNumber);
                    if (sNumber != IntToString(nNumber))
                        HelpText(oPC, "Unrecognized ability value: " + sNumber);
                    else
                    {
                        if (GetStringMatchesAbbreviation(sChangeWhat, CMD_STR))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_STRENGTH, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_STR + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                            {
                                if (nNumber > 100 - 12)
                                    HelpText(oPC, "NOTE: having a total " + CMD_STR + " above 100 can cause problems (the weight that you can carry goes to 0)");
                                _prc_inc_shifting_SetSTR(oTarget, nNumber);
                            }
                        }
                        else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_DEX))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_DEXTERITY, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_DEX + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                                _prc_inc_shifting_SetDEX(oTarget, nNumber);
                        }
                        else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_CON))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_CONSTITUTION, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_CON + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                                _prc_inc_shifting_SetCON(oTarget, nNumber);
                        }
                        else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_INT))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_INTELLIGENCE, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_INT + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                                _prc_inc_shifting_SetINT(oTarget, nNumber);
                        }
                        else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_WIS))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_WISDOM, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_WIS + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                                _prc_inc_shifting_SetWIS(oTarget, nNumber);
                        }
                        else if (GetStringMatchesAbbreviation(sChangeWhat, CMD_CHA))
                        {
                            if (GetStringMatchesAbbreviation(sChangeHow, CMD_BY))
                                nNumber += GetAbilityScore(oTarget, ABILITY_CHARISMA, TRUE);
                            if (nNumber < 3 || nNumber > 255)
                                HelpText(oPC, "Invalid " + CMD_CHA + " value (must be between 3 and 255): " + sChangeWhat);
                            else
                                _prc_inc_shifting_SetCHA(oTarget, nNumber);
                        }

                        else
                            HelpText(oPC, "Unrecognized ability to change: " + sChangeWhat);
                    }
                }
            }
*/
            else
            {
                HelpText(oPC, "Unrecognized value to change: " + sChangeWhat);
            }
        }
    }
    else if (GetStringMatchesAbbreviation(sCommandName, CMD_SPAWN))
    {
        bResult = TRUE;
        if (!DEBUG && !GetIsDM(oPC))
            HelpText(oPC, "This command only works if DEBUG = TRUE");
        else
        {
            string sSpawnType = GetStringWord(sCommand, 2);
            string sResRef = GetStringWord(sCommand, 3);
            if (GetStringMatchesAbbreviation(sSpawnType, CMD_CREATURE))
            {
                AssignCommand(oPC, DoSummon(oPC, sResRef));
            }
            else if (GetStringMatchesAbbreviation(sSpawnType, CMD_ITEM))
            {
                object oItem = CreateItemOnObject(sResRef, oTarget);
                SetIdentified(oItem, TRUE);
                if(GetIsObjectValid(oItem))
                    HelpText(oPC, "Created item: " + GetName(oItem));
                else
                    HelpText(oPC, "Faild to create item--invalid resref?: " + sResRef);
            }
            else
                HelpText(oPC, "Unrecognized spawn type: " + sSpawnType);
        }
    }
    else if (GetStringMatchesAbbreviation(sCommandName, CMD_RELEVEL))
    {
        bResult = TRUE;
        if (!DEBUG)
            HelpText(oPC, "This command only works if DEBUG = TRUE");
        else
        {
            string sNumber = GetStringWord(sCommand, 2);
            int nNumber = StringToInt(sNumber);
            int nStartXP = GetXP(oTarget);
            int nStartLevel = _prc_inc_XPToLevel(nStartXP);
            if (sNumber != IntToString(nNumber))
                HelpText(oPC, "Unrecognized level: " + sNumber);
            else if (nNumber > nStartLevel)
                HelpText(oPC, "Nothing to do: specified level is higher than current level.");
            else
            {
                if (nNumber < 1)
                    nNumber = 1;
                SetXP(oTarget, _prc_inc_LevelToXP(nNumber-1)); //Level down to the the level before the 1st we want to change
                SetXP(oTarget, nStartXP); //Level back up to our starting XP
            }
        }
    }
    else if (GetStringMatchesAbbreviation(sCommandName, CMD_SPECIAL))
    {
        bResult = TRUE;

        string sSpecialCommandName = GetStringWord(sCommand, 2);

        if (GetStringMatchesAbbreviation(sSpecialCommandName, CMD_REST))
        {
            if (!DEBUG)
                HelpText(oPC, "This command only works if DEBUG = TRUE");
            else
                PRCForceRest(oTarget);
        }
        else if (GetStringMatchesAbbreviation(sSpecialCommandName, CMD_HANDLE_FORCE_REST_1) && 
            GetStringMatchesAbbreviation(GetStringWord(sCommand, 3), CMD_HANDLE_FORCE_REST_2) && 
            GetStringMatchesAbbreviation(GetStringWord(sCommand, 4), CMD_HANDLE_FORCE_REST_3)
            )
        {
            StartForcedRestDetector(oTarget);
        }
    }
    else if(GetStringMatchesAbbreviation(sCommandName, CMD_CHK_PP))
    {
        bResult = TRUE;
        TellCharacterPowerPointStatus(oPC);
    }

    return bResult;
}
