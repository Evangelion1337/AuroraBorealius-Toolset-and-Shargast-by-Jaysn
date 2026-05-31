int P_MAX_ITEMS = 5;     // Max number of things to respawn.  This should be less
                         // expensive than an array, though less pretty.

int P_TIMER_MAX = 80;    // number of rounds to wait before checking to refill.


void DoOnce();
void CheckContents();
void CheckThing(object oThing);
void CreateNewThing(object oThing);

void main()
{
// check to see if our pseudo-checksum is different now that we've been closed.

    if (GetLocalInt(OBJECT_SELF,"pac_do_once") == 0)
    {
       SetLocalInt(OBJECT_SELF,"pac_do_once",1);
       DoOnce();
       return;
    }

    CheckContents();
}

void DoOnce()
{
     int i = 0;

     object oThing = GetFirstItemInInventory(OBJECT_SELF);

     for (i=0; i<P_MAX_ITEMS; i++)
     {
          SetLocalObject(OBJECT_SELF,"oThing_" + IntToString(i),oThing);
          if (GetIsObjectValid(oThing)) { oThing = GetNextItemInInventory(OBJECT_SELF); }
     }

}


void CheckContents()
{
     int iCounter = GetLocalInt(OBJECT_SELF,"iCounter");
     iCounter++;


     // don't recreate the items immediately...
     if (iCounter>P_TIMER_MAX)
     {

          object oThing = OBJECT_INVALID;
          int i = 0;

          for (i=0; i<P_MAX_ITEMS; i++)
          {
               oThing = GetLocalObject(OBJECT_SELF,"oThing_" + IntToString(i));
               CheckThing(oThing);
          }

          iCounter = 0;
     }

     SetLocalInt(OBJECT_SELF,"iCounter",iCounter);
}



void CheckThing(object oThing)
{
     // See if the object is already in the inventory.  If so, don't worry about it.

     if (!GetIsObjectValid(oThing)) { return; }

     int iFound=FALSE;

     object oBoxThing = GetFirstItemInInventory(OBJECT_SELF);

     while (GetIsObjectValid(oBoxThing))
     {

          if (GetName(oThing)==GetName(oBoxThing) && GetTag(oThing)==GetTag(oBoxThing))
          {
               iFound=TRUE;
          }
          oBoxThing = GetNextItemInInventory(OBJECT_SELF);
     }

     if (!iFound)
     {
          CreateNewThing(oThing); // It's not in the box
     }

}

void CreateNewThing(object oThing)
{
     //ActionSpeakString("Creating a " + GetName(oThing));
     //ActionGiveItem(oThing,OBJECT_SELF);
     CreateItemOnObject(GetTag(oThing),OBJECT_SELF,1);
}

