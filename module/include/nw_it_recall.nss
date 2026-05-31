#include "x2_inc_switches"
#include "nw_i0_plot"
void main()
{
    int nEvent =GetUserDefinedItemEventNumber();

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        //IsRecall is defined in nw_i0_plot
        IsRecall();
    }
}

