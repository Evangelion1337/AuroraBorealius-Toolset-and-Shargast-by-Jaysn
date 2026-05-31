#include "nwnx"
#include "nwnx_sql"

void main()
{
    int iHour = GetTimeHour();
    int iMinute = GetTimeMinute();
    int iSecond = GetTimeSecond();
    int iMillisecond = GetTimeMillisecond();
    SetTime(iHour, iMinute, iSecond, iMillisecond);

    ExecuteScript("hif_trkloc", OBJECT_SELF);
}
