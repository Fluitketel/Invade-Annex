// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file restores a previously activated location.

private ["_loccache","_objects","_groups","_grp","_obj","_pos","_unit","_waypoints"];

_loccache = dep_loc_cache select _this;
if ((count _loccache) == 0) exitWith { false; };

dep_spawning = true;
diag_log format ["Restoring location %1", _this];

_location = dep_locations select _this;
_locpos = _location select 0;

_objects = _loccache select 0;
_groups = _loccache select 1;

_totalgroups = [];
_totalenemies = 0;
_totalobjects = [];

{
    _pos = _x select 0;
    _obj = objNull;
    switch (_x select 2) do {
        case "ATMine": {
            _obj = createMine ["ATMine", _pos, [], 0];
            dep_side revealMine _obj;
        };
        default {
            if (_pos distance _locpos > (_location select 2)) then {
                // Prevent objects from spawning outside the location
                _list = _locpos nearRoads (_location select 2);
                _road = _list call BIS_fnc_selectRandom;
                _pos = (getPos _road);
            };
            _obj = (_x select 2) createVehicle _pos;
        };
    };
    _totalobjects = _totalobjects + [_obj];
    _obj setDir (_x select 1);
    _obj setDamage (_x select 3);
    
    if ((count (_x select 4)) > 0) then {
        _grp = createGroup dep_side;
        _totalgroups = _totalgroups + [_grp];
        {
            _unit = _grp createUnit [(_x select 0), _pos, [], 0, "NONE"];
            _totalenemies = _totalenemies + 1;
            _roles = _x select 1;
            if ((count _roles) > 0) then {
                _role = _roles select 0;
                switch (_role) do {
                    case "Driver": {
                        _unit assignAsDriver _obj;
                        _unit moveInDriver _obj;
                    };
                    case "Turret": {
                        _unit assignAsGunner _obj;
                        _unit moveInGunner _obj;
                    };
                    case "Cargo": {
                        _unit assignAsCargo _obj;
                        _unit moveInCargo _obj;
                    };
                    default {
                        _unit assignAsCommander _obj;
                        _unit moveInCommander _obj;
                    };
                };
            };
            _unit removeEventHandler ["killed", 0];
            _unit addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
            
        } foreach (_x select 4); // respawn crew
        _return = [_locpos, _grp] call dep_fnc_vehiclepatrol;
    };
} foreach _objects;

{
    _grp = createGroup dep_side;
    _totalgroups = _totalgroups + [_grp];
    _group = _x;
    {
        _obj = _grp createUnit [(_x select 2), (_x select 0), [], 0, "NONE"];
        _totalenemies = _totalenemies + 1;
        _obj setDir (_x select 1);
        _obj setDamage (_x select 3);
        _obj removeEventHandler ["killed", 0];
        _obj addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    } foreach _group;
    if ((_location select 1) in ["roadpop"]) then {
        if ((random 1) <= 0.5) then {
            [_grp] spawn dep_fnc_housepatrol;
        } else {
            [_grp] spawn dep_fnc_garrison;
        };
    } else {
        _unit = _group select 0;
        if (count _unit > 5) then {
            _waypoints = _unit select 5;
            if (count _waypoints > 0) then {
                [_grp, _waypoints] spawn dep_fnc_setwaypoints;              
            };
        };
    };
} foreach _groups;

_location set [3, true];
_location set [4, _totalgroups];
_location set [6, _totalenemies];
_location set [8, _totalobjects];
dep_locations set [_this, _location];
dep_spawning = false;

true;