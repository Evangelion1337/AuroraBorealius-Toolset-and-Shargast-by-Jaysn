//::///////////////////////////////////////////////
//:: Chat Command include
//:: prc_inc_chat
//::///////////////////////////////////////////////

const string PRC_CHAT_HOOK_ACTIVE = "prc_chat_hook";
const string PRC_CHAT_HOOK_SCRIPT = "prc_chat_script";
const string PRC_PLAYER_RESPONSE  = "prc_player_response";

void AddChatEventHook(object oPC, string sScriptToCall, float fDur = 0.0f);

struct _prc_inc_WordInfo{
    int nWordStart;
    int nWordLength;
};

//we assume that sDivider is always 1 character
struct _prc_inc_WordInfo GetStringWordInfo(string sString, int nWordToGet, string sDivider = " ")
{
    struct _prc_inc_WordInfo info;

    // Safety checks
    if(sString == "")
        return info;

    if(sDivider == "")
        sDivider = " ";

    int nStrLength = GetStringLength(sString);

    nWordToGet--;

    // Start with the first word.
    int nCurrentWord = 0;
    int nCurrentStart = 0;
    int nCurrentEnd = FindSubString(sString, sDivider);
    // Advance to the specified element.
    while (nCurrentWord < nWordToGet && nCurrentEnd > -1)
    {
        nCurrentWord++;
        nCurrentStart = nCurrentEnd + 1;
        nCurrentEnd = FindSubString(sString, sDivider, nCurrentStart);
    }
    // Adjust the end point if this is the last element.
    if (nCurrentEnd == -1) nCurrentEnd = nStrLength;

    if (nCurrentWord >= nWordToGet)
    {
        info.nWordStart = nCurrentStart;
        info.nWordLength = nCurrentEnd-nCurrentStart;
    }

    return info;
}

string GetStringWord(string sString, int nWordToGet, string sDivider = " ")
{
    struct _prc_inc_WordInfo info = GetStringWordInfo(sString, nWordToGet, sDivider);
    return GetSubString(sString, info.nWordStart, info.nWordLength);
}

string GetStringWordToEnd(string sString, int nWordToGet, string sDivider = " ")
{
    struct _prc_inc_WordInfo info = GetStringWordInfo(sString, nWordToGet, sDivider);
    return GetSubString(sString, info.nWordStart, GetStringLength(sString)-info.nWordStart);
}

//Returns TRUE if sPrefix matches sWord or some part of the beginning of sWord
/*int GetStringMatchesAbbreviation(string sString, string sAbbreviationPattern)
{
    int nShortestAbbreviation = FindSubString(sAbbreviationPattern, "-");
    if(nShortestAbbreviation > 0)
        sAbbreviationPattern = GetStringLeft(sAbbreviationPattern, nShortestAbbreviation) + GetStringRight(sAbbreviationPattern, GetStringLength(sAbbreviationPattern)-(nShortestAbbreviation+1));
    else if (nShortestAbbreviation == 0)
    {
        sAbbreviationPattern = GetStringRight(sAbbreviationPattern, GetStringLength(sAbbreviationPattern)-1);
        nShortestAbbreviation = GetStringLength(sAbbreviationPattern);
    }
    else
        nShortestAbbreviation = GetStringLength(sAbbreviationPattern);

    if(GetStringLength(sString) >= nShortestAbbreviation)
        return GetStringLeft(sAbbreviationPattern, GetStringLength(sString)) == sString;
    else
        return FALSE;
}*/

int GetStringMatchesAbbreviation(string sString, string sAbbreviationPattern)
{
    string sTest;
    int iAbbrevEnd = FindSubString(sAbbreviationPattern, "-");

    if(iAbbrevEnd == -1)
        sTest = sAbbreviationPattern;
    else
        sTest = GetSubString(sAbbreviationPattern, 0, iAbbrevEnd);

    return FindSubString(sString, sTest) == 0;
}

void HelpText(object oPC, string sString)
{
    SendMessageToPC(oPC, PRC_TEXT_WHITE + sString + "</c>");
}

void _clear_chat_vars(object oPC)
{
    DeleteLocalInt(oPC, PRC_CHAT_HOOK_ACTIVE);
    DeleteLocalString(oPC, PRC_CHAT_HOOK_SCRIPT);
}

void AddChatEventHook(object oPC, string sScriptToCall, float fDur = 0.0f)
{
    SetLocalInt(oPC, PRC_CHAT_HOOK_ACTIVE, TRUE);
    SetLocalString(oPC, PRC_CHAT_HOOK_SCRIPT, sScriptToCall);
    if(fDur > 0.0f) DelayCommand(fDur, _clear_chat_vars(oPC));
}