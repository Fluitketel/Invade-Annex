// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file contains the settings used in DEP.

dep_size            = 300; // location size
dep_spacing         = 300; // distance between locations
dep_debug           = DEBUG; // enable debug
dep_avoid           = [getMarkerPos "respawn_west"]; // empty array for none
dep_max_ai_loc      = 30; // maximum enemies per location
dep_max_loc         = 8; // maximum location active
dep_side            = resistance; // Enemies will join this side