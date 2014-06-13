mortar_camp_big = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_center", "_amountofmortars", "_spawnstatic", "_spawnunits"];
	_pos 				= _this select 0; // Camp position
	_dir 				= _this select 1; // Camp direction
	_amountofmortars 	= if (count _this > 2) then {_this select 2} else { 2 };
	_spawnstatic 		= if (count _this > 3) then {_this select 3} else { true };
	_spawnunits 		= if (count _this > 4) then {_this select 4} else { true };
	
	if (_amountofmortars < 1) then { _amountofmortars = 1; };
	if (_amountofmortars > 6) then { _amountofmortars = 6; };
	
	_flatPos = _pos isFlatEmpty [10, 0, 0.2, 10, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
	
	_mortargroup = createGroup east;
	_mortargroup call CampCleanup;
	_mortargroup setFormDir _dir;
	
	_center = "Box_East_AmmoVeh_F" createVehicle _pos;
	_center call CampCleanup;
	_center setDir _dir;
	
	_newpos = [_center, 8, _dir] call BIS_fnc_relPos;
	_prop = (["Land_i_Stone_Shed_V1_F", "Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_prop, 3, (_dir + 270)] call BIS_fnc_relPos;
	_prop = (["Land_FieldToilet_F", "Land_LampShabby_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_center, 7, (_dir + 45)] call BIS_fnc_relPos;
	_prop = "Land_PowerGenerator_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 110);
	
	_prop = "Land_CanisterFuel_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_wall = ["Land_Mound01_8m_F", "Land_HBarrier_5_F"] call BIS_fnc_selectRandom;
	_newpos = [_center, 10, (_dir + 270)] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
	_prop = _wall createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 270);
	
	_newpos = [_center, 10, (_dir + 270)] call BIS_fnc_relPos;
	_newpos = [_newpos, 2, (_dir + 180)] call BIS_fnc_relPos;
	_prop = _wall createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 270);
	
	_pallets = ["Land_Pallet_MilBoxes_F", "Land_PaperBox_open_full_F", "Land_Pallets_stack_F"];
	_newpos = [_center, 7, (_dir + 180)] call BIS_fnc_relPos;
	_prop = (_pallets call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	_newpos = [_center, 7, (_dir + 150)] call BIS_fnc_relPos;
	_prop = (_pallets call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 30);
	
	
	_newpos = [_center, 10, (_dir + 200)] call BIS_fnc_relPos;
	_prop = (["Land_Cargo20_military_green_F", "Land_Cargo20_grey_F", "Land_Cargo20_sand_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 15);
	
	if (random 1 < 0.5) then {
		_newpos = [_center, 10, (_dir + 100)] call BIS_fnc_relPos;
		_prop = "Land_Wreck_T72_hull_F" createVehicle _newpos;
		_prop call CampCleanup;
		_prop setDir (_dir + 200);
	} else {
		if (_spawnstatic) then {
			_mortargungroup = createGroup east;
			_mortargungroup call CampCleanup;
			_mortargungroup setFormDir _dir + 90;
			_newpos = [_center, 10, (_dir + 100)] call BIS_fnc_relPos;
			_gun1 = objNull;
			if (random 1 < 0.3) then {
				_gun1 = "O_GMG_01_high_F" createVehicle _newpos;
			} else {
				_gun1 = "O_HMG_01_high_F" createVehicle _newpos;
			};
			waitUntil {alive _gun1};
			_gun1 call CampCleanup;
			_gun1 setDir _dir;
			_gunner1 = _mortargungroup createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
			waitUntil {alive _gunner1};
			_gunner1 assignAsGunner _gun1;
			_gunner1 moveInGunner _gun1;
			_gunner1 setDir (_dir + 90);
		};
	};
	
	if (_spawnunits) then {
		_mortardefgroup = createGroup east;
		_mortardefgroup call CampCleanup;
		_mortardefgroup setFormDir _dir;
		_newpos = [_center, 10, (_dir + 45)] call BIS_fnc_relPos;
		"O_SoldierU_SL_F" createUnit [_newpos, _mortardefgroup];
		"O_soldierU_AA_F" createUnit [_newpos, _mortardefgroup];
		"O_soldierU_AR_F" createUnit [_newpos, _mortardefgroup];
		"O_soldierU_AR_F" createUnit [_newpos, _mortardefgroup];
		"O_SoldierU_GL_F" createUnit [_newpos, _mortardefgroup];
		if !(isNil "aw_fnc_spawn2_perimeterPatrol") then {
			[_mortardefgroup, _pos, 50] call aw_fnc_spawn2_perimeterPatrol;
		};
	};
	
	_newdir = _dir;
	for "_c" from 1 to _amountofmortars do {
		_newdir = _newdir + (360 / _amountofmortars);
		_newpos = [_center, 1, _newdir] call BIS_fnc_relPos;
		_mortar = "O_Mortar_01_F" createVehicle _newpos;
		_mortar call AddMortars;
		_mortar call CampCleanup;
		_mortar setDir _newdir;
		_mortar addEventHandler["Fired",{if (!isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 1; };}];
		_mortar addEventHandler["GetIn",{if (isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 0; };}];
		_soldier = _mortargroup createUnit ["O_support_Mort_F", _pos, [], 0, "NONE"];
		_soldier assignAsGunner _mortar;
		_soldier moveInGunner _mortar;
	};
	true;
};

mortar_camp_small = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_amountofmortars"];
	_pos 				= _this select 0; // Camp position
	_dir 				= _this select 1; // Camp direction
	_amountofmortars 	= if (count _this > 2) then {_this select 2} else { 2 };
	
	if (_amountofmortars < 1) then { _amountofmortars = 1; };
	if (_amountofmortars > 4) then { _amountofmortars = 4; };
	
	_flatPos = _pos isFlatEmpty [4, 0, 0.2, 4, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
	
	_numberofbarriers = 4;
	_newdir = 0;
	for "_c" from 1 to _numberofbarriers do
	{
		_newpos = [_pos, 4, _newdir] call BIS_fnc_relPos;
		_prop = "Land_BagFence_Round_F" createVehicle _newpos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _newdir + 180;
		_newdir = _newdir + (360 / _numberofbarriers);
	};
	
	_mortargroup = createGroup east;
	_mortargroup call CampCleanup;
	_mortargroup setFormDir _dir;
	_newdir = 0;
	for "_c" from 1 to _amountofmortars do {
		_newdir = _newdir + (360 / _amountofmortars);
		_newpos = [_pos, 1, _newdir] call BIS_fnc_relPos;
		_mortar = "O_Mortar_01_F" createVehicle _newpos;
		_mortar call AddMortars;
		_mortar call CampCleanup;
		_mortar setDir _newdir;
		_mortar addEventHandler["Fired",{if (!isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 1; };}];
		_mortar addEventHandler["GetIn",{if (isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 0; };}];
		_soldier = _mortargroup createUnit ["O_support_Mort_F", _pos, [], 0, "NONE"];
		_soldier assignAsGunner _mortar;
		_soldier moveInGunner _mortar;
	};
	true;
};

random_mortar_camps = {
	private ["_amount", "_created", "_camplocations", "_triescamp", "_position", "_spacing", "_location", "_radius", "_allowed", "_amountofmortars"];
	_amount 			= if (count _this > 0) then {_this select 0} else { 2 }; 	// Amount of camps to create
	_location			= if (count _this > 1) then {_this select 1} else { [] }; 	// Location where to create the camps - if not set use random all over the map
	_radius				= if (count _this > 2) then {_this select 2} else { 1500 }; // Radius of user defined location
	_amountofmortars	= if (count _this > 3) then {_this select 3} else { 2 }; // Amount of mortars in each camp
	_spacing 			= if (count _this > 4) then {_this select 4} else { _radius / 10 };	// Distance between camps in meters
	
	diag_log format ["random_mortar_camps amount %1, location %2, radius %3, amountofmortars %4, spacing %5", _amount, _location,_radius, _amountofmortars, _spacing];
	
	if (count _location != 3) exitWith {false;};
	
	_camplocations = [];
	_debug = DEBUG;
	if (_amount < 1) then { _amount = 1; };
	for "_y" from 1 to _amount do {
		_created = false;
		_triescamp = 100; // Number of tries to create each camp
		while {!_created} do {
			_triescamp = _triescamp - 1;
			_variableradius = 100 + (_radius / 10);
			_position = [_location, (_radius + round (random _variableradius)), random 360] call BIS_fnc_relPos;
			_allowed = true;
			{
				if ((_position distance _x) < _spacing) exitWith {
					_allowed = false;
				};
			} foreach _camplocations;
			
			if (_allowed) then {
				_dir = [_location, _position] call BIS_fnc_DirTo;
				if (_radius > 500) then {
					_created = [_position, _dir, _amountofmortars] call mortar_camp_big;
				} else {
					_created = [_position, _dir, _amountofmortars] call mortar_camp_small;
				};
			};
			
			if (_created) exitWith {
				_camplocations set [count _camplocations, _position];
				diag_log format ["Mortar camp #%2 created with %1 tries left.", _triescamp, _y];
				if (_debug) then {
					_m = createMarker [format ["mortar %1 %2",_y, random 99999], _position];				
					_m setMarkerType "o_mortar";
					_m setMarkerText format ["%1", format ["mortar %1",_y]];
					_m setMarkerColor "ColorRed";
				};
			};
			if (_triescamp < 1 && !_created) exitWith {
				diag_log format ["Mortar camp creation failed. Skipping camp #%1.", _y];
				_created = true;
			};
			sleep 0.05;
		};
	};
	diag_log format ["Created %1 of %2 mortar camps.", count _camplocations, _amount];
	
	_camplocations;
};