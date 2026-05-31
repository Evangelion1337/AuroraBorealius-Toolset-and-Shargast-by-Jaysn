#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZGetIsCursed(GetPCSpeaker());
    return iResult;
}
