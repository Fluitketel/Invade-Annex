// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file creates a unit.

private ["_unit","_group","_pos","_type"];
_group  = _this select 0;
_type   = _this select 1;
_pos    = _this select 2;

_unit = _group createUnit [_type, _pos, [], 0, "NONE"];
waitUntil{alive _unit};

if (dep_unit_init != "") then {
    _unit spawn (compile dep_unit_init);
};

_unit;