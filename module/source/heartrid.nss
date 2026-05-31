void main()
{
   int seconds;
   for (seconds = 1; seconds < 7; seconds++)
      DelayCommand( IntToFloat(seconds), SignalEvent( OBJECT_SELF, EventUserDefined(1300)));
}
