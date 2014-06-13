aa_camp = {
	private ["_pos", "_dir", "_camps", "_camp", "_created"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	_camps = [aa_camp1, aa_camp2];
	_camp = _camps call BIS_fnc_selectRandom;
	_created = [_pos, _dir] call _camp;
	_created;
};

aa_camp1 = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_housepos"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	
	_flatPos = _pos isFlatEmpty [15, 0, 0.2, 10, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
	
	_campgroup = createGroup east;
	_campgroup call CampCleanup;
	_campgroup setFormDir _dir;
	
	_housepos = [_pos, 7, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_Cargo_House_V3_F" createVehicle _housepos;
	_prop call CampCleanup;
	_prop setDir _dir - 90;
	
	_newpos = [_pos, 6, _dir + 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 3, _dir] call BIS_fnc_relPos;
	_prop = "Land_HBarrier_5_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 90;
	
	_newpos = [_pos, 6, _dir + 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 3, _dir + 180] call BIS_fnc_relPos;
	_prop = "Land_HBarrier_5_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 90;
	
	_newpos = [_housepos, 5, _dir] call BIS_fnc_relPos;
	_prop = "Land_FieldToilet_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_barrels = ["Land_BarrelWater_grey_F", "Land_BarrelEmpty_grey_F", "Land_GarbageBarrel_01_F", "Land_BarrelTrash_grey_F"];
	_newpos = [_housepos, 4, _dir + 200] call BIS_fnc_relPos;
	_prop = (_barrels call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	if (random 1 < 0.7) then {
		_prop = (_barrels call BIS_fnc_selectRandom) createVehicle _newpos;
		_prop call CampCleanup;
		_prop setDir _dir;
	};
	
	if (random 1 < 0.7) then {
		_newpos = [_pos, 6, _dir + 170] call BIS_fnc_relPos;
		_prop = (["Land_Pallet_MilBoxes_F", "Land_PaperBox_closed_F", "Land_PaperBox_open_empty_F", "Land_PaperBox_open_full_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
		_prop call CampCleanup;
		_prop setDir _dir;
	};
	
	_prop = (["Box_East_Ammo_F", "Box_East_AmmoOrd_F", "Box_East_Grenades_F", "Box_East_Ammo_F"] call BIS_fnc_selectRandom) createVehicle _housepos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	sleep 1;
	
	if (random 1 < 0.5) then {
		_campgun1group = createGroup east;
		_campgun1group call CampCleanup;
		_campgun1group setFormDir _dir;
		
		_gun1 = "O_static_AA_F" createVehicle _pos;
		waitUntil {alive _gun1};
		_gun1 call CampCleanup;
		_gun1 setDir _dir;
		_gunner1 = _campgun1group createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
		waitUntil {alive _gunner1};
		_gunner1 assignAsGunner _gun1;
		_gunner1 moveInGunner _gun1;
	};
	
	_soldier = _campgroup createUnit ["O_Soldier_TL_F", _housepos, [], 0, "NONE"];
	doStop _soldier;
	for "_c" from 1 to (1 + round (random 1)) do { 
		_newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AA_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
		_newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AAA_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
	};
	true;
};

aa_camp2 = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_ammo"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	
	_flatPos = _pos isFlatEmpty [15, 0, 0.2, 12, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
	
	_campgroup = createGroup east;
	_campgroup call CampCleanup;
	_campgroup setFormDir _dir;
	
	_ammo = "Box_East_WpsLaunch_F" createVehicle _pos;
	_ammo call CampCleanup;
	_ammo setDir _dir;
	
	_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
	_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 90;
	
	_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
	_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 90;
	
	_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
	_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir - 90;
	
	_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
	_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir - 90;
	
	_newpos = [_ammo, 10, _dir] call BIS_fnc_relPos;
	_tower = "Land_HBarrierTower_F" createVehicle _newpos;
	_tower call CampCleanup;
	_tower setDir _dir + 180;
	
	if (random 1 < 0.75) then {
		_campgun1group = createGroup east;
		_campgun1group call CampCleanup;
		_campgun1group setFormDir _dir + 180;
		
		_newpos = [_ammo, 5, _dir + 180] call BIS_fnc_relPos;
		_gun1 = "O_static_AA_F" createVehicle _newpos;
		waitUntil {alive _gun1};
		_gun1 call CampCleanup;
		_gun1 setDir _dir + 180;
		_newpos = [_newpos, 1, _dir] call BIS_fnc_relPos;
		_gunner1 = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
		waitUntil {alive _gunner1};
		_gunner1 assignAsGunner _gun1;
		_gunner1 moveInGunner _gun1;
	};
	
	_newpos = [_ammo, 11, _dir + 180] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 30;
	
	_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir + 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir - 30;
	
	sleep 0.5;
	_soldier = _campgroup createUnit ["O_Soldier_TL_F", getPos _tower, [], 0, "NONE"];
	doStop _soldier;
	for "_c" from 1 to (1 + round (random 1)) do
	{ 
		_newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AA_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
		
		_newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AAA_F", _newpos, [], 0, "NONE"];
		doStop _soldier;
	};
	true;
};