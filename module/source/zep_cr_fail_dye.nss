#include "zep_inc_craft"

int StartingConditional() {
    return (GetLocalInt(GetPCSpeaker(), "ZEP_CR_DONE") == ZEP_CR_DONE_NODYE);
}
