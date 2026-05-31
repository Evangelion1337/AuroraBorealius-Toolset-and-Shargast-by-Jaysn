void CreateThing(string sTemplate, int type, location locHere)
{
     CreateObject(type, sTemplate, locHere);
}

void main()
{
    string tag;
    location loc;
    int what=GetObjectType(OBJECT_SELF);

    tag=GetTag(OBJECT_SELF);
    loc=GetLocation(OBJECT_SELF);
    AssignCommand(GetArea(OBJECT_SELF), DelayCommand(10.0,CreateThing(tag,what,loc)));

object oPC = GetLastKiller();

if (!GetIsPC(oPC)) return;

object oTarget;
object oSpawn;
location lTarget;
oTarget = GetWaypointByTag("WP_VP001");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "vakosportal", lTarget);

oTarget = oSpawn;

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION), oTarget));
else DelayCommand(0.5, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION), GetLocation(oTarget)));

}



