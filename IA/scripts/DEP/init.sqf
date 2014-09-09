/*=======================================================================================
    DYNAMIC ENEMY POPULATION 
        by Fluit 
            bugs & feedback:    fluitketel@outlook.com
            last revision:      2014-09-09
    
    This script places cached enemies all across the map including:
    - units in buildings
    - units patroling outside buildings
    - patroling vehicles
    - roadblocks
    - anti-air camps
    - IED's
    - mines (AT & APERS)
  =======================================================================================*/

// SETTINGS
dep_directory = "scripts\DEP\";   // Script location
_handle = execVM format ["%1settings.sqf", dep_directory];
waitUntil{scriptDone _handle};

// PUBLIC VARIABLES
dep_total_ai    = 0;
dep_total_veh   = 0;
dep_spawning    = false;
dep_locations   = [];
dep_loc_cache   = [];
dep_num_loc     = 0;
dep_act_bl      = [];
dep_veh_pat_rad = 600;

// FUNCTIONS
dep_fnc_setwaypoints        = compile preprocessFileLineNumbers format ["%1setwaypoints.sqf",       dep_directory];
dep_fnc_getwaypoints        = compile preprocessFileLineNumbers format ["%1getwaypoints.sqf",       dep_directory];
dep_fnc_vehiclepatrol       = compile preprocessFileLineNumbers format ["%1vehiclepatrol.sqf",      dep_directory];
dep_fnc_housepatrol         = compile preprocessFileLineNumbers format ["%1housepatrol.sqf",        dep_directory];
dep_fnc_unitpatrol          = compile preprocessFileLineNumbers format ["%1unitpatrol.sqf",         dep_directory];
dep_fnc_enterablehouses     = compile preprocessFileLineNumbers format ["%1enterablehouses.sqf",    dep_directory];
dep_fnc_findnearhouses      = compile preprocessFileLineNumbers format ["%1findnearhouses.sqf",     dep_directory];
dep_fnc_buildingpositions   = compile preprocessFileLineNumbers format ["%1buildingpositions.sqf",  dep_directory];
dep_fnc_vehicledamage       = compile preprocessFileLineNumbers format ["%1vehicledamage.sqf",      dep_directory];
dep_fnc_nearestroad         = compile preprocessFileLineNumbers format ["%1nearestroad.sqf",        dep_directory];
dep_fnc_roaddir             = compile preprocessFileLineNumbers format ["%1roaddir.sqf",            dep_directory];
dep_fnc_roadblock           = compile preprocessFileLineNumbers format ["%1roadblock.sqf",          dep_directory];
dep_fnc_aacamp1             = compile preprocessFileLineNumbers format ["%1aacamp1.sqf",            dep_directory];
dep_fnc_aacamp2             = compile preprocessFileLineNumbers format ["%1aacamp2.sqf",            dep_directory];
dep_fnc_restore             = compile preprocessFileLineNumbers format ["%1restore.sqf",            dep_directory];
dep_fnc_activate            = compile preprocessFileLineNumbers format ["%1activate.sqf",           dep_directory];
dep_fnc_activate_aacamp     = compile preprocessFileLineNumbers format ["%1activate_aacamp.sqf",    dep_directory];
dep_fnc_deactivate          = compile preprocessFileLineNumbers format ["%1deactivate.sqf",         dep_directory];
dep_fnc_garrison            = compile preprocessFileLineNumbers format ["%1garrison.sqf",           dep_directory];
dep_fnc_enemyspawnprotect   = compile preprocessFileLineNumbers format ["%1enemyspawnprotect.sqf",  dep_directory];
dep_fnc_disable_ied         = compile preprocessFileLineNumbers format ["%1disable_ied.sqf",        dep_directory];
dep_fnc_disable_ied_action  = compile preprocessFileLineNumbers format ["%1disable_ied_action.sqf", dep_directory];

private ["_locations","_pos"];
diag_log "Initializing DEP . . .";

_buildings = nearestObjects [[15000, 15000, 0], ["Cargo_Tower_base_F", "Cargo_House_base_F", "Cargo_HQ_base_F", "Cargo_Patrol_base_F"], 25000];
_numbuildings = (count _buildings) / 2;

if (dep_debug) then {
    diag_log "Finding military buildings";
};
for [{_x=0}, {_x<=_numbuildings}, {_x=_x+1}] do {
    _building = _buildings call BIS_fnc_selectRandom;
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
        _ownradius = 75;
        _distance = true;
        {
            _loc_pos    = _x select 0;
            _radius     = _x select 2;
            if ((_pos distance _loc_pos) < (_radius + _ownradius)) exitWith { _distance = false; };
        } foreach dep_locations;
        if (_distance) then {
            _milbuild = nearestObjects [_pos, ["Cargo_Tower_base_F", "Cargo_House_base_F", "Cargo_HQ_base_F", "Cargo_Patrol_base_F"], _ownradius];
            if (count _milbuild > 2) then {
                _houses = [_pos, _ownradius] call dep_fnc_enterablehouses;
                if ((count _houses) > 1) then {
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "military"];      // location type
                    _location set [2, _ownradius];      // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                };
            };
        };
    };
    //sleep 0.005;
};
_buildings = nil;

