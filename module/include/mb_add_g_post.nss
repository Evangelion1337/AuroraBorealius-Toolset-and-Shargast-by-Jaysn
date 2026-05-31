#include "mb_inc"

void main()
{
   string sTitle = GetLocalString(OBJECT_SELF, "TITLE");
   string sMessage = GetLocalString(OBJECT_SELF, "BODY");
   MB_AddPost(sTitle,sMessage,GetPCSpeaker(),0);
}
