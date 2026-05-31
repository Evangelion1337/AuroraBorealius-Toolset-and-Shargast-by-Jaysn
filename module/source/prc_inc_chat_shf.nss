//::///////////////////////////////////////////////
//:: PnP Shifter Chat Command include
//:: prc_inc_chat_shf
//::///////////////////////////////////////////////

#include "prc_inc_chat"
#include "prc_inc_shifting"

const string CMD_GREATER_WILDSHAPE = "gw";
const string CMD_SHIFT = "s-hift";
const string CMD_EPIC_SHIFT = "e-pic";
const string CMD_UNSHIFT = "u-nshift";
const string CMD_LIST = "l-ist";
const string CMD_INFO = "i-nfo";
const string CMD_MARK = "mark";
const string CMD_UNMARK = "unmark";
const string CMD_DELETE = "delete";

int PnPShifter_ProcessChatCommand_Help(object oPC, string sCommand)
{
    string sCommandName = GetStringWord(sCommand, 2);
    int nLevel = sCommandName != "";
    int bResult = FALSE;
    
    if (!nLevel)
    {
        HelpText(oPC, "=== PNP SHIFTER COMMANDS");
        HelpText(oPC, "");
    }

    if(GetStringMatchesAbbreviation(sCommandName, CMD_GREATER_WILDSHAPE) || !nLevel)
    {
        if (nLevel)
        {
            bResult = TRUE;
            HelpText(oPC, "=== PNP SHIFTER COMMAND: " + CMD_GREATER_WILDSHAPE + " (Greater Wildshape)");
            HelpText(oPC, "");
        }

        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_LIST + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "   Lists known shapes that match <shape-name>; if <shape-name> is omitted, lists all known shapes.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_INFO + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "    Lists shapes that match <shape-name>; if an unambiguous match is found, prints information about it.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_SHIFT + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "   Searches for shapes that match <shape-name>; if an unambiguous match is found, shifts into it.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_EPIC_SHIFT + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "   Searches for shapes that match <shape-name>; if an unambiguous match is found, epic shifts into it.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_UNSHIFT);
        if (nLevel)
            HelpText(oPC, "   Unshifts back into true form.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_MARK + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "   Marks the specified shape for deletion.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_UNMARK + " <shape-name>");
        if (nLevel)
            HelpText(oPC, "   Removes the shape's deletion mark, if any.");
        HelpText(oPC, "~~" + CMD_GREATER_WILDSHAPE + " " + CMD_DELETE + " yes");
        if (nLevel)
            HelpText(oPC, "   Deletes all shapes marked for deletion. Note that the word 'yes' is required as part of the command in order to confirm the deletion.");
        if (nLevel)
        {
            HelpText(oPC, "");
            HelpText(oPC, "'" + CMD_GREATER_WILDSHAPE + "' stands for 'Greater Wildshape'");
            HelpText(oPC, "<shape-name> must match a known shape, is case-insenstive, and can be:");
            HelpText(oPC, "   '.': matches the shape the PC is currently shifted into");
            HelpText(oPC, "   A number: matches the shape with the given number. The numbers can be found found using command '~~gw list''.");
            HelpText(oPC, "   'Q1' through 'Q10': matches the shape in the specified quickslot");
            HelpText(oPC, "   A resref: if you don't know what this means, ignore this option. The resref can be found found using command '~~gw list'.");
            HelpText(oPC, "   Part of the name of a shape:");
            HelpText(oPC, "       If there is exactly one exact match, that will be used.");
            HelpText(oPC, "       Otherwise, if there is exactly one shape whose name starts with <shape-name>, that will be used.");
            HelpText(oPC, "       Otherwise, if there is exactly one shape whose name contains <shape-name>, that will be used.");
            HelpText(oPC, "       Otherwise, no shape matches and nothing will happen.");
        }
        HelpText(oPC, "");
    }
    
    return bResult;
}

