#include "gzinc_effecttool"


int StartingConditional()
{
    int iResult;
    iResult = GZGetHasAbilityDamage(GetPCSpeaker());
    return iResult;
}
