void main()
{
   int ude = GetUserDefinedEventNumber();
   if (ude == 1300)
   {

      object riddledoor = GetObjectByTag("riddledoor");
      if(!GetIsOpen(riddledoor))
      {
         int listen = GetListenPatternNumber();
         if (listen == 1000)
         {
            SetLocked(riddledoor,FALSE);
            AssignCommand(riddledoor,ActionOpenDoor(riddledoor));
            SetListening(OBJECT_SELF,FALSE);
            DestroyObject(OBJECT_SELF,0.2);
         }
      }
   }
}
