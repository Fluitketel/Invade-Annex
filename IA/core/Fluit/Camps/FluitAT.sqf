at_camp = {
	private ["_pos", "_dir", "_newpos", "_newdir", "_campgroup", "_prop", "_soldier", "_numberofbarriers"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	
	_flatPos = _pos isFlatEmpty [12, 0, 0.2, 10, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
	
	_campgroup = createGroup east;
	_campgroup call CampCleanup;
	_campgroup setFormDir _dir;
	
	_prop = "CamoNet_OPFOR_open_F" createVehicle _pos;
	_prop setDir (_dir + 180);
	_prop call CampCleanup;
	
	if (random 1 < 0.5) then {
		_campgun1group = createGroup east;
		_campgun1group call CampCleanup;
		_campgun1group setFormDir _dir;
		_gun1 = objNull;
		if (random 1 < 0.3) then {
			_gun1 = "O_GMG_01_high_F" createVehicle _pos;
		} else {
			_gun1 = "O_HMG_01_high_F" createVehicle _pos;
		};
		waitUntil {alive _gun1};
		_gun1 call CampCleanup;
		_gun1 setDir _dir;
		_newpos = [_pos, 1, (_dir + 180)] call BIS_fnc_relPos;
		_gunner1 = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
		waitUntil {alive _gunner1};
		_gunner1 assignAsGunner _gun1;
		_gunner1 moveInGunner _gun1;
		_gunner1 setDir _dir;
	};
	
	_numberofbarriers = 12;
	_newdir = 0;
	for "_c" from 1 to _numberofbarriers do
	{
		_newpos = [_pos, 9, _newdir] call BIS_fnc_relPos;
		_prop = "Land_CncBarrier_F" createVehicle _newpos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _newdir;
		_newdir = _newdir + (360 / _numberofbarriers);
	};
	
	_prop = (["Box_East_Ammo_F", "Box_East_AmmoOrd_F", "Box_East_Grenades_F", "Box_East_Ammo_F"] call BIS_fnc_selectRandom) createVehicle _pos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_props = ["Land_ChairPlastic_F","Land_Sacks_heap_F","Land_Sack_F","Land_Tyres_F","Land_GarbageBags_F","Land_CinderBlocks_F","Land_Bricks_V2_F","Land_BarrelTrash_F","Land_BarrelEmpty_F","Land_MetalBarrel_F","Land_Pallets_stack_F","Land_BarrelEmpty_grey_F","Land_GarbageBarrel_01_F"];
	for "_c" from 1 to (1 + floor(random 6)) do {
		_newpos = [_pos, (4 + round(random 12)), random 360] call BIS_fnc_relPos;
		_prop = (_props call BIS_fnc_selectRandom) createVehicle _newpos;
		_prop call CampCleanup;
		_prop setDir random 360;
	};
	
	sleep 1;
	_soldier = _campgroup createUnit ["O_Soldier_TL_F", _pos, [], 0, "NONE"];
	doStop _soldier;
	for "_c" from 1 to (1 + round (random 1)) do { 
		_newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AT_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
		_newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AAT_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
	};
	true;
};