void _prc_inc_ChatShift(object oPC, string sShapeName, int bEpic)
{
    //See if a valid shape was specified
    if(sShapeName == "")
        return;

    string sResRef = FindResRefFromString(oPC, SHIFTER_TYPE_SHIFTER, sShapeName, FALSE);
    if(sResRef == "")
        return;

    //Make sure we're not affected by a condition that prevents shifting
    effect eTest = GetFirstEffect(oPC);
    int nEType;
    while(GetIsEffectValid(eTest))
    {
        nEType = GetEffectType(eTest);
        if(nEType == EFFECT_TYPE_CUTSCENE_PARALYZE
        || nEType == EFFECT_TYPE_DAZED
        || nEType == EFFECT_TYPE_PARALYZE
        || nEType == EFFECT_TYPE_PETRIFY
        || nEType == EFFECT_TYPE_SLEEP
        || nEType == EFFECT_TYPE_STUNNED)
            return;
        eTest = GetNextEffect(oPC);
    }

    //If we have at least one use of a suitable feat remaining, shift
    int nPaidFeat = GWSPay(oPC, bEpic);
    if(nPaidFeat)
    {
        if(!ShiftIntoResRef(oPC, SHIFTER_TYPE_SHIFTER, sResRef, bEpic))
            GWSRefund(oPC, nPaidFeat);
    }
    else
        FloatingTextStrRefOnCreature(16828373, oPC, FALSE); // "You didn't have (Epic) Greater Wildshape uses available."
}

void _prc_inc_ListShapes(object oShifter, int nShifterType, string sFindString)
{
    FindResRefFromString(oShifter, nShifterType, sFindString, TRUE);
}

void _prc_inc_ChatMark(object oPC, string sShapeName, int bMark)
{
    if (sShapeName == "")
        return;

    string sResRef = FindResRefFromString(oPC, SHIFTER_TYPE_SHIFTER, sShapeName, FALSE);
    if (sResRef == "")
        return;

    int nIndex = _prc_inc_shifting_GetIsTemplateStored(oPC, SHIFTER_TYPE_SHIFTER, sResRef);
    if (!nIndex)
        return;

    SetStoredTemplateDeleteMark(oPC, SHIFTER_TYPE_SHIFTER, nIndex-1, bMark);
}

int PnPShifter_ProcessChatCommand(object oPC, string sCommand)
{
    if(!GetLevelByClass(CLASS_TYPE_PNP_SHIFTER, oPC))
        return FALSE;

    int bResult = FALSE;
    if(GetStringWord(sCommand, 1) == CMD_GREATER_WILDSHAPE)
    {
        bResult = TRUE;
        string sWord = GetStringWord(sCommand, 2);

        object oTemplate;
        string sShape, sResRef;
        if(GetStringMatchesAbbreviation(sWord, CMD_SHIFT))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            _prc_inc_ChatShift(oPC, sShape, FALSE);
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_EPIC_SHIFT))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            _prc_inc_ChatShift(oPC, sShape, TRUE);
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_UNSHIFT))
        {
            UnShift(oPC);
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_LIST))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            DelayCommand(0.0f, _prc_inc_ListShapes(oPC, SHIFTER_TYPE_SHIFTER, sShape));
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_INFO))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            if(sShape != "")
            {
                sResRef = FindResRefFromString(oPC, SHIFTER_TYPE_SHIFTER, sShape, FALSE);
                if(sResRef != "")
                {
                    oTemplate = _prc_inc_load_template_from_resref(sResRef, GetHitDice(oPC));
                    if(GetIsObjectValid(oTemplate))
                    {
                        DelayCommand(0.0, _prc_inc_PrintShape(oPC, oTemplate, FALSE));
                        DelayCommand(10.0, MyDestroyObject(oTemplate));
                    }
                }
            }
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_MARK))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            _prc_inc_ChatMark(oPC, sShape, TRUE);
            HelpText(oPC, "Shape marked for deletion");
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_UNMARK))
        {
            sShape = GetStringWordToEnd(sCommand, 3);
            _prc_inc_ChatMark(oPC, sShape, FALSE);
            HelpText(oPC, "Shape no longer marked for deletion");
        }
        else if(GetStringMatchesAbbreviation(sWord, CMD_DELETE))
        {
            if (GetStringWordToEnd(sCommand, 3) == "yes")
            {
                DelayCommand(0.0f, DeleteMarkedStoredTemplates(oPC, SHIFTER_TYPE_SHIFTER));
                HelpText(oPC, "Marked shapes deleted");
            }
            else
                HelpText(oPC, "Marked shapes not deleted: please enter 'yes' after the word 'delete' to confirm");
        }
        else
        {
            HelpText(oPC, "Unrecognize " + CMD_GREATER_WILDSHAPE + " command: " + sWord);
        }
    }
    return bResult;
}
