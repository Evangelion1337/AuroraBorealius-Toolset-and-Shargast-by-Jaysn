#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZGetIsBlindOrDeaf(GetPCSpeaker());
    return iResult;
}
