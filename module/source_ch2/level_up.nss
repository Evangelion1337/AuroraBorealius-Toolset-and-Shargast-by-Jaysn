//Script created by -=Fujisawa=-
//This script was designed to detect the players level by XP,
//and then return if they are levels 1-2, or 3+
//==This is used for conversations.==
//It can also be broken up and used for other scripts that
//require a level check.

//Standard make sure its a conditional script.
int StartingConditional()
{
    // Establish that we want a number and call it iPlayerXP.
    int iPlayerXP;
    // Get player
    object oPlayer = GetLastSpeaker();
    // Get that players XP and associate it with number called iPlayerXP.
    iPlayerXP = GetXP(oPlayer);
    // If the players XP is below 999 (level 1)
    if (iPlayerXP <= 999)
    {
    // Then return they are level 1.
    return TRUE;
    }
    else
    {
    // They are level 2+
    return FALSE;
    }
}