if (dep_debug) then {
    diag_log "Finding normal buildings";
};
_buildings = nearestObjects [[15000, 15000, 0], ["House_F"], 25000];
//_numbuildings = (count _buildings);
_numbuildings = 0;

while {_numbuildings < dep_roadpop} do {
    _building = _buildings call BIS_fnc_selectRandom;
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
        _ownradius = 100 + (round random 100);
        _distance = true;
        _spacing = 50;
        {
            _loc_pos    = _x select 0;
            _radius     = _x select 2;
            if ((_pos distance _loc_pos) < (_radius + _spacing + _ownradius)) exitWith { _distance = false; };
        } foreach dep_locations;
        if (_distance) then {
            _houses = [_pos, _ownradius] call dep_fnc_enterablehouses;
            if ((count _houses) > 1) then {
                _location = [];
                _location set [0, _pos];            // position
                _location set [1, "roadpop"];       // location type
                _location set [2, _ownradius];      // radius
                _location set [3, false];           // location active
                _location set [4, []];              // enemy groups
                _location set [5, 0];               // time last active
                _location set [6, 0];               // enemy amount
                _location set [7, false];           // location cleared
                _location set [8, []];              // objects to cleanup
                _location set [9, 0];               // possible direction of objects
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _numbuildings = _numbuildings + 1;
            };
        };
    };
    //sleep 0.005;
};
_buildings = nil;

if (dep_debug) then {
    diag_log "Finding roadblocks";
};
// Roadblocks
_list = [15000, 15000, 0] nearRoads 25000;
for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
            _distance = true;
            {
                _loc_pos    = _x select 0;
                _radius     = _x select 2;
                _spacing    = 0;
                if ((_x select 1) == "roadblock") then { _spacing = 1000; };
                if ((_pos distance _loc_pos) < (_spacing + _radius + 100)) exitWith { _distance = false; };
            } foreach dep_locations;
            if (_distance) then {
                _flatPos = _pos isFlatEmpty [12, 0, 0.3, 12, 0, false];
                if (count _flatPos == 3) then {
                    _dir = [_road] call dep_fnc_roaddir;
                    _location = [];
                    _location set [0, _pos];            // position
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
                    dep_loc_cache = dep_loc_cache + [[]];
                    _valid = true;
                };
            };
        };
        //sleep 0.01;
    };
};

// Random road population
/*for [{_x=1}, {_x<=dep_roadpop}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
            _ownradius = 100 + (round random 100);
            _distance = true;
            {
                _loc_pos    = _x select 0;
                _radius     = _x select 2;
                _spacing    = 0;
                if ((_pos distance _loc_pos) < (_spacing + _radius + _ownradius)) exitWith { _distance = false; };
            } foreach dep_locations;
            if (_distance) then {
                _houses = [_pos, 100] call dep_fnc_enterablehouses;
                if ((count _houses) > 1) then {
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "roadpop"];       // location type
                    _location set [2, _ownradius];      // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                    _valid = true;
                };
            };
        };
        sleep 0.005;
    };
};*/

if (dep_debug) then {
    diag_log "Finding aa camps";
};
// AA Camps
_aacamps = [];
for "_c" from 1 to dep_aa_camps do {
    _valid = false;
    while {!_valid} do {
        _pos = [] call BIS_fnc_randomPos;
        // Check if out of safe zone
        if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
            _flatPos = _pos isFlatEmpty [15, 0, 0.2, 12, 0, false];
            // Check is position is flat and empty
            if (count _flatPos == 3) then {
                _distance = true;
                {
                    if ((_pos distance _x) < 1000) exitWith { _distance = false; };
                } foreach _aacamps;
                // Check distance between other AA camps
                if (_distance) then {
                    _valid = true;
                    _aacamps = _aacamps + [_pos];
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "antiair"];       // location type
                    _location set [2, 50];              // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                };
            };
        };
    };
};
_aacamps = nil;

// Get other locations
/*_locs = nearestLocations [ [15000, 15000, 0], ["NameLocal"], 25000];
{
    if ((random 1) < 0.5) then {
        _pos = getPos _x;
        if ((_pos distance (getMarkerPos "respawn_west")) > dep_safezone) then {
            _ownradius = 100 + (round random 100);
            _distance = true;
            {
                _loc_pos    = _x select 0;
                _radius     = _x select 2;
                if ((_pos distance _loc_pos) < (_radius + _ownradius)) exitWith { _distance = false; };
            } foreach dep_locations;
            if (_distance) then {
                _houses = [_pos, 100] call dep_fnc_enterablehouses;
                if ((count _houses) > 1) then {
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "roadpop"];       // location type
                    _location set [2, _ownradius];      // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                };
            };
        };
        sleep 0.005;
    };
} forEach _locs;
_locs = nil;*/

