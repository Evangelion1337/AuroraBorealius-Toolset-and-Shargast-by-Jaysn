// Name     : Avlis Persistence System ready script
// Purpose  : Check if NWNX is ready
// Authors  : Ingmar Stieger
// Modified : February 4, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

void main()
{
    if (SQLFirstRow() && (SQLGetData(1) == "NWNX!READY"))
    {
        SetLocalInt(GetModule(), "NWNX!READY", TRUE);
        WriteTimestampedLogEntry("NWNX is ready.");

        // Call your script that loads persistent data on module load here.
         ExecuteScript("pwdata", GetModule());
    }
    else
        DelayCommand(1.0f, ExecuteScript("aps_ready", GetModule()));
}
