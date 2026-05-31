/** @file
    This set of functions controlls time for players.
    When recalculate time is called, the clock advances to that of the most behind player.

    This system works best with single party modules. If you have multiple parties and player
    you may find that when the server catches up it may disorent players for a time.

    This is disabled unless the switch PRC_PLAYER_TIME is true

    Also in this include is a time struct and various functions for expressing time
    As part of this, there is some custom tokens that can be setup
    //82001         part of day
    //82002         date
    //82003         month
    //82004         year
    //82005         hour
    //82006         minutes
    //82007         seconds

    @author Primogenitor
*/

//////////////////////////////////////////////////
/* Function Prototypes                          */
//////////////////////////////////////////////////


struct time
{
    int nYear;
    int nMonth;
    int nDay;
    int nHour;
    int nMinute;
    int nSecond;
    int nMillisecond;
};

struct time TimeCheck(struct time tTime);
struct time GetLocalTime(object oObject, string sName);
void SetLocalTime(object oObject, string sName, struct time tTime);
void DeleteLocalTime(object oObject, string sName);
struct time GetPersistantLocalTime(object oObject, string sName);
void SetPersistantLocalTime(object oObject, string sName, struct time tTime);
string TimeToString(struct time tTime);
struct time StringToTime(string sIn);

void SetTimeAndDate(struct time tTime);
int GetIsTimeAhead(struct time tTime1, struct time tTime2);

void RecalculateTime(int nMaxStep = 6);
void AdvanceTimeForPlayer(object oPC, float fSeconds);


//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

//#include "prc_inc_switch"
#include "inc_persist_loca"


//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

struct time TimeAdd(struct time tTime1, struct time tTime2)
{
    tTime1 = TimeCheck(tTime1);
    tTime2 = TimeCheck(tTime2);
    tTime1.nYear            += tTime2.nYear;
    tTime1.nMonth           += tTime2.nMonth;
    tTime1.nDay             += tTime2.nDay;
    tTime1.nHour            += tTime2.nHour;
    tTime1.nMinute          += tTime2.nMinute;
    tTime1.nSecond          += tTime2.nSecond;
    tTime1.nMillisecond     += tTime2.nMillisecond;
    tTime1 = TimeCheck(tTime1);
    return tTime1;
}

struct time TimeSubtract(struct time tTime1, struct time tTime2)
{
    tTime1 = TimeCheck(tTime1);
    tTime2 = TimeCheck(tTime2);
    tTime1.nYear            -= tTime2.nYear;
    tTime1.nMonth           -= tTime2.nMonth;
    tTime1.nDay             -= tTime2.nDay;
    tTime1.nHour            -= tTime2.nHour;
    tTime1.nMinute          -= tTime2.nMinute;
    tTime1.nSecond          -= tTime2.nSecond;
    tTime1.nMillisecond     -= tTime2.nMillisecond;
    tTime1 = TimeCheck(tTime1);
    return tTime1;
}

struct time GetLocalTime(object oObject, string sName)
{
    struct time tTime;
    tTime.nYear         = GetLocalInt(oObject, sName+".nYear");
    tTime.nMonth        = GetLocalInt(oObject, sName+".nMonth");
    tTime.nDay          = GetLocalInt(oObject, sName+".nDay");
    tTime.nHour         = GetLocalInt(oObject, sName+".nHour");
    tTime.nMinute       = GetLocalInt(oObject, sName+".nMinute");
    tTime.nSecond       = GetLocalInt(oObject, sName+".nSecond");
    tTime.nMillisecond  = GetLocalInt(oObject, sName+".nMillisecond");
    tTime = TimeCheck(tTime);
    return tTime;
}

void SetLocalTime(object oObject, string sName, struct time tTime)
{
    tTime = TimeCheck(tTime);
    SetLocalInt(oObject, sName+".nYear", tTime.nYear);
    SetLocalInt(oObject, sName+".nMonth", tTime.nMonth);
    SetLocalInt(oObject, sName+".nDay", tTime.nDay);
    SetLocalInt(oObject, sName+".nHour", tTime.nHour);
    SetLocalInt(oObject, sName+".nMinute", tTime.nMinute);
    SetLocalInt(oObject, sName+".nSecond", tTime.nSecond);
    SetLocalInt(oObject, sName+".nMillisecond", tTime.nMillisecond);
}

