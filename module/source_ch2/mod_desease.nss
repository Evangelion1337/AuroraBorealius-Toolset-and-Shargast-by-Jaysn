void main()
{

object oPC = GetEnteringObject();
int iDisease=0;

if (GetIsObjectValid( oPC) && GetIsPC(oPC))
{
    if (!FortitudeSave(oPC, 14, SAVING_THROW_TYPE_DISEASE ))
   {

    switch (Random (17))
     {
        case 0:
            iDisease =  DISEASE_BLINDING_SICKNESS ;
        break;
        case 1:
            iDisease =  DISEASE_CACKLE_FEVER ;
        break;
        case 2:
            iDisease =  DISEASE_DEVIL_CHILLS ;
        break;
        case 3:
            iDisease =  DISEASE_DEMON_FEVER ;
        break;
        case 4:
            iDisease =  DISEASE_FILTH_FEVER ;
        break;
        case 5:
            iDisease =  DISEASE_MINDFIRE ;
        break;
        case 6:
            iDisease =  DISEASE_MUMMY_ROT ;
        break;
        case 7:
            iDisease =  DISEASE_RED_ACHE ;
        break;
        case 8:
            iDisease =  DISEASE_SHAKES ;
        break;
        case 9:
            iDisease =  DISEASE_SLIMY_DOOM ;
        break;
        case 10:
            iDisease =  DISEASE_RED_SLAAD_EGGS ;
        break;
        case 11:
            iDisease =  DISEASE_GHOUL_ROT ;
        break;
        case 12:
            iDisease =  DISEASE_ZOMBIE_CREEP ;
        break;
        case 13:
            iDisease =  DISEASE_DREAD_BLISTERS ;
        break;
        case 14:
            iDisease =  DISEASE_BURROW_MAGGOTS ;
        break;
        case 15:
            iDisease =  DISEASE_SOLDIER_SHAKES ;
        break;
        default :
            iDisease =  DISEASE_VERMIN_MADNESS ;
        break;
     }
     ApplyEffectToObject( DURATION_TYPE_TEMPORARY, EffectDisease( iDisease ), oPC, RoundsToSeconds(10) );
   }

}
}
