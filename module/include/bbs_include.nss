//BULLETIN BOARD SYSTEM VERSION 1.1

//This is an include file. Upon building your module you will get
//a compile error in this file. That is normal and does not
//affect the operation of the bulletin board.

void bbs_do_board_stats();
void bbs_initiate(object oBBS);
int bbs_can_show(int WhichEntry);
void bbs_change_page(int PageChange);
void bbs_select_entry(int WhichEntry);
void bbs_add_notice(object oBBS, string sPoster, string sTitle, string sMessage, string sDate, string sBBStag = "");

//Loads into tokens the stats for a board
void bbs_do_board_stats() {
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageSize = GetLocalInt(oBBS, "PageSize");
  int TotalItems = GetLocalInt(oBBS, "TotalItems");
  int PageIndex = GetLocalInt(oBBS, "PageIndex") + 1;
  SetCustomToken(3671, IntToString(TotalItems));
  if (TotalItems == 0) {PageIndex = 0;}
  SetCustomToken(3672, IntToString(PageIndex));
  SetCustomToken(3673, IntToString((TotalItems + PageSize - 1) / PageSize));
}

//Initiates a bulletin board's settings if neccessary
void bbs_initiate(object oBBS) {
  string sBBS = "BBS_" + GetTag(oBBS);
  object myBBS = GetLocalObject(GetModule(), sBBS);
  if (!GetIsObjectValid(myBBS)) {
    SetLocalObject(GetModule(), sBBS, oBBS);
    myBBS = oBBS;
    //MaxItems is the maximum number of messages
    SetLocalInt(myBBS, "MaxItems", 25);
    //PageSize is the number of entries per page, between 1 and 10
    SetLocalInt(myBBS, "PageSize", 5);
  }
}

//Determines whether a dialogue option is visible in conversation
int bbs_can_show(int WhichEntry) {
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageSize = GetLocalInt(oBBS, "PageSize");
  int nSpot = GetLocalInt(oBBS, "PageIndex") * PageSize + WhichEntry;
  if(nSpot <= GetLocalInt(oBBS, "TotalItems") && WhichEntry <= PageSize) {return TRUE;}
  return FALSE;
}

//Moves the page by the required PageFlip:
//0 to reload page, -1 for previous page, 1 for next page
void bbs_change_page(int PageFlip) {
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageSize = GetLocalInt(oBBS, "PageSize");
  int TotalItems = GetLocalInt(oBBS, "TotalItems");
  int MaxItems = GetLocalInt(oBBS, "MaxItems");
  int LatestItem = GetLocalInt(oBBS, "LatestItem");
  int PageIndex = GetLocalInt(oBBS, "PageIndex") + 1 * PageFlip;
  if (PageIndex < 0) {PageIndex = 0;}
  SetLocalInt(oBBS, "PageIndex", PageIndex);

  string sInfo;
  int iLoop;
  int iNotice;

  for (iLoop = 0; iLoop < PageSize; iLoop++) {
    iNotice = LatestItem - PageIndex * PageSize - iLoop;
    if (iNotice < 1) {iNotice = MaxItems + iNotice;}
    sInfo = GetLocalString(oBBS, "Title" + IntToString(iNotice));
    SetCustomToken(3680 + iLoop, sInfo);
    sInfo = GetLocalString(oBBS, "Poster" + IntToString(iNotice));
    if (((PageIndex * PageSize + iLoop + 2) > TotalItems) || (iLoop == PageSize - 1)){
      sInfo = sInfo + "\n ";
    }
    SetCustomToken(3690 + iLoop, sInfo);
  }
  bbs_do_board_stats();
  SetCustomToken(3674, "");
  SetCustomToken(3675, "");
  SetCustomToken(3676, "");
  SetCustomToken(3677, "");
  SetCustomToken(3678, "");
}

//Displays the selected post
void bbs_select_entry(int WhichEntry) {
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageSize = GetLocalInt(oBBS, "PageSize");
  int MaxItems = GetLocalInt(oBBS, "MaxItems");
  int LatestItem = GetLocalInt(oBBS, "LatestItem");
  int PageIndex = GetLocalInt(oBBS, "PageIndex");

  int iNotice = LatestItem - PageIndex * PageSize - WhichEntry + 1;
  if (iNotice < 1) {iNotice = MaxItems + iNotice;}

  string sNotice = IntToString(iNotice);
  bbs_do_board_stats();
  SetCustomToken(3674, "\n\n" + GetLocalString(oBBS, "Title" + sNotice) + "\nBy: ");
  SetCustomToken(3675, GetLocalString(oBBS, "Poster" + sNotice));
  SetCustomToken(3676, "     On: ");
  SetCustomToken(3677, GetLocalString(oBBS, "Date" + sNotice));
  SetCustomToken(3678, "\n" + GetLocalString(oBBS, "Message" + sNotice));
}

//Adds a post to the bulletin board. This can be called at any time
//so you can insert your own notices. If you don't specify a sDate,
//it will use the current game time. The proper format for sDate is
//something like "6/30/1373 11:58". The last two lines write code to
//the log file for restoring the messages after a module edit.
void bbs_add_notice(object oBBS, string sPoster, string sTitle, string sMessage, string sDate, string sBBStag = "")
{
  if (sBBStag != "") {oBBS = GetObjectByTag(sBBStag);}
  bbs_initiate(oBBS);
  oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(oBBS));
  if (sDate == "") {
    sDate = IntToString(GetTimeMinute());
    if (GetStringLength(sDate) == 1) {sDate = "0" + sDate;}
    sDate = IntToString(GetCalendarMonth()) + "/" + IntToString(GetCalendarDay()) + "/" + IntToString(GetCalendarYear()) + " " + IntToString(GetTimeHour()) + ":" + sDate;
  }
  int MaxItems = GetLocalInt(oBBS, "MaxItems");
  int TotalItems = GetLocalInt(oBBS, "TotalItems");
  int nSpot = TotalItems + 1;
  if (nSpot > MaxItems) {
    nSpot = GetLocalInt(oBBS, "LatestItem") + 1;
    if (nSpot > MaxItems) {nSpot = nSpot - MaxItems;}
  }
  SetLocalString(oBBS, "Poster" + IntToString(nSpot), sPoster);
  SetLocalString(oBBS, "Date" + IntToString(nSpot), sDate);
  SetLocalString(oBBS, "Title" + IntToString(nSpot), sTitle);
  SetLocalString(oBBS, "Message" + IntToString(nSpot), sMessage);
  SetLocalInt(oBBS, "LatestItem", nSpot);
  if (MaxItems > TotalItems) {SetLocalInt(oBBS, "TotalItems", TotalItems + 1);}

  string sQuote = GetSubString(GetStringByStrRef(464), 13, 1);
  PrintString("bbs_add_notice(OBJECT_SELF, " + sQuote + sPoster + sQuote + ", " + sQuote + sTitle + sQuote + ", " + sQuote + sMessage + sQuote + ", " + sQuote + sDate + sQuote + ", " + sQuote + GetTag(oBBS) + sQuote + "); //:::BBS:::");
}