void DeleteLocalTime(object oObject, string sName)
{
    DeleteLocalInt(oObject, sName+".nYear");
    DeleteLocalInt(oObject, sName+".nMonth");
    DeleteLocalInt(oObject, sName+".nDay");
    DeleteLocalInt(oObject, sName+".nHour");
    DeleteLocalInt(oObject, sName+".nMinute");
    DeleteLocalInt(oObject, sName+".nSecond");
    DeleteLocalInt(oObject, sName+".nMillisecond");
}

struct time GetPersistantLocalTime(object oObject, string sName)
{
    struct time tTime;
    tTime.nYear         = GetPersistantLocalInt(oObject, sName+".nYear");
    tTime.nMonth        = GetPersistantLocalInt(oObject, sName+".nMonth");
    tTime.nDay          = GetPersistantLocalInt(oObject, sName+".nDay");
    tTime.nHour         = GetPersistantLocalInt(oObject, sName+".nHour");
    tTime.nMinute       = GetPersistantLocalInt(oObject, sName+".nMinute");
    tTime.nSecond       = GetPersistantLocalInt(oObject, sName+".nSecond");
    tTime.nMillisecond  = GetPersistantLocalInt(oObject, sName+".nMillisecond");
    tTime = TimeCheck(tTime);
    return tTime;
}

void SetPersistantLocalTime(object oObject, string sName, struct time tTime)
{
    tTime = TimeCheck(tTime);
    SetPersistantLocalInt(oObject, sName+".nYear", tTime.nYear);
    SetPersistantLocalInt(oObject, sName+".nMonth", tTime.nMonth);
    SetPersistantLocalInt(oObject, sName+".nDay", tTime.nDay);
    SetPersistantLocalInt(oObject, sName+".nHour", tTime.nHour);
    SetPersistantLocalInt(oObject, sName+".nMinute", tTime.nMinute);
    SetPersistantLocalInt(oObject, sName+".nSecond", tTime.nSecond);
    SetPersistantLocalInt(oObject, sName+".nMillisecond", tTime.nMillisecond);
}

string TimeToString(struct time tTime)
{
    string sReturn;
    sReturn += IntToString(tTime.nYear)+"|";
    sReturn += IntToString(tTime.nMonth)+"|";
    sReturn += IntToString(tTime.nDay)+"|";
    sReturn += IntToString(tTime.nHour)+"|";
    sReturn += IntToString(tTime.nMinute)+"|";
    sReturn += IntToString(tTime.nSecond)+"|";
    sReturn += IntToString(tTime.nMillisecond);
    return sReturn;
}

struct time StringToTime(string sIn)
{
    struct time tTime;
    int nPos;
    string sID;
    nPos = FindSubString(sIn, "|");
    tTime.nYear = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nMonth = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nDay = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nHour = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nMinute = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nSecond = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    nPos = FindSubString(sIn, "|");
    tTime.nMillisecond = StringToInt(GetStringLeft(sIn, nPos));
    sIn = GetStringRight(sIn, GetStringLength(sIn)-nPos-1);

    return tTime;
}

struct time TimeCheck(struct time tTime)
{
    while(tTime.nMillisecond > 1000)
    {
        tTime.nSecond       += 1;
        tTime.nMillisecond  -= 1000;
    }
    while(tTime.nSecond > 60)
    {
        tTime.nMinute       += 1;
        tTime.nSecond       -= 60;
    }
    while(tTime.nMinute > FloatToInt(HoursToSeconds(1))/60)
    {
        tTime.nHour         += 1;
        tTime.nMinute       -= FloatToInt(HoursToSeconds(1))/60;
    }
    while(tTime.nHour > 24)
    {
        tTime.nDay          += 1;
        tTime.nHour         -= 24;
    }
    while(tTime.nDay > 28)
    {
        tTime.nMonth        += 1;
        tTime.nDay          -= 28;
    }
    while(tTime.nMonth > 12)
    {
        tTime.nYear         += 1;
        tTime.nMonth        -= 12;
    }
    //decreases
    while(tTime.nMillisecond < 1)
    {
        tTime.nSecond       -= 1;
        tTime.nMillisecond  += 1000;
    }
    while(tTime.nSecond < 1)
    {
        tTime.nMinute       -= 1;
        tTime.nSecond       += 60;
    }
    while(tTime.nMinute < 1)
    {
        tTime.nHour         -= 1;
        tTime.nMinute       += FloatToInt(HoursToSeconds(1))/60;
    }
    while(tTime.nHour < 1)
    {
        tTime.nDay          -= 1;
        tTime.nHour         += 24;
    }
    while(tTime.nDay < 1)
    {
        tTime.nMonth        -= 1;
        tTime.nDay          += 28;
    }
    while(tTime.nMonth < 1)
    {
        tTime.nYear         -= 1;
        tTime.nMonth        += 12;
    }
    return tTime;
}

