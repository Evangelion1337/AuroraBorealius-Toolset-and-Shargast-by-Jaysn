//::///////////////////////////////////////////////
//:: AnchorDeep Message Board
//::
//:: MB_INC.nss
//:://////////////////////////////////////////////
//:: This holds all the main message board
//:: functions.
//::
//:://////////////////////////////////////////////
//:: Created By: 69_Jeremy_69 On: August 20, 2003
//////////////////////////////////////////////////

//::///////////////////////////////////////////////////////////////
//::///////////////////:: Constants :://///////////////////////////
//::///////////////////////////////////////////////////////////////
// **AFTER EDITING ANY OF THESE FIELDS YOU WILL HAVE TO REBUILD**
//::////////////////////////////////////////////////////////////////
#include "sql_campaign"
    string sMB_DB           = "Message_Board";  // Database Name
    float FLOOD_CONTROL     = 420.0;            // Duration a player has to wait after a post
    int HIDE_NAMES          = FALSE;            // Dont add player names to posts
    int HIDE_DMs            = TRUE;             // Display 'DM' not the DM's name
    int DEBUG_MODE          = FALSE;            // Show Debug messages
//:: FILTER
          // Add words to be blocked
    string sFILTER ="**(shit|fuck| asshole| fag | faggot| cunt| pussey| pussy| cock| rape| homo| bitch|nigger| chink| jew )**";
//::///////////////////////////////////////////////////////////////////////
//::///////////////////////////////////////////////////////////////////////

// Add a post to the board
void MB_AddPost(string sTitle, string sMessage, object oPoster, int Local = TRUE);
// Link a post to the creator
void MB_TrackOwner(int nID, object oPoster);
// Read Local or Global post
// * Local by default
void MB_ReadPost(object oReader, int Local = TRUE);
// Delete a message board
void MB_DeleteBoard(object oReader, int Local = TRUE);
// Only read the Owner's posts, Local or Global
// * DM's can access all posts
void MB_ReadOwnerPosts(object oOwner,  int DM = FALSE, int Local = TRUE);
// Delete a post
void MB_DeletePost(object oPoster, int nID, int Local = TRUE);
// Returns TRUE if the text to be checked has illegal words
int MB_FailFilterTest(object oSpeaker, string sCheck);


////////////////////
//:: FUNCTIONS :://
///////////////////
void MB_AddPost(string sTitle, string sMessage, object oPoster, int Local = 1)
{
   if(!GetIsObjectValid(oPoster)) return;
   string TITLE, POST, TOTAL_POST;

   if(Local == 1){
      TITLE = "TT_"+GetTag(GetArea(oPoster));
      POST = "PT_"+GetTag(GetArea(oPoster));
      TOTAL_POST = "TTP_"+GetTag(GetArea(oPoster));
   }else{
      TITLE = "TITLE_";
      POST = "POST_";
      TOTAL_POST = "TOTAL_POSTS";
   }

   if(HIDE_NAMES==0)
   {
      if(GetIsDM(oPoster) && HIDE_DMs==1)
         sTitle+="\n[DM]";
      else
         sTitle+="\n["+GetName(oPoster)+"]";
   }
   int nCount = SQL_GetCampaignInt(sMB_DB, TOTAL_POST);
   nCount++;
   if(DEBUG_MODE) SpeakString("Debug: Node Info = "+TITLE+IntToString(nCount)+", "+POST+IntToString(nCount));
   SQL_SetCampaignString(sMB_DB, TITLE + IntToString(nCount), sTitle);
   SQL_SetCampaignString(sMB_DB, POST + IntToString(nCount), sMessage);
   SQL_SetCampaignInt(sMB_DB, TOTAL_POST, nCount);
   MB_TrackOwner(nCount, oPoster);
}

