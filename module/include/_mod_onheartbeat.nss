// _mod_onheartbeat
void main()
{
ExecuteScript("asg_hbs_dbplayer",GetModule());
int iHour = GetTimeHour();
    int iMilli = GetTimeMillisecond();
    int iMinute = GetTimeMinute();
    int iSecond = GetTimeSecond();
    SetTime(iHour, iMinute, iSecond, iMilli);
}

