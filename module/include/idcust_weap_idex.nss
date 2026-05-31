//prototypes
int GetBastardSwordIndex( int iIndex, int iPart);
int GetBattleAxeIndex( int iIndex, int iPart);
int GetClubIndex( int iIndex, int iPart);
int GetDaggerIndex( int iIndex, int iPart);
int GetGreatAxeIndex( int iIndex, int iPart);
int GetGreatSwordIndex( int iIndex, int iPart);
int GetKatanaIndex( int iIndex, int iPart);
int GetLightMaceIndex( int iIndex, int iPart);
int GetLongBowIndex( int iIndex, int iPart);
int GetLongSwordIndex( int iIndex, int iPart);
int GetRapierIndex( int iIndex, int iPart);
int GetScimitarIndex( int iIndex, int iPart);
int GetShortSwordIndex( int iIndex, int iPart);
int GetSpearIndex( int iIndex, int iPart);
int GetWarHammerIndex( int iIndex, int iPart);
int GetScytheIndex( int iIndex, int iPart);
int GetQuarterStaffIndex( int iIndex, int iPart);
int GetHalberdIndex( int iIndex, int iPart);

int GetD3Index( int iIndex, int iPart);
int GetD4Index( int iIndex, int iPart);
int GetD6Index( int iIndex, int iPart);
int GetNewWeaponIndex( int iIndex, int iPart);

