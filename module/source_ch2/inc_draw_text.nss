/*
   =============================================
   PENTAGRAMS & SUMMONING CIRCLES -
   BEAM-STYLE TEXT
   =============================================
   gaoneng                      January 17, 2005
   #include "inc_draw_text"

   last updated on April 25, 2005

   Extension library for PENTAGRAMS & SUMMONING
   CIRCLES. Used for creating text display.
   =============================================
*/

/*
   ==================================
   FUNCTIONS DECLARATIONS
   ==================================
*/
// Assigns oData to display sMessage
// =================================
// sMessage = message to display
// oData = target group
// fSpeed = second per letter
// fLifetime = seconds text lasts
// fFontHeight = height of font in meters
// fFontWidth = width of font in meters
// nVFX = VFX_BEAM_* constant
void TextMessage(string sMessage, object oData, float fSpeed=2.0f, float fLifetime=0.0f, float fFontHeight=0.5f, float fFontWidth=0.25f, int nVFX=VFX_BEAM_FIRE_W_SILENT);

/*
   ==================================
   PRIVATE FUNCTIONS
   ==================================
*/

// void gao_BeamLetter(object oNode, string sAlphabet, int nVFX, int nDurationType=2, float fFlashRate=0.0f);
// void gao_CreateTextGrid(object oNode, float fFontHeight, float fFontWidth);
// void gao_AlphabetBlink(object oNode, string sAlphabet, int nVFX, float fFlashRate, float fLifetime);
// void gao_AlphabetPermanent(object oNode, string sAlphabet, int nVFX, float fLifetime);
// void gao_AlphabetScroll(object oNode, string sMessage, int nVFX, float fFlashRate, float fLifetime=0.0f);
// string gao_ReverseMessage(string sMessage);


/*
   ==================================
   FUNCTIONS IMPLEMENTATIONS
   ==================================
*/
void gao_CreateTextGrid(object oNode, float fFontHeight, float fFontWidth, object oData, float fLifetime)
{
   object oArea = GetArea(oNode);
   vector vPos = GetPosition(oNode);
   float fFacing = GetFacing(oNode);
   vector vFacing = AngleToVector(fFacing + 90.0);
   vector vLedNode;
   object oLedNode;
   fFontWidth /= 2.0;
   fFontHeight /= 2.0;

   int i, j, nTotal;
   float f, g;

   for (i=0; i<3; i++)
   {
      f = IntToFloat(i);

      for (j=0; j<3; j++)
      {
         g = IntToFloat(j-1);
         vLedNode = vPos - fFontWidth*g*vFacing + f*Vector(0.0, 0.0, fFontHeight);
         oLedNode = CreateObject(OBJECT_TYPE_PLACEABLE, "prc_invisobj", Location(oArea, vLedNode, fFacing), FALSE, "PSC_X_TEXTMESSAGE");
         AssignCommand(oLedNode, ActionDoCommand(SetLocalObject(oNode, "led" + IntToString(j) + IntToString(i), oLedNode)));
         if (fLifetime == 0.0)
         {
            nTotal = GetLocalInt(oData, "storetotal");
            AssignCommand(oLedNode, ActionDoCommand(SetLocalObject(oData, "store" + IntToString(nTotal), oLedNode)));
            SetLocalInt(oData, "storetotal", nTotal + 1);
         }
      }
   }
}

void gao_DestroyTextGrid(object oNode)
{
   DestroyObject(GetLocalObject(oNode, "led00"));
   DestroyObject(GetLocalObject(oNode, "led10"));
   DestroyObject(GetLocalObject(oNode, "led20"));
   DestroyObject(GetLocalObject(oNode, "led01"));
   DestroyObject(GetLocalObject(oNode, "led11"));
   DestroyObject(GetLocalObject(oNode, "led21"));
   DestroyObject(GetLocalObject(oNode, "led02"));
   DestroyObject(GetLocalObject(oNode, "led12"));
   DestroyObject(GetLocalObject(oNode, "led22"));
}

void gao_BeamLetter(object oNode, string sAlphabet, int nVFX)
{
   object oNode1 = GetLocalObject(oNode, "led00");
   object oNode2 = GetLocalObject(oNode, "led10");
   object oNode3 = GetLocalObject(oNode, "led20");
   object oNode4 = GetLocalObject(oNode, "led01");
   object oNode5 = GetLocalObject(oNode, "led11");
   object oNode6 = GetLocalObject(oNode, "led21");
   object oNode7 = GetLocalObject(oNode, "led02");
   object oNode8 = GetLocalObject(oNode, "led12");
   object oNode9 = GetLocalObject(oNode, "led22");

   if (sAlphabet == "a")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "b")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode8);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode8);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode6);
   }
   else if (sAlphabet == "c")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "d")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode2);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode8, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode8);
   }
   else if (sAlphabet == "e")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode5);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "f")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode5);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "g")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "h")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
   }
   else if (sAlphabet == "i")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode8);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "j")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode4);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "k")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode5);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode5);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "l")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
   }
   else if (sAlphabet == "m")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode8);
   }
   else if (sAlphabet == "n")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "o" || sAlphabet == "0")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "p")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode6, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "q")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode3);
   }
   else if (sAlphabet == "r")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode6, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode5);
   }
   else if (sAlphabet == "s" || sAlphabet == "5")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode6);
   }
   else if (sAlphabet == "t")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode8);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "u")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "v")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "w")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode5);
   }
   else if (sAlphabet == "x")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode7);
   }
   else if (sAlphabet == "y")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode5, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode2, BODY_NODE_CHEST), oNode5);
   }
   else if (sAlphabet == "z")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "1")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "2")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode4);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode6, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "3")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "4")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "6")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode6);
   }
   else if (sAlphabet == "7")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "8")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
   }
   else if (sAlphabet == "9")
   {
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode1, BODY_NODE_CHEST), oNode3);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode6);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode7, BODY_NODE_CHEST), oNode9);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode4, BODY_NODE_CHEST), oNode7);
      ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(nVFX, oNode3, BODY_NODE_CHEST), oNode9);
   }
   else gao_DestroyTextGrid(oNode);
}

void gao_AlphabetPermanent(object oNode, string sAlphabet, int nVFX, float fLifetime)
{
   gao_BeamLetter(oNode, sAlphabet, nVFX);
   if (fLifetime > 0.0) DelayCommand(fLifetime, gao_DestroyTextGrid(oNode));
}

void TextMessage(string sMessage, object oData=OBJECT_SELF, float fSpeed=2.0f, float fLifetime=0.0f, float fFontHeight=0.5f, float fFontWidth=0.25f, int nVFX=VFX_BEAM_FIRE_W_SILENT)
{
   int i;
   object oNode;

   sMessage = GetStringLowerCase(sMessage);
   int nLength = GetStringLength(sMessage);
   int nData = GetLocalInt(oData, "storetotal");

   if (nLength > nData) nLength = nData;

   for (i=0; i<nLength; i++)
   {
      oNode = GetLocalObject(oData, "store" + IntToString(i));
      if (oNode != OBJECT_INVALID)
      {
         gao_CreateTextGrid(oNode, fFontHeight, fFontWidth, oData, fLifetime);
         DelayCommand(fSpeed*IntToFloat(i) + 1.0, gao_AlphabetPermanent(oNode, GetSubString(sMessage, i, 1), nVFX, fLifetime));
      }
      else break;
   }
}
