//::///////////////////////////////////////////////
//:: Dye Kit - Include
//:: dye_include.nss
//:: Copyright (c) 2006 Jake E. Fitch
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: August 30th, 2006
//:://////////////////////////////////////////////

string ClothColor(int iColor);
string MetalColor(int iColor);

string ClothColor(int iColor) {
    switch (iColor) {
        case 00: return "Lightest Tan/Brown";
        case 01: return "Light Tan/Brown";
        case 02: return "Dark Tan/Brown";
        case 03: return "Darkest Tan/Brown";

        case 04: return "Lightest Tan/Red";
        case 05: return "Light Tan/Red";
        case 06: return "Dark Tan/Red";
        case 07: return "Darkest Tan/Red";

        case 08: return "Lightest Tan/Yellow";
        case 09: return "Light Tan/Yellow";
        case 10: return "Dark Tan/Yellow";
        case 11: return "Darkest Tan/Yellow";

        case 12: return "Lightest Tan/Grey";
        case 13: return "Light Tan/Grey";
        case 14: return "Dark Tan/Grey";
        case 15: return "Darkest Tan/Grey";

        case 16: return "Lightest Olive";
        case 17: return "Light Olive";
        case 18: return "Dark Olive";
        case 19: return "Darkest Olive";

        case 20: return "White";
        case 21: return "Light Grey";
        case 22: return "Dark Grey";
        case 23: return "Charcoal";

        case 24: return "Light Blue";
        case 25: return "Dark Blue";

        case 26: return "Light Aqua";
        case 27: return "Dark Aqua";

        case 28: return "Light Teal";
        case 29: return "Dark Teal";

        case 30: return "Light Green";
        case 31: return "Dark Green";

        case 32: return "Light Yellow";
        case 33: return "Dark Yellow";

        case 34: return "Light Orange";
        case 35: return "Dark Orange";

        case 36: return "Light Red";
        case 37: return "Dark Red";

        case 38: return "Light Pink";
        case 39: return "Dark Pink";

        case 40: return "Light Purple";
        case 41: return "Dark Purple";

        case 42: return "Light Violet";
        case 43: return "Dark Violet";

        case 44: return "Shiny White";
        case 45: return "Shiny Black";

        case 46: return "Shiny Blue";
        case 47: return "Shiny Aqua";

        case 48: return "Shiny Teal";
        case 49: return "Shiny Green";

        case 50: return "Shiny Yellow";
        case 51: return "Shiny Orange";

        case 52: return "Shiny Red";
        case 53: return "Shiny Pink";

        case 54: return "Shiny Purple";
        case 55: return "Shiny Violet";

        case 56: return "Hidden: Silver";
        case 57: return "Hidden: Obsidian";
        case 58: return "Hidden: Gold";
        case 59: return "Hidden: Copper";
        case 60: return "Hidden: Grey";
        case 61: return "Hidden: Mirror";
        case 62: return "Hidden: Pure White";
        case 63: return "Hidden: Pure Black";

        case 64: return "Smoky Pink";
        case 65: return "Smoky Taupe";
        case 66: return "Smoky Gold";
        case 67:return "Smoky Leaf Green";
        case 68: return "Smoky Green";
        case 69: return "Smoky Dark Green";
        case 70: return "Smoky Royal Purple";
        case 71: return "Smoky Dusk";

        case 72: return "Smoky Plum";
        case 73: return "Smoky Wisteria";
        case 74: return "Smoky Brown";
        case 75: return "Smoky Grey";
        case 76: return "Smoky Sea Green";
        case 77: return "Smoky Eucalyptus Leaf";
        case 78: return "Smoky Blue";
        case 79: return "Smoky Slate Blue";

        case 80: return "Smoky Hunter Green";
        case 81: return "Smoky Thyme Green";
        case 82: return "Smoky Ice Blue";
        case 83: return "Smoky Cobalt Blue";
        case 84: return "Smoky Grasshopper";
        case 85: return "Smoky Stone";
        case 86: return "Smoky Mushroom";
        case 87: return "Smoky Moss Green";

        case 88: return "Smoky Lightest Red";
        case 89: return "Smoky Light Red";
        case 90: return "Smoky Red";
        case 91: return "Smoky Dark Red";
        case 92: return "Smoky Lightest Brass";
        case 93: return "Smoky Light Brass";
        case 94: return "Smoky Brass";
        case 95: return "Smoky Dark Brass";

        case 96: return "Lightest Black Cherry";
        case 97: return "Light Black Cherry";
        case 98: return "Black Cherry";
        case 99: return "Dark Black Cherry";
        case 100: return "Lightest Cinnamon";
        case 101: return "Light Cinnamon";
        case 102: return "Cinnamon";
        case 103: return "Dark Cinnamon";

        case 104: return "Lightest Hunter Green.";
        case 105: return "Light Hunter Green.";
        case 106: return "Hunter Green.";
        case 107: return "Dark Hunter Green.";
        case 108: return "Lightest Druid Green.";
        case 109: return "Light Druid Green.";
        case 110: return "Druid Green.";
        case 111: return "Dark Druid Green.";

        case 112: return "Lightest Graveyard Fog.";
        case 113: return "Light Graveyard Fog.";
        case 114: return "Graveyard Fog.";
        case 115: return "Dark Graveyard Fog.";
        case 116: return "Lightest Chestnut.";
        case 117: return "Light Chestnut.";
        case 118: return "Chestnut.";
        case 119: return "Dark Chestnut.";

        case 120: return "Lightest Clay.";
        case 121: return "Light Clay.";
        case 122: return "Clay.";
        case 123: return "Dark Clay.";
        case 124: return "Lightest Toasted Ash.";
        case 125: return "Light Toasted Ash.";
        case 126: return "Toasted Ash.";
        case 127: return "Dark Toasted Ash.";

        case 128: return "Lightest Snail Brown.";
        case 129: return "Light Snail Brown.";
        case 130: return "Snail Brown.";
        case 131: return "Dark Snail Brown.";
        case 132: return "Lightest Cobalt Blue.";
        case 133: return "Light Cobalt Blue.";
        case 134: return "Cobalt Blue.";
        case 135: return "Dark Cobalt Blue.";

        case 136: return "Lightest Midnight Blue.";
        case 137: return "Light Midnight Blue.";
        case 138: return "Midnight Blue.";
        case 139: return "Dark Midnight Blue.";
        case 140: return "Lightest Peacock Green.";
        case 141: return "Light Peacock Green.";
        case 142: return "Peacock Green.";
        case 143: return "Dark Peacock Green.";

        case 144: return "Lightest Royal Purple.";
        case 145: return "Light Royal Purple.";
        case 146: return "Royal Purple.";
        case 147: return "Dark Royal Purple.";
        case 148: return "Mountain Blue.";
        case 149: return "Dark Mountain Blue.";
        case 150: return "Sea Foam Green.";
        case 151: return "Dark Sea Foam Green.";

        case 152: return "Spring Green.";
        case 153: return "Dark Spring Green.";
        case 154: return "Honey Gold.";
        case 155: return "Dark Honey Gold.";
        case 156: return "Copper Coin.";
        case 157: return "Dark Copper Coin.";
        case 158: return "Berry Ice.";
        case 159: return "Dark Berry Ice.";

        case 160: return "Sugar Plum.";
        case 161: return "Dark Sugar Plum.";
        case 162: return "Light Berry Ice.";
        case 163: return "Plum.";
        case 164: return "Ice Blue.";
        case 165: return "Cadet Blue.";
        case 166: return "White Ice.";
        case 167: return "Black Onyx.";

        case 168: return "Celery Stalk.";
        case 169: return "Evergreen.";
        case 170: return "Mystic Purple.";
        case 171: return "Mystic Blue.";
        case 172: return "Golden Green.";
        case 173: return "Chocolate Raspberry.";
        case 174: return "Saddle Brown.";
        case 175: return "Mottled Gold.";
    }

    return "";
}

