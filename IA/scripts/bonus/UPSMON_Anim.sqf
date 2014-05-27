/*
Stances
[
	"STAND",
	"STAND_IA",
	"GUARD",
	"SIT_LOW",
	"KNEEL",
	"LEAN",
	"WATCH",
	"WATCH1",
	"WATCH2"
];
gear
[
	"NONE",
	"LIGHT",
	"MEDIUM",
	"FULL",
	"ASIS",
	"RANDOM"
];
*/


_unit = _this select 0;
_anim = _this select 1;
_clothes = _this select 2;

_groupleader = leader (group _unit);

if (isNil("UPSMON_INIT")) then {
	UPSMON_INIT=0;
};

waitUntil {UPSMON_INIT==1};

waituntil {!Alive _unit || !canmove _unit || _groupleader in UPSMON_NPCs};

If (Alive _unit && canmove _unit) then
{
	[_unit,_anim,_clothes,{(_unit getvariable "UPSMON_Grpstatus") select 1 != "GREEN" || lifestate _unit == "INJURED"}] call BIS_fnc_ambientAnimCombat;
};