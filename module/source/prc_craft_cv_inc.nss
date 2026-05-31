
//:: prc_craft_cv_inc.nss

#include "prc_craft_inc"
#include "inc_dynconv"

//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

//const int STAGE_                        = ;

const int STAGE_START                   = 0;
const int STAGE_SELECT_SUBTYPE          = 1;
const int STAGE_SELECT_COSTTABLEVALUE   = 2;
const int STAGE_SELECT_PARAM1VALUE      = 3;
const int STAGE_CONFIRM                 = 4;
const int STAGE_BANE                    = 5;

const int STAGE_CONFIRM_MAGIC           = 7;
const int STAGE_APPEARANCE              = 8;
const int STAGE_CLONE                   = 9;
const int STAGE_APPEARANCE_LIST         = 10;
const int STAGE_APPEARANCE_VALUE        = 11;
const int STAGE_CRAFT_GOLEM             = 12;
const int STAGE_CRAFT_GOLEM_HD          = 13;
const int STAGE_CRAFT_ALCHEMY           = 14;
const int STAGE_CONFIRM_ALCHEMY         = 15;
const int STAGE_CRAFT_POISON            = 16;
const int STAGE_CONFIRM_POISON          = 17;
const int STAGE_CRAFT_LICH              = 18;
const int STAGE_CRAFT                   = 101;
const int STAGE_CRAFT_SELECT            = 102;
const int STAGE_CRAFT_MASTERWORK        = 103;
const int STAGE_CRAFT_AC                = 104;
const int STAGE_CRAFT_MIGHTY            = 105;
const int STAGE_CRAFT_CONFIRM           = 106;

//const int STAGE_CRAFT                   = 101;


//const int CHOICE_                       = ;

//these must be past the highest 2da entry to be read
const int CHOICE_FORGE                  = 20001;
const int CHOICE_BOOST                  = 20002;
const int CHOICE_BACK                   = 20003;
const int CHOICE_CLEAR                  = 20004;
const int CHOICE_CONFIRM                = 20005;
const int CHOICE_SETNAME                = 20006;
const int CHOICE_SETAPPEARANCE          = 20007;
const int CHOICE_CLONE                  = 20008;

const int CHOICE_APPEARANCE_SHOUT       = 20009;
const int CHOICE_APPEARANCE_SELECT      = 20010;

const int CHOICE_PLUS_1                 = 20011;
const int CHOICE_PLUS_10                = 20012;
const int CHOICE_MINUS_1                = 20013;
const int CHOICE_MINUS_10               = 20014;

const int CHOICE_CRAFT                  = 20101;

//const int NUM_MAX_COSTTABLEVALUES       = 70;
//const int NUM_MAX_PARAM1VALUES          = 70;

const int HAS_SUBTYPE                   = 1;
const int HAS_COSTTABLE                 = 2;
const int HAS_PARAM1                    = 4;

const int STRREF_YES                = 4752;     // "Yes"
const int STRREF_NO                 = 4753;     // "No"

const string PRC_CRAFT_ITEM             = "PRC_CRAFT_ITEM";
const string PRC_CRAFT_TYPE             = "PRC_CRAFT_TYPE";
const string PRC_CRAFT_SUBTYPE          = "PRC_CRAFT_SUBTYPE";
const string PRC_CRAFT_SUBTYPEVALUE     = "PRC_CRAFT_SUBTYPEVALUE";
const string PRC_CRAFT_COSTTABLE        = "PRC_CRAFT_COSTTABLE";
const string PRC_CRAFT_COSTTABLEVALUE   = "PRC_CRAFT_COSTTABLEVALUE";
const string PRC_CRAFT_PARAM1           = "PRC_CRAFT_PARAM1";
const string PRC_CRAFT_PARAM1VALUE      = "PRC_CRAFT_PARAM1VALUE";
const string PRC_CRAFT_PROPLIST         = "PRC_CRAFT_PROPLIST";
const string PRC_CRAFT_COST             = "PRC_CRAFT_COST";
const string PRC_CRAFT_XP               = "PRC_CRAFT_XP";
const string PRC_CRAFT_TIME             = "PRC_CRAFT_TIME";
//const string PRC_CRAFT_BLUEPRINT        = "PRC_CRAFT_BLUEPRINT";
const string PRC_CRAFT_CONVO_           = "PRC_CRAFT_CONVO_";
const string PRC_CRAFT_BASEITEMTYPE     = "PRC_CRAFT_BASEITEMTYPE";
const string PRC_CRAFT_AC               = "PRC_CRAFT_AC";
const string PRC_CRAFT_MIGHTY           = "PRC_CRAFT_MIGHTY";
const string PRC_CRAFT_MATERIAL         = "PRC_CRAFT_MATERIAL";
const string PRC_CRAFT_TAG              = "PRC_CRAFT_TAG";
const string PRC_CRAFT_LINE             = "PRC_CRAFT_LINE";
const string PRC_CRAFT_FILE             = "PRC_CRAFT_FILE";

const string PRC_CRAFT_MAGIC_ENHANCE    = "PRC_CRAFT_MAGIC_ENHANCE";
const string PRC_CRAFT_MAGIC_ADDITIONAL = "PRC_CRAFT_MAGIC_ADDITIONAL";
const string PRC_CRAFT_MAGIC_EPIC       = "PRC_CRAFT_MAGIC_EPIC";

const string PRC_CRAFT_SCRIPT_STATE     = "PRC_CRAFT_SCRIPT_STATE";

