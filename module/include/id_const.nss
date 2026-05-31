// A list of the current Totems the players can have.

#include "sql_campaign"
string sCamName = "Imperial Dusk";
string sVenderName = "Vender Dbase";

int INT_ID_UNKNOWN = 0;
int INT_ID_DOG = 1;
int INT_ID_CAT = 2;
int INT_ID_BIRD = 3;
int INT_ID_BEAR = 4;
int INT_ID_FIRE = 5;
int INT_ID_ICE = 6;
int INT_ID_EARTH = 7;
int INT_ID_AIR = 8;
int INT_ID_SPIDER = 9;
int INT_ID_RAT = 10;
int INT_ID_BOVINE = 11;

string STR_ID_DOG = "Dog";
string STR_ID_CAT = "Cat";
string STR_ID_BIRD = "Bird";
string STR_ID_BEAR = "Bear";
string STR_ID_FIRE = "Fire";
string STR_ID_ICE = "Ice";
string STR_ID_EARTH = "Earth";
string STR_ID_AIR = "Air";
string STR_ID_SPIDER = "Spider";
string STR_ID_RAT = "Rat";
string STR_ID_BOVINE = "Bovine";

// list of the 'RAT' resrefs
string STR_ID_RAT_REF1 = "rattotem1";
string STR_ID_RAT_REF2 = "rattotem2";
string STR_ID_RAT_REF3 = "rattotem3";
string STR_ID_RAT_REF4 = "rattotem4";
string STR_ID_RAT_REF5 = "rattotem5";
string STR_ID_RAT_REF6 = "rattotem6";
string STR_ID_RAT_REF7 = "rattotem7";
string STR_ID_RAT_REF8 = "rattotem8";
string STR_ID_RAT_REF9 = "rattotem9";

// list of the 'DOG' resrefs
string STR_ID_DOG_REF1 = "dogtotem1";
string STR_ID_DOG_REF2 = "dogtotem2";
string STR_ID_DOG_REF3 = "dogtotem3";
string STR_ID_DOG_REF4 = "dogtotem4";
string STR_ID_DOG_REF5 = "dogtotem5";
string STR_ID_DOG_REF6 = "dogtotem6";
string STR_ID_DOG_REF7 = "dogtotem7";
string STR_ID_DOG_REF8 = "dogtotem8";
string STR_ID_DOG_REF9 = "dogtotem9";

// list of the 'CAT' resrefs
string STR_ID_CAT_REF1 = "penguin";
string STR_ID_CAT_REF2 = "penguin";
string STR_ID_CAT_REF3 = "penguin";
string STR_ID_CAT_REF4 = "penguin";
string STR_ID_CAT_REF5 = "penguin";
string STR_ID_CAT_REF6 = "penguin";
string STR_ID_CAT_REF7 = "penguin";
string STR_ID_CAT_REF8 = "penguin";
string STR_ID_CAT_REF9 = "penguin";

// list of the 'BIRD' resrefs
string STR_ID_BIRD_REF1 = "penguin";
string STR_ID_BIRD_REF2 = "penguin";
string STR_ID_BIRD_REF3 = "penguin";
string STR_ID_BIRD_REF4 = "penguin";
string STR_ID_BIRD_REF5 = "penguin";
string STR_ID_BIRD_REF6 = "penguin";
string STR_ID_BIRD_REF7 = "penguin";
string STR_ID_BIRD_REF8 = "penguin";
string STR_ID_BIRD_REF9 = "penguin";

// list of the 'BEAR' resrefs
string STR_ID_BEAR_REF1 = "penguin";
string STR_ID_BEAR_REF2 = "penguin";
string STR_ID_BEAR_REF3 = "penguin";
string STR_ID_BEAR_REF4 = "penguin";
string STR_ID_BEAR_REF5 = "penguin";
string STR_ID_BEAR_REF6 = "penguin";
string STR_ID_BEAR_REF7 = "penguin";
string STR_ID_BEAR_REF8 = "penguin";
string STR_ID_BEAR_REF9 = "penguin";

// list of the 'FIRE' resrefs
string STR_ID_FIRE_REF1 = "firetotem1";
string STR_ID_FIRE_REF2 = "firetotem2";
string STR_ID_FIRE_REF3 = "firetotem3";
string STR_ID_FIRE_REF4 = "firetotem4";
string STR_ID_FIRE_REF5 = "firetotem5";
string STR_ID_FIRE_REF6 = "firetotem6";
string STR_ID_FIRE_REF7 = "firetotem7";
string STR_ID_FIRE_REF8 = "firetotem8";
string STR_ID_FIRE_REF9 = "firetotem9";

// list of the 'ICE' resrefs
string STR_ID_ICE_REF1 = "watertotem1";
string STR_ID_ICE_REF2 = "watertotem2";
string STR_ID_ICE_REF3 = "watertotem3";
string STR_ID_ICE_REF4 = "watertotem4";
string STR_ID_ICE_REF5 = "watertotem5";
string STR_ID_ICE_REF6 = "watertotem6";
string STR_ID_ICE_REF7 = "watertotem7";
string STR_ID_ICE_REF8 = "watertotem8";
string STR_ID_ICE_REF9 = "watertotem9";

