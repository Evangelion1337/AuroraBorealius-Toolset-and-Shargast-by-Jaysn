void main()
{
object oPC = GetPCSpeaker();
int iHeard = StringToInt(GetMatchedSubstring(0));

string sAppearance = Get2DAString("appearance","LABEL",iHeard);

if (sAppearance == "")
    {
    SendMessageToPC(oPC,"Invalid appearance chosen - " + IntToString(iHeard));
    return;
    }

SetLocalInt(oPC,"iheard",iHeard);

SetCustomToken(5713,IntToString(iHeard));
SetCustomToken(5714,sAppearance);

SetListening(OBJECT_SELF,FALSE);
}
