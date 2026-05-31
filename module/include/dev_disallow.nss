int testdevcrit(object oPC)
{
    if (GetHasFeat(990,oPC)) //Epic Warding
        return 1;

    if (GetHasFeat(955, oPC))
        return 1; //Dwarven Waraxe
    if (GetHasFeat(996, oPC))
        return 1; //Whip

    int nFeat = 495; //495 is the first dev. crit. feat
    while (nFeat<532) //531 is the last dev. crit. feat, repeat for all dev. crits between 495 and 531
    {
        if (GetHasFeat(nFeat, oPC))
        {
            return 1;
        }
        else
        {
                nFeat++;
        }
   }
   return 0;
}

void devcritdelevel(object oPC, int nFirstLoop, int nCorrectXP)
{
   if (testdevcrit(oPC)) //If a Dev. Crit. or Epic Warding was chosen
   {
        if (nFirstLoop)
        {
            FloatingTextStringOnCreature("Devastating Critical and Epic Warding are forbidden.",oPC,FALSE);
            DelayCommand(20.0,SetXP(oPC, nCorrectXP)); //Restore the XP so the player can relevel
        }

        int nLevel = GetHitDice(oPC); //Get level
        int nDelevelXP = (nLevel-1) * (nLevel - 2) * 500; //Work out how much XP will delevel the PC
        SetXP(oPC, nDelevelXP); //Set that level

        DelayCommand(0.7,devcritdelevel(oPC,FALSE,nCorrectXP));
    }


    else
    {
        // No Problem then
    }
}



void main()
{
    object oPC = GetPCLevellingUp();
    devcritdelevel(oPC,1,GetXP(oPC));
}
