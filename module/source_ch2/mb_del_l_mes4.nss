#include "mb_inc"

void main()
{
   int nID = GetLocalInt(GetPCSpeaker(),"POST_ID_4");
   MB_DeletePost(GetPCSpeaker(), nID);
}
