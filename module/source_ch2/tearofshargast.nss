/*BLACKSMITH SCRIPT
Created by
Lilac Soul's NWN Script Generator, v. 2.2
for download info please visit
http://nwvault.ign.com/View.php?view=Other.Detail&id=4683&id=625
*/

int lsn=1;
//lsstype=2

void SetItemLocals()
{
SetLocalString(OBJECT_SELF, "lsn1", "shartear");
SetLocalInt(OBJECT_SELF, "lsc_shartear", 30);
SetLocalString(OBJECT_SELF, "lsi1_shartear", "shar001");
SetLocalString(OBJECT_SELF, "lsi2_shartear", "shar002");
SetLocalString(OBJECT_SELF, "lsi3_shartear", "shar003");
SetLocalString(OBJECT_SELF, "lsi4_shartear", "shar004");
SetLocalString(OBJECT_SELF, "lsi5_shartear", "shar005");
SetLocalString(OBJECT_SELF, "lsi6_shartear", "shar006");
SetLocalString(OBJECT_SELF, "lsi7_shartear", "shar007");
SetLocalString(OBJECT_SELF, "lsi8_shartear", "shar008");
SetLocalString(OBJECT_SELF, "lsi9_shartear", "shar009");
SetLocalString(OBJECT_SELF, "lsi10_shartear", "shar010");
SetLocalString(OBJECT_SELF, "lsi11_shartear", "shar011");
SetLocalString(OBJECT_SELF, "lsi12_shartear", "shar012");
SetLocalString(OBJECT_SELF, "lsi13_shartear", "shar013");
SetLocalString(OBJECT_SELF, "lsi14_shartear", "shar014");
SetLocalString(OBJECT_SELF, "lsi15_shartear", "shar015");
SetLocalString(OBJECT_SELF, "lsi16_shartear", "shar016");
SetLocalString(OBJECT_SELF, "lsi17_shartear", "shar017");
SetLocalString(OBJECT_SELF, "lsi18_shartear", "shar018");
SetLocalString(OBJECT_SELF, "lsi19_shartear", "shar019");
SetLocalString(OBJECT_SELF, "lsi20_shartear", "shar020");
SetLocalString(OBJECT_SELF, "lsi21_shartear", "shar021");
SetLocalString(OBJECT_SELF, "lsi22_shartear", "shar022");
SetLocalString(OBJECT_SELF, "lsi23_shartear", "shar023");
SetLocalString(OBJECT_SELF, "lsi24_shartear", "shar024");
SetLocalString(OBJECT_SELF, "lsi25_shartear", "shar025");
SetLocalString(OBJECT_SELF, "lsi26_shartear", "shar026");
SetLocalString(OBJECT_SELF, "lsi27_shartear", "shar027");
SetLocalString(OBJECT_SELF, "lsi28_shartear", "shar028");
SetLocalString(OBJECT_SELF, "lsi29_shartear", "shar029");
SetLocalString(OBJECT_SELF, "lsi30_shartear", "shar030");
SetLocalInt(OBJECT_SELF, "lss_shartear", -10);
SetLocalInt(OBJECT_SELF, "lsv_shartear", VFX_FNF_IMPLOSION);
}

void CreateGold(object oTarget, int nAmount)
{
CreateItemOnObject("nw_it_gold001", oTarget, nAmount);
}

void main()
{
object oOwner=OBJECT_SELF;

if (!GetLocalInt(OBJECT_SELF, "lsvar_set"))
{
SetItemLocals();
SetLocalInt(OBJECT_SELF, "lsvar_set", TRUE);
}

if (lsn==0) return;

object oItem;
int bOkay, nGold, nCount, nNum, nLoop, nLoops, nHasGold, nVis;
string sCur, sReq;

for (nLoop=1; nLoop<=lsn; nLoop++)
   {
   sCur=GetLocalString(OBJECT_SELF, "lsn"+IntToString(nLoop));

   nNum=GetLocalInt(OBJECT_SELF, "lsc_"+sCur);

   for (nLoops=1; nLoops<=nNum; nLoops++)
      {

      sReq=GetLocalString(OBJECT_SELF, "lsi"+IntToString(nLoops)+"_"+sCur);
      if (GetStringLeft(sReq, 8)=="  gold  ")
         {
         nGold=StringToInt(GetStringRight(sReq, GetStringLength(sReq)-8));
         if (GetGold(oOwner)>=nGold) nCount++;

         }
      else if (GetItemPossessedBy(oOwner, sReq)!=OBJECT_INVALID)
         {
         SetLocalObject(OBJECT_SELF, "ls__"+IntToString(nLoops), GetItemPossessedBy(oOwner, sReq));

         nCount++;
         }
      }

   if (GetLocalInt(OBJECT_SELF, "lss_"+sCur)==-10) bOkay=TRUE;
   else if (GetLastSpell()==GetLocalInt(OBJECT_SELF, "lss_"+sCur)) bOkay=TRUE;
   else bOkay=FALSE;

   if (bOkay && (nCount==nNum)) bOkay=TRUE;
   else bOkay=FALSE;
   if (bOkay==TRUE)
      {

      if (nGold>0)
      {
      nHasGold=GetGold(oOwner);
      DestroyObject(GetItemPossessedBy(oOwner, "NW_IT_GOLD001"));
      DelayCommand(0.2, CreateGold(oOwner, nHasGold-nGold));
      }
      for (nLoops=1; nLoops<=nNum; nLoops++)
         {
         oItem=GetLocalObject(OBJECT_SELF, "ls__"+IntToString(nLoops));
         DestroyObject(oItem);
         }
      CreateItemOnObject(sCur, oOwner);
      int nVis=GetLocalInt(OBJECT_SELF, "lsv_"+sCur);
      if (nVis!=-10) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nVis), oOwner);
      }

   oItem=OBJECT_INVALID;
   bOkay=FALSE;
   nGold=0;
   nCount=0;
   sCur="";
   sReq="";
   nNum=0;
   }
}

