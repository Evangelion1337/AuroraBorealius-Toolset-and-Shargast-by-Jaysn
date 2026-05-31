int StartingConditional()
{
    int iResult;

    if(GetLocalInt(GetPCSpeaker(), "BAD_WORDS")==0) iResult = 1;

    return iResult;
}
