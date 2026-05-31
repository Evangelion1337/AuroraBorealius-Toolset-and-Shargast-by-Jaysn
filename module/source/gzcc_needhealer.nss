#include "gzinc_effecttool"

void SetUpCustomTokens()
{
    int nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_FULLCHECK");
    SetCustomToken(141,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_HEAL");
    SetCustomToken(142,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_RESLVL");
    SetCustomToken(143,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_RESAB");
    SetCustomToken(144,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_DISEASE");
    SetCustomToken(145,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_BLIND");
    SetCustomToken(146,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_POISON");
    SetCustomToken(147,IntToString(nGP));
    nGP = GetLocalInt(GetModule(),"T1_MODULE_HEALER_CURSE");
    SetCustomToken(148,IntToString(nGP));
}

int StartingConditional()
{
    int iResult;
    iResult = GZHasNegativeEffects(GetPCSpeaker());
    SetUpCustomTokens();
    return iResult;
}
