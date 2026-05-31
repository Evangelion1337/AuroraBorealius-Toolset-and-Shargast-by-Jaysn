#include "NW_O2_CONINCLUDE"

void main()

{
    object oItem = OBJECT_INVALID;
    int respawntime = 200;

    // Check object for the time it was last opened and see if it is time to respawn
    int lastopened = GetLocalInt(OBJECT_SELF,"CS_Opened");
    // CS_Openend = 0 on not found, GetLocalInt error return
    int currenttime = GetTimeSecond()+60*GetTimeMinute()+3600*GetTimeHour();
    if (currenttime > lastopened + respawntime)
    {
        // respawntime seconds passed?
        SetLocalInt(OBJECT_SELF,"NW_DO_ONCE",0);
    }
     if (lastopened > currenttime)
    {
        // maybe a whole day passed? or it's midnight?
        SetLocalInt(OBJECT_SELF,"NW_DO_ONCE",0);
    }

    // Respawn chest
    if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") == 0)
    {
      oItem = GetFirstItemInInventory();
      while ( oItem != OBJECT_INVALID )
      {
         DestroyObject( oItem, 0.0 );
         oItem = GetNextItemInInventory();
      }
      object oLastOpener = GetLastOpener();
      // See NW_O2_CONINCLUDE for more Treasure generating scripts,
      // Thisone generates high treasure depending on the lastopener level
      GenerateMediumTreasure(oLastOpener, OBJECT_SELF);
      SetLocalInt(OBJECT_SELF,"CS_Opened",GetTimeSecond()+60*GetTimeMinute()+3600*GetTimeHour());
      SetLocalInt(OBJECT_SELF,"NW_DO_ONCE",1);
    }
}
