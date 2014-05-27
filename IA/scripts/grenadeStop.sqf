/*
	GrenadeStop v0.8 for ArmA 3 Alpha by Bake (tweaked slightly by Rarek)
	
	DESCRIPTION:
	Stops players from throwing grenades in safety zones.
	
	INSTALLATION:
	Move grenadeStop.sqf to your mission's folder. Then add the
	following line to your init.sqf file (create one if necessary):
	execVM "grenadeStop.sqf";
	
	CONFIGURATION:
	Edit the #defines below.
*/

#define SAFETY_ZONES	[["respawn_west", 85]] // Syntax: [["marker1", radius1], ["marker2", radius2], ...]
#define MESSAGE "Placing / throwing items and firing at base is STRICTLY PROHIBITED!"
#define MORTAR_MESSAGE	"No point you putting that up, soldier; we're fresh out of ammo for those things."
#define AA_MESSAGE	"Sorry, solider! All AA missiles are disabled!"

if (isDedicated) exitWith {};
waitUntil {!isNull player};


player addEventHandler ["Fired", {
	if ({(_this select 0) distance getMarkerPos (_x select 0) < _x select 1} count SAFETY_ZONES > 0) then
	{
		deleteVehicle (_this select 6);
		titleText [MESSAGE, "PLAIN", 3];
	};
}];


player addEventHandler ["WeaponAssembled", {
	deleteVehicle _this select 1;
	titleText [MORTAR_MESSAGE, "PLAIN", 3];
}];