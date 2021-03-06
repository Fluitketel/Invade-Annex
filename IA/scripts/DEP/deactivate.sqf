// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file cleans up a location after it is deactivated.

private ["_location", "_waypoints"];
diag_log format ["Despawning location %1", _this];
_location = dep_locations select _this;

// If location is not clear, store all objects
if (!(_location select 7)) then {
    _loccache = [];
    _loccacheobjs = [];
    // Store all objects
    {
        _obj = _x;
        if (!isNull _obj) then {
            if (alive _obj) then {
                _loccacheitem = [];
                _loccacheitem set [0, position _obj];             // Position
                _loccacheitem set [1, direction _obj];            // Direction
                _loccacheitem set [2, typeOf _obj];               // Kind
                _loccacheitem set [3, damage _obj];               // Health
                _crew = [];
                {
                    _unit = _x;
                    _crewunit = [];
                    if (alive _unit) then {
                        _crewunit set [0, typeOf _unit];
                        _crewunit set [1, assignedVehicleRole _unit];
                    };
                    _crew = _crew + [_crewunit];
                } foreach (crew _x);
                _loccacheitem set [4, _crew];                 // Optional crew
                _loccacheobjs = _loccacheobjs + [_loccacheitem];
            };            
        };
    } foreach (_location select 8);
    _loccache set [0, _loccacheobjs];
    
    // Store all groups
    _loccachegrps = [];
    {
        _loccachegrp = [];
        _group = _x;
        _waypoints = [_group] call dep_fnc_getwaypoints;
        {
            if (alive _x && vehicle _x == _x) then {
                _loccacheitem = [];
                _loccacheitem set [0, position _x];             // Position
                _loccacheitem set [1, direction _x];            // Direction
                _loccacheitem set [2, typeOf _x];               // Kind
                _loccacheitem set [3, damage _x];               // Health
                _loccacheitem set [4, []];                      // Crew
                _loccacheitem set [5, _waypoints];              // Waypoints
                _loccachegrp = _loccachegrp + [_loccacheitem];
            };
        } foreach (units _group); // foreach unit in group
        if ((count _loccachegrp) > 0) then { _loccachegrps = _loccachegrps + [_loccachegrp]; };
    } foreach (_location select 4); // foreach group
    _loccache set [1, _loccachegrps];
    
    dep_loc_cache set [_this , _loccache];
} else {
    dep_loc_cache set [_this , []];
};

{
    {
        if (!isNull _x) then { 
            deleteVehicle _x; 
        };
    } forEach (units _x);
    if ((count units _x) == 0) then {
        deleteGroup _x;
    };
} foreach (_location select 4);

if (!(_location select 7)) then {
    // Clear all objects if location is not clear
    {
        if (!isNull _x) then {
            if (_x isKindOf "Tank" || _x isKindOf "Car") then {
                dep_total_veh = dep_total_veh - 1;
            };
            deleteVehicle _x; 
        };
    } foreach (_location select 8);
};

_location set [3, false];
_location set [4, []];
_location set [6, 0];
_location set [8, []];
dep_locations set [_this, _location];
true;