void MB_TrackOwner(int nID, object oPoster)
{
   int nCount = SQL_GetCampaignInt(sMB_DB, "TOTAL_ACCOUNT_POSTS", oPoster);
   nCount++;
   SQL_SetCampaignInt(sMB_DB, "POST_ID_"+IntToString(nCount), nID, oPoster);
   SQL_SetCampaignInt(sMB_DB, "TOTAL_ACCOUNT_POSTS", nCount, oPoster);
   if(!GetIsDM(oPoster)) SetLocalInt(oPoster, "MB_POSTED", 1);
   if(!GetIsDM(oPoster)) DelayCommand(FLOOD_CONTROL, DeleteLocalInt(oPoster, "MB_POSTED"));
}

void MB_ReadPost(object oReader, int Local = 1)
{
   string TITLE, POST, TOTAL_POST;
   if(DEBUG_MODE) SpeakString(ObjectToString(GetArea(oReader)));

   if(Local == 1){
      TITLE = "TT_"+GetTag(GetArea(oReader));
      POST = "PT_"+GetTag(GetArea(oReader));
      TOTAL_POST = "TTP_"+GetTag(GetArea(oReader));
   }else{
      TITLE = "TITLE_";
      POST = "POST_";
      TOTAL_POST = "TOTAL_POSTS";
   }

   int nCount = SQL_GetCampaignInt(sMB_DB, TOTAL_POST);
   if(nCount==0)
   {
      SetCustomToken(7011, "NO POSTS");
      return;
   }
   if(DEBUG_MODE) SpeakString("Debug: Total Posts = "+IntToString(nCount));
   int nRead = GetLocalInt(OBJECT_SELF,"MB_LOOP");
   int nLoop, nID;
   string sTitle, sPost;
   if(nRead==0) nRead = nCount;

   // Read 7 Posts
   nLoop = 1;
   nID = 1;
   while(nLoop < 1000 && nID < 8)
   {
      // Were at the end start over
      if(nRead < 1)
      {
         SetCustomToken(7010+nID, "LAST POST");
         nID++;
         // Clear stored titles
         while(7010+nID < 7018)
         {
            SetCustomToken(7010+nID, "");
            nID++;
         }
         nRead--;
         SetLocalInt(OBJECT_SELF,"MB_LOOP",nRead);
         return;
      }
      sTitle = SQL_GetCampaignString(sMB_DB, TITLE + IntToString(nRead));
      if(DEBUG_MODE) SpeakString("Debug: Post Title = "+sTitle);
      sPost = SQL_GetCampaignString(sMB_DB, POST + IntToString(nRead));
      if(sTitle!="")
      {
         SetCustomToken(7010+nID, sTitle);
         SetCustomToken(7020+nID, sPost);
         nID++;
      }
      nRead--;
      nLoop++;
   }
   SetLocalInt(OBJECT_SELF,"MB_LOOP",nRead);
}

void MB_DeleteBoard(object oReader, int Local = 1)
{
   string TITLE, POST, TOTAL_POST;

   if(Local == 1){
      TITLE = "TT_"+GetTag(GetArea(oReader));
      POST = "PT_"+GetTag(GetArea(oReader));
      TOTAL_POST = "TTP_"+GetTag(GetArea(oReader));
   }else{
      TITLE = "TITLE_";
      POST = "POST_";
      TOTAL_POST = "TOTAL_POSTS";
   }

   int nCount = SQL_GetCampaignInt(sMB_DB, TOTAL_POST);
   while(nCount > 0)
   {
      DeleteCampaignVariable(sMB_DB, TITLE + IntToString(nCount));
      DeleteCampaignVariable(sMB_DB, POST + IntToString(nCount));
      nCount--;
   }
   DeleteCampaignVariable(sMB_DB, TOTAL_POST);
}

