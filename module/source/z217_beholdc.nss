///////////////////////////////////////////////////
// Beholder Ray: On Heartbeat                    //
///////////////////////////////////////////////////
/*
    The persistent area of effect is destroyed each
    round and recreated if needed...
*/
///////////////////////////////////////////////////
// Created By: Zarathustra217                    //
// Created On: Okt 7. 2002                       //
///////////////////////////////////////////////////
#include "NW_I0_SPELLS"

void main()
{
    object oBeholder = GetAreaOfEffectCreator();
    object oFacing=GetLocalObject(OBJECT_SELF,"Facing");
    if(GetIsInCombat(oBeholder))
    {
        if(!GetIsDead(oBeholder)||!GetIsObjectValid(oBeholder)||!GetIsDead(oFacing)||!GetIsObjectValid(oFacing))
        {
            AssignCommand(oBeholder,ClearAllActions());
            AssignCommand(oBeholder,SetFacingPoint(GetPosition(oFacing)));
            int nESCInFacingArc=GetLocalInt(OBJECT_SELF,"SpellCastersInFacingArc");
            if(GetIsEnemy(oFacing,oBeholder))
            {
                if(nESCInFacingArc>1&&GetDistanceBetween(oBeholder,oFacing)>5.0&&GetLocalInt(OBJECT_SELF,"EyeOpen"))
                {
                    AssignCommand(oBeholder,ActionAttack(oFacing,TRUE));
                }
                else
                {
                    AssignCommand(oBeholder,ActionAttack(oFacing,FALSE));
                }
            }
        }
    }
    DestroyObject(OBJECT_SELF, 0.0);
}

