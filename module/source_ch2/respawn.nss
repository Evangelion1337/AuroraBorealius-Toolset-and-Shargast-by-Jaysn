void Remake(int nType, string sResRef, location lLoc)
{
CreateObject(nType, sResRef, lLoc);
}

void main()
{
object oMod=GetModule();

string sResRef=GetLocalString(oMod, "resref");
int nType=GetLocalInt(oMod, "type");
location lLoc=GetLocalLocation(oMod, "location");
float fDelay=GetLocalFloat(oMod, "delay");

DelayCommand(fDelay, Remake(nType, sResRef, lLoc));
}

