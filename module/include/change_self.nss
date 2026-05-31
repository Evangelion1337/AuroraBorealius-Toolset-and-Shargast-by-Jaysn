// pulls StrRef in appearance.2da
// by line number nStrRef
string cyl_getname(int nStrRef);

// cycles to next valid appearance
void cyl_getnextshape(object oObject=OBJECT_SELF);

// cycles to last valid appearance
void cyl_getlastshape(object oObject=OBJECT_SELF);

//***********************MAIN SCRIPT**************************************
void main()
{
int nListen = GetListenPatternNumber();

switch(nListen)
{

    case 1919:   //next
          cyl_getnextshape();
          break;

    case 2929: //last
          cyl_getlastshape();
          break;

    case 3939: //taunt
          PlayAnimation(ANIMATION_FIREFORGET_TAUNT);
          break;

    case 4949:  // *n
          {
          string sAppearance = GetMatchedSubstring(0);
          int nAppearance = StringToInt(sAppearance);
          if (Get2DAString("appearance","LABEL",nAppearance) == "" ||
              nAppearance < 0 || nAppearance > 1486)
              {
               SpeakString("Not a valid number.  Please choose another " +
                           "one or type in the words, next or last to view" +
                           " the next available creature appearance.");
               return;
              }
          SetCreatureAppearanceType(OBJECT_SELF,nAppearance);
          SpeakString("# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance));
          break;
          }
    case 5959: //set*w*n
          {
          int nAppearance = StringToInt(GetMatchedSubstring(2));
          if (Get2DAString("appearance","LABEL",nAppearance) == "" ||
              nAppearance < 0 || nAppearance > 1486)
              {
               SpeakString("Not a valid number.  Please choose another " +
                           "one, or type in set next or set last to change" +
                           " your appearance.");
               return;
              }
          SetCreatureAppearanceType(GetLastSpeaker(),nAppearance);
          SpeakString("# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance));
          break;
          }

    case 6969: //set next
          cyl_getnextshape(GetLastSpeaker());
          break;

    case 7979: //set last
          cyl_getlastshape(GetLastSpeaker());
          break;


}
}
//******************END MAIN SCRIPT*******************************************


void cyl_getnextshape(object oObject=OBJECT_SELF)
{
int nAppearance = GetAppearanceType(oObject);
string s2da;
string sSpeak;
int nTest;

switch (nAppearance)
{   // used for empty lines of 10 or more to cut down
    // lag, since I'm using a looping statement on 2da files.
    case 306:
        nAppearance = 350;
        nTest = TRUE;
        break;
    case 480:
        nAppearance = 1000;
        nTest = TRUE;
        break;
    case 1485:
        nAppearance = 0;
        nTest = TRUE;
        break;
}

if (nTest)
    {
    sSpeak = "# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance);
    SetCreatureAppearanceType(oObject,nAppearance);
    SpeakString("# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance));
    return;
    }

nAppearance++;
s2da = Get2DAString("appearance","LABEL",nAppearance);
// empty entry in LABEL column of 2da is invalid.
while (s2da == "")
  {
   nAppearance++;
   s2da = Get2DAString("appearance","LABEL",nAppearance);
  }
SetCreatureAppearanceType(oObject,nAppearance);
sSpeak = "# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance);
SpeakString(sSpeak);
}
//end




void cyl_getlastshape(object oObject=OBJECT_SELF)
{
int nAppearance = GetAppearanceType(oObject);
string s2da = Get2DAString("appearance","STRING_REF",480);
string sSpeak;
int nTest;

switch(nAppearance)
{
    case 0:
        nAppearance = 1485;
        nTest = TRUE;
        break;
    case 1000:
        nAppearance = 480;
        nTest = TRUE;
        break;
    case 350:
        nAppearance = 306;
        nTest = TRUE;
        break;
}

if (nTest)
    {
    sSpeak = "# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance);
    SetCreatureAppearanceType(oObject,nAppearance);
    SpeakString("# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance));
    return;
    }

nAppearance--;
s2da = Get2DAString("appearance","LABEL",nAppearance);




while (s2da == "")
  {
   nAppearance--;
   s2da = Get2DAString("appearance","LABEL",nAppearance);
  }
SetCreatureAppearanceType(oObject,nAppearance);
sSpeak = "# " + IntToString(nAppearance) + "  " + cyl_getname(nAppearance);
SpeakString(sSpeak);
}
//end

string cyl_getname(int nStrRef)
{
string s2da = Get2DAString("appearance","STRING_REF",nStrRef);

string sName = GetStringByStrRef(StringToInt(s2da));
return sName;
}
//end
