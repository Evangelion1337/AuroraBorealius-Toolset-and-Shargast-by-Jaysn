int StartingConditional()
{
    int iResult;

    if(GetLocalInt(GetPCSpeaker(), "MB_POSTED")==1) iResult = 1;

    return iResult;
}
