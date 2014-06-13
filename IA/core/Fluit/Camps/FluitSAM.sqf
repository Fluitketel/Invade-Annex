create_sam_site = {
	private ["_position", "_pos", "_dir", "_distance", "_barrier"];
	_position = _this select 0;

	systemChat format ["Creating SAM site at %1 ...", _position];
	_flatPosAlt = [(_position select 0) - 5, (_position select 1) - 5, (_position select 2)];
	_flatPosClose = [(_position select 0) + 5, (_position select 1) + 5, (_position select 2)];
	_priorityGroup = createGroup resistance;
	SamVeh1 = "O_APC_Tracked_02_AA_F" createVehicle _flatPosAlt;
	waitUntil {!isNull SamVeh1};
	SamVeh2 = "O_APC_Tracked_02_AA_F" createVehicle _flatPosClose;
	waitUntil {!isNull SamVeh2};
	SamVeh1 lock 3;
	SamVeh2 lock 3;
	
	SamVeh1 setDir (direction SamVeh1) + random 360;
	SamVeh2 setDir (direction SamVeh2) + random 360;

	SamVeh1 addEventHandler["Fired",{if (!isPlayer (gunner SamVeh1)) then { SamVeh1 setVehicleAmmo 1; };}];
	SamVeh2 addEventHandler["Fired",{if (!isPlayer (gunner SamVeh2)) then { SamVeh2 setVehicleAmmo 1; };}];
	SamVeh1 addEventHandler["GetIn",{if (isPlayer (gunner SamVeh1)) then { SamVeh1 setVehicleAmmo 0; };}];
	SamVeh2 addEventHandler["GetIn",{if (isPlayer (gunner SamVeh2)) then { SamVeh2 setVehicleAmmo 0; };}];
	"I_crew_F" createUnit [_flatPosAlt, _priorityGroup, "priorityTarget1 = this; this moveInGunner SamVeh1;"];
	"I_crew_F" createUnit [_flatPosClose, _priorityGroup, "priorityTarget2 = this; this moveInGunner SamVeh2;"];

	_priorityGroup setBehaviour "COMBAT";

	//Small sleep to let units settle in
	sleep 10;

	//Spawn H-Barrier cover "Land_HBarrierBig_F"
	_distance = 15;
	_dir = 0;
	for "_c" from 0 to 15 do
	{
		_pos = [_position, _distance, _dir] call BIS_fnc_relPos;
		_barrier = "Land_HBarrier_3_F" createVehicle _pos;
		waitUntil {alive _barrier};
		_barrier setDir _dir;
		_dir = _dir + 22.5;
	};
};

random_sam_sites = {
	private ["_samcount", "_sampos", "_valid", "_locations", "_spawned", "_spread"];
	_locations	= _this select 0;
	_samcount	= _this select 1;
	_spread 	= _this select 2;
	
	// If no valid locations found, end function here
	if (count _locations == 0) exitWith { systemChat "No valid locations found"; };
	
	systemChat format ["%1 valid locations found", count _locations];

	// Spawn SAM sites at random locations
	_numberofsams = 0;
	_numberoftries = 100;
	_finished = false;
	_spawned = [];
	while {!_finished} do {
		_sampos = _locations call BIS_fnc_selectRandom;
		_valid = true;
		{
			if ((_sampos distance _x) < _spread) then { _valid = false; };
		} forEach _spawned;
		
		if (_valid) then {
			_spawned set [count _spawned, _sampos];
			_numberofsams = _numberofsams + 1;		
			[_sampos] spawn create_sam_site;
			sleep 10;
		};
		
		_numberoftries = _numberoftries - 1;
		if (_numberofsams >= _samcount) then {
			_finished = true;
			systemChat format ["Done creating %1 SAM sites", _numberofsams];
		} else {
			if (_numberoftries <= 0) then {
				systemChat format ["Failed creating all SAM sites. Created only %1", _numberofsams];
				_finished = true;
			};
		};
	};
	if (DEBUG) then
	{
		{
			_m = createMarker [format ["sammrk%1",random 100000], _x];
			_m setMarkerShape "ELLIPSE";
			_m setMarkerSize [_spread / 2, _spread / 2];
			_m setMarkerBrush "Solid";
			_m setMarkerAlpha 0.5;
			_m setMarkerColor "ColorRed";
		} forEach _spawned;
	};
};