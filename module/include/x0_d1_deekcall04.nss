// Deekin now calls the PC by their gender

void main()
{
    string sCall;
    int nSex = GetGender(GetPCSpeaker());
    if (nSex == GENDER_FEMALE)
    {
        sCall = GetStringByStrRef(4886);
    }
    else
    {
        sCall = GetStringByStrRef(4885);
    }

    SetCampaignString("Deekin", "q6_Deekin_Call"+ GetName(GetPCSpeaker()), sCall, GetPCSpeaker());
    SetCustomToken(1001, sCall);
}