// list of the 'EARTH' resrefs
string STR_ID_EARTH_REF1 = "earthtotem1";
string STR_ID_EARTH_REF2 = "earthtotem2";
string STR_ID_EARTH_REF3 = "earthtotem3";
string STR_ID_EARTH_REF4 = "earthtotem4";
string STR_ID_EARTH_REF5 = "earthtotem5";
string STR_ID_EARTH_REF6 = "earthtotem6";
string STR_ID_EARTH_REF7 = "earthtotem7";
string STR_ID_EARTH_REF8 = "earthtotem8";
string STR_ID_EARTH_REF9 = "earthtotem9";

// list of the 'AIR' resrefs
string STR_ID_AIR_REF1 = "airtotem1";
string STR_ID_AIR_REF2 = "airtotem2";
string STR_ID_AIR_REF3 = "airtotem3";
string STR_ID_AIR_REF4 = "airtotem4";
string STR_ID_AIR_REF5 = "airtotem5";
string STR_ID_AIR_REF6 = "airtotem6";
string STR_ID_AIR_REF7 = "airtotem7";
string STR_ID_AIR_REF8 = "airtotem8";
string STR_ID_AIR_REF9 = "airtotem9";

// list of the 'SPIDER' resrefs
string STR_ID_SPIDER_REF1 = "spidertotem1";
string STR_ID_SPIDER_REF2 = "spidertotem2";
string STR_ID_SPIDER_REF3 = "spidertotem3";
string STR_ID_SPIDER_REF4 = "spidertotem4";
string STR_ID_SPIDER_REF5 = "spidertotem5";
string STR_ID_SPIDER_REF6 = "spidertotem6";
string STR_ID_SPIDER_REF7 = "spidertotem7";
string STR_ID_SPIDER_REF8 = "spidertotem8";
string STR_ID_SPIDER_REF9 = "spidertotem9";

//list of the 'bovine' resrefs
string STR_ID_BOVINE_REF1 = "pb_cowtotem_01";
string STR_ID_BOVINE_REF2 = "pb_cowtotem_02";
string STR_ID_BOVINE_REF3 = "pb_cowtotem_03";
string STR_ID_BOVINE_REF4 = "pb_cowtotem_04";
string STR_ID_BOVINE_REF5 = "pb_cowtotem_05";
string STR_ID_BOVINE_REF6 = "pb_cowtotem_06";
string STR_ID_BOVINE_REF7 = "pb_cowtotem_07";
string STR_ID_BOVINE_REF8 = "pb_cowtotem_08";
string STR_ID_BOVINE_REF9 = "pb_cowtotem_09";


int GetPCTotem( object oPC)
{
  int iTotem = SQL_GetCampaignInt( sCamName, "Totem", oPC);

  switch( iTotem)
  {
    case 1:
      return INT_ID_DOG;
    case 2:
      return INT_ID_CAT;
    case 3:
      return INT_ID_BIRD;
    case 4:
      return INT_ID_BEAR;
    case 5:
      return INT_ID_FIRE;
    case 6:
      return INT_ID_ICE;
    case 7:
      return INT_ID_EARTH;
    case 8:
      return INT_ID_AIR;
    case 9:
      return INT_ID_SPIDER;
    case 10:
      return INT_ID_RAT;
    case 11:
      return INT_ID_BOVINE;
  }
  return INT_ID_UNKNOWN;
}

