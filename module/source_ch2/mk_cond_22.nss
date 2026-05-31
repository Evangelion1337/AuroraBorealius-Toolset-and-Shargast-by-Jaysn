#include "mk_inc_generic"

int StartingConditional()
{
    return MK_GenericDialog_GetCondition(22);
//    return (GetLocalInt(OBJECT_SELF, "MK_CONDITION_22")==1);
}
