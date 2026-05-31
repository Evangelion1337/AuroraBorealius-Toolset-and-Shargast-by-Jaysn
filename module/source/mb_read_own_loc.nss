#include "mb_inc"

void main()
{
   object oPC = GetPCSpeaker();
   MB_ReadOwnerPosts(oPC, GetIsDM(oPC));
}
