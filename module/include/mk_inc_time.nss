//::///////////////////////////////////////////////
//:: FileName mk_inc_time.nss
//:: Copyright (c) 2008 Kamiryn
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Kamiryn
//:: Created On: 07.03.2008
//:://////////////////////////////////////////////

const string g_sDateZero = "mk_datezero";

struct mk_datetime
{
    int nYear;
    int nMonth;
    int nDay;
    int nHour;
    int nMinutes;
    int nSeconds;
    int nMilliSeconds;
};

// time stamp is in minutes since 'DateZero'.

// initializes 'DateZero' with current time,
// should be called once before any of the other functions gets used
// returns DateZero
struct mk_datetime mk_initTimeStamp();

// returns current time as time stamp
float mk_getCurrentTimeStamp();

// deletes time stamp on oObject
void mk_deleteTimeStampOnObject(object oObject, string sVarName);

// writes current time as time stamp on object oObject storing it in sVarName
void mk_writeTimeStampToObject(object oObject, string sVarName);

// returns time stamp stored in sVarName on object oObject
float mk_getTimeStampFromObject(object oObject, string sVarName);

// returns time passed since time stamp sVarName was written on oObject
float mk_getTimeSinceTimeStamp(object oObject, string sVarName);

// returns time stamp as datetime span (datetime span = time stamp)
struct mk_datetime mk_timeStampToDateTimeSpan(float fTimeStamp);

// returns time stamp as datetime (datetime = DateZero + time stamp)
struct mk_datetime mk_timeStampToDateTime(float fTimeStamp);

// returns date1 + date2
struct mk_datetime mk_addDateTime(struct mk_datetime date1, struct mk_datetime date2);

// returns datetime span as readable string
string mk_formatDateTimeSpan(struct mk_datetime datetime);

// returnd datetime as readable string
string mk_formatDateTime(struct mk_datetime datetime);

float fHourToMinutes = HoursToSeconds(1) / 60.0f;

const float fYearToHours = 8064.0f; // 8064 = 12.0f*28.0f*24.0f;
const float fMonthToHours = 672.0f; // 672 = 28.0f*24.0f;
const float fDayToHours = 24.0f;

struct mk_datetime mk_initTimeStamp()
{
    string strZeroDate = GetLocalString(GetModule(), "MK_ZERODATE");
    if (strZeroDate == "")
    {
        strZeroDate = FloatToString(IntToFloat(GetCalendarYear()),5,0) +
                      FloatToString(IntToFloat(GetCalendarMonth()),2,0) +
                      FloatToString(IntToFloat(GetCalendarDay()),2,0) +
                      FloatToString(IntToFloat(GetTimeHour()),2,0);
        SetLocalString(GetModule(), "MK_ZERODATE", strZeroDate);
    }

    struct mk_datetime datetime;
    datetime.nYear = StringToInt(GetSubString(strZeroDate,0,5));
    datetime.nMonth = StringToInt(GetSubString(strZeroDate,5,2));
    datetime.nDay = StringToInt(GetSubString(strZeroDate,7,2));
    datetime.nHour = StringToInt(GetSubString(strZeroDate,9,2));
    datetime.nMinutes = 0;
    datetime.nSeconds = 0;
    datetime.nMilliSeconds = 0;

    return datetime;
}

float mk_getCurrentTimeStamp()
{
    struct mk_datetime datetime = mk_initTimeStamp();

    float fYear = IntToFloat(GetCalendarYear() - datetime.nYear);

    float fMonth = IntToFloat(GetCalendarMonth() - datetime.nMonth);
    float fDay = IntToFloat(GetCalendarDay() - datetime.nDay);
    float fHour = IntToFloat(GetTimeHour() - datetime.nHour);
    float fMinute = IntToFloat(GetTimeMinute());
    float fSecond = IntToFloat(GetTimeSecond()) + IntToFloat(GetTimeMillisecond())/1000.0;
/*
    SendMessageToPC(GetFirstPC(),
       FloatToString(fYear,8,0)+
       FloatToString(fMonth,3,0)+
       FloatToString(fDay,3,0)+
       FloatToString(fHour,3,0)+
       FloatToString(fMinute,3,0)+
       FloatToString(fSecond,3,0));
*/
    float fTimeStamp =
      (
        (
          (
            (
              (
                (fYear * 12.0) + fMonth
              ) * 28.0
            ) + fDay
          ) * 24.0
        ) + fHour
      ) + ((fSecond / 60.0) + fMinute) / fHourToMinutes;

    return fTimeStamp;
}

void mk_deleteTimeStampOnObject(object oObject, string sVarName)
{
    DeleteLocalFloat(oObject, sVarName);
}

void mk_writeTimeStampToObject(object oObject, string sVarName)
{
    if (!GetIsObjectValid(oObject)) return;

    float fTimeStamp = mk_getCurrentTimeStamp();

    SetLocalFloat(oObject, sVarName, fTimeStamp);

/*    SendMessageToPC(oObject,"mk_writeTimeStampToObject: "+
        FloatToString(fTimeStamp,17,5)); */
}

float mk_getTimeStampFromObject(object oObject, string sVarName)
{
    float fTimeStamp = GetLocalFloat(oObject,sVarName);

/*    SendMessageToPC(oObject,"mk_getTimeStampFromObject: "+
        FloatToString(fTimeStamp,17,5));*/

    return fTimeStamp;
}