struct time GetTimeAndDate()
{
    struct time tTime;
    tTime.nYear         = GetCalendarYear();
    tTime.nMonth        = GetCalendarMonth();
    tTime.nDay          = GetCalendarDay();
    tTime.nHour         = GetTimeHour();
    tTime.nMinute       = GetTimeMinute();
    tTime.nSecond       = GetTimeSecond();
    tTime.nMillisecond  = GetTimeMillisecond();
    tTime = TimeCheck(tTime);
    return tTime;
}

void SetTimeAndDate(struct time tTime)
{
    tTime = TimeCheck(tTime);
    SetCalendar(tTime.nYear, tTime.nMonth, tTime.nDay);
    SetTime(tTime.nHour, tTime.nMinute, tTime.nSecond, tTime.nMillisecond);
}

int GetIsTimeAhead(struct time tTime1, struct time tTime2)
{
    if(tTime1.nYear > tTime2.nYear)
        return TRUE;
    else if(tTime1.nYear < tTime2.nYear)
        return FALSE;
    //equal
    if(tTime1.nMonth > tTime2.nMonth)
        return TRUE;
    else if(tTime1.nMonth < tTime2.nMonth)
        return FALSE;
    //equal
    if(tTime1.nDay > tTime2.nDay)
        return TRUE;
    else if(tTime1.nDay < tTime2.nDay)
        return FALSE;
    //equal
    if(tTime1.nHour > tTime2.nHour)
        return TRUE;
    else if(tTime1.nHour < tTime2.nHour)
        return FALSE;
    //equal
    if(tTime1.nMinute > tTime2.nMinute)
        return TRUE;
    else if(tTime1.nMinute < tTime2.nMinute)
        return FALSE;
    //equal
    if(tTime1.nSecond > tTime2.nSecond)
        return TRUE;
    else if(tTime1.nSecond < tTime2.nSecond)
        return FALSE;
    //equal
    if(tTime1.nMillisecond > tTime2.nMillisecond)
        return TRUE;
    else if(tTime1.nMillisecond < tTime2.nMillisecond)
        return FALSE;
    //must be exactly the same
    return FALSE;
}

void RecalculateTime(int nMaxStep = 6)
{
    if(!GetPRCSwitch(PRC_PLAYER_TIME))
        return;
    //get the earliest time ahead of all PCs
    object oPC = GetFirstPC();
    struct time tTimeAhead = GetLocalTime(oPC, "TimeAhead");
    while(GetIsObjectValid(oPC))
    {
        struct time tTest = GetLocalTime(oPC, "TimeAhead");
        if(!GetIsTimeAhead(tTimeAhead, tTest))
            tTimeAhead = tTest;
        oPC = GetNextPC();
    }
    //if its zero, abort
    struct time tNULL;
    if(tNULL == tTimeAhead)
        return;
    //if its not zero, recalulate it till it is
    DelayCommand(0.01, RecalculateTime());//do it again until caught up
    //create the steps to use
    struct time tStep;
    tStep.nSecond = nMaxStep;
    //make sure you dont skip more than a step at a time
    if(GetIsTimeAhead(tTimeAhead, tStep))
        tTimeAhead = tStep;
    //set the new real time
    struct time tNewTime = GetTimeAndDate();
    tNewTime = TimeAdd(tNewTime, tTimeAhead);
    SetTimeAndDate(tNewTime);

    //update the stored values
    oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        struct time tTest = GetLocalTime(oPC, "TimeAhead");
        tTest = TimeSubtract(tTest, tTimeAhead);
        SetLocalTime(oPC, "TimeAhead", tTest);
        oPC = GetNextPC();
    }
}