void MB_ReadOwnerPosts(object oOwner, int DM = 0, int Local = 1)
{
   string TITLE, POST, TOTAL_POST, sTitle;;

   if(Local == 1){
      TITLE = "TT_"+GetTag(GetArea(oOwner));
      POST = "PT_"+GetTag(GetArea(oOwner));
      TOTAL_POST = "TTP_"+GetTag(GetArea(oOwner));
   }else{
      TITLE = "TITLE_";
      POST = "POST_";
      TOTAL_POST = "TOTAL_POSTS";
   }

   int nRead = GetLocalInt(oOwner,"MB_LOOP"), nID, nLoop, nNext;
   if(DM==0)
   {
      int nCount = SQL_GetCampaignInt(sMB_DB, "TOTAL_ACCOUNT_POSTS", oOwner);
      if(nCount==0)
      {
         SetCustomToken(7011, "NO POSTS");
         return;
      }
      if(nRead==0) nRead++;

      // Read 7 Posts
      nLoop = 1;
      nNext = 1;
      while(nLoop < 1000 && nNext < 8)
      {
         // Were at the end start over
         if(nRead > nCount)
         {
            SetCustomToken(7010+nID, "END OF LIST");
            nID++;
            // Clear stored titles
            while(7010+nID < 7018)
            {
               SetCustomToken(7010+nID, "");
               nID++;
            }
            nRead++;
            SetLocalInt(OBJECT_SELF,"MB_LOOP",nRead);
            return;
         }

         nID = SQL_GetCampaignInt(sMB_DB, "POST_ID_"+IntToString(nRead), oOwner);
         sTitle = SQL_GetCampaignString(sMB_DB, TITLE + IntToString(nID));
         if(sTitle!="")
         {
            SetCustomToken(7010+nNext, sTitle);
            if(DEBUG_MODE) SpeakString("Debug: Post Info = POST_ID_"+IntToString(nNext)+", ID="+IntToString(nID));
            SetLocalInt(oOwner,"POST_ID_"+IntToString(nNext),nID);
            nNext++;
         }
         nRead++;
         nLoop++;
      }
   }else if(DM==1){
      int nCount = SQL_GetCampaignInt(sMB_DB, TOTAL_POST);
      if(nCount==0)
      {
         SetCustomToken(7011, "NO POSTS");
         return;
      }

      if(nRead==0) nRead++;

      // Read 7 Posts
      nLoop = 1;
      nNext = 1;
      while(nLoop < 1000 && nNext < 8)
      {
         // Were at the end start over
         if(nRead > nCount)
         {
            SetCustomToken(7010+nID, "END OF LIST");
            nID++;
            // Clear stored titles
            while(7010+nID < 7018)
            {
               SetCustomToken(7010+nID, "");
               nID++;
            }
            nRead++;
            SetLocalInt(OBJECT_SELF,"MB_LOOP",nRead);
            return;
         }

         sTitle = SQL_GetCampaignString(sMB_DB, TITLE + IntToString(nRead));
         if(sTitle!="")
         {
            SetCustomToken(7010+nNext, sTitle);
            if(DEBUG_MODE) SpeakString("Debug: Post Info = POST_ID_"+IntToString(nNext)+", ID="+IntToString(nRead));
            SetLocalInt(oOwner,"POST_ID_"+IntToString(nNext),nRead);
            nNext++;
         }
         nRead++;
         nLoop++;
      }
   }
   SetLocalInt(oOwner,"MB_LOOP",nRead);
}

void MB_DeletePost(object oPoster, int nID, int Local = 1)
{
   string TITLE, POST, TOTAL_POST;

   if(Local == 1){
      TITLE = "TT_"+GetTag(GetArea(oPoster));
      POST = "PT_"+GetTag(GetArea(oPoster));
      TOTAL_POST = "TTP_"+GetTag(GetArea(oPoster));
   }else{
      TITLE = "TITLE_";
      POST = "POST_";
      TOTAL_POST = "TOTAL_POSTS";
   }
   if(DEBUG_MODE) SpeakString("Debug: Del Info = "+TITLE+IntToString(nID)+", "+POST+IntToString(nID));
   DeleteCampaignVariable(sMB_DB, TITLE + IntToString(nID));
   DeleteCampaignVariable(sMB_DB, POST + IntToString(nID));
}

int MB_FailFilterTest(object oSpeaker, string sCheck)
{
   int nNOT_OK = 0;
   int nLoop;
   string sBlock;

   if(TestStringAgainstPattern(sFILTER, sCheck) > 0)
      nNOT_OK = 1;

   if(DEBUG_MODE) SpeakString("Debug: I swore = "+IntToString(nNOT_OK));
   return nNOT_OK;
}