float mk_getTimeSinceTimeStamp(object oObject, string sVarName)
{
    float fCurrentTimeStamp = mk_getCurrentTimeStamp();

/*    SendMessageToPC(oObject,"mk_getCurrentTimeStamp: "+
        FloatToString(fCurrentTimeStamp,17,5));*/

    float fTimeStamp = mk_getTimeStampFromObject(oObject,sVarName);

/*    SendMessageToPC(oObject,"mk_getTimeSinceTimeStamp: "+
        FloatToString(fCurrentTimeStamp - fTimeStamp,17,5));*/

    return fCurrentTimeStamp - fTimeStamp;
}

struct mk_datetime mk_timeStampToDateTimeSpan(float fTimeStamp)
{
    struct mk_datetime datetime;

    float fMinSec = fTimeStamp - IntToFloat(FloatToInt(fTimeStamp));
    int nMinutes = FloatToInt(fMinSec*fHourToMinutes);
    float fSeconds = (fMinSec*fHourToMinutes - IntToFloat(nMinutes))*60.0;

    int nSeconds = FloatToInt(fSeconds);
    int nMilliSeconds = FloatToInt((fSeconds - IntToFloat(nSeconds))*1000.0);

//    SendMessageToPC(GetFirstPC(), "fMinSec : "+FloatToString(fMinSec));
//    SendMessageToPC(GetFirstPC(), "fMinSec2: "+FloatToString((IntToFloat(nSeconds)/60.0 + IntToFloat(nMinutes))/fHourToMinutes));

    int nYear = FloatToInt(fTimeStamp / fYearToHours);
    int nMonth = FloatToInt((fTimeStamp - IntToFloat(nYear)*fYearToHours) / fMonthToHours);
    int nDay = FloatToInt((fTimeStamp - IntToFloat(nYear)*fYearToHours - IntToFloat(nMonth)*fMonthToHours) / fDayToHours);
    int nHour = FloatToInt(fTimeStamp - IntToFloat(nYear)*fYearToHours - IntToFloat(nMonth)*fMonthToHours - IntToFloat(nDay)*fDayToHours);

    datetime.nYear = nYear;
    datetime.nMonth = nMonth;
    datetime.nDay = nDay;
    datetime.nHour = nHour;
    datetime.nMinutes = nMinutes;
    datetime.nSeconds = nSeconds;
    datetime.nMilliSeconds = nMilliSeconds;

    return datetime;
}

struct mk_datetime mk_addDateTime(struct mk_datetime date1, struct mk_datetime date2)
{
    struct mk_datetime date;
    date.nMilliSeconds = (date1.nMilliSeconds + date2.nMilliSeconds) % 1000;
    date.nSeconds = (date1.nSeconds + date2.nSeconds
        + (date1.nMilliSeconds + date2.nMilliSeconds) / 1000) % 60;
    date.nMinutes = (date1.nMinutes + date2.nMinutes
        + (date1.nSeconds + date2.nSeconds) / 60) % FloatToInt(fHourToMinutes)
        ;
    date.nHour = (date1.nHour + date2.nHour
        + (date1.nMinutes + date2.nMinutes) / FloatToInt(fHourToMinutes)) % 24;

    date.nDay = (date1.nDay + date2.nDay + (date1.nHour + date2.nHour)/24 - 1) % 28 + 1;

    date.nMonth = (date1.nMonth + date2.nMonth + (date1.nDay + date2.nDay - 1) / 28 - 1) % 12 + 1;

    date.nYear = (date1.nYear + date2.nYear + (date1.nMonth + date2.nMonth - 1) / 12);

    return date;
}


struct mk_datetime mk_timeStampToDateTime(float fTimeStamp)
{
    return mk_addDateTime(mk_initTimeStamp(),mk_timeStampToDateTimeSpan(fTimeStamp));
}

string mk_formatDateTimeSpan(struct mk_datetime datetime)
{
    string sDateTimeSpan =
       (datetime.nYear>0 ? IntToString(datetime.nYear)+" years, " : "")+
       (datetime.nMonth>0 ? IntToString(datetime.nMonth)+" month, " : "")+
       (datetime.nDay>0 ? IntToString(datetime.nDay)+" days, " : "")+
       (datetime.nHour>0 ? IntToString(datetime.nHour)+" hours, " : "")+
       (datetime.nMinutes>0 ? IntToString(datetime.nMinutes)+" minutes, " : "")+
       (datetime.nSeconds>0 ? IntToString(datetime.nSeconds)+" seconds, " : "")+
       (datetime.nMilliSeconds>0 ? IntToString(datetime.nMilliSeconds)+" milliseconds, " : "");


    return GetStringLeft(sDateTimeSpan, GetStringLength(sDateTimeSpan)-2);
}

string mk_formatDateTime(struct mk_datetime datetime)
{
    string sDateTime =
       "year "+IntToString(datetime.nYear)+", "+
       "month "+IntToString(datetime.nMonth)+", "+
       "day "+IntToString(datetime.nDay)+", "+
       "hour "+IntToString(datetime.nHour)+", "+
       "minutes "+IntToString(datetime.nMinutes)+", "+
       "seconds "+IntToString(datetime.nSeconds)+", "+
       "seconds "+IntToString(datetime.nMilliSeconds);

    return sDateTime;
}

/* DO NOT CLOSE THIS TOP COMMENT!
   This main() function is here only for compilation testing.
void main() {}
/* */


