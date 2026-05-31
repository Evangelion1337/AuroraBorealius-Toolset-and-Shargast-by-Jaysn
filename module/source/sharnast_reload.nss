//This script first checks to make sure that the ModuleReloader item made
//this function call, if so reload module.
void main()
{
 if (GetTag(GetItemActivated()) == "ModuleReloader")
  {
   StartNewModule("Sharnast");
   return;
  }
}

