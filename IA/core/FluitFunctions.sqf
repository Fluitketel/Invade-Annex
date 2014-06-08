// Register Fluit's functions

handle_gforce = {
	/*
	=== Visual G-Force FX ===
		Author: 		Fluit
		Version: 		1.0.2
		Released:		2014-05-24
		Description:	Adds visual effects to the player when suffering too many g's
						while flying a jet. Not wearing the proper outfit will increase
						the effects significantly.
		
		Changelog:		1.0.2	- maxg of pilot from 10 to 16
						1.0.1	- Detects plane of any type or faction
								- Can wear filot outfit from any faction
								- Speed has an effect on the amount of blur
		
		To do:	- Add heartbeat sound while effects occur
				- Enable on screen g-force display through parameter
				- Reduce black out to black corners of screen
	*/
	private ["_gforce", "_headgear", "_uniforms", "_vol", "_outfit"];
	_gforce = 0; _outfit = false; _vol = soundVolume; _volnew = soundVolume; _blur = 0; _effect = 0.4; _maxg = 5; _maxgblackout = 15; _warning = false; _blackout = false; _velocity = []; _velocityprev = [];
	_log = 0; // 0 = off; 1 = gforce logging; 2 = complete logging
	
	_headgear = ["H_PilotHelmetFighter_B", "H_PilotHelmetFighter_O", "H_PilotHelmetFighter_I"];
	_uniforms = ["U_B_PilotCoveralls", "U_O_PilotCoveralls", "U_I_pilotCoveralls"];
	
    while {true} do {
		// is the player in a plane
		if (vehicle player isKindOf "PLANE") then {
			
			// check if the player is wearing the correct outfit
			if (headgear player in _headgear && uniform player in _uniforms) then {
				_outfit = true;
				_maxg = 16;
				_maxgblackout = 32;
				_effect = 0.1;
			} else {
				// not wearing pilot outfit => increased effects
				_outfit = false;
				_maxg = 5;
				_effect = 0.4;
				_maxgblackout = 15;
				
				// show warning if not yet shown
				if (!_warning) then {
					systemChat "Warning: you are not wearing the proper outfit to fly this.";
					_warning = true;
				};
			};
			
			_volnew = _vol; // reset the volume;
			
			// get the plane velocity
			_velocity = velocity (vehicle player);
			if (count _velocityprev == 0) then {
				_velocityprev = _velocity;
			};
			
			// calculate gforce
			_a_x = (( _velocity select 0 ) - ( _velocityprev select 0 )) / 9.8;
			_a_y = (( _velocity select 1 ) - ( _velocityprev select 1 )) / 9.8;
			_a_z = (( _velocity select 2 ) - ( _velocityprev select 2 )) / 9.8;
			_gforce = (sqrt( (_a_x * _a_x) + (_a_y * _a_y) + (_a_z * _a_z))) * 7;
			
			// round down to 2 decimals
			_gforce = (floor (_gforce * 100) / 100);
			
			// save velocity for next calculation
			_velocityprev = _velocity;
			
			// calculate the amount of blur
			_blur = 0;
			if (_gforce > _maxg) then {
				_blur = (_gforce - _maxg) * _effect;
			};
			
			// speed has an effect on the amount of blur when going faster than 250
			if (speed player >= 250) then {
				if (!_outfit) then {
					// if not wearing correct outfit speed will have a great effect on blur
					_blur = _blur + (speed player / 1000);
				} else {
					_blur = _blur + (speed player / 5000);
				};
			};
			
			// round down to 2 decimals
			_blur = (floor (_blur * 100) / 100);
			
			// apply the blur effect
			"dynamicBlur" ppEffectEnable true;
			"dynamicBlur" ppEffectAdjust [_blur];
			"dynamicBlur" ppEffectCommit 1;
			
			// if blur greater than 2, reduce the volume
			if (_blur > 1.5) then {
				_volnew = (_vol / 1.7);
			};
			
			// black out if player takes too many g's
			if (_gforce > _maxgblackout) then {
				if (!_blackout) then {
					// only apply the black out effect if not already blacked out
					_blackout = true;
					"ColorCorrections" ppEffectEnable true;
					"ColorCorrections" ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0],[0.0, 0.0, 0.0, 1.0]];
					"ColorCorrections" ppEffectCommit 1;
					_volnew = 0.2;
				};
			} else {
				if (_blackout) then {
					// remove the black out effect
					_blackout = false;
					"ColorCorrections" ppEffectEnable true;
					"ColorCorrections" ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0],[0.0, 0.0, 0.0, 0.0]];
					"ColorCorrections" ppEffectCommit 1;
				};
			};
			
			// alter game volume
			1 fadeSound _volnew;
			
			// on screen logging
			if (_log >= 1) then {
				systemChat format ["G-force: %1", _gforce];
			};
			if (_log >= 2) then {
				systemChat format ["Blur: %1  Volume: %2", _blur, _volnew];
			};
			
			// g-force should be calculated every second
			sleep 1;
		} else {
			// when player is not or no longer in plane the effects should be removed
			"dynamicBlur" ppEffectEnable false;
			"ColorCorrections" ppEffectEnable false;
			
			// reset variables after eject
			_warning = false;
			_blackout = false;
			0 fadeSound _vol;
			sleep 5;
		};
    };
};

