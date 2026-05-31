//::///////////////////////////////////////////////
//:: commoner_main.nss
//:://////////////////////////////////////////////
/*
     Main script for the commoner spawner. Enter
     the different parameters in the "Options"
     block below. See readme.txt for additional
     help.
     Use the "Custom" block to add script lines
     if you need to run some script in the area
     heartbeat yourself.
*/
//:://////////////////////////////////////////////
//:: Created By: EntropyDecay
//:: Created On: May 2003
//:://////////////////////////////////////////////

void main()
{
  object oArea = GetArea(OBJECT_SELF);
  if (GetLocalInt(oArea, "initialized")==0)
  {
    SetLocalInt(oArea, "initialized", 1);

    //Options:
    //Required parameters
    int nWalkWayPoints =  3;                //Number of waypoints in area
    string sCommonerName = "Commoner";      //Name of commoners (used to select which
                                            //spawned creatures can be randomized)
    string sResRefBody = "commoner_";       //ResRef-beginning of commoners in area
    int nTypesOfCommoner = 2;               //Number of different commoners
    string sResRefClothing = "clothing_";   //ResRef-beginning of clothing
    int nTypesOfClothing = 2;               //Number of different clothings
    int nDialogLines = 10;                  //Number of different one liner dialogs

    //Commoner options
    int nCommonerMax = 10;                  //Maximum number of commoners spawned
                                            //(clear weather & day!)
    int nCommonerRain = 50;                 //Percentage when it's raining
    int nCommonerSnow = 20;                 //Percentage when it's snowing
    int nCommonerNight = 100;               //Percentage by night
    int nCommonerTorchOnlyByNight = TRUE;   //When to spawn with torch:
                                            //TRUE: only by night, FALSE: all day
    int nCommonerTorch = 50;                //Percentage carrying a torch
    int nClothingRandom = 100;              //Percentage with random selected clothing
    int nCommonerCarry = 50;                //Percentage carrying something in hands
                                            //(this does not modify the torch chance!)

    //Weather and movement options
    int nCommonerDayRun = FALSE;            //Movement mode by day
    int nCommonerNightRun = FALSE;          //Movement mode by night
    int nCommonerRainRun = TRUE;            //Movement mode if weather = rain
    int nCommonerSnowRun = FALSE;           //Movement mode if weather = snow


    //Initialization
    //Don't change anything in this block or the script package
    //won't function properly!
    SetLocalInt(oArea, "nWalkWayPoints", nWalkWayPoints);
    SetLocalString(oArea, "sCommonerName", sCommonerName);
    SetLocalString(oArea, "sResRefBody", sResRefBody);
    SetLocalInt(oArea, "nTypesOfCommoner", nTypesOfCommoner);
    SetLocalString(oArea, "sResRefClothing", sResRefClothing);
    SetLocalInt(oArea, "nTypesOfClothing", nTypesOfClothing);
    SetLocalInt(oArea, "nDialogLines", nDialogLines);

    SetLocalInt(oArea, "nCommonerMax", nCommonerMax);
    SetLocalInt(oArea, "nCommonerRain", nCommonerRain);
    SetLocalInt(oArea, "nCommonerSnow", nCommonerSnow);
    SetLocalInt(oArea, "nCommonerNight", nCommonerNight);
    SetLocalInt(oArea, "nCommonerTorchOnlyByNight", nCommonerTorchOnlyByNight);
    SetLocalInt(oArea, "nCommonerTorch", nCommonerTorch);
    SetLocalInt(oArea, "nClothingRandom", nClothingRandom);
    SetLocalInt(oArea, "nCommonerCarry", nCommonerCarry);

    SetLocalInt(oArea, "nCommonerDayRun", nCommonerDayRun);
    SetLocalInt(oArea, "nCommonerNightRun", nCommonerNightRun);
    SetLocalInt(oArea, "nCommonerRainRun", nCommonerRainRun);
    SetLocalInt(oArea, "nCommonerSnowRun", nCommonerSnowRun);

    int nWeatherType = GetWeather(oArea);
    int nNewMovement;
    if (GetIsNight()) {nNewMovement = GetLocalInt(oArea, "nCommonerNightRun");}
    else {nNewMovement = GetLocalInt(oArea, "nCommonerDayRun");}

    if ((nWeatherType == WEATHER_RAIN) && (GetLocalInt(oArea, "nCommonerRainRun") == TRUE))
      {nNewMovement = TRUE;}
    else if ((nWeatherType == WEATHER_SNOW) && (GetLocalInt(oArea, "nCommonerSnowRun") == TRUE))
      {nNewMovement = TRUE;}

    SetLocalInt(oArea, "nWalkType", nNewMovement);
  }


  //Custom (insert own code here)

  //Custom end


  //Check if any player is in area
  int i;
  object oPlayerInArea = OBJECT_INVALID;
  object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
      if (GetArea(OBJECT_SELF)==GetArea(oPC))
      {
        oPlayerInArea = oPC;
        SetLocalObject(oArea, "oFirstPlayerInArea", oPC);
        break;
      }
      else oPC = GetNextPC();
    }

  //If any player is in area then execute the following script lines
  if (GetIsObjectValid(oPlayerInArea))
  {
    //Weatherblock
    int nWeatherType = GetWeather(oArea);

    if (nWeatherType != GetLocalInt(oArea, "nWeather"))
    {
      int nNewMovement;
      if (GetIsNight()) {nNewMovement = GetLocalInt(oArea, "nCommonerNightRun");}
      else {nNewMovement = GetLocalInt(oArea, "nCommonerDayRun");}

      if ((nWeatherType == WEATHER_RAIN) && (GetLocalInt(oArea, "nCommonerRainRun") == TRUE))
        {nNewMovement = TRUE;}
      else if ((nWeatherType == WEATHER_SNOW) && (GetLocalInt(oArea, "nCommonerSnowRun") == TRUE))
        {nNewMovement = TRUE;}

      SetLocalInt(oArea, "nWeather", nWeatherType);
      SetLocalInt(oArea, "nWalkType", nNewMovement);

      i=1;
      object oCommoner = GetNearestObjectByTag("NW_COMMONER", oPC,i);
      while (GetIsObjectValid(oCommoner))
      {
        AssignCommand(oCommoner, ExecuteScript("commoner_resume", oCommoner));
        i++;
        oCommoner = GetNearestObjectByTag("NW_COMMONER", oPC,i);
      }
    }

    //Commonerblock
    int nCommonersToSpawn;
    int nMaximumToSpawn = GetLocalInt(oArea, "nCommonerMax");
    int nRainMultiplier = GetLocalInt(oArea, "nCommonerRain");
    int nSnowMultiplier = GetLocalInt(oArea, "nCommonerSnow");
    int nNightMultiplier = GetLocalInt(oArea, "nCommonerNight");

    if (!GetIsNight()) nNightMultiplier = 100;

    if (GetWeather(oArea)==WEATHER_RAIN)
    {
      nMaximumToSpawn = (nMaximumToSpawn * nRainMultiplier * nNightMultiplier + 5000)/10000;
    }
    else if (GetWeather(oArea)==WEATHER_SNOW)
    {
      nMaximumToSpawn = (nMaximumToSpawn * nSnowMultiplier * nNightMultiplier + 5000)/10000;
    }
    else
    {
      nMaximumToSpawn = (nMaximumToSpawn * nNightMultiplier + 50)/100;
    }

    int nCommonersSpawned=0;
    object oCount = GetNearestObjectByTag("NW_COMMONER", oPlayerInArea);
    while (GetIsObjectValid(oCount))
    {
      nCommonersSpawned++;
      oCount = GetNearestObjectByTag("NW_COMMONER", oPlayerInArea, nCommonersSpawned+1);
    }

    nCommonersToSpawn = nMaximumToSpawn - nCommonersSpawned;
    if (nCommonersToSpawn > 0)
    {
      int nSpawn = Random(nCommonersToSpawn+1);

      int nSpawnInterval;
      if (nSpawn!=0) nSpawnInterval = 60 / nSpawn;

      for (i=1; i <= nSpawn; i++)
      {
        float fSpawnDelay = IntToFloat(Random(nSpawnInterval))/10 + ((IntToFloat(nSpawnInterval)/10) * (i-1));
        DelayCommand(fSpawnDelay, ExecuteScript("commoner_creator", OBJECT_SELF));
      }
    }
  }
}
