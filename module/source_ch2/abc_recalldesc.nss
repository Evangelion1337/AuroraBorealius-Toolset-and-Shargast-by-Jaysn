#include "nwnx_sql"

// Place this at the bottom of your script file
string ReplaceString(string sSource, string sTemplate, string sReplacement)
{
    int nLen = GetStringLength(sTemplate);
    if (nLen == 0) return sSource;

    int nPos = FindSubString(sSource, sTemplate);
    while (nPos != -1)
    {
        sSource = GetSubString(sSource, 0, nPos) + sReplacement + GetSubString(sSource, nPos + nLen, GetStringLength(sSource));
        nPos = FindSubString(sSource, sTemplate);
    }
    return sSource;
}

// Updates the Recall Stone's Description
void UpdateRecallStoneDescription(object oPC, string sCDKey, string sCharName)
{
    // Search the player's inventory for the specific item tag
    object oStone = GetItemPossessedBy(oPC, "recallstone");
    if (!GetIsObjectValid(oStone))
    {
        return; // No stone found on the player, exit safely
    }

    // 1. Fetch the stored locations for this specific character from the database
    NWNX_SQL_PrepareQuery(
        "SELECT mark_area_tag, jump_area_tag " +
        "FROM player_recall_stones " +
        "WHERE cdkey = ? AND charname = ?");

    NWNX_SQL_PreparedString(1, sCDKey);
    NWNX_SQL_PreparedString(2, sCharName);

    string sMarkArea = "No Leypoint Anchored";
    string sJumpArea = "No Echo Bound";

    if (NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();

        string sDbMark = NWNX_SQL_ReadDataInActiveRow(0);
        string sDbJump = NWNX_SQL_ReadDataInActiveRow(1);

        // Assign clean text if the fields are not empty in the row data
        if (sDbMark != "") sMarkArea = sDbMark;
        if (sDbJump != "") sJumpArea = sDbJump;
    }
    NWNX_SQL_DestroyPreparedQuery();

    // 2. Define your formatted layout string template with bracketed placeholders
    string sTemplate =
        "An ancient Elvish relic from lost Shargast, humming with localized chronomancy. " +
        "Though the order vanished long before the realm of HOPE, its power endures.\n\n" +

        "Current Attunements:\n" +
        "  * Echo of Departure:\n" +
        "      {jump_loc}\n" +
        "  * Anchored Leypoint:\n" +
        "      {mark_loc}\n\n" +

        "Mystical Actions:\n\n" +

        "I. Rite of Binding (Target Yourself):\n" +
        "Saves your current location as your Anchored Leypoint.\n\n" +

        "II. Step Into the Veil (Target Ground / Anything Else):\n" +
        "Teleports you instantly back to your Anchored Leypoint. Leaving an Echo of Departure.\n\n" +

        "III. Trace the Echo (Target the Stone Itself):\n" +
        "Teleports you back to your Echo of Departure.";

    // 3. Manually replace the placeholders with the text (or fallback strings)
    string sFinalDescription = ReplaceString(sTemplate, "{jump_loc}", sJumpArea);
    sFinalDescription = ReplaceString(sFinalDescription, "{mark_loc}", sMarkArea);

    // 4. Overwrite the description directly on this specific stone instance
    SetDescription(oStone, sFinalDescription);
}