string MetalColor(int iColor) {
    switch (iColor) {
        case 00: return "Lightest Shiny Silver";
        case 01: return "Light Shiny Silver";
        case 02: return "Dark Shiny Obsidian";
        case 03: return "Darkest Shiny Obsidian";

        case 04: return "Lightest Dull Silver";
        case 05: return "Light Dull Silver";
        case 06: return "Dark Dull Obsidian";
        case 07: return "Darkest Dull Obsidian";

        case 08: return "Lightest Gold";
        case 09: return "Light Gold";
        case 10: return "Dark Gold";
        case 11: return "Darkest Gold";

        case 12: return "Lightest Celestial Gold";
        case 13: return "Light Celestial Gold";
        case 14: return "Dark Celestial Gold";
        case 15: return "Darkest Celestial Gold";

        case 16: return "Lightest Copper";
        case 17: return "Light Copper";
        case 18: return "Dark Copper";
        case 19: return "Darkest Copper";

        case 20: return "Lightest Brass";
        case 21: return "Light Brass";
        case 22: return "Dark Brass";
        case 23: return "Darkest Brass";

        case 24: return "Light Red";
        case 25: return "Dark Red";
        case 26: return "Light Dull Red";
        case 27: return "Dark Dull Red";

        case 28: return "Light Purple";
        case 29: return "Dark Purple";
        case 30: return "Light Dull Purple";
        case 31: return "Dark Dull Purple";

        case 32: return "Light Blue";
        case 33: return "Dark Blue";
        case 34: return "Light Dull Blue";
        case 35: return "Dark Dull Blue";

        case 36: return "Light Teal";
        case 37: return "Dark Teal";
        case 38: return "Light Dull Teal";
        case 39: return "Dark Dull Teal";

        case 40: return "Light Green";
        case 41: return "Dark Green";
        case 42: return "Light Dull Green";
        case 43: return "Dark Dull Green";

        case 44: return "Light Olive";
        case 45: return "Dark Olive";
        case 46: return "Light Dull Olive";
        case 47: return "Dark Dull Olive";

        case 48: return "Light Prismatic";
        case 49: return "Dark Prismatic";

        case 50: return "Lightest Rust";
        case 51: return "Light Rust";
        case 52: return "Dark Rust";
        case 53: return "Darkest Rust";

        case 54: return "Light Aged Metal";
        case 55: return "Dark Aged Metal";

        case 56: return "Hidden: Silver";
        case 57: return "Hidden: Obsidian";
        case 58: return "Hidden: Gold";
        case 59: return "Hidden: Copper";
        case 60: return "Hidden: Grey";
        case 61: return "Hidden: Mirror";
        case 62: return "Hidden: Pure White";
        case 63: return "Hidden: Pure Black";

        case 64: return "Smoky Pink";
        case 65: return "Smoky Taupe";
        case 66: return "Smoky Gold";
        case 67:return "Smoky Leaf Green";
        case 68: return "Smoky Green";
        case 69: return "Smoky Dark Green";
        case 70: return "Smoky Royal Purple";
        case 71: return "Smoky Dusk";

        case 72: return "Smoky Plum";
        case 73: return "Smoky Wisteria";
        case 74: return "Smoky Brown";
        case 75: return "Smoky Grey";
        case 76: return "Smoky Sea Green";
        case 77: return "Smoky Eucalyptus Leaf";
        case 78: return "Smoky Blue";
        case 79: return "Smoky Slate Blue";

        case 80: return "Smoky Hunter Green";
        case 81: return "Smoky Thyme Green";
        case 82: return "Smoky Ice Blue";
        case 83: return "Smoky Cobalt Blue";
        case 84: return "Smoky Grasshopper";
        case 85: return "Smoky Stone";
        case 86: return "Smoky Mushroom";
        case 87: return "Smoky Moss Green";

        case 88: return "Smoky Lightest Red";
        case 89: return "Smoky Light Red";
        case 90: return "Smoky Red";
        case 91: return "Smoky Dark Red";
        case 92: return "Smoky Lightest Brass";
        case 93: return "Smoky Light Brass";
        case 94: return "Smoky Brass";
        case 95: return "Smoky Dark Brass";

        case 96: return "Lightest Black Cherry";
        case 97: return "Light Black Cherry";
        case 98: return "Black Cherry";
        case 99: return "Dark Black Cherry";
        case 100: return "Lightest Cinnamon";
        case 101: return "Light Cinnamon";
        case 102: return "Cinnamon";
        case 103: return "Dark Cinnamon";

        case 104: return "Lightest Hunter Green.";
        case 105: return "Light Hunter Green.";
        case 106: return "Hunter Green.";
        case 107: return "Dark Hunter Green.";
        case 108: return "Lightest Druid Green.";
        case 109: return "Light Druid Green.";
        case 110: return "Druid Green.";
        case 111: return "Dark Druid Green.";

        case 112: return "Lightest Graveyard Fog.";
        case 113: return "Light Graveyard Fog.";
        case 114: return "Graveyard Fog.";
        case 115: return "Dark Graveyard Fog.";
        case 116: return "Lightest Chestnut.";
        case 117: return "Light Chestnut.";
        case 118: return "Chestnut.";
        case 119: return "Dark Chestnut.";

        case 120: return "Lightest Clay.";
        case 121: return "Light Clay.";
        case 122: return "Clay.";
        case 123: return "Dark Clay.";
        case 124: return "Lightest Toasted Ash.";
        case 125: return "Light Toasted Ash.";
        case 126: return "Toasted Ash.";
        case 127: return "Dark Toasted Ash.";

        case 128: return "Lightest Snail Brown.";
        case 129: return "Light Snail Brown.";
        case 130: return "Snail Brown.";
        case 131: return "Dark Snail Brown.";
        case 132: return "Lightest Cobalt Blue.";
        case 133: return "Light Cobalt Blue.";
        case 134: return "Cobalt Blue.";
        case 135: return "Dark Cobalt Blue.";

        case 136: return "Lightest Midnight Blue.";
        case 137: return "Light Midnight Blue.";
        case 138: return "Midnight Blue.";
        case 139: return "Dark Midnight Blue.";
        case 140: return "Lightest Peacock Green.";
        case 141: return "Light Peacock Green.";
        case 142: return "Peacock Green.";
        case 143: return "Dark Peacock Green.";

        case 144: return "Lightest Royal Purple.";
        case 145: return "Light Royal Purple.";
        case 146: return "Royal Purple.";
        case 147: return "Dark Royal Purple.";
        case 148: return "Mountain Blue.";
        case 149: return "Dark Mountain Blue.";
        case 150: return "Sea Foam Green.";
        case 151: return "Dark Sea Foam Green.";

        case 152: return "Spring Green.";
        case 153: return "Dark Spring Green.";
        case 154: return "Honey Gold.";
        case 155: return "Dark Honey Gold.";
        case 156: return "Copper Coin.";
        case 157: return "Dark Copper Coin.";
        case 158: return "Berry Ice.";
        case 159: return "Dark Berry Ice.";

        case 160: return "Sugar Plum.";
        case 161: return "Dark Sugar Plum.";
        case 162: return "Light Berry Ice.";
        case 163: return "Plum.";
        case 164: return "Ice Blue.";
        case 165: return "Cadet Blue.";
        case 166: return "White Ice.";
        case 167: return "Black Onyx.";

        case 168: return "Celery Stalk.";
        case 169: return "Evergreen.";
        case 170: return "Mystic Purple.";
        case 171: return "Mystic Blue.";
        case 172: return "Golden Green.";
        case 173: return "Chocolate Raspberry.";
        case 174: return "Saddle Brown.";
        case 175: return "Mottled Gold.";
    }

    return "";
}