if (dep_debug) then {
    diag_log "Finding patrols";
};
// Vehicle patrols
for [{_x=1}, {_x<=80}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        if ((_pos distance (getMarkerPos "respawn_west")) > (dep_safezone + dep_veh_pat_rad)) then {
            _distance = true;
            {
                if (_x select 1 == "patrol") then {
                    _loc_pos    = _x select 0;
                    _radius     = _x select 2;
                    if ((_pos distance _loc_pos) < (_radius + dep_veh_pat_rad)) exitWith { _distance = false; };
                };
            } foreach dep_locations;
            if (_distance) then {
                _location = [];
                _location set [0, _pos];            // position
                _location set [1, "patrol"];        // location type
                _location set [2, dep_veh_pat_rad]; // radius
                _location set [3, false];           // location active
                _location set [4, []];              // enemy groups
                _location set [5, 0];               // time last active
                _location set [6, 0];               // enemy amount
                _location set [7, false];           // location cleared
                _location set [8, []];              // objects to cleanup
                _location set [9, 0];               // possible direction of objects
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _valid = true;
            };
        };
        //sleep 0.005;
    };
};
_list = nil;

// Place makers in debug mode
if (dep_debug) then {
    diag_log "Placing markers";
};
if (dep_debug) then {
    for [{_x=0}, {_x<(count dep_locations)}, {_x=_x+1}] do {
        _location = dep_locations select _x;
        _pos = _location select 0;
        _m = createMarker [format ["depmarker-%1",_x], _pos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_location select 2, _location select 2];
        switch (_location select 1) do {
            case "patrol":          { _m setMarkerColor "ColorRed";};
            case "antiair":         { _m setMarkerColor "ColorBlue";};
            case "roadblock":       { _m setMarkerColor "ColorGreen";};
            case "roadpop":         { _m setMarkerColor "ColorYellow";};
            case "military":        { _m setMarkerColor "ColorPink";};
        };
        _m setMarkerBrush "Solid";
        _m setMarkerAlpha 0.7;
    };
};

// Start searching for players
if (dep_debug) then {
    diag_log "Done creating...";
};
dep_num_loc = (count dep_locations);
diag_log format ["DEP ready with %1 locations", dep_num_loc];
while {true} do {
    waitUntil{!dep_spawning};
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
        _tooclose   = false;
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
            
            if (_enemies > 0) then {
                if ((_alive / _enemies) < 0.1) then {
                    // If number of enemies alive below 10% concider this location clear.
                    diag_log format ["Cleared location %1", _g];
                    _clear = true;
                    _location set [7, _clear];
                    dep_locations set [_g, _location];
                };
            } else {
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
            _units = playableUnits;
            if ((count _units) == 0) then { 
                _units = allUnits;
            };
            _closest = 999999;
            {
               if ((side _x) == West && isPlayer _x) then
               {
                    _speedok = true;
                    _heightok = true;
                    if (_type != "antiair") then {
                        // Check the speed and height of the player
                        if (((getPos _x) select 2) > dep_act_height) then { _heightok = false; };
                        if ((speed _x) > dep_act_speed) then { _speedok = false; };
                    };
                    
                    if ((_speedok && _heightok)) then {
                        _distance = (getPos _x) distance _pos;
                        if (_distance < _closest) then { _closest = _distance; };
                    };
               };
            } forEach _units;
            
            if (_type == "antiair") then {
                // Anti air locations have 3x greater activation distance
                if (_closest < (_radius + (dep_act_dist * 3))) then { _close = true; };
            } else {
                if (_closest < (_radius + dep_act_dist)) then { _close = true; };
            };

            // Don't activate when players are too close
            if (_closest < (2 * _radius) && _type != "vehicle_patrol") then { _tooclose = true; };
        };
        
        if (_close && !_clear) then {
            // Players are close and location not clear, should enemies be spawned?
            if (!_active && dep_total_ai < dep_max_ai_tot && !_tooclose) then {
                // Location is not cleared and not active => spawn units
                if (_type == "antiair") then {
                    _handle = _g call dep_fnc_activate_aacamp;
                } else {
                    _handle = _g call dep_fnc_activate;
                };
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
                    _handle = _g call dep_fnc_deactivate;
                };
            };
        };
        sleep 0.02;
    };
    
    _fps = diag_fps;
    if (dep_debug) then {
        _west = 0;
        _east = 0;
        _resi = 0;
        {
            if (side _x == east) then { _east = _east + 1; };
            if (side _x == west) then { _west = _west + 1; };
            if (side _x == resistance) then { _resi = _resi + 1; };
        } forEach allUnits;
        
        //systemChat format ["west: %1 east: %2 resistance: %3 FPS: %4", _west, _east, _resi, _fps];
    };
    if (_fps > 45) then {
        sleep 1;
    } else {
        if (_fps > 40) then {
            sleep 4;
        } else {
            sleep 8;
        };
    };
};