#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZHasNegativeLevels(GetPCSpeaker());
    return iResult;
}