string GetTotemName( int iTotem, int iLevel)
{
  if( iTotem == INT_ID_RAT)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_RAT_REF1;
        break;
      case 2:
        return STR_ID_RAT_REF2;
        break;
      case 3:
        return STR_ID_RAT_REF3;
        break;
      case 4:
        return STR_ID_RAT_REF4;
        break;
      case 5:
        return STR_ID_RAT_REF5;
        break;
      case 6:
        return STR_ID_RAT_REF6;
        break;
      case 7:
        return STR_ID_RAT_REF7;
        break;
      case 8:
        return STR_ID_RAT_REF8;
        break;
      case 9:
        return STR_ID_RAT_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_CAT)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_CAT_REF1;
        break;
      case 2:
        return STR_ID_CAT_REF2;
        break;
      case 3:
        return STR_ID_CAT_REF3;
        break;
      case 4:
        return STR_ID_CAT_REF4;
        break;
      case 5:
        return STR_ID_CAT_REF5;
        break;
      case 6:
        return STR_ID_CAT_REF6;
        break;
      case 7:
        return STR_ID_CAT_REF7;
        break;
      case 8:
        return STR_ID_CAT_REF8;
        break;
      case 9:
        return STR_ID_CAT_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_DOG)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_DOG_REF1;
        break;
      case 2:
        return STR_ID_DOG_REF2;
        break;
      case 3:
        return STR_ID_DOG_REF3;
        break;
      case 4:
        return STR_ID_DOG_REF4;
        break;
      case 5:
        return STR_ID_DOG_REF5;
        break;
      case 6:
        return STR_ID_DOG_REF6;
        break;
      case 7:
        return STR_ID_DOG_REF7;
        break;
      case 8:
        return STR_ID_DOG_REF8;
        break;
      case 9:
        return STR_ID_DOG_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_BEAR)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_BEAR_REF1;
        break;
      case 2:
        return STR_ID_BEAR_REF2;
        break;
      case 3:
        return STR_ID_BEAR_REF3;
        break;
      case 4:
        return STR_ID_BEAR_REF4;
        break;
      case 5:
        return STR_ID_BEAR_REF5;
        break;
      case 6:
        return STR_ID_BEAR_REF6;
        break;
      case 7:
        return STR_ID_BEAR_REF7;
        break;
      case 8:
        return STR_ID_BEAR_REF8;
        break;
      case 9:
        return STR_ID_BEAR_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_BIRD)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_BIRD_REF1;
        break;
      case 2:
        return STR_ID_BIRD_REF2;
        break;
      case 3:
        return STR_ID_BIRD_REF3;
        break;
      case 4:
        return STR_ID_BIRD_REF4;
        break;
      case 5:
        return STR_ID_BIRD_REF5;
        break;
      case 6:
        return STR_ID_BIRD_REF6;
        break;
      case 7:
        return STR_ID_BIRD_REF7;
        break;
      case 8:
        return STR_ID_BIRD_REF8;
        break;
      case 9:
        return STR_ID_BIRD_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_SPIDER)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_SPIDER_REF1;
        break;
      case 2:
        return STR_ID_SPIDER_REF2;
        break;
      case 3:
        return STR_ID_SPIDER_REF3;
        break;
      case 4:
        return STR_ID_SPIDER_REF4;
        break;
      case 5:
        return STR_ID_SPIDER_REF5;
        break;
      case 6:
        return STR_ID_SPIDER_REF6;
        break;
      case 7:
        return STR_ID_SPIDER_REF7;
        break;
      case 8:
        return STR_ID_SPIDER_REF8;
        break;
      case 9:
        return STR_ID_SPIDER_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_FIRE)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_FIRE_REF1;
        break;
      case 2:
        return STR_ID_FIRE_REF2;
        break;
      case 3:
        return STR_ID_FIRE_REF3;
        break;
      case 4:
        return STR_ID_FIRE_REF4;
        break;
      case 5:
        return STR_ID_FIRE_REF5;
        break;
      case 6:
        return STR_ID_FIRE_REF6;
        break;
      case 7:
        return STR_ID_FIRE_REF7;
        break;
      case 8:
        return STR_ID_FIRE_REF8;
        break;
      case 9:
        return STR_ID_FIRE_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_ICE)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_ICE_REF1;
        break;
      case 2:
        return STR_ID_ICE_REF2;
        break;
      case 3:
        return STR_ID_ICE_REF3;
        break;
      case 4:
        return STR_ID_ICE_REF4;
        break;
      case 5:
        return STR_ID_ICE_REF5;
        break;
      case 6:
        return STR_ID_ICE_REF6;
        break;
      case 7:
        return STR_ID_ICE_REF7;
        break;
      case 8:
        return STR_ID_ICE_REF8;
        break;
      case 9:
        return STR_ID_ICE_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_EARTH)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_EARTH_REF1;
        break;
      case 2:
        return STR_ID_EARTH_REF2;
        break;
      case 3:
        return STR_ID_EARTH_REF3;
        break;
      case 4:
        return STR_ID_EARTH_REF4;
        break;
      case 5:
        return STR_ID_EARTH_REF5;
        break;
      case 6:
        return STR_ID_EARTH_REF6;
        break;
      case 7:
        return STR_ID_EARTH_REF7;
        break;
      case 8:
        return STR_ID_EARTH_REF8;
        break;
      case 9:
        return STR_ID_EARTH_REF9;
        break;
    }
  }
  else if( iTotem == INT_ID_AIR)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_AIR_REF1;
        break;
      case 2:
        return STR_ID_AIR_REF2;
        break;
      case 3:
        return STR_ID_AIR_REF3;
        break;
      case 4:
        return STR_ID_AIR_REF4;
        break;
      case 5:
        return STR_ID_AIR_REF5;
        break;
      case 6:
        return STR_ID_AIR_REF6;
        break;
      case 7:
        return STR_ID_AIR_REF7;
        break;
      case 8:
        return STR_ID_AIR_REF8;
        break;
      case 9:
        return STR_ID_AIR_REF9;
        break;
    }
  }
    else if( iTotem == INT_ID_BOVINE)
  {
    switch( iLevel)
    {
      case 1:
        return STR_ID_BOVINE_REF1;
        break;
      case 2:
        return STR_ID_BOVINE_REF2;
        break;
      case 3:
        return STR_ID_BOVINE_REF3;
        break;
      case 4:
        return STR_ID_BOVINE_REF4;
        break;
      case 5:
        return STR_ID_BOVINE_REF5;
        break;
      case 6:
        return STR_ID_BOVINE_REF6;
        break;
      case 7:
        return STR_ID_BOVINE_REF7;
        break;
      case 8:
        return STR_ID_BOVINE_REF8;
        break;
      case 9:
        return STR_ID_BOVINE_REF9;
        break;
    }
  }

  return "";
}