const string ARTIFICER_PREREQ_RACE      = "ARTIFICER_PREREQ_RACE";
const string ARTIFICER_PREREQ_ALIGN     = "ARTIFICER_PREREQ_ALIGN";
const string ARTIFICER_PREREQ_CLASS     = "ARTIFICER_PREREQ_CLASS";
const string ARTIFICER_PREREQ_SPELL1    = "ARTIFICER_PREREQ_SPELL1";
const string ARTIFICER_PREREQ_SPELL2    = "ARTIFICER_PREREQ_SPELL2";
const string ARTIFICER_PREREQ_SPELL3    = "ARTIFICER_PREREQ_SPELL3";
const string ARTIFICER_PREREQ_SPELLOR1  = "ARTIFICER_PREREQ_SPELLOR1";
const string ARTIFICER_PREREQ_SPELLOR2  = "ARTIFICER_PREREQ_SPELLOR2";
const string ARTIFICER_PREREQ_COMPLETE  = "ARTIFICER_PREREQ_COMPLETE";

const int PRC_CRAFT_STATE_NORMAL        = 1;
const int PRC_CRAFT_STATE_MAGIC         = 2;

const string PRC_CRAFT_HB               = "PRC_CRAFT_HB";

const int SORT       = TRUE; // If the sorting takes too much CPU, set to FALSE
const int DEBUG_LIST = FALSE;


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void PrintList(object oPC)
{
    string tp = "Printing list:\n";
    string s = GetLocalString(oPC, "ForgeConvo_List_Head");
    if(s == ""){
        tp += "Empty\n";
    }
    else{
        tp += s + "\n";
        s = GetLocalString(oPC, "ForgeConvo_List_Next_" + s);
        while(s != ""){
            tp += "=> " + s + "\n";
            s = GetLocalString(oPC, "ForgeConvo_List_Next_" + s);
        }
    }

    DoDebug(tp);
}

/**
 * Creates a linked list of entries that is sorted into alphabetical order
 * as it is built.
 * Assumption: Power names are unique.
 *
 * @param oPC     The storage object aka whomever is gaining powers in this conversation
 * @param sChoice The choice string
 * @param nChoice The choice value
 */

void AddToTempList(object oPC, string sChoice, int nChoice)
{
    if(DEBUG_LIST) DoDebug("\nAdding to temp list: '" + sChoice + "' - " + IntToString(nChoice));
    if(DEBUG_LIST) PrintList(oPC);
    // If there is nothing yet
    if(!GetLocalInt(oPC, "PRC_CRAFT_CONVO_ListInited"))
    {
        SetLocalString(oPC, "PRC_CRAFT_CONVO_List_Head", sChoice);
        SetLocalInt(oPC, "PRC_CRAFT_CONVO_List_" + sChoice, nChoice);

        SetLocalInt(oPC, "PRC_CRAFT_CONVO_ListInited", TRUE);
    }
    else
    {
        // Find the location to instert into
        string sPrev = "", sNext = GetLocalString(oPC, "PRC_CRAFT_CONVO_List_Head");
        while(sNext != "" && StringCompare(sChoice, sNext) >= 0)
        {
            if(DEBUG_LIST) DoDebug("Comparison between '" + sChoice + "' and '" + sNext + "' = " + IntToString(StringCompare(sChoice, sNext)));
            sPrev = sNext;
            sNext = GetLocalString(oPC, "PRC_CRAFT_CONVO_List_Next_" + sNext);
        }

        // Insert the new entry
        // Does it replace the head?
        if(sPrev == "")
        {
            if(DEBUG_LIST) DoDebug("New head");
            SetLocalString(oPC, "PRC_CRAFT_CONVO_List_Head", sChoice);
        }
        else
        {
            if(DEBUG_LIST) DoDebug("Inserting into position between '" + sPrev + "' and '" + sNext + "'");
            SetLocalString(oPC, "PRC_CRAFT_CONVO_List_Next_" + sPrev, sChoice);
        }

        SetLocalString(oPC, "PRC_CRAFT_CONVO_List_Next_" + sChoice, sNext);
        SetLocalInt(oPC, "PRC_CRAFT_CONVO_List_" + sChoice, nChoice);
    }
}

/**
 * Reads the linked list built with AddToTempList() to AddChoice() and
 * deletes it.
 *
 * @param oPC A PC gaining powers at the moment
 */

void TransferTempList(object oPC)
{
    string sChoice = GetLocalString(oPC, "PRC_CRAFT_CONVO_List_Head");
    int    nChoice = GetLocalInt   (oPC, "PRC_CRAFT_CONVO_List_" + sChoice);

    DeleteLocalString(oPC, "PRC_CRAFT_CONVO_List_Head");
    string sPrev;

    if(DEBUG_LIST) DoDebug("Head is: '" + sChoice + "' - " + IntToString(nChoice));

    while(sChoice != "")
    {
        // Add the choice
        AddChoice(sChoice, nChoice, oPC);

        // Get next
        sChoice = GetLocalString(oPC, "PRC_CRAFT_CONVO_List_Next_" + (sPrev = sChoice));
        nChoice = GetLocalInt   (oPC, "PRC_CRAFT_CONVO_List_" + sChoice);

        if(DEBUG_LIST) DoDebug("Next is: '" + sChoice + "' - " + IntToString(nChoice) + "; previous = '" + sPrev + "'");

        // Delete the already handled data
        DeleteLocalString(oPC, "PRC_CRAFT_CONVO_List_Next_" + sPrev);
        DeleteLocalInt   (oPC, "PRC_CRAFT_CONVO_List_" + sPrev);
    }

    DeleteLocalInt(oPC, "PRC_CRAFT_CONVO_ListInited");
}

