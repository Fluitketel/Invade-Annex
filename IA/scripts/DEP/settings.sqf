// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This is the settings file for DEP. Edit to your own liking.

dep_side        = independent;          // Enemy side (east, west, independent)
dep_despawn     = PARAMS_DEP_DESPAWN;   // Despawn location after x minutes inactivity
dep_debug       = DEBUG;                // Enable debug
dep_max_ai_loc  = PARAMS_DEP_AI_LOC;    // Maximum AI per location
dep_max_ai_tot  = PARAMS_DEP_AI_TOT;    // Maximum AI in total
dep_act_dist    = PARAMS_DEP_ACTDIST;   // Location activation distance
dep_act_height  = 80;                   // Player must be below this height to activate location
dep_act_speed   = 160;                  // Player must be below this speed to activate location
dep_roadblocks  = PARAMS_DEP_ROADBLK;   // Number of roadblocks
dep_aa_camps    = PARAMS_DEP_AA;        // Number of AA camps
dep_roadpop     = PARAMS_DEP_ROADPOP;   // Number of road population
dep_safezone    = 1000;                 // Respawn safe zone radius
dep_max_veh     = PARAMS_DEP_MAX_VEH;   // Max number of vehicles
dep_ied_chance  = 0.7;                  // Chance of IEDs
dep_veh_chance  = 0.4;                  // Chance of vehicles

// Military forces
// dep_u_soldier       = "I_soldier_F";        // Soldier
// dep_u_gl            = "I_Soldier_GL_F";     // Grenade launcher
// dep_u_ar            = "I_Soldier_AR_F";     // Assault rifle
// dep_u_at            = "I_Soldier_LAT_F";    // Anti tank
// dep_u_medic         = "I_medic_F";          // Medic
// dep_u_aa            = "I_Soldier_AA_F";     // Anti air
// dep_u_aaa           = "I_Soldier_AAA_F";    // Assistant anti air
// dep_u_sl            = "I_Soldier_SL_F";     // Squad leader
// dep_u_marksman      = "I_soldier_M_F";      // Marksman
// dep_u_sniper        = "I_Sniper_F";         // Sniper

// Guerilla forces
// dep_u_g_soldier     = "I_G_Soldier_F";      // Soldier
// dep_u_g_gl          = "I_G_Soldier_GL_F";   // Grenade launcher
// dep_u_g_ar          = "I_G_Soldier_AR_F";   // Assault rifle
// dep_u_g_at          = "I_G_Soldier_LAT_F";  // Anti tank
// dep_u_g_medic       = "I_G_medic_F";        // Medic
// dep_u_g_sl          = "I_G_Soldier_SL_F";   // Squad leader
// dep_u_g_marksman    = "I_G_Soldier_M_F";    // Marksman