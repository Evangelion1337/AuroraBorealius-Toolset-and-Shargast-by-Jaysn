#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZGetIsPoisoned(GetPCSpeaker());
    return iResult;
}