//Returns the next conversation stage according
//  to item property
int GetNextItemPropStage(int nStage, object oPC, int nPropList)
{
    nStage++;
    if(nStage == STAGE_SELECT_SUBTYPE && !(nPropList & HAS_SUBTYPE))
        nStage++;
    if(nStage == STAGE_SELECT_COSTTABLEVALUE && !(nPropList & HAS_COSTTABLE))
        nStage++;
    if(nStage == STAGE_SELECT_PARAM1VALUE && !(nPropList & HAS_PARAM1))
        nStage++;
    MarkStageNotSetUp(nStage, oPC);
    return nStage;
}

//Returns the previous conversation stage according
//  to item property
int GetPrevItemPropStage(int nStage, object oPC, int nPropList)
{
    nStage--;
    if(nStage == STAGE_SELECT_PARAM1VALUE && !(nPropList & HAS_PARAM1))
        nStage--;
    if(nStage == STAGE_SELECT_COSTTABLEVALUE && !(nPropList & HAS_COSTTABLE))
        nStage--;
    if(nStage == STAGE_SELECT_SUBTYPE && !(nPropList & HAS_SUBTYPE))
        nStage--;
    MarkStageNotSetUp(nStage, oPC);
    return nStage;
}

 //hardcoded to save time/prevent tmi
int SkipLineSpells(int i)
{
    switch(i)
    {
        //i +2
        case 3:
        case 6:
        case 16:
        case 22:
        case 26:
        case 29:
        case 38:
        case 41:
        case 44:
        case 58:
        case 61:
        case 64:
        case 70:
        case 73:
        case 79:
        case 82:
        case 96: 
        case 111:
        case 116:
        case 134:
        case 145:
        case 165:
        case 185:
        case 193:
        case 202: 
        case 289:
        case 292:
        case 295:
        case 312:
        case 516:
        case 1017:
        case 1038:
        case 1041:
        case 1068:
        case 1082:
        case 1090:
        case 1099:
        case 1104:
        case 1107:
        case 1134:
        case 1363:
        case 1430:
        case 1435: i = i + 2; break;
        
        //i +1
        case 10:
        case 12:
        case 19:
        case 21:
        case 24:
        case 32:
        case 34:
        case 36:
        case 47:
        case 51:
        case 53:
        case 56:
        case 67:
        case 85:
        case 91:
        case 93:
        case 102:
        case 107:
        case 109:
        case 114:
        case 124:
        case 132:
        case 138:
        case 141:
        case 156:
        case 163:
        case 181:
        case 191:
        case 196:
        case 199:
        case 214:
        case 218:
        case 220:
        case 222:
        case 224:
        case 235:
        case 237:
        case 248:
        case 252:
        case 256:
        case 258:
        case 263:
        case 276:
        case 285:
        case 306:
        case 309:
        case 315:
        case 325:
        case 397:
        case 462:
        case 475:
        case 485:
        case 514:
        case 949:
        case 953:
        case 1001:
        case 1003:
        case 1005:
        case 1007:
        case 1009:
        case 1011:
        case 1013:
        case 1020:
        case 1031:
        case 1034:
        case 1043:
        case 1045:
        case 1048:
        case 1050:
        case 1052:
        case 1055:
        case 1057:
        case 1059:
        case 1061:
        case 1063:
        case 1076:
        case 1078:
        case 1086:
        case 1088:
        case 1095:
        case 1097:
        case 1102:
        case 1111:
        case 1113:
        case 1119:
        case 1121:
        case 1124:
        case 1126:
        case 1128:
        case 1145:
        case 1147:
        case 1196:
        case 1205:
        case 1215:
        case 1260:
        case 1350: i = i + 1; break;
        case 173: i = 179; break;
        case 317: i = 321; break;
        case 328: i = 345; break;
        case 359: i = 360; break;
        case 400: i = 450; break;
        case 487: i = 514; break;
        case 520: i = 538; break;
        case 540: i = 899; break;
        case 902: i = 903; break;
        case 914: i = 928; break;
        case 967: i = 1000; break;
        case 1366: i = 1369; break;
        case 1389: i = 1416; break;
    }
    return i;
}


//added by MSB - hardcoded to prevent TMI
int SkipLineFeats(int i)
{
     switch (i)
     {
        case 40: i = 99; break;
        case 141: i = 201; break;
        case 213: i = 257; break;
        case 259: i = 260; break;
        case 262: i = 264; break;
        case 266: i = 343; break;
        case 381: i = 394; break;
        case 395: i = 24813; break;
     }
     return i;
}

//hardcoded to save time/prevent tmi
int SkipLineItemprops(int i)
{
    switch(i)
    {
        case 94: i = 100; break;
        case 102: i = 133; break;
        case 135: i = 150; break;
        case 151: i = 200; break;
    }
    return i;
}

