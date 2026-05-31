void main()
{
   object oEntered = GetEnteringObject();

  int nGetIsPC = GetIsPC(oEntered);
   if(nGetIsPC == FALSE) //Checks if it's a creature or a PC
   {
       DestroyObject(oEntered);  //If it's a creature, it will destroy it
        //You can put something else here (ie:visual effect)
   }
  else
  {
     //if(nGetIsPC == TRUE)
     //In case you want to have it speak a string like "approved" or something
  }
}
