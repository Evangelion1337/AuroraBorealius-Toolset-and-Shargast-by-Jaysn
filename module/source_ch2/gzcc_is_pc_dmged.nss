#include "gzinc_effecttool"

int StartingConditional()
{
    int iResult;
    iResult = GZGetIsDamaged(GetPCSpeaker());
    return iResult;
}
