//Basic Commented Combat Dummy Trainer
//Rewards an average of 10 xp to lvl 1 characters per hostile action
void main()
{
    object oSelf = OBJECT_SELF; //The thing calling this, nameily the dummy itself
    object oAttacker = GetLastHostileActor(oSelf); //The last person to act hostilely, attacker, dammagers, spellcaster (if hostile), or disturber(in case of pickpocketing)
    int iPc = GetIsPC(oAttacker); //Wanna make sure it is a pc, just for good measure but we don't want wizard's pets getting lvls do we.
    int iHd = GetHitDice(oAttacker); //Easiest way to restrict via a lvl
    int iXp = d20(1);//Averages out to 10 xp, random amounts often make things feel more fluid, and organic
    if (iPc == TRUE){ //When the last attacker, is a pc
        if (iHd <= 1){ //If the pc is lvl 1, in this case left lvl 1 or lower to simplify editing for people whom want to make dumbies for higher lvl characters
            GiveXPToCreature(oAttacker, iXp); //Give the xp to the attacker
            }
        else{}//If the attack doesn't meet the level restrictions do this, (nothing)
        }
    else{} //If the Attack isn't a pc, do this (nothing)
}
