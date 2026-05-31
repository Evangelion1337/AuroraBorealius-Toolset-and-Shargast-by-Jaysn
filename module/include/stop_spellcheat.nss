#include "x2_inc_switches"

int i;

void ClearSpells()
{
   //No need to run more than 15 times
   i = i + 1;
   if(i > 15) return;

    int nAction = GetCurrentAction();

    if(nAction == 4)
       //If you change the time delay a player might be able to cheat
        DelayCommand(0.1,ClearSpells());
       else if(nAction == 31)
        {
        /*
        Kill the cheater.
        I recommend not removing this.
        There is still a possibility a really coordinated player could get a feel for the timing and still be able to exploit.
        This will help ensure that doesn't happen.
       */
        ClearAllActions(TRUE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(GetMaxHitPoints()+1000,DAMAGE_TYPE_MAGICAL,DAMAGE_POWER_ENERGY),OBJECT_SELF);
        SetModuleOverrideSpellScriptFinished();
        SendMessageToPC(OBJECT_SELF,"Cheating is not allowed here.");
        }
}


void main()
{
ClearSpells();

}
