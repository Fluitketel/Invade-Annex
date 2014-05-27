/*  =====================================================================================================
	MON_spawn.sqf
	Author: Monsada (chs.monsada@gmail.com) 
		Comunidad Hispana de Simulación: 
		http://www.simulacion-esp.com
 =====================================================================================================		
	Parámeters: [_artillery,(_rounds,_area,_cadence,_mincadence)] execvm "scripts\UPSMON\MON_artillery_add.sqf";	
		<- _artillery 		object to attach artillery script, must be an object with gunner.
		<- ( _rounds ) 		number of rounds for the artillery [FLARE,SMOKE,HE]
		<- ( _area ) 		Dispersion area, 150m by default
		<- ( _maxcadence ) 	Cadence of fire, is random between min, default 10s
		<- ( _mincadence )	Minimum cadence, default 5s
 =====================================================================================================
	1.  Place a static weapon on map.
	2. Exec module in int of static weapon

		nul=[this] execVM "scripts\UPSMON\MON_artillery_add.sqf";

	1. Be sure static weapon has a gunner or place a "fortify" squad near, this will make squad to take static weapon.
	2. Create a trigger in your mission for setting when to fire. Set side artillery variable to true:

		UPSMON_ARTILLERY_EAST_FIRE = true;

	This sample will do east artilleries to fire on known enemies position, when you want to stop fire set to false.

	For more info:
	http://dev-heaven.net/projects/upsmon/wiki/Artillery_module
 =====================================================================================================*/
//if (!isserver) exitWith {}; 
if (!isServer) exitWith {};

//Waits until UPSMON is init
waitUntil {!isNil("UPSMON_INIT")};
waitUntil {UPSMON_INIT==1};
	
private ["_artillery","_smoke1","_i","_area","_position","_maxcadence","_mincadence","_rounds","_dummypos","_salvobreak","_sidearty","_artillerysupport","_cfgArtillery","_grpunits","_batteryunits"];

_area = 50;
_maxcadence = 6;
_mincadence = 3;
_rounds = [10,20,35];	
_vector =[];

_artillery  = _this select 0;
_cfgArtillery =0;
//_cfgArtillery = getArray (configFile >> "cfgVehicles" >> (typeOf (vehicle _artillery)) >> "availableForSupportTypes"); // only for Blufor ?
_cfgArtillery = getnumber (configFile >> "cfgVehicles" >> (typeOf (vehicle _artillery)) >> "artilleryScanner");
if (_cfgArtillery != 1) exitwith {if (UPSMON_Debug>0) then {player sidechat "This kind of static is not supported"};};
_grpunits = (units (group _artillery));
_grpunits = _grpunits - [_artillery];
_batteryunits = [];

If (count _grpunits > 0) then
{
	{
		_unit = _x;
		_cfgArtillery = getnumber (configFile >> "cfgVehicles" >> (typeOf (vehicle _artillery)) >> "artilleryScanner");
		if (_cfgArtillery == 1) then {_batteryunits = _batteryunits + [_unit]};
	} foreach _grpunits;
};

if (UPSMON_Debug>0) then {diag_log format["MON_artillery_add before %1 %2 %3",isnull _artillery,alive _artillery]};		

if (isnull _artillery || !alive _artillery) exitwith{};
if ((count _this) > 1) then {_rounds = _this select 1;};	
if ((count _this) > 2) then {_area = _this select 2;};	
if ((count _this) > 3) then {_maxcadence = _this select 3;};	
if ((count _this) > 4) then {_mincadence = _this select 4;};	

_cfgArtillerymag = getArray (configFile >> "cfgVehicles" >> (typeOf _artillery) >> "Turrets" >> "MainTurret" >> "magazines");
_artimuntype = [0,0,0];
_id = -1; 
{
	_foundshell=[_x,"shells"] call UPSMON_StrInStr;
	_foundshell=[_x,"HE"] call UPSMON_StrInStr;
	_foundrocket=[_x,"rockets"] call UPSMON_StrInStr;
	_foundsmoke=[_x,"smoke"] call UPSMON_StrInStr;
	_foundsmoke=[_x,"WP"] call UPSMON_StrInStr;
	_foundillum=[_x,"Flare"] call UPSMON_StrInStr;
	_foundillum=[_x,"ILLUM"] call UPSMON_StrInStr;
	If (_foundshell || _foundrocket) then {_artimuntype set [2,1]};
	If (_foundsmoke) then {_artimuntype set [1,1]};
	If (_foundillum) then {_artimuntype set [0,1]};
} foreach _cfgArtillerymag;

{
	_id = _id + 1;
	if (_x != 0 && (_artimuntype select _id) != 1) then {_rounds set [_id,0];};
} foreach _rounds;

//Add artillery to array of artilleries
_vector = [false,_rounds,_area,_maxcadence,_mincadence,_batteryunits];

_sidearty = side (gunner _artillery);


	switch (_sidearty) do {
		case West: {
		if (isnil "UPSMON_ARTILLERY_WEST_UNITS") then  {UPSMON_ARTILLERY_WEST_UNITS = []};
		UPSMON_ARTILLERY_WEST_UNITS = UPSMON_ARTILLERY_WEST_UNITS + [_artillery];
		PublicVariable "UPSMON_ARTILLERY_WEST_UNITS";		
		};
		case EAST: {
		if (isnil "UPSMON_ARTILLERY_EAST_UNITS") then  {UPSMON_ARTILLERY_EAST_UNITS = []};
		UPSMON_ARTILLERY_EAST_UNITS = UPSMON_ARTILLERY_EAST_UNITS + [_artillery];
		PublicVariable "UPSMON_ARTILLERY_EAST_UNITS";	
		};
		case resistance: {
		if (isnil "UPSMON_ARTILLERY_GUER_UNITS") then  {UPSMON_ARTILLERY_GUER_UNITS = []};
		UPSMON_ARTILLERY_GUER_UNITS = UPSMON_ARTILLERY_GUER_UNITS + [_artillery];
		PublicVariable "UPSMON_ARTILLERY_GUER_UNITS";			
		};
	
	};
	
(vehicle _artillery) setVariable ["UPSMON_ArtiOptions",_vector];

_dummypos = [getpos _artillery, 50, getdir _artillery] call UPSMON_relPos3D;
(gunner _artillery) lookAt [_dummypos select 0, _dummypos select 1,(_dummypos select 2)+100];
