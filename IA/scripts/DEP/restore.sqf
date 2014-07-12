private ["_loccache","_objects","_groups","_grp","_obj"];

_loccache = dep_loc_cache select _this;
if ((count _loccache) == 0) exitWith { false; };

_objects = _loccache select 0;
_groups = _loccache select 1;

{
    _obj = (_x select 2) createVehicle (_x select 0);
    _obj setDir (_x select 1);
    _obj setDamage (_x select 3);
} foreach _objects;

{
    _grp = createGroup dep_side;
    _obj = _grp createUnit [(_x select 5), (_x select 2), [], 0, "NONE"];
    _obj = (_x select 2) createVehicle (_x select 0);
    _obj setDir (_x select 1);
    _obj setDamage (_x select 3);
    _obj removeEventHandler ["killed", 0];
    _obj addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
} foreach _groups;