float fDelay=320.0f;//CHANGE

string sSelf=GetResRef(OBJECT_SELF);

int nType=GetObjectType(OBJECT_SELF);

location lLoc=GetLocation(OBJECT_SELF);


void main()
{

object oMod=GetModule();

SetLocalString(oMod, "resref", sSelf);
SetLocalInt(oMod, "type", nType);
SetLocalLocation(oMod, "location", lLoc);
SetLocalFloat(oMod, "delay", fDelay);

ExecuteScript("respawn", oMod);
}
