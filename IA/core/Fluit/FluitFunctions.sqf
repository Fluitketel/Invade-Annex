diag_log " * Fluit common functions are initializing...";
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
				sleep 0.05;
			};
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

CampCleanup = {
	if (isNil "campArray") then { 
		campArray = [];
	};
	if !(isNull _this) then {
		campArray = campArray + [_this];
		publicVariable "campArray";
	};
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

FireFlares = {
	_pos 	= _this select 0;
	_amount = if (count _this > 1) then {_this select 1} else { 12 };
	_color	= if (count _this > 2) then {_this select 2} else { "white" };
	
	_xdir = -10 + (random 20);
	_ydir = -10 + (random 20);
	
	for "_c" from 1 to _amount do {
		_newpos = [_pos, (10 + (random 60)), (random 360)] call BIS_fnc_relPos;
		_newpos set [2, 140 + (round (random 30))];
		_flare = objNull;
		switch (_color) do { 
			case "yellow": { 
				_flare = "F_40mm_Yellow" createVehicle _newpos; 
			};  
			case "green": { 
				_flare = "F_40mm_Green" createVehicle _newpos; 
			};  
			case "red": { 
				_flare = "F_40mm_Red" createVehicle _newpos; 
			};  
			case "lsd": { 
				_flare = (["F_40mm_White","F_40mm_Yellow","F_40mm_Green","F_40mm_Red"] call BIS_fnc_selectRandom) createVehicle _newpos; 
			};  
			default { 
				_flare = "F_40mm_White" createVehicle _newpos; 
			}; 
		}; 
		waitUntil {alive _flare};
		_flare setVelocity [_xdir, _ydir, 0];
		sleep (0.2 + (random 1));
	};
};

FlareClusters = {
	private ["_pos", "_amount", "_color", "_newpos"];
	_pos 	= _this select 0;
	_amount = if (count _this > 1) then {_this select 1} else { 12 };
	_color	= if (count _this > 2) then {_this select 2} else { "white" };
	
	for "_c" from 1 to _amount do {
		_newpos = [_pos, (10 + (random 60)), (random 360)] call BIS_fnc_relPos;
		[_newpos, _color] spawn FlareCluster;
		sleep (0.2 + (random 1));
	};
};

FlareCluster = {
	private ["_pos", "_clustersize", "_color", "_cluster", "_flare", "_type", "_speed"];
	_pos 	= _this select 0;
	_color	= if (count _this > 1) then {_this select 1} else { "white" };
	
	_pos set [2, 140 + (round (random 30))]; 	// Set flare height
	_clustersize = 6 + (round (random 4));		// Set amount of flares in cluster
	_cluster = [];
	for "_p" from 1 to _clustersize do
	{
		_flare = objNull;
		_type = "F_40mm_White";
		switch (_color) do { 
			case "yellow": { 
				_type = "F_40mm_Yellow"; 
			};  
			case "green": { 
				_type = "F_40mm_Green";					
			};  
			case "red": { 
				_type = "F_40mm_Green";
			};  
			case "lsd": { 
				_type = ["F_40mm_White","F_40mm_Yellow","F_40mm_Green","F_40mm_Red"] call BIS_fnc_selectRandom; 
			};   
		};
		_flare = _type createVehicle _pos;
		waitUntil {alive _flare}; 
		_flare setVelocity [10, 0.01, 0];
		_cluster = _cluster + [_flare];
	};
	sleep 7 + (random 10);
	// Burst open
	{
		_speed	= 50 + (random 200);
		_xdir 	= ((random  (_speed * 2)) - _speed);
		_ydir 	= ((random  (_speed * 2)) - _speed);
		_zdir 	= (((random (_speed * 2)) - _speed) / 2);
		_x setVelocity [_xdir, _ydir, _zdir];
	} forEach _cluster;
};

diag_log " * Done initializing Fluit common functions!";