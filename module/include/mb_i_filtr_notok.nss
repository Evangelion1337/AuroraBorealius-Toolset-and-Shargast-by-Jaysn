int StartingConditional()
{
    int iResult;

    if(GetLocalInt(GetPCSpeaker(), "BAD_WORDS")==1) iResult = 1;

    return iResult;
}