//implimentation
int GetNextWeaponIndex( int iIndex, int iItemType, int iPart)
{
  switch( iItemType)
  {
    case BASE_ITEM_BASTARDSWORD:
    {
      iIndex = GetBastardSwordIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_BATTLEAXE:
    {
      iIndex = GetBattleAxeIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_CLUB:
    {
      iIndex = GetClubIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_DAGGER:
    {
      iIndex = GetDaggerIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_DART:
    {
      iIndex = GetNewWeaponIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_DIREMACE:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_DOUBLEAXE:
    {
      iIndex = GetD3Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_DWARVENWARAXE:
    {
      iIndex = GetNewWeaponIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_GREATAXE:
    {
      iIndex = GetGreatAxeIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_GREATSWORD:
    {
      iIndex =GetGreatSwordIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_HALBERD:
    {
      iIndex = GetHalberdIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_HANDAXE:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_HEAVYCROSSBOW:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_HEAVYFLAIL:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_KAMA:
    {
      iIndex = GetNewWeaponIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_KATANA:
    {
      iIndex = GetKatanaIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_KUKRI:
    {
      iIndex = GetNewWeaponIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LIGHTCROSSBOW:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LIGHTFLAIL:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LIGHTHAMMER:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LIGHTMACE:
    {
      iIndex = GetLightMaceIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LONGBOW:
    {
      iIndex = GetLongBowIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_LONGSWORD:
    {
      iIndex = GetLongSwordIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_MORNINGSTAR:
    {
      iIndex = GetD4Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_QUARTERSTAFF:
    {
      iIndex = GetQuarterStaffIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_RAPIER:
    {
      iIndex = GetRapierIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SCIMITAR:
    {
      iIndex = GetScimitarIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SCYTHE:
    {
      iIndex = GetScytheIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SHORTBOW:
    {
      iIndex = GetD6Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SHORTSPEAR:
    {
      iIndex = GetSpearIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SHORTSWORD:
    {
      iIndex = GetShortSwordIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_SICKLE:
    {
      iIndex = 1;
      break;
    }
    case BASE_ITEM_SLING:
    {
      iIndex = GetNewWeaponIndex( iIndex, iPart);
      break;
    }
    case BASE_ITEM_TWOBLADEDSWORD:
    {
      iIndex = GetD3Index( iIndex, iPart);
      break;
    }
    case BASE_ITEM_WARHAMMER:
    {
      iIndex = GetWarHammerIndex( iIndex, iPart);
      break;
    }
    default:
    {
      if( iIndex > 3)
        iIndex = 1;
    }
  }
  return iIndex;
}

int GetD3Index( int iIndex, int iPart)
{
  if( iIndex > 3)
    iIndex = 1;
  return iIndex;
}

int GetD4Index( int iIndex, int iPart)
{
  if( iIndex > 4)
    iIndex = 1;
  return iIndex;
}

int GetD6Index( int iIndex, int iPart)
{
  if( iIndex > 6)
    iIndex = 1;
  return iIndex;
}

int GetNewWeaponIndex( int iIndex, int iPart)
{
  if( iIndex > 30)
    iIndex = 1;
  return iIndex;
}


int GetScytheIndex( int iIndex, int iPart)
{
  if( iIndex == 4)
    iIndex = 25;
  else if( iIndex > 25)
    iIndex = 1;
  return iIndex;
}

int GetQuarterStaffIndex( int iIndex, int iPart)
{
  if( iIndex == 5)
    iIndex = 23;
  else if( iIndex == 24)
    iIndex = 25;
  else if( iIndex > 25)
    iIndex = 1;
  return iIndex;
}

int GetSpearIndex( int iIndex, int iPart)
{
  if( iIndex == 5)
    iIndex = 24;
  else if( iIndex > 25)
    iIndex = 1;

  return iIndex;
}

int GetKatanaIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 13)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 14)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 13)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}


int GetHalberdIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if ( iIndex > 23)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if ( iIndex > 23)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetClubIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if( iIndex == 24)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 21;
      else if( iIndex == 24)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetGreatAxeIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 18)
        iIndex = 19;
      else if( iIndex == 20)
        iIndex = 21;
      else if( iIndex == 22)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 12)
        iIndex = 13;
      else if( iIndex == 14)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if( iIndex == 19)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetGreatSwordIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 6)
        iIndex = 9;
      else if( iIndex == 16)
        iIndex = 17;
      else if( iIndex == 18)
        iIndex = 19;
      else if( iIndex == 20)
        iIndex = 21;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 6)
        iIndex = 9;
      else if( iIndex == 16)
        iIndex = 19;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 6)
        iIndex = 9;
      else if( iIndex == 12)
        iIndex = 19;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetBattleAxeIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 13)
        iIndex = 15;
      else if( iIndex == 18)
        iIndex = 19;
      else if( iIndex == 22)
        iIndex = 23;
      else if( iIndex == 24)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 7)
        iIndex = 9;
      else if( iIndex == 13)
        iIndex = 15;
      else if( iIndex == 17)
        iIndex = 18;
      else if ( iIndex > 18)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 7)
        iIndex = 9;
      else if ( iIndex > 16)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetBastardSwordIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if( iIndex == 12)
        iIndex = 14;
      else if( iIndex == 19)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if( iIndex == 19)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if( iIndex == 17)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetLongBowIndex( int iIndex, int iPart)
{
  if( iIndex == 9)
    iIndex = 25;
  else if( iIndex> 25)
    iIndex = 1;

  return iIndex;
}

int GetLongSwordIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 10)
        iIndex = 11;
      else if( iIndex == 15)
        iIndex = 17;
      else if( iIndex == 20)
        iIndex = 22;
      else if( iIndex == 24)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 10)
        iIndex = 11;
      else if( iIndex == 21)
        iIndex = 22;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 10)
        iIndex = 11;
      else if( iIndex == 17)
        iIndex = 18;
      else if( iIndex == 20)
        iIndex = 23;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetDaggerIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 7)
        iIndex = 18;
      else if( iIndex == 19)
        iIndex = 20;
      else if ( iIndex > 20)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 7)
        iIndex = 20;
      else if ( iIndex > 20)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 7)
        iIndex = 20;
      else if ( iIndex > 20)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetRapierIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex > 13)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex > 24)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex > 16)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetScimitarIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 6)
        iIndex = 11;
      else if ( iIndex == 16)
        iIndex = 17;
      else if ( iIndex == 18)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if ( iIndex == 6)
        iIndex = 11;
      else if ( iIndex == 16)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if ( iIndex == 6)
        iIndex = 11;
      else if ( iIndex == 14)
        iIndex = 24;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetLightMaceIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex == 17)
        iIndex = 18;
      else if ( iIndex == 21)
        iIndex = 22;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex == 19)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 5)
        iIndex = 11;
      else if ( iIndex == 12)
        iIndex = 25;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetShortSwordIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex == 14)
        iIndex = 15;
      else if ( iIndex == 20)
        iIndex = 21;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex == 14)
        iIndex = 21;
      else if ( iIndex > 25)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}

int GetWarHammerIndex( int iIndex, int iPart)
{
  switch( iPart)
  {
    case ITEM_APPR_WEAPON_MODEL_TOP:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex > 16)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_MIDDLE:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex > 14)
        iIndex = 1;
      break;
    }
    case ITEM_APPR_WEAPON_MODEL_BOTTOM:
    {
      if( iIndex == 7)
        iIndex = 11;
      else if ( iIndex > 14)
        iIndex = 1;
      break;
    }
  }
  return iIndex;
}
