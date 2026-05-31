#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZGetIsDiseased(GetPCSpeaker());
    return iResult;
}
