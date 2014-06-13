roadblock = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_gate"];
	_pos = _this select 0; // roadblock position
	_dir = _this select 1; // roadblock direction
	
	_flatPos = _pos isFlatEmpty [12, 0, 0.3, 12, 0, false];
	if (count _flatPos == 0) exitWith {false;}; // Return false if the roadblock fails to create
	
	_campgroup = createGroup east;
	_campgroup call CampCleanup;
	_campgroup setFormDir _dir;
	
	_gate = "Land_BarGate_F" createVehicle _pos;
	waitUntil {alive _gate};
	_gate call CampCleanup;
	_gate setDir _dir;
	
	_newpos = [_gate, 6, _dir] call BIS_fnc_relPos;
	_newpos = [_newpos, 11, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_Sign_WarningMilitaryArea_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir + 180;
	
	_newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
	_newpos = [_newpos, 11, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	_newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
	_newpos = [_newpos, 16, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	_newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
	_newpos = [_newpos, 3, _dir + 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	_newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
	_newpos = [_newpos, 7, _dir + 90] call BIS_fnc_relPos;
	_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_gate, 9, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir + 90] call BIS_fnc_relPos;
	_prop = "Land_Razorwire_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	_newpos = [_gate, 9, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 13, _dir - 90] call BIS_fnc_relPos;
	_prop = "Land_Razorwire_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_gate, 4, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 5, _dir + 90] call BIS_fnc_relPos;
	_prop = (["Flag_CSAT_F","Land_TTowerSmall_1_F","Land_FieldToilet_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_gate, 14, _dir - 90] call BIS_fnc_relPos;
	if (random 1 > 0.5) then {
		_prop = "Land_BagBunker_Small_F" createVehicle _newpos;
		_prop setDir (_dir + 180);
	} else {
		_prop = "Land_Cargo_House_V3_F" createVehicle _newpos;
		_prop setDir (_dir - 90);
	};
	_prop call CampCleanup;
	
	_prop = (["Box_East_Ammo_F", "Box_East_AmmoOrd_F", "Box_East_Grenades_F", "Box_East_Ammo_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	sleep 0.5;
	
	_campgun1group = createGroup east;
	_campgun1group call CampCleanup;
	_campgun1group setFormDir _dir;
	_newpos = [_gate, 6, _dir + 90] call BIS_fnc_relPos;
	_gun1 = objNull;
	if (random 1 < 0.3) then {
		_gun1 = "O_GMG_01_high_F" createVehicle _newpos;
	} else {
		_gun1 = "O_HMG_01_high_F" createVehicle _newpos;
	};
	waitUntil {alive _gun1};
	_gun1 call CampCleanup;
	_gun1 setDir _dir;
	_newpos = [_newpos, 1, (_dir + 180)] call BIS_fnc_relPos;
	_gunner1 = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	waitUntil {alive _gunner1};
	_gunner1 assignAsGunner _gun1;
	_gunner1 moveInGunner _gun1;
	_gunner1 setDir _dir;
	
	sleep 1;
	_newpos = [_gate, 4, _dir + 180] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir  - 90] call BIS_fnc_relPos;
	_soldier = _campgroup createUnit ["O_Soldier_TL_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	for "_c" from 1 to (1 + round (random 1)) do
	{
		_newpos = [_newpos, round (random 6), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AT_F", _newpos, [], 0, "NONE"];
		waitUntil {alive _soldier};
		doStop _soldier;
		
		_newpos = [_newpos, round (random 6), random 360] call BIS_fnc_relPos;
		_soldier = _campgroup createUnit ["O_Soldier_AA_F", _newpos, [], 0, "NONE"];
		waitUntil {alive _soldier};
		doStop _soldier;
	};
	true;
};

defensive_roadblocks = {
	// Example: [2, 600, getMarkerPos "AO_marker", 1000] spawn defensive_roadblocks;
	private ["_amount", "_camplocations", "_triesroad", "_triescamp", "_position", "_spacing", "_location", "_radius", "_giveup"];
	_amount 	= if (count _this > 0) then {_this select 0} else { 3 }; 	// Amount of camps to create
	_spacing 	= if (count _this > 1) then {_this select 1} else { 400 };	// Distance between camps in meters
	_location	= if (count _this > 2) then {_this select 2} else { [] }; 	// Location where to create the camps - if not set use random all over the map
	_radius		= if (count _this > 3) then {_this select 3} else { 2000 }; // Radius of user defined location
	
	diag_log format ["defensive_roadblocks amount %1, spacing %2, location %3, radius %4", _amount, _spacing, _location, _radius];
	
	if (count _location != 3) exitWith {false;};
	
	_camplocations = [];
	_debug = DEBUG;
	_giveup = false;
	_triesroad = 10 * _amount; // Number of tries to find a road
	while {count _camplocations < _amount} do {
		_triesroad = _triesroad - 1;
		_position = [_location, _radius, random 360] call BIS_fnc_relPos;
		_list = _position nearRoads 200; // Get roads near this position
		_created = false;
		if (count _list > 0) then {
			_triescamp = 20; // Number of tries to create the camp
			while {!_created} do {
				_triescamp = _triescamp - 1;
				_road = _list call BIS_fnc_selectRandom; // Get random position on road
				_roadpos = getPos _road;
				_roaddir = [_road] call road_dir;
				_allowed = true;
				{
					if ((_roadpos distance _x) < _spacing) exitWith {
						_allowed = false;
					};
				} foreach _camplocations;
				
				if (_allowed) then {
					_dirCenterToRB = [_location, _roadpos] call BIS_fnc_DirTo;
					_dirRB = [_dirCenterToRB, [_roaddir, _roaddir + 180]] call closest_azt;
					_created = [_roadpos, _dirRB] call roadblock;
				};
				
				if (_created) exitWith {
					_camplocations set [count _camplocations, _roadpos];
					diag_log format ["Roadblock created with %1 tries left.", _triescamp];
					if (_debug) then {
						_m = createMarker [format ["camp%1",random 999], _roadpos];
						_m setMarkerShape "ELLIPSE";
						_m setMarkerSize [50, 50];
						_m setMarkerText "ROADBLOCK";
						_m setMarkerBrush "Solid";
						_m setMarkerType  "Marker";
						_m setMarkerColor "ColorRed";
					};
				};
				if (_triescamp <= 0) exitWith {
					diag_log "Roadblock creation failed. Trying different location.";
					_created = true;
				};
			};
			if (_triesroad < 1) exitWith {
				_giveup = true;
				diag_log "Could not create all roadblocks...";
			};
		};
		if (_giveup) exitWith {};
	};
	diag_log format ["Created %1 of %2 roadblocks.", count _camplocations, _amount];
	diag_log format ["Leaving defensive roadblock script with %1 tries left.", _triesroad];
};