//Adds names to a list based on sTable (2da), delayed recursion
//  to avoid TMI
void PopulateList(object oPC, int MaxValue, int bSort, string sTable, object oItem = OBJECT_INVALID, int i = 0)
{
    if(GetLocalInt(oPC, "DynConv_Waiting") == FALSE)
        return;
    if(i <= MaxValue)
    {
        int bValid = TRUE;
        string sTemp = "";
        if(sTable == "iprp_spells")
        {
            i = SkipLineSpells(i);
            MaxValue = 1150; //MSB changed this from 540
        }
        else if(sTable == "IPRP_FEATS")
        {
            MaxValue = 24819;
            i = SkipLineFeats(i);
        }
        else if(sTable == "itempropdef")
        {
            i = SkipLineItemprops(i);
            bValid = ValidProperty(oItem, i);
            if(bValid)
                bValid = !GetPRCSwitch("PRC_CRAFT_DISABLE_itempropdef_" + IntToString(i));
        }
        else if(GetStringLeft(sTable, 6) == "craft_")
            bValid = array_get_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i);
        sTemp = Get2DACache(sTable, "Name", i);
        if((sTemp != "") && bValid)//this is going to kill
        {
            if(sTable == "iprp_spells")
            {
                AddToTempList(oPC, ActionString(GetStringByStrRef(StringToInt(sTemp))), i);
            }
            else
            {
                if(bSort)
                    AddToTempList(oPC, ActionString(GetStringByStrRef(StringToInt(sTemp))), i);
                else
                    AddChoice(ActionString(GetStringByStrRef(StringToInt(sTemp))), i, oPC);
            }
        }
        if(!(i % 100) && i) //i != 0, i % 100 == 0
	    //following line is for debugging
	    //FloatingTextStringOnCreature(sTable, oPC, FALSE);
            FloatingTextStringOnCreature("*Tick*", oPC, FALSE);

    }
    else
    {
        if(bSort) TransferTempList(oPC);
        DeleteLocalInt(oPC, "DynConv_Waiting");
        FloatingTextStringOnCreature("*Done*", oPC, FALSE);
        return;
    }
    DelayCommand(0.01, PopulateList(oPC, MaxValue, bSort, sTable, oItem, i + 1));
}

//use heartbeat
void ApplyProperties(object oPC, object oItem, itemproperty ip, int nCost, int nXP, string sFile, int nLine)
{
	if(DEBUG) DoDebug("ApplyProperties: Starting with nCost=" + IntToString(nCost) +   
                     ", and Crafter GP =" + IntToString(GetGold(oPC))); 
					 
    if(GetGold(oPC) < nCost)
    {
        FloatingTextStringOnCreature("Crafting: Insufficient gold!", oPC);
        return;
    }
    int nHD = GetHitDice(oPC);
    int nMinXP = nHD * (nHD - 1) * 500;
    int nCurrentXP = GetXP(oPC);
    if((nCurrentXP - nMinXP) < nXP)
    {
        FloatingTextStringOnCreature("Crafting: Insufficient XP!", oPC);
        return;
    }
    if(GetItemPossessor(oItem) != oPC)
    {
        FloatingTextStringOnCreature("Crafting: You do not have the item!", oPC);
        return;
    }
	
	if(DEBUG) DoDebug("ApplyProperties: Passed validation, about to apply properties");
	
    if(nLine == -1)
        IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    else if(nLine == -2)
    {   //clone item
        CopyItem(oItem, oPC, TRUE);
    }
    else
    {
        string sPropertyType = Get2DACache(sFile, "PropertyType", nLine);
        if(sPropertyType == "M")
        {   //checking required spells
            if(!CheckCraftingSpells(oPC, sFile, nLine, TRUE))
            {
                FloatingTextStringOnCreature("Crafting: Required spells not available!", oPC);
                return;
            }
        }
        else if(sPropertyType == "P")
        {
            if(!CheckCraftingPowerPoints(oPC, sFile, nLine, TRUE))
            {
                FloatingTextStringOnCreature("Crafting: Insufficient power points!", oPC);
                return;
            }
        }
		if(DEBUG) DoDebug("ApplyProperties: Calling ApplyItemProps()"); 
        ApplyItemProps(oItem, sFile, nLine);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BREACH), oPC);
	
	// With this conditional logic:  
	if(GetLocalInt(oPC, "PRC_CRAFT_RESTORED"))  
	{  
		AssignCommand(oPC, ClearAllActions());
		if(DEBUG) DoDebug("ApplyProperties: About to call TakeGoldFromCreature() with cost=" + IntToString(nCost));		
		AssignCommand(oPC, TakeGoldFromCreature(nCost, oPC, TRUE)); 
		SpendXP(oPC, nXP); 
		  
		DeleteLocalInt(oPC, "PRC_CRAFT_RESTORED");  
	}
	else  
	{  
	AssignCommand(oPC, ClearAllActions());
	if(DEBUG) DoDebug("ApplyProperties: About to call TakeGoldFromCreature() with cost=" + IntToString(nCost));  
	AssignCommand(oPC, TakeGoldFromCreature(nCost, oPC, TRUE));     
	if(DEBUG) DoDebug("ApplyProperties: TakeGoldFromCreature() completed, new gold =" + IntToString(GetGold(oPC)));  
	SpendXP(oPC, nXP); 
	if(DEBUG) DoDebug("ApplyProperties: XP deduction completed, new XP=" + IntToString(GetXP(oPC)));
	}	
	
	//if(DEBUG) DoDebug("ApplyProperties: About to deduct gold ("+IntToString(nCost)+") and XP ("+IntToString(nCost)+").");
    //TakeGoldFromCreature(nCost, oPC, TRUE);
    //SetXP(oPC, GetXP(oPC) - nXP);
	
	if(DEBUG) DoDebug("ApplyProperties: Completed successfully");
}

//use heartbeat
void CreateGolem(object oPC, int nCost, int nXP, string sFile, int nLine)
{
    if(GetGold(oPC) < nCost)
    {
        FloatingTextStringOnCreature("Crafting: Insufficient gold!", oPC);
        return;
    }
    int nHD = GetHitDice(oPC);
    int nMinXP = nHD * (nHD - 1) * 500;
    int nCurrentXP = GetXP(oPC);
    if((nCurrentXP - nMinXP) < nXP)
    {
        FloatingTextStringOnCreature("Crafting: Insufficient XP!", oPC);
        return;
    }
    string sPropertyType = Get2DACache(sFile, "CasterType", nLine);
    if(sPropertyType == "M")
    {   //checking required spells
        if(!CheckCraftingSpells(oPC, sFile, nLine, TRUE))
        {
            FloatingTextStringOnCreature("Crafting: Required spells not available!", oPC);
            return;
        }
    }
    else if(sPropertyType == "P")
    {
        if(!CheckCraftingPowerPoints(oPC, sFile, nLine, TRUE))
        {
            FloatingTextStringOnCreature("Crafting: Insufficient power points!", oPC);
            return;
        }
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BREACH), oPC);
    TakeGoldFromCreature(nCost, oPC, TRUE);
    SetXP(oPC, GetXP(oPC) - nXP);
}

int ArtificerPrereqCheck(object oPC, string sFile, int nLine, int nCost)
{
    string sTemp, sSub, sSpell;
    int nRace, nAlignGE, nAlignLC, nClass, i, j, bBreak, nLength, nPosition, nTemp;
    int nSpell1, nSpell2, nSpell3, nSpellOR1, nSpellOR2;
    int nDays = nCost / 1000;   //one set of UMD checks per "day" spent crafting
    if(nCost % 1000) nDays++;
    sTemp = Get2DACache(sFile, "PrereqMisc", nLine);
    sSpell = Get2DACache(sFile, "Spells", nLine);
    if(sTemp == "")
    {
        bBreak = TRUE;
        nRace = -1;
        nAlignGE = -1;
        nAlignLC = -1;
        nClass = -1;
    }
    nLength = GetStringLength(sTemp);
    for(i = 0; i < 5; i++)
    {
        if(bBreak)
            break;
        nPosition = FindSubString(sTemp, "_");
        sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
        nLength -= (nPosition + 1);
        if(sSub == "*")
            nTemp = -1;
        else
            nTemp = StringToInt(sSub);
        switch(i)
        {
            case 0:
            {
                nRace = (MyPRCGetRacialType(oPC) == nTemp) ? -1 : nTemp;
                break;
            }
            case 1:
            {
                //can't emulate feat requirement
                break;
            }
            case 2:
            {
                nAlignGE = -1;
                if(sSub == "G") nAlignGE = (GetAlignmentGoodEvil(oPC) == ALIGNMENT_GOOD) ? -1 : ALIGNMENT_GOOD;
                else if(sSub == "E") nAlignGE = (GetAlignmentGoodEvil(oPC) == ALIGNMENT_EVIL) ? -1 : ALIGNMENT_EVIL;
                else if(sSub == "N") nAlignGE = (GetAlignmentGoodEvil(oPC) == ALIGNMENT_NEUTRAL) ? -1 : ALIGNMENT_NEUTRAL;
                break;
            }
            case 3:
            {
                nAlignLC = -1;
                if(sSub == "L") nAlignLC = (GetAlignmentLawChaos(oPC) == ALIGNMENT_LAWFUL) ? -1 : ALIGNMENT_LAWFUL;
                if(sSub == "C") nAlignLC = (GetAlignmentLawChaos(oPC) == ALIGNMENT_CHAOTIC) ? -1 : ALIGNMENT_CHAOTIC;
                if(sSub == "N") nAlignLC = (GetAlignmentLawChaos(oPC) == ALIGNMENT_NEUTRAL) ? -1 : ALIGNMENT_NEUTRAL;
                break;
            }
            case 4:
            {
                nClass = (GetLevelByClass(nTemp, oPC)) ? -1 : nTemp;
                break;
            }
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }
    if(sSpell == "")
    {
        nSpell1 = -1;
        nSpell2 = -1;
        nSpell3 = -1;
        nSpellOR1 = -1;
        nSpellOR2 = -1;
    }
    else
    {
        for(i = 0; i < 5; i++)
        {
            nPosition = FindSubString(sTemp, "_");
            sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
            nLength -= (nPosition + 1);
            if(sSub == "*")
                nTemp = -1;
            else
            {
                nTemp = StringToInt(sSub);
                switch(i)
                {
                    case 0:
                    {   //storing the spell level and assuming it's a valid number
                        nSpell1 = (PRCGetHasSpell(nTemp, oPC)) ? -1 : StringToInt(Get2DACache("spells", "Innate", nTemp)) + 20;
                        break;
                    }
                    case 1:
                    {
                        nSpell2 = (PRCGetHasSpell(nTemp, oPC)) ? -1 : StringToInt(Get2DACache("spells", "Innate", nTemp)) + 20;
                        break;
                    }
                    case 2:
                    {
                        nSpell3 = (PRCGetHasSpell(nTemp, oPC)) ? -1 : StringToInt(Get2DACache("spells", "Innate", nTemp)) + 20;
                        break;
                    }
                    case 3:
                    {
                        nSpellOR1 = (PRCGetHasSpell(nTemp, oPC)) ? -1 : StringToInt(Get2DACache("spells", "Innate", nTemp)) + 20;
                        break;
                    }
                    case 4:
                    {
                        nSpellOR2 = (PRCGetHasSpell(nTemp, oPC)) ? -1 : StringToInt(Get2DACache("spells", "Innate", nTemp)) + 20;
                        break;
                    }
                }
            }
            sTemp = GetSubString(sTemp, nPosition + 1, nLength);
        }
    }
    int bTake10 = GetHasFeat(FEAT_SKILL_MASTERY_ARTIFICER, oPC) ? 10 : -1;
    for(i = 0; i <= nDays; i++) //with extra last-ditch roll
    {
        if((nRace == -1) &&
            (nAlignGE == -1) &&
            (nAlignLC == -1) &&
            (nClass == -1) &&
            (nSpell1 == -1) &&
            (nSpell2 == -1) &&
            (nSpell3 == -1) &&
            (nSpellOR1 == -1) &&
            (nSpellOR2 == -1)
            )
            return TRUE;

        if(nRace != -1)     nRace       = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 25, bTake10)) ? -1 : nRace;
        if(nAlignGE != -1)  nAlignGE    = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 30, bTake10)) ? -1 : nAlignGE;
        if(nAlignLC != -1)  nAlignLC    = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 30, bTake10)) ? -1 : nAlignLC;
        if(nClass != -1)    nClass      = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 21, bTake10)) ? -1 : nClass;
        if(nSpell1 != -1)   nSpell1     = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, nSpell1, bTake10)) ? -1 : nSpell1;
        if(nSpell2 != -1)   nSpell2     = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, nSpell2, bTake10)) ? -1 : nSpell2;
        if(nSpell3 != -1)   nSpell3     = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, nSpell3, bTake10)) ? -1 : nSpell3;
        if(nSpellOR1 != -1) nSpellOR1   = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, nSpellOR1, bTake10)) ? -1 : nSpellOR1;
        if(nSpellOR2 != -1) nSpellOR2   = (GetPRCIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, nSpellOR2, bTake10)) ? -1 : nSpellOR2;
    }
    if((nRace == -1) &&
        (nAlignGE == -1) &&
        (nAlignLC == -1) &&
        (nClass == -1) &&
        (nSpell1 == -1) &&
        (nSpell2 == -1) &&
        (nSpell3 == -1) &&
        (nSpellOR1 == -1) &&
        (nSpellOR2 == -1)
        )
        return TRUE;
    else
        return FALSE;   //made all the UMD rolls allocated and still failed
}

// Save crafting state during crafting 
void SaveCraftingState(object oPC)      
{      
    if(DEBUG) DoDebug("prc_craft_cv_inc >> SaveCraftingState called for " + GetName(oPC));    
        
    if(GetLocalInt(oPC, PRC_CRAFT_HB))      
    {      
        if(DEBUG) DoDebug("prc_craft_cv_inc >> SaveCraftingState: Player is crafting, saving state...");    
            
        // Get the crafting item  
        object oItem = GetLocalObject(oPC, PRC_CRAFT_ITEM);  
        
        // Save item identification info
        SQLocalsPlayer_SetString(oPC, "crafting_item_name", GetName(oItem));
        SQLocalsPlayer_SetString(oPC, "crafting_item_tag", GetTag(oItem));
        SQLocalsPlayer_SetInt(oPC, "crafting_item_basetype", GetBaseItemType(oItem));
          
        // Save UUID if not already saved
        string sItemUUID = SQLocalsPlayer_GetString(oPC, "crafting_item_uuid");    
        if(sItemUUID == "")    
        {    
            sItemUUID = GetObjectUUID(oItem);    
            SQLocalsPlayer_SetString(oPC, "crafting_item_uuid", sItemUUID);    
            if(DEBUG) DoDebug("prc_craft_cv_inc >> SaveCraftingState: Generated and saved new UUID: " + sItemUUID);    
        }    
          
        // Get crafting cost values  
        int nCostDiff = GetLocalInt(oPC, PRC_CRAFT_COST);  
        int nXPDiff = GetLocalInt(oPC, PRC_CRAFT_XP);  
        int nRounds = GetLocalInt(oPC, PRC_CRAFT_TIME);
          
        // Save all basic crafting parameters    
        SQLocalsPlayer_SetInt(oPC, "crafting_cost", nCostDiff);    
        SQLocalsPlayer_SetInt(oPC, "crafting_xp", nXPDiff);    
        SQLocalsPlayer_SetInt(oPC, "crafting_rounds", nRounds);    
        SQLocalsPlayer_SetString(oPC, "crafting_file", GetLocalString(oPC, PRC_CRAFT_FILE));    
        SQLocalsPlayer_SetInt(oPC, "crafting_line", GetLocalInt(oPC, PRC_CRAFT_LINE));    
        SQLocalsPlayer_SetInt(oPC, "crafting_active", 1);    
          
        // Save item property components for reconstruction
        SQLocalsPlayer_SetInt(oPC, "crafting_ip_type", GetLocalInt(oPC, "PRC_CRAFT_IP_TYPE"));
        SQLocalsPlayer_SetInt(oPC, "crafting_ip_subtype", GetLocalInt(oPC, "PRC_CRAFT_IP_SUBTYPE"));
        SQLocalsPlayer_SetInt(oPC, "crafting_ip_costtable", GetLocalInt(oPC, "PRC_CRAFT_IP_COSTTABLE"));
        SQLocalsPlayer_SetInt(oPC, "crafting_ip_param1", GetLocalInt(oPC, "PRC_CRAFT_IP_PARAM1"));
          
        // Save item property parameters
        SQLocalsPlayer_SetInt(oPC, "crafting_type", GetLocalInt(oPC, PRC_CRAFT_TYPE));  
        SQLocalsPlayer_SetString(oPC, "crafting_subtype", GetLocalString(oPC, PRC_CRAFT_SUBTYPE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_subtypevalue", GetLocalInt(oPC, PRC_CRAFT_SUBTYPEVALUE));  
        SQLocalsPlayer_SetString(oPC, "crafting_costtable", GetLocalString(oPC, PRC_CRAFT_COSTTABLE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_costtablevalue", GetLocalInt(oPC, PRC_CRAFT_COSTTABLEVALUE));  
        SQLocalsPlayer_SetString(oPC, "crafting_param1", GetLocalString(oPC, PRC_CRAFT_PARAM1));  
        SQLocalsPlayer_SetInt(oPC, "crafting_param1value", GetLocalInt(oPC, PRC_CRAFT_PARAM1VALUE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_proplist", GetLocalInt(oPC, PRC_CRAFT_PROPLIST));  
          
        // Save item properties
        SQLocalsPlayer_SetInt(oPC, "crafting_baseitemtype", GetLocalInt(oPC, PRC_CRAFT_BASEITEMTYPE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_time", nRounds);  
        SQLocalsPlayer_SetInt(oPC, "crafting_material", GetLocalInt(oPC, PRC_CRAFT_MATERIAL));  
        SQLocalsPlayer_SetInt(oPC, "crafting_mighty", GetLocalInt(oPC, PRC_CRAFT_MIGHTY));  
        SQLocalsPlayer_SetInt(oPC, "crafting_ac", GetLocalInt(oPC, PRC_CRAFT_AC));  
        SQLocalsPlayer_SetString(oPC, "crafting_tag", GetLocalString(oPC, PRC_CRAFT_TAG));  
          
        // Save magic crafting variables
        SQLocalsPlayer_SetInt(oPC, "crafting_enhancement", GetLocalInt(oPC, PRC_CRAFT_MAGIC_ENHANCE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_additional", GetLocalInt(oPC, PRC_CRAFT_MAGIC_ADDITIONAL));  
        SQLocalsPlayer_SetInt(oPC, "crafting_epic", GetLocalInt(oPC, PRC_CRAFT_MAGIC_EPIC));  
          
        // Save system state variables
        SQLocalsPlayer_SetInt(oPC, "crafting_script_state", GetLocalInt(oPC, PRC_CRAFT_SCRIPT_STATE));  
        SQLocalsPlayer_SetInt(oPC, "crafting_token", GetLocalInt(oPC, PRC_CRAFT_TOKEN));  
            
        if(DEBUG) DoDebug("DEBUG: Crafting state saved - rounds: " + IntToString(nRounds));    
    }    
}


/* // Save crafting state on logout, pause concentration checks & time tracking  
void SaveCraftingState(object oPC)  
{  
    if(GetLocalInt(oPC, "PRC_CRAFT_HB"))  
    {  
        // Get all crafting parameters  
        object oItem = GetLocalObject(oPC, "PRC_CRAFT_ITEM");  
        int nCost = GetLocalInt(oPC, "PRC_CRAFT_COST");  
        int nXP = GetLocalInt(oPC, "PRC_CRAFT_XP");  
        int nRounds = GetLocalInt(oPC, "PRC_CRAFT_ROUNDS");  
        string sFile = GetLocalString(oPC, "PRC_CRAFT_FILE");  
        int nLine = GetLocalInt(oPC, "PRC_CRAFT_LINE");  
          
        // Save all parameters to database  
        SQLocalsPlayer_SetObject(oPC, "crafting_item", oItem);  
        SQLocalsPlayer_SetInt(oPC, "crafting_cost", nCost);  
        SQLocalsPlayer_SetInt(oPC, "crafting_xp", nXP);  
        SQLocalsPlayer_SetInt(oPC, "crafting_rounds", nRounds);  
        SQLocalsPlayer_SetString(oPC, "crafting_file", sFile);  
        SQLocalsPlayer_SetInt(oPC, "crafting_line", nLine);  
        SQLocalsPlayer_SetInt(oPC, "crafting_active", 1);  
          
        // Save logout time using PRC time system  
        struct time tLogoutTime = GetTimeAndDate();  
        SetPersistantLocalTime(oPC, "crafting_logout_time", tLogoutTime);  
          
        // Remove concentration monitoring and clear heartbeat  
        RemoveEventScript(oPC, EVENT_VIRTUAL_ONDAMAGED, "prc_od_conc");  
        DeleteLocalInt(oPC, "PRC_CRAFT_HB");  
    }  
} */

object GetItemByUUID(object oPC, string sUUID)  
{  
    if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Searching for item with UUID: " + sUUID);  
      
    // Check player's inventory  
    object oItem = GetFirstItemInInventory(oPC);  
    while(GetIsObjectValid(oItem))  
    {  
        if(GetObjectUUID(oItem) == sUUID)  
        {  
            if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Found item in player inventory: " + GetName(oItem));  
            return oItem;  
        }  
        oItem = GetNextItemInInventory(oPC);  
    }  
      
    // Check equipped slots  
    int i;  
    for(i = 0; i < NUM_INVENTORY_SLOTS; i++)  
    {  
        oItem = GetItemInSlot(i, oPC);  
        if(GetIsObjectValid(oItem) && GetObjectUUID(oItem) == sUUID)  
        {  
            if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Found equipped item: " + GetName(oItem));  
            return oItem;  
        }  
    }  
    
    // Check the craft storage chest
    object oChest = GetCraftChest();
    if(GetIsObjectValid(oChest))
    {
        oItem = GetFirstItemInInventory(oChest);
        while(GetIsObjectValid(oItem))
        {
            if(GetObjectUUID(oItem) == sUUID)
            {
                if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Found item in craft chest: " + GetName(oItem));
                return oItem;
            }
            oItem = GetNextItemInInventory(oChest);
        }
    }
    
    // Check temporary craft chest
    object oTempChest = GetTempCraftChest();
    if(GetIsObjectValid(oTempChest))
    {
        oItem = GetFirstItemInInventory(oTempChest);
        while(GetIsObjectValid(oItem))
        {
            if(GetObjectUUID(oItem) == sUUID)
            {
                if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Found item in temp craft chest: " + GetName(oItem));
                return oItem;
            }
            oItem = GetNextItemInInventory(oTempChest);
        }
    }
      
    if(DEBUG) DoDebug("prc_craft_cv_inc >> GetItemByUUID | Item not found with UUID: " + sUUID);  
    return OBJECT_INVALID;  
}


void CraftingHB(object oPC, object oItem, itemproperty ip, int nCost, int nXP, string sFile, int nLine, int nRounds)  
{  
    // Save current timestamp for offline progress calculation  
    int nCurrentTime = GetCurrentUnixTimestamp();  
    if(nCurrentTime > 0)  
    {  
        SQLocalsPlayer_SetInt(oPC, "crafting_last_timestamp", nCurrentTime);  
    }  
      
    // Set the heartbeat flag  
    SetLocalInt(oPC, PRC_CRAFT_HB, 1);    
      
    // Set database flag for persistence tracking  
    SQLocalsPlayer_SetInt(oPC, "crafting_active", 1);  
      
    // Update local variables for heartbeat logic    
    SetLocalInt(oPC, PRC_CRAFT_TIME, nRounds);    
    SetLocalInt(oPC, PRC_CRAFT_COST, nCost);    
    SetLocalInt(oPC, PRC_CRAFT_XP, nXP);    
    SetLocalString(oPC, PRC_CRAFT_FILE, sFile);    
    SetLocalInt(oPC, PRC_CRAFT_LINE, nLine);    
      
    // Store the item property components for reconstruction  
    if(GetIsItemPropertyValid(ip))  
    {  
        SetLocalInt(oPC, "PRC_CRAFT_IP_TYPE", GetItemPropertyType(ip));  
        SetLocalInt(oPC, "PRC_CRAFT_IP_SUBTYPE", GetItemPropertySubType(ip));  
        SetLocalInt(oPC, "PRC_CRAFT_IP_COSTTABLE", GetItemPropertyCostTableValue(ip));  
        SetLocalInt(oPC, "PRC_CRAFT_IP_PARAM1", GetItemPropertyParam1Value(ip));  
    }  
        
    // Save current crafting state continuously for persistence  
    if(GetPRCSwitch(PRC_CRAFTING_TIME_SCALE) > 1)            
    {            
        // Store the CURRENT rounds value in database  
        SQLocalsPlayer_SetInt(oPC, "crafting_rounds", nRounds);  
        SaveCraftingState(oPC);            
    }    
        
    if(GetBreakConcentrationCheck(oPC))    
    {    
        FloatingTextStringOnCreature("Crafting: Concentration lost!", oPC);    
        DeleteLocalInt(oPC, PRC_CRAFT_HB);    
        RemoveEventScript(oPC, EVENT_VIRTUAL_ONDAMAGED, "prc_od_conc");  
        // Clear database state  
        SQLocalsPlayer_SetInt(oPC, "crafting_active", 0);  
        return;    
    }    
      
    if(nRounds == 0 || GetPCPublicCDKey(oPC) == "") //default to zero time if single player    
    {    
        if(DEBUG) DoDebug("prc_craft_cv_inc >> CraftHB() | Crafting completion - nCost: " + IntToString(nCost) + ", nLine: " + IntToString(nLine));  
		  
		RemoveEventScript(oPC, EVENT_VIRTUAL_ONDAMAGED, "prc_od_conc");    
        if(GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC))    
        {    
            if(!ArtificerPrereqCheck(oPC, sFile, nLine, nCost))    
            {    
                FloatingTextStringOnCreature("Crafting Failed!", oPC);    
                DeleteLocalInt(oPC, PRC_CRAFT_HB);    
                TakeGoldFromCreature(nCost, oPC, TRUE);    
                SetXP(oPC, PRCMax(GetXP(oPC) - nXP, GetHitDice(oPC) * (GetHitDice(oPC) - 1) * 500));  
                SQLocalsPlayer_SetInt(oPC, "crafting_active", 0);  
                return;    
            }    
        }    
        FloatingTextStringOnCreature("Crafting Complete!", oPC);           
		if(DEBUG) DoDebug("prc_craft_cv_inc >> CraftHB() | Entering ApplyProperties() - nCost: " + IntToString(nCost) + ", nLine: " + IntToString(nLine));  
        ApplyProperties(oPC, oItem, ip, nCost, nXP, sFile, nLine);    
		DeleteLocalInt(oPC, PRC_CRAFT_HB);   
	    
        if(GetLocalInt(oPC, "PRC_CRAFT_REMOVE_MASTERWORK"))		    
        {		    
            RemoveMasterworkProperties(oItem);		    
            DeleteLocalInt(oPC, "PRC_CRAFT_REMOVE_MASTERWORK");		    
        }    
          
        // Clear database state on completion  
        SQLocalsPlayer_SetInt(oPC, "crafting_active", 0);  
    }    
    else    
    {    
        if(DEBUG) DoDebug("prc_craft_cv_inc >> CraftHB() | Continuing CraftingHB() - nCost: " + IntToString(nCost) + ", nLine: " + IntToString(nLine));  
		FloatingTextStringOnCreature("Crafting: " + IntToString(nRounds) + " round(s) remaining", oPC);    
        DelayCommand(6.0, CraftingHB(oPC, oItem, ip, nCost, nXP, sFile, nLine, nRounds - 1));    
    }    
}

//;: void main(){}