#include "NW_O2_CONINCLUDE"
#include "prc_class_const"


//Create Amulet in chest based on Hit Dice
void CreateAmulet(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck022"; break;
                       case 2: sItem = "nw_it_mneck023"; break;
                       case 3: sItem = "nw_it_mneck021"; break;
                   }
            }
            else if (GetRange(2, nHD))   // * 200 - 2500
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck001"; break;
                       case 2: sItem = "nw_it_mneck007"; break;
                       case 3: sItem = "nw_it_mneck006"; break;
                   }
            }
            else if (GetRange(3, nHD))   // * 800 - 10000
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck012"; break;
                       case 2: sItem = "nw_it_mneck025"; break;
                       case 3: sItem = "nw_it_mneck016"; break;
                   }

            }
            else if (GetRange(4, nHD))   // * 2500 - 16500
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck029"; break;
                       case 2: sItem = "nw_it_mneck013"; break;
                       case 3: sItem = "nw_it_mneck033"; break;
                   }

            }
            else if (GetRange(5, nHD))   // * 8000 - 25000
            {
                   int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck015"; break;
                       case 2: sItem = "nw_it_mneck019"; break;
                       case 3: sItem = "nw_it_mneck005"; break;
                   }

            }
            else if (GetRange(6, nHD))   // * 16000 and up
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mneck034"; break;
                       case 2: sItem = "nw_it_mneck037"; break;
                       case 3: sItem = "nw_it_mneck011"; break;
                   }
            }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Ring in chest based on Hit Dice
void CreateRing(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring023"; break;
                       case 2: sItem = "nw_it_mring021"; break;
                       case 3: sItem = "nw_it_mring022"; break;
                   }
            }
            else if (GetRange(2, nHD))   // * 200 - 2500
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring018"; break;
                       case 2: sItem = "nw_it_mring003"; break;
                       case 3: sItem = "nw_it_mring014"; break;
                   }
            }
            else if (GetRange(3, nHD))   // * 800 - 10000
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring029"; break;
                       case 2: sItem = "nw_it_mring015"; break;
                       case 3: sItem = "nw_it_mring028"; break;
                   }

            }
            else if (GetRange(4, nHD))   // * 2500 - 16500
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring033"; break;
                       case 2: sItem = "nw_it_mring016"; break;
                       case 3: sItem = "nw_it_mring005"; break;
                   }

            }
            else if (GetRange(5, nHD))   // * 8000 - 25000
            {
                   int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring020"; break;
                       case 2: sItem = "nw_it_mring012"; break;
                       case 3: sItem = "nw_it_mring007"; break;
                   }

            }
            else if (GetRange(6, nHD))   // * 16000 and up
            {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mring004"; break;
                       case 2: sItem = "nw_it_mring030"; break;
                       case 3: sItem = "nw_it_mring017"; break;
                   }
            }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Bracer/Gauntlet for Monk
void CreateMonkGlove(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mbracer002"; break;
                       case 2: sItem = "nw_it_mglove026"; break;
                       case 3: sItem = "nw_it_mbracer001"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                    int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mbracer003"; break;
                       case 2: sItem = "nw_it_mglove027"; break;
                       case 3: sItem = "nw_it_mglove016"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mbracer008"; break;
                       case 2: sItem = "nw_it_mbracer004"; break;
                       case 3: sItem = "nw_it_mglove018"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                   int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mbracer003"; break;
                       case 2: sItem = "nw_it_mbracer013"; break;
                       case 3: sItem = "nw_it_mglove023"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mglove029"; break;
                       case 2: sItem = "nw_it_mglove019"; break;
                       case 3: sItem = "nw_it_mbracer005"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_it_mbracer006"; break;
                       case 2: sItem = "nw_it_mglove030"; break;
                       case 3: sItem = "nw_it_mglove020"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Clothing for Monk/Wizard/Sorcerer
void CreateClothing(object oTarget, object oAdventurer)
{
    string sItem = "";

    int nRandom = Random(12) + 1;
        switch (nRandom)
            {
                case 1: sItem = "nw_mcloth020"; break;
                case 2: sItem = "nw_mcloth017"; break;
                case 3: sItem = "nw_mcloth004"; break;
                case 4: sItem = "nw_mcloth003"; break;
                case 5: sItem = "nw_mcloth016"; break;
                case 6: sItem = "nw_mcloth007"; break;
                case 7: sItem = "nw_mcloth008"; break;
                case 8: sItem = "nw_mcloth010"; break;
                case 9: sItem = "nw_mcloth009"; break;
                case 10: sItem = "nw_mcloth002"; break;
                case 11: sItem = "nw_mcloth022"; break;
                case 12: sItem = "nw_mcloth001"; break;
            }

    if (sItem != "")
      dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Light Armor based on Hit Dice
void CreateLightArmor(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_aarcl012"; break;
                       case 2: sItem = "nw_aarcl001"; break;
                       case 3: sItem = "nw_aarcl032"; break;
                  }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl079"; break;
                       case 2: sItem = "nw_maarcl087"; break;
                       case 3: sItem = "nw_maarcl013"; break;
                  }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl005"; break;
                       case 2: sItem = "nw_maarcl034"; break;
                       case 3: sItem = "nw_maarcl006"; break;
                  }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl001"; break;
                       case 2: sItem = "nw_maarcl008"; break;
                       case 3: sItem = "nw_it_novel003"; break;
                  }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl009"; break;
                       case 2: sItem = "nw_maarcl033"; break;
                       case 3: sItem = "nw_maarcl017"; break;
                  }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl002"; break;
                       case 2: sItem = "nw_maarcl004"; break;
                       case 3: sItem = "nw_maarcl005"; break;
                  }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Medium Armor based on Hit Dice
void CreateMediumArmor(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_aarcl010"; break;
                       case 2: sItem = "nw_aarcl004"; break;
                       case 3: sItem = "nw_aarcl003"; break;
                  }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl058"; break;
                       case 2: sItem = "nw_maarcl065"; break;
                       case 3: sItem = "nw_maarcl073"; break;
                  }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl016"; break;
                       case 2: sItem = "nw_maarcl037"; break;
                       case 3: sItem = "nw_maarcl085"; break;
                  }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl040"; break;
                       case 2: sItem = "nw_maarcl061"; break;
                  }

        }
        else  if (GetRange(5, nHD))
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl039"; break;
                  }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl015"; break;
                       case 2: sItem = "nw_maarcl010"; break;
                       case 3: sItem = "nw_maarcl014"; break;
                  }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//Create Heavy Armor based on Hit Dice
void CreateHeavyArmor(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl051"; break;
                       case 2: sItem = "nw_maarcl050"; break;
                       case 3: sItem = "nw_maarcl052"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl076"; break;
                       case 2: sItem = "nw_maarcl081"; break;
                       case 3: sItem = "nw_maarcl026"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl018"; break;
                       case 2: sItem = "nw_maarcl080"; break;
                       case 3: sItem = "nw_maarcl042"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl063"; break;
                       case 2: sItem = "nw_maarcl062"; break;
                       case 3: sItem = "nw_maarcl028"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {

                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl054"; break;
                       case 2: sItem = "nw_maarcl063"; break;
                       case 3: sItem = "nw_maarcl024"; break;
                   }
        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_maarcl025"; break;
                       case 2: sItem = "nw_maarcl027"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

//:://////////////////////////////////////////////
/*
    Creates personalized armor, amulet, or ring in chest.
*/
//:://////////////////////////////////////////////
//:: Created By: Rand Al'Thor
//:: Created On: August 2002
//:://////////////////////////////////////////////

void main()
{
    object oLastOpener = GetLastOpener();
    object oContainer = OBJECT_SELF;

	if (GetLocalInt(OBJECT_SELF, "NW_L_OPENONCE") > 0 || GetIsObjectValid(oLastOpener) == FALSE)
    {
        return; // * abort treasure if no one opened the container
    }
    SetLocalInt(OBJECT_SELF, "NW_L_OPENONCE",1);
    ShoutDisturbed();

    // * Choose the armor type to create
    int Random2 = Random(3) +1;

    if (Random2 == 1)
        CreateAmulet(oContainer, oLastOpener);

    else if (Random2 == 2)
        CreateRing(oContainer, oLastOpener);

    else if (Random2 == 3)
    {
        if (GetClassByPosition(1, oLastOpener) == CLASS_TYPE_MONK)
        {
            int nRandom3 = Random(2) + 1;
                switch (nRandom3)
                {
                    case 1: CreateMonkGlove(oContainer, oLastOpener); break;
                    case 2: CreateClothing(oContainer, oLastOpener); break;
                }
        }

        else if (GetClassByPosition(1, oLastOpener) == CLASS_TYPE_WIZARD || 
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_SORCERER || 
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_DRAGONFIRE_ADEPT ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_DRAGON_SHAMAN ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_DREAD_NECROMANCER ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_BEGUILER ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_SHADOWCASTER ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_WARMAGE ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_BINDER ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_TRUENAMER ||
					GetClassByPosition(1, oLastOpener) == CLASS_TYPE_WARLOCK) 
			
			CreateClothing(oContainer, oLastOpener);

        else if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oLastOpener) == TRUE && GetHasFeat(FEAT_ARMOR_PROFICIENCY_MEDIUM, oLastOpener) == TRUE && GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY, oLastOpener) == TRUE)
        {
            int nRandom3 = Random(3) + 1;
                switch (nRandom3)
                {
                    case 1: CreateLightArmor(oContainer, oLastOpener); break;
                    case 2: CreateMediumArmor(oContainer, oLastOpener); break;
                    case 3: CreateHeavyArmor(oContainer, oLastOpener); break;
                }
        }
        else if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oLastOpener) == TRUE && GetHasFeat(FEAT_ARMOR_PROFICIENCY_MEDIUM, oLastOpener) == TRUE)
        {
            int nRandom3 = Random(2) + 1;
                switch (nRandom3)
                {
                    case 1: CreateLightArmor(oContainer, oLastOpener); break;
                    case 2: CreateMediumArmor(oContainer, oLastOpener); break;
                }
        }
        else if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oLastOpener) == TRUE)
            CreateLightArmor(oContainer, oLastOpener);
    }
}

