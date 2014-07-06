/*=======================================================================================
    DYNAMIC ENEMY POPULATION by Fluit
    This script places enemies all across the map
  =======================================================================================*/
private ["_locations","_pos"];
diag_log "Initializing DEP . . .";

// SETTINGS
dep_side        = east;         // Enemy side
dep_despawn     = 5;            // Despawn location after x minutes inactivity
dep_debug       = DEBUG;        // Enable debug
dep_max_ai_loc  = 60;           // Maximum AI per location
dep_max_ai_tot  = 200;          // Maximum AI in total
dep_act_dist    = 800;          // Location activation distance
dep_roadblocks  = 30;           // Number of roadblocks
dep_safezone    = 1500;         // Respawn safe zone radius

// PUBLIC VARIABLES
dep_total_ai    = 0;
dep_spawning    = false;
dep_locations   = [];
dep_num_loc     = 0;
dep_act_bl      = [];           // Activation blacklist

// FUNCTIONS
dep_fnc_buildingpositions = {
	private ["_building", "_positions", "_i"];
	_building = _this;
	_positions = [];
	_i = 1;
	while {_i > 0} do {
	   _next = _building buildingPos _i;
	   if (((_next select 0) == 0) && ((_next select 1) == 0) && ((_next select 2) == 0)) then {
		  _i = 0;
	   } else {
		  _positions set [(count _positions), _next];
		  _i = _i + 1;
	   };
	};
	_positions;
};

dep_fnc_roaddir = {
	private ["_road","_roadsConnectedTo","_connectedRoad","_roaddir","_connected"];
	_road = _this select 0;
	_roadsConnectedTo = roadsConnectedTo _road;
	_roaddir = 0;
    _connected = count _roadsConnectedTo;
    _connectedRoad = objNull;
    if (_connected == 0) then {
        _roaddir = direction _road;
    } else {
        if (_connected > 1) then {
            _connectedRoad = _roadsConnectedTo select (round(random (_connected - 1)));
        } else {
            _connectedRoad = _roadsConnectedTo select 0;
        };
        _roaddir = [_road, _connectedRoad] call BIS_fnc_DirTo;;
    };
	_roaddir;
};

_scriptHandle = [] execVM "DEP\roadblock.sqf"; 
waitUntil {scriptDone _scriptHandle};

// Get city locations
_locations = nearestLocations [[15000, 15000, 0], ["NameVillage","NameCity","NameCityCapital"], 25000];
{
    if ( ((position _x) distance (getMarkerPos "respawn_west")) > dep_safezone) then {
        _location = [];
        _location set [0, (position _x)];
        _location set [1, "city"];
        _location set [2, 400];
        _location set [3, false];   // location active
        _location set [4, []];      // enemy groups
        _location set [5, 0];       // time last active
        _location set [6, 0];       // enemy amount
        _location set [7, false];   // location cleared
        _location set [8, []];      // objects to cleanup
        _location set [9, []];      // possible direction of objects
        dep_locations = dep_locations + [_location];
    };
} forEach _locations;

// Get local locations
_locations = nearestLocations [[15000, 15000, 0], ["NameLocal"], 25000];
{
    if ( ((position _x) distance (getMarkerPos "respawn_west")) > dep_safezone) then {
        _location = [];
        _location set [0, (position _x)];
        _location set [1, "local"];
        _location set [2, 250];
        _location set [3, false];   // location active
        _location set [4, []];      // enemy groups
        _location set [5, 0];       // time last active
        _location set [6, 0];       // enemy amount
        _location set [7, false];   // location cleared
        _location set [8, []];      // objects to cleanup
        _location set [9, []];      // possible direction of objects
        dep_locations = dep_locations + [_location];
    };
} forEach _locations;

