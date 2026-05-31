//add in to the top of the ondeath of the creature ffbj
void main()
{
//the following is the body of the script.  I just left the void
//main in so it would compile.
object oBoss = OBJECT_SELF;//code begins
object oPC = GetLastHostileActor(oBoss);
object oArea = GetArea(oBoss);
string sBoss = GetName(oBoss);
string sPC = GetName(oPC);
string sArea = GetName(oArea);
object oPlayer = GetFirstPC();
if (GetIsDead(oBoss))
     while (oPlayer != OBJECT_INVALID)

        { string sMessage = (sBoss + " was killed by "+sPC+" in "+sArea);
        SendMessageToPC(oPlayer, sMessage);
        oPlayer = GetNextPC();
        }//end of code

}

