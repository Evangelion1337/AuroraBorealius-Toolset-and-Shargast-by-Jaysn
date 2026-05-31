// Moved to a seperate inc to prevent a circular dependency error

/*********************\
* Function Prototypes *
\*********************/

/**
 * This function will get the width of the area passed in.
 *
 * Created By:  Zaddix
 * Created On: July 17, 2002
 * Optimized: March , 2003 by Knat
 *
 * @param oArea  The area to get the width of.
 * @return       The width of oArea, as number of tiles. One tile = 10 meters.
 */
int GetAreaWidth(object oArea);

/**
 * This function will get the height of the area passed in.
 *
 * Created By:  Zaddix
 * Created On: July 17, 2002
 * Optimized: March , 2003 by Knat
 *
 * @param oArea  The area to get the height of.
 * @return       The height of oArea, as number of tiles. One tile = 10 meters.
 */
int GetAreaHeight(object oArea);

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////



/**********************\
* Function Definitions *
\**********************/

int GetAreaWidth(object oArea)
{
  int nX = GetLocalInt(oArea,"#WIDTH");
  if( nX == 0)
  {
    int nY = 0; int nColor;
    for (nX = 0; nX < 32; ++nX)
    {
      nColor = GetTileMainLight1Color(Location(oArea, Vector(IntToFloat(nX), 0.0, 0.0), 0.0));
      if (nColor < 0 || nColor > 255)
      {
        SetLocalInt(oArea,"#WIDTH", nX);
        return(nX);
      }
    }
    SetLocalInt(oArea,"#WIDTH", 32);
    return 32;
  }
  else
    return nX;
}

int GetAreaHeight(object oArea)
{
  int nY = GetLocalInt(oArea,"#HEIGHT");
  if( nY == 0)
  {
    int nX = 0; int nColor;
    for (nY=0; nY<32; ++nY)
    {
      nColor = GetTileMainLight1Color(Location(oArea, Vector(0.0, IntToFloat(nY), 0.0),0.0));
      if (nColor < 0 || nColor > 255)
      {
        SetLocalInt(oArea,"#HEIGHT",nY);
        return(nY);
      }
    }
    SetLocalInt(oArea,"#HEIGHT",32);
    return 32;
  }
  else
    return nY;
}