// Get roadblock locations
_timestart = time;
_giveup = false;
for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        _pos = [] call BIS_fnc_randomPos;
        _list = _pos nearRoads 300;
        if ((count _list) > 0) then {
            _road = _list call BIS_fnc_selectRandom;
            if (((getPos _road) distance (getMarkerPos "respawn_west")) > dep_safezone) then {
                _distance = true;
                {
                    _loc_pos    = _x select 0;
                    _radius     = _x select 2;
                    _spacing    = 500;
                    if ((_x select 1) == "roadblock") then { _spacing = 1500; };
                    if ((_pos distance _loc_pos) < (_spacing + _radius + 100)) exitWith { _distance = false; };
                } foreach dep_locations;
                if (_distance) then {
                    _flatPos = _pos isFlatEmpty [12, 0, 0.3, 12, 0, false];
                    if (count _flatPos == 3) then {
                        _dir = [_road] call dep_fnc_roaddir;
                        _location = [];
                        _location set [0, (getPos _road)];  // position
                        _location set [1, "roadblock"];     // location type
                        _location set [2, 100];             // radius
                        _location set [3, false];           // location active
                        _location set [4, []];              // enemy groups
                        _location set [5, 0];               // time last active
                        _location set [6, 0];               // enemy amount
                        _location set [7, false];           // location cleared
                        _location set [8, []];              // objects to cleanup
                        _location set [9, _dir];            // possible direction of objects
                        dep_locations = dep_locations + [_location];
                        _valid = true;
                    };
                };
            };
        };
        if ((time - _timestart) > 90) exitWith {_giveup = true; };
    };
    if (_giveup) exitWith {};
};

// Place makers in debug mode
if (dep_debug) then {
    for [{_x=0}, {_x<(count dep_locations)}, {_x=_x+1}] do {
        _location = dep_locations select _x;
        _pos = _location select 0;
        _m = createMarker [format ["depmarker-%1",_x], _pos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_location select 2, _location select 2];
        switch (_location select 1) do {
            case "city":        { _m setMarkerColor "ColorRed";};
            case "local":       { _m setMarkerColor "ColorBlue";};
            case "roadblock":   { _m setMarkerColor "ColorGreen";};
        };
        _m setMarkerBrush "Solid";
        _m setMarkerAlpha 0.5;
    };
};

// Start searching for players
dep_num_loc = (count dep_locations);
diag_log format ["DEP ready with %1 locations", dep_num_loc];
while {true} do {
    if (dep_spawning) exitWith {};
    dep_total_ai = 0;
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location = dep_locations select _g;
        _groups = _location select 4;
        _alive = 0;
        {
            _grp = _x;
            {
                if (!isNull _x) then {
                    if (alive _x) then { _alive = _alive + 1; };
                };
            } foreach (units _grp);
        } foreach _groups;
        dep_total_ai = dep_total_ai + _alive;
    };
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location   = dep_locations select _g;
        _pos        = _location select 0;
        _type       = _location select 1;
        _radius     = _location select 2;
        _active     = _location select 3;
        _groups     = _location select 4;
        _time       = _location select 5;
        _enemies    = _location select 6;
        _clear      = _location select 7;
        _close      = false;
        _blacklist  = false;
        
        // Check if active location is clear
        if (_active && !_clear) then {
            _alive = 0;
            {
                _grp = _x;
                {
                    if (alive _x) then { _alive = _alive + 1; };
                } foreach (units _grp);
            } foreach _groups;
            
            if ((_alive / _enemies) < 0.1) then {
                // If number of enemies alive below 10% concider this location clear.
                diag_log format ["Cleared location %1", _g];
                _clear = true;
                _location set [7, _clear];
                dep_locations set [_g, _location];
            };
        };
        
        // Check if location is close to blacklisted positions
        {
            if ((_pos distance _x) < (_radius * 2)) exitWith {_blacklist = true; };
        } foreach dep_act_bl;
        
        // Check if at least 1 player is close
        if (!_blacklist) then {
            {
               if ((side _x) == West && isPlayer _x) then
               {
                    if (((getPos _x) select 2) <= 80 && (speed player) <= 120) then {
                        if (((getPos _x) distance _pos) < (_radius + dep_act_dist)) exitWith { _close = true; };
                    };
               };
            } forEach allUnits;
        };
        
        if (_close && !_clear) then {
            // Players are close and location not clear, should enemies be spawned?
            if (!_active && dep_total_ai < dep_max_ai_tot) then {
                // Location is not cleared and not active => spawn units
                _handle = _g execVM "DEP\activate.sqf";
                waitUntil {scriptDone _handle};
            };
            _time = time;
            _location set [5, _time];
            dep_locations set [_g, _location];
        } else {
            // No players close to location, should it be deactivated?
            if (_active) then {
                // Despawn after time limit
                if ((_clear && (time - _time) > (60 * dep_despawn)) || (!_clear && (time - _time) > (60 * (dep_despawn / 2))) ) then {
                    // Deactivate the location
                    _handle = _g execVM "DEP\deactivate.sqf";
                    waitUntil {scriptDone _handle};
                };
            };
        };
        sleep 0.02;
    };
    sleep 1;
};