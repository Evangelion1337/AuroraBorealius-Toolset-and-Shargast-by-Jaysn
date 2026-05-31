//Basic Commented Combat Dummy Trainer (for on Damaged Dummies)
//Rewards xp to lvl 1 characters based on damage they deal
void main()
{
    object oSelf = OBJECT_SELF; //The dummy, or object calling the script
    object oDamager = GetLastDamager(); //The last creature that damaged the dummy, or controller of last effect to damage the dummy
    int iPc = GetIsPC(oDamager); //To make sure the damage is a pc, no trainer xp for summoned puppies
    int iHd = GetHitDice(oDamager); //Get damager's level, for restricting later
    int iLocal = GetLocalInt(oSelf, "hp"); //a local number stored on the dummy to remember its life so it can tell how much life it looses per attack
    int iHpm = GetMaxHitPoints(oSelf); //The dummy's maximum hit points
    int iHpc = GetCurrentHitPoints(oSelf); //the dummy's current hit points
    if (iLocal == 0){//When I local is 0, ie it hasn't been set yet, such that we assume the dummy is undamaged
        int iAmount = ((iHpm)-(iHpc)); //Amount of xp to give the damager
        SetLocalInt(oSelf, "hp", iHpc); //Sets the local int to the dummies health
    if (iPc == TRUE){//If the dmagaer is a pc
        if (iHd <= 1){//If the pc is level 1 or lower, < for ease of changing. In this particular case <= and == are equivelint
            GiveXPToCreature(oDamager, iAmount);//Give the damager xp = to the amount of damage they dealt
            }
        else{} //If the damager doesn't meet the level restrictions
        }
    else{}//If the damager isn't a pc
    }
    else{// if the Local int has been set
        int iAmount = ((iLocal)-(iHpc));//The previous current health - the new current health give the damage of the last damage dealt
        SetLocalInt(oSelf, "hp", iHpc);//Set the local int to the newest current health
    if (iPc == TRUE){
        if (iHd == 1){
            GiveXPToCreature(oDamager, iAmount);
            }
        else{}
        }
    else{}
    }
}
