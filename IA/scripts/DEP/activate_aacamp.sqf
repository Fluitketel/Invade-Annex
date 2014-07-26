// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file activates an anti-air camp.

private ["_location","_pos","_return"];

_cache = dep_loc_cache select _this;
if ((count _cache) > 0) exitWith {
    _result = _this call dep_fnc_restore;
    true;
};

dep_spawning = true;
_location = dep_locations select _this;
_pos = _location select 0;

_return = [];
if ((random 1) <= 0.5) then {
    _return = [_pos, random 360] call dep_fnc_aacamp1;
} else {
    _return = [_pos, random 360] call dep_fnc_aacamp2;
};
_location set [3, true];
_location set [4, (_return select 1)];
_location set [6, (_return select 0)];
_location set [8, (_return select 2)];
dep_locations set [_this, _location];
dep_spawning = false;
true;