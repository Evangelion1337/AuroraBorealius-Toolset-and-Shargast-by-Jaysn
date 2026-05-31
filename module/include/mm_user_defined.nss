
void main()
{
   int nUser=GetUserDefinedEventNumber();

   switch(GetUserDefinedEventNumber())
    {
    case 200:
/*
    Export all characters every 'n' seconds. Note that this event triggers
    itself, on a timer, when finished -- until the module is unloaded.
*/
    WriteTimestampedLogEntry("Saving Module");

    SendMessageToAllDMs("starting save");
    SpeakString(("Exporting all PC's"), TALKVOLUME_WHISPER);
    ExportAllCharacters();
    SendMessageToAllDMs("done");
    DelayCommand(2400.0, SignalEvent(OBJECT_SELF, EventUserDefined(200)));
    break;
    }  /* switch */
}
