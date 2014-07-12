// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file cleans up a location after it is deactivated.

private ["_location"];
diag_log format ["Despawning location %1", _this];
_location = dep_locations select _this;

// If location is not clear, store all objects
/*if (!(_location select 7)) then {
    _loccache = [];
    _loccacheobjs = [];
    // Store all objects
    {
        if (!isNull _x) then {
            _loccacheitem = [];
            _loccacheitem set [0, position _x];             // Position
            _loccacheitem set [1, direction _x];            // Direction
            _loccacheitem set [2, typeOf _x];               // Kind
            _loccacheitem set [3, damage _x];               // Health
            _loccacheitem set [4, objNull];                 // Vehicle
            _loccacheitem set [5, []];                      // Role in vehicle
            _loccacheobjs = _loccacheobjs + [_loccacheitem]; 
        };
    } foreach (_location select 8);
    _loccache set [0, _loccacheobjs];
    
    // Store all groups
    _loccachegrps = [];
    {
        _loccachegrp = [];
        _group = _x;
        {
            if (alive _x) then {
                _loccacheitem = [];
                _loccacheitem set [0, position _x];             // Position
                _loccacheitem set [1, direction _x];            // Direction
                _loccacheitem set [2, typeOf _x];               // Kind
                _loccacheitem set [3, damage _x];               // Health
                _loccacheitem set [4, assignedVehicle _x];      // Vehicle
                _loccacheitem set [5, assignedVehicleRole _x];  // Role in vehicle
                _loccachegrp = _loccachegrp + [_loccacheitem];
            };
        } foreach (units _group);
        _loccachegrps = _loccachegrps + [_loccachegrp];
    } foreach (_location select 4);
    _loccache set [1, _loccachegrps];
    
    dep_loc_cache set [_this , _loccache];
} else {
    dep_loc_cache set [_this , []];
};*/

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