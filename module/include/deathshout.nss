//ffbj addition 16.04.07

    void main()
        {
           object oPC = GetLastPlayerDied();
           object oArea = GetArea(oPC);
           string sPC = GetName(oPC);
           object oKiller = GetLastDamager(oPC);
           string sKillerName = GetName(oKiller);
           string sArea = GetName(oArea);
           object oPlayer = GetFirstPC();
           string sMessage = (sPC + " Died At " +sArea + " Killed By " +sKillerName);
         //if (!GetIsPC(oKiller)|| (!(GetBaseItemType(oKiller) == BASE_ITEM_TRAPKIT)))
         //return;//ucomment this statement if you want only pc/trap caused deaths shouted.

           SpeakString(sMessage, TALKVOLUME_SHOUT);
           while (oPlayer != OBJECT_INVALID)
           {

              FloatingTextStringOnCreature(sMessage, oPlayer, FALSE);
              oPlayer = GetNextPC();
           }
        }
