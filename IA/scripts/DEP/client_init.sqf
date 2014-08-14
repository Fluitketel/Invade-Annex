// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This is the init file that should run on every client.
dep_directory               = "scripts\DEP\";   // Script location
dep_fnc_disable_ied         = compile preprocessFileLineNumbers format ["%1disable_ied.sqf",        dep_directory];
dep_fnc_disable_ied_action  = compile preprocessFileLineNumbers format ["%1disable_ied_action.sqf", dep_directory];