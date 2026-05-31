#include "mb_inc"

void main()
{
   int nID = GetLocalInt(GetPCSpeaker(),"POST_ID_2");
   MB_DeletePost(GetPCSpeaker(), nID, 0);
}