void AdvanceTimeForPlayer(object oPC, float fSeconds)
{
    struct time tTime = GetLocalTime(oPC, "TimeAhead");
    tTime.nSecond += FloatToInt(fSeconds);
    SetLocalTime(oPC, "TimeAhead", tTime);
    DelayCommand(0.01, RecalculateTime());
}

void AssembleTokens(struct time tTime)
{
    tTime = TimeCheck(tTime);
    //setup time tokens
    //82001         part of day
    //82002         date
    //82003         month
    //82004         year
    //82005         hour
    //82006         minutes
    //82007         seconds
    //82008         24 hour clock
    //82009         timer

    //this assumes default time settings
    //Dawn, 06:00
    //Dusk, 18:00
    if(tTime.nHour == 6)
        SetCustomToken(82001, "dawn");
    else if(tTime.nHour == 18)
        SetCustomToken(82001, "dusk");
    else if(tTime.nHour >= 19 || tTime.nHour <= 5)
        SetCustomToken(82001, "night");
    else if(tTime.nHour >= 7 && tTime.nHour < 13)
        SetCustomToken(82001, "morning");
    else if(tTime.nHour >= 13 &&  tTime.nHour < 18)
        SetCustomToken(82001, "afternoon");

    string sDay = IntToString(tTime.nDay);
    if(tTime.nDay == 1
        //|| tTime.nDay == 11 //this is 11th
        || tTime.nDay == 21)
        sDay += "st";
    else if(tTime.nDay == 2
        //|| tTime.nDay == 12 //this is 12th
        || tTime.nDay == 22)
        sDay += "nd";
    else if(tTime.nDay == 3
        //|| tTime.nDay == 13 //this is 13th
        || tTime.nDay == 23)
        sDay += "rd";
    else
        sDay += "th";
    SetCustomToken(82002, sDay);

    string sMonth;
    switch(tTime.nMonth)
    {
        case 1:  sMonth = "January";   break;
        case 2:  sMonth = "Febuary";   break;
        case 3:  sMonth = "March";     break;
        case 4:  sMonth = "April";     break;
        case 5:  sMonth = "May";       break;
        case 6:  sMonth = "June";      break;
        case 7:  sMonth = "July";      break;
        case 8:  sMonth = "August";    break;
        case 9:  sMonth = "September"; break;
        case 10: sMonth = "October";   break;
        case 11: sMonth = "November";  break;
        case 12: sMonth = "December";  break;
    }
    SetCustomToken(82003, sMonth);

    SetCustomToken(82004, IntToString(tTime.nYear));
    SetCustomToken(82005, IntToString(tTime.nHour));
    SetCustomToken(82006, IntToString(tTime.nMinute));
    SetCustomToken(82007, IntToString(tTime.nSecond));
    SetCustomToken(82008, IntToString(tTime.nHour)+":"+IntToString(tTime.nMinute));

    string sTimer;
    if(!tTime.nYear)
    {
        if(tTime.nYear > 1)
            sTimer += IntToString(tTime.nYear)+" years";
        else
            sTimer += IntToString(tTime.nYear)+" year";
    }
    if(!tTime.nMonth)
    {
        if(sTimer != "")
            sTimer += ", ";
        if(tTime.nMonth > 1)
            sTimer += IntToString(tTime.nMonth)+" months";
        else
            sTimer += IntToString(tTime.nMonth)+" month";
    }
    if(!tTime.nDay)
    {
        if(sTimer != "")
            sTimer += ", ";
        if(tTime.nDay > 1)
            sTimer += IntToString(tTime.nDay)+" days";
        else
            sTimer += IntToString(tTime.nMonth)+" day";
    }
    if(!tTime.nHour)
    {
        if(sTimer != "")
            sTimer += ", ";
        if(tTime.nHour > 1)
            sTimer += IntToString(tTime.nHour)+" hours";
        else
            sTimer += IntToString(tTime.nMonth)+" hour";
    }
    if(!tTime.nMinute)
    {
        if(sTimer != "")
            sTimer += ", ";
        if(tTime.nMinute > 1)
            sTimer += IntToString(tTime.nMinute)+" minutes";
        else
            sTimer += IntToString(tTime.nMonth)+" minute";
    }
    SetCustomToken(82009, sTimer);
}