restrict_artycomputer = {
    while {true} do {
		if (shownArtilleryComputer) then { 
			player action ["GetOut", vehicle player];
		};
		sleep 2;
    };
};

dr_handle_healing = {
		diag_log "inside dr_handle_healing";
		private ["_unit", "_healer", "_medic", "_damage", "_return"];
		_unit = _this select 0;
		_healer = _this select 1;
		_medic = _this select 2;
		_damage = 0.4;
		
		if (_medic) then {
			// Medic has beter healing
			_damage = 0.2;
		};
		
		if (damage _unit > _damage) then {
			_unit setDamage _damage;
			diag_log format ["unit %1 is healed by %2 to damage %3", _unit, _healer, _damage];
			systemchat format ["unit %1 is healed by %2 to damage %3", _unit, _healer, _damage];
		};
	    AISFinishHeal [_unit, _healer, _medic];
		_return = true;
		_return;
};

locations_minheight = {
	private ["_validmount", "_center", "_size", "_minheight"];
	_center 	= _this select 0;
	_size 		= _this select 1;
	_minheight	= _this select 2;
	
	diag_log format ["locations_minheight (center: %1, size: %2, minheight: %3)", _center, _size, _minheight];
	
	// Get valid locations
	_validmount = [];
	_mount = nearestlocations [_center, ["Mount"], _size];
	{ 
		_flatPos = (getPos _x) isFlatEmpty [5, 0, 0.2, 5, 0, false];
		if (getTerrainHeightASL (getPos _x) >= _minheight && count _flatPos == 3) then
		{
			_validmount set [count _validmount, getPos _x];
		};
	} foreach _mount;
	
	_validmount;
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

road_dir = {
	private ["_road","_roadsConnectedTo","_connectedRoad","_roaddir"];
	_road = _this select 0;
	_roadsConnectedTo = roadsConnectedTo _road;
	_roaddir = 0;
	if (count _roadsConnectedTo > 0) then {
		_connectedRoad = _roadsConnectedTo select 0;
		_roaddir = [_road, _connectedRoad] call BIS_fnc_DirTo;
	} else {
		_roaddir = direction _road;
	};
	_roaddir;
};

format_azt = {
	//	Formats the azimuth. 
	//	For example		-90 => 270
	//					380 => 20
	private ["_azt"];
	_azt = _this;
	while {_azt >= 360} do { _azt = _azt - 360;};
	while {_azt <= -360} do { _azt = _azt + 360;};
	if (_azt < 0) then {_azt = _azt + 360;};
	_azt;
};

diff_azt = {
	// Finds the smallest difference between 2 bearings
	// For example		45 - 315 = 90
	private ["_azt1", "_azt2", "_dif1", "_dif2", "_result"];
	_azt1 = _this select 0;
	_azt2 = _this select 1;
	_azt1 = _azt1 call format_azt;
	_azt2 = _azt2 call format_azt;
	_dif1 = abs (_azt1 - _azt2); 
	_dif2 = 360 - _dif1;
	_result = _dif1;
	if (_dif2 < _dif1) then { _result = _dif2; };
	_result;
};

closest_azt = {
	// Compare one azimuth against an array of others and return the most similar one
	// For example		45 : [10, 50, 180] = 50
	private ["_azt", "_compare", "_result", "_tempdiff"];
	_azt = _this select 0;
	_compare = _this select 1;
	_diff = 360;
	_result = _azt;
	{
		_tempdiff = [_azt, _x] call diff_azt;
		if (_tempdiff < _diff) then {
			_diff = _tempdiff;
			_result = _x;
		};
	} forEach _compare;
	_result;
};

random_camps = {
	// Example: [round (random 3), 400, getMarkerPos "AO_marker", 1000, [getMarkerPos "respawn_west"]] spawn random_camps;
	private ["_amount", "_camplocations", "_triesroad", "_triescamp", "_position", "_spacing", "_location", "_radius", "_markercolor", "_giveup"];
	_amount 	= if (count _this > 0) then {_this select 0} else { 8 }; 	// Amount of camps to create
	_spacing 	= if (count _this > 1) then {_this select 1} else { 2500 };	// Distance between camps in meters
	_location	= if (count _this > 2) then {_this select 2} else { [] }; 	// Location where to create the camps - if not set use random all over the map
	_radius		= if (count _this > 3) then {_this select 3} else { 2500 }; // Radius of user defined location
	_avoid 		= if (count _this > 4) then {_this select 4} else { [] }; 	// Locations that should be avoided
	_onroad 	= if (count _this > 5) then {_this select 5} else { false };// Only put camps on roads (default false)
	
	diag_log format ["random_camps amount %1, spacing %2, avoid %3", _amount, _spacing, _avoid];
	
	_camplocations = [];
	_debug = DEBUG;
	_giveup = false;
	_triesroad = 10 * _amount; // Number of tries to find a road
	_markercolor = "ColorRed";
	while {count _camplocations < _amount} do {
		_triesroad = _triesroad - 1;
		if (count _location == 3) then {
			_position = [_location, ceil (random _radius), random 360] call BIS_fnc_relPos; // User defined location
		} else {
			_position = ["water", "out"] call BIS_fnc_randomPos; // Get random position on the map
		};
		_list = _position nearRoads 200; // Get roads near this position
		_created = false;
		if (count _list > 0 || !_onroad) then {
			_triescamp = 20; // Number of tries to create the camp
			while {!_created} do {
				_triescamp = _triescamp - 1;
				_camppos = _position;
				_campdir = 0;
				if (_onroad) then {
					_road = _list call BIS_fnc_selectRandom; // Get random position on road
					_camppos = getPos _road;
					_campdir = [_road] call road_dir;
				} else {
					_camppos = [_position, ceil (random 200), random 360] call BIS_fnc_relPos;
					_campdir = random 360;
					if (count _location == 3) then {
						// Align the camp with the center of the location
						_campdir = [_location, _camppos] call BIS_fnc_DirTo;
					};
				};
				_allowed = true;
				{
					if ((_camppos distance _x) < _spacing) exitWith {
						_allowed = false;
					};
				} foreach _avoid;
				{
					if ((_camppos distance _x) < _spacing) exitWith {
						_allowed = false;
					};
				} foreach _camplocations;
				
				if (_allowed) then {
					_randomcamp = round (random 2);
					switch (_randomcamp) do { 
						case 0: {_created = [_camppos, _campdir] call at_camp; _markercolor = "ColorYellow"; };
						case 1: {_created = [_camppos, _campdir] call aa_camp; _markercolor = "ColorBlue"; };
						case 2: {_created = [_camppos, _campdir] call hmg_camp; _markercolor = "ColorGreen"; };
					};
				} else {
					diag_log format ["Position %1 not allowed.", _camppos];
				};
				
				if (_created) exitWith {
					_camplocations set [count _camplocations, _camppos];
					diag_log format ["Camp created with %1 tries left.", _triescamp];
					if (_debug) then {
						_m = createMarker [format ["camp%1",random 999], _camppos];
						_m setMarkerShape "ELLIPSE";
						_m setMarkerSize [50, 50];
						_m setMarkerText "CAMP";
						_m setMarkerBrush "Solid";
						_m setMarkerType  "Marker";
						_m setMarkerColor _markercolor;
					};
				};
				if (_triescamp < 1) exitWith {
					diag_log "Camp creation failed. Trying different location.";
					_created = true;
				};
			};
		} else {
			if (_triesroad < 1) exitWith {
				_giveup = true;
				diag_log "Could not create all camps...";
			};
		};
		if (_giveup) exitWith {};
	};
	diag_log format ["Created %1 of %2 camps.", count _camplocations, _amount];
	diag_log format ["Leaving random camp script with %1 tries left.", _triesroad];
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
		} else {
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

CampCleanup = {
	if (isNil "campArray") then { 
		campArray = [];
	};
	if !(isNull _this) then {
		campArray = campArray + [_this];
		publicVariable "campArray";
	};
};

hmg_camp = {
	private ["_pos", "_newpos", "_dir", "_campgroup", "_campgun1group", "_campgun2group", "_prop", "_bagspos"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	
	_flatPos = _pos isFlatEmpty [13, 0, 0.2, 10, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
		
	_campgroup 		= createGroup east;
	_campgun1group 	= createGroup east;
	_campgun2group 	= createGroup east;
	_campgroup 		setFormDir _dir;
	_campgun1group 	setFormDir _dir;
	_campgun2group 	setFormDir _dir + 180;
	_campgroup 		call CampCleanup;
	_campgun1group 	call CampCleanup;
	_campgun2group 	call CampCleanup;
	
	_prop = "Land_BagBunker_Tower_F" createVehicle _pos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_pos, 9, (_dir - 15)] call BIS_fnc_relPos;
	_prop = (["Flag_CSAT_F","Land_TTowerSmall_1_F","Land_TTowerSmall_2_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	
	_bagspos = [_pos, 6, (_dir + 90)] call BIS_fnc_relPos;
	_numberofbags = 5;
	_bagsdir = _dir;
	for "_c" from 1 to _numberofbags do
	{
		_temppos = [_bagspos, 6, _bagsdir] call BIS_fnc_relPos;
		_prop = "Land_BagFence_Long_F" createVehicle _temppos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _bagsdir;
		_bagsdir = _bagsdir + (200 / _numberofbags);
	};
	sleep 0.5;
	
	_gun1 = "O_HMG_01_high_F" createVehicle _bagspos;
	waitUntil {alive _gun1};
	_gun1 call CampCleanup;
	_gun1 setDir _dir;
	_newpos = [_bagspos, 1, (_dir + 180)] call BIS_fnc_relPos;
	_gunner1 = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	waitUntil {alive _gunner1};
	_gunner1 assignAsGunner _gun1;
	_gunner1 moveInGunner _gun1;
	_gunner1 setDir _dir;
	
	_newpos = [_bagspos, 5, _dir + 90] call BIS_fnc_relPos;
	_soldier = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	
	_bagspos = [_pos, 6, (_dir - 90)] call BIS_fnc_relPos;
	_numberofbags = 5;
	_bagsdir = _dir + 180;
	for "_c" from 1 to _numberofbags do
	{
		_temppos = [_bagspos, 6, _bagsdir] call BIS_fnc_relPos;
		_prop = "Land_BagFence_Long_F" createVehicle _temppos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _bagsdir;
		_bagsdir = _bagsdir + (200 / _numberofbags);
	};
	sleep 1;
	
	_gun2 = "O_HMG_01_high_F" createVehicle _bagspos;
	waitUntil {alive _gun2};
	_gun2 call CampCleanup;
	_gun2 setDir _dir + 180;
	_newpos = [_bagspos, 1, (_dir + 180)] call BIS_fnc_relPos;
	_gunner2 = _campgun2group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	waitUntil {alive _gunner2};
	_gunner2 assignAsGunner _gun2;
	_gunner2 moveInGunner _gun2;
	_gunner2 setDir _dir + 180;
	
	_newpos = [_bagspos, 5, _dir - 90] call BIS_fnc_relPos;
	_soldier = _campgun2group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	
	_soldier = _campgroup createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
	doStop _soldier;
	_newpos = _pos; _newpos set [2, 1];
	_soldier = _campgroup createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	true;
};

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
			if (_debug) then {
				_marker = createMarker [format ["%1-%2-%3",_y, _triescamp, random 99999],_position];
				_marker setMarkerType "hd_dot_noShadow";
				//_marker setMarkerText format ["%1",_marker];
				_marker setMarkerColor "ColorBlue";
			};
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

mortar_camp_big = {
	private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_center", "_amountofmortars"];
	_pos 				= _this select 0; // Camp position
	_dir 				= _this select 1; // Camp direction
	_amountofmortars 	= if (count _this > 2) then {_this select 2} else { 2 };
	_spawnvehicle 		= if (count _this > 3) then {_this select 3} else { true };
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
	_prop = (["Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_prop, 3, (_dir + 270)] call BIS_fnc_relPos;
	_prop = "Land_FieldToilet_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_center, 7, (_dir + 45)] call BIS_fnc_relPos;
	_prop = "Land_PowerGenerator_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 110);
	
	_prop = "Land_CanisterFuel_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_center, 8, (_dir + 270)] call BIS_fnc_relPos;
	_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
	_prop = "Land_HBarrier_5_F" createVehicle _newpos;
	_prop call CampCleanup;
	_prop setDir (_dir + 270);
	
	_newpos = [_center, 8, (_dir + 270)] call BIS_fnc_relPos;
	_newpos = [_newpos, 2, (_dir + 180)] call BIS_fnc_relPos;
	_prop = "Land_HBarrier_5_F" createVehicle _newpos;
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
		if (_spawnvehicle) then {
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
		"O_SoldierU_SL_F" createUnit [_pos, _mortardefgroup];
		"O_soldierU_AA_F" createUnit [_pos, _mortardefgroup];
		"O_soldierU_AR_F" createUnit [_pos, _mortardefgroup];
		"O_soldierU_AR_F" createUnit [_pos, _mortardefgroup];
		"O_SoldierU_GL_F" createUnit [_pos, _mortardefgroup];
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

AddMortars = {
	if (isNil "Mortars") then { 
		Mortars = [];
	};
	if !(isNull _this) then {
		Mortars = Mortars + [_this];
		publicVariable "Mortars";
	};
};

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

fluit_unlockable = {
	// Returns true if the target is unlockable
	private ["_target", "_allowed"];
	_return = false;
	_target = cursorTarget;
	_allowed = false;
	if !(isNil {_caller getVariable "friend"}) then {
		_allowed = _caller getVariable "friend";
	};
	if (_allowed && alive _target && (locked _target == 2 || locked _target == 3)) then { 
		_return = true; 
	};	
	_return;
};

fluit_lockable = {
	// Returns true if the target is lockable
	private ["_target", "_allowed"];
	_return = false;
	_target = cursorTarget;
	_allowed = false;
	if !(isNil {_caller getVariable "friend"}) then {
		_allowed = _caller getVariable "friend";
	};
	if (_allowed && alive _target && (locked _target == 0 || locked _target == 1)) then { 
		_return = true; 
	};	
	_return;
};

format_markers = {
	private ["_markers"];
	_markers = [];
	_cleanup = 60;
	while {true} do 
	{
		{  
            private "_a";
            _a = toArray _x;
            _a resize 15;
             if (toString _a == "_USER_DEFINED #") then {
					if !(_x in _markers) then {
						_a = toArray _x;
						_hash = 0;
						_slash = 0;
						for "_c" from 0 to ((count _a) - 1) do {
							_val = _a select _c;
							if (_val == 35) then {_hash = _c};
							if (_val == 47) then {_slash = _c};
						};
						_playerid = [];
						for "_c" from (_hash + 1) to (_slash - 1) do {
							_playerid set [count _playerid, _a select _c];
						};
						_playerid = toString _playerid;
						systemChat format ["Thanks player %1", _playerid];
						_markers set [count _markers, _x];
						_text = format ["%1%2", format ["[%1:%2]", date select 3, date select 4], markerText _x];
						//_x setMarkerText format ["%1%2", format ["[%1:%2]", date select 3, date select 4], markerText _x];
						[[_x, _text], "change_marker_text"] spawn BIS_fnc_MP;
					};
             };
        } forEach allMapMarkers;
		//diag_log format ["_markers = %1",_markers];
		
		_cleanup = _cleanup - 1;
		if (_cleanup < 1) then {
			_delete = [];
			{
				if !(_x in allMapMarkers) then { _delete set [count _delete, _x]; };
			} foreach _markers;
			if (count _delete > 0) then { _markers = _markers - _delete; };
			_cleanup = 60;
		};
        sleep 1;
	};
};

change_marker_text = {
	private ["_marker", "_text"];
	_marker	= _this select 0;
	_text	= _this select 1;
	_marker setMarkerText _text;
};

fluit_sortBy = {
	private ["_unsortedArray","_inputParams","_algorithm","_sortDirection","_filter","_removeElement","_values","_sortedArray","_sortedValues","_fnc_sort","_initValue","_sortCode"];

	_unsortedArray 	= [_this, 0, [], [[]]] call BIS_fnc_param;
	_inputParams	= [_this, 1, [], [[]]] call BIS_fnc_param;
	_algorithm 		= [_this, 2, {_x}, [{}]] call BIS_fnc_param;
	_sortDirection	= [_this, 3, "ASCEND", [""]] call BIS_fnc_param;
	_filter			= [_this, 4, {true}, [{}]] call BIS_fnc_param;

	_removeElement = "BIS_fnc_sortBy_RemoveMe";

	if (count _unsortedArray == 0) exitWith {[]};

	//create the input params
	private["_input0","_input1","_input2","_input3","_input4","_input5","_input6","_input7","_input8","_input9"];

	//--- ToDo: Pass arguments in _this instead of pre-defining limited number of input variables as below
	_this = _inputParams;

	_input0 = [_inputParams, 0, objNull] call BIS_fnc_param;
	_input1 = [_inputParams, 1, objNull] call BIS_fnc_param;
	_input2 = [_inputParams, 2, objNull] call BIS_fnc_param;
	_input3 = [_inputParams, 3, objNull] call BIS_fnc_param;
	_input4 = [_inputParams, 4, objNull] call BIS_fnc_param;
	_input5 = [_inputParams, 5, objNull] call BIS_fnc_param;
	_input6 = [_inputParams, 6, objNull] call BIS_fnc_param;
	_input7 = [_inputParams, 7, objNull] call BIS_fnc_param;
	_input8 = [_inputParams, 8, objNull] call BIS_fnc_param;
	_input9 = [_inputParams, 9, objNull] call BIS_fnc_param;

	//check the filter
	{
		if !(call _filter) then
		{
			_unsortedArray set [_forEachIndex,_removeElement];
		};
	}
	forEach _unsortedArray;

	//remove filtered-out items
	_unsortedArray = _unsortedArray - [_removeElement];

	//get the sort values
	_values = [];

	{
		private ["_algorithmTemp"];
		_algorithmTemp = _algorithm;

		//--- Wipe out all existing variables to prevent accidental overwriting (except of _values)
		private ["_unsortedArray","_inputParams","_algorithm","_sortDirection","_filter","_removeElement","_sortedArray","_sortedValues","_fnc_sort","_initValue","_sortCode"];

		//--- Evaluate the algorithm
		_values set [count _values,call _algorithmTemp];
	}
	forEach _unsortedArray;

	//init sorted arrays
	_sortedArray = [];
	_sortedValues = [];

	//handle ASCENDing vs. DESCENDing sorting
	if (_sortDirection == "ASCEND") then
	{
		_initValue = 1e9;
		_sortCode  = {_x < _selectedValue};
	}
	else
	{
		_initValue = -1e9;
		_sortCode  = {_x > _selectedValue};
	};

	if (count _values > 0) then {
		while {count _values > 0} do {
			private["_selectedValue","_selectedItem","_selectedIndex"];

			_selectedValue = _initValue;

			{
				if (call _sortCode) then
				{
					_selectedValue = _x;
					_selectedItem = _unsortedArray select _forEachIndex;
					_selectedIndex = _forEachIndex;
				};
			}
			forEach _values;

			//store selected
			if (!isNil "_selectedItem") then { // Fluit: check if item exists 
				_sortedArray set [count _sortedArray,_selectedItem];
			};
			_sortedValues set [count _sortedValues,_selectedValue];

			//remove stored from source pool
			_unsortedArray set [_selectedIndex,_removeElement];
			_unsortedArray = _unsortedArray - [_removeElement];
			_values set [_selectedIndex,_removeElement];
			_values = _values - [_removeElement];
		};
	};

	//return sorted array
	_sortedArray
};

fluitfunctions = true; // waitUntil {!isNil "fluitfunctions"}; to check if functions are loaded