#include "mb_inc"

void main()
{
   int nID = GetLocalInt(GetPCSpeaker(),"POST_ID_1");
   MB_DeletePost(GetPCSpeaker(), nID);
}
