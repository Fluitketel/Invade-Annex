// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds the closest enterable houses.
private ["_pos", "_validhouses"];
_pos = _this select 0;
_validhouses = [_pos, 4] call dep_fnc_enterablehouses;
if ((count _validhouses) == 0) then { _validhouses = [_pos, 10] call dep_fnc_enterablehouses; };
if ((count _validhouses) == 0) then { _validhouses = [_pos, 20] call dep_fnc_enterablehouses; };
if ((count _validhouses) == 0) then { _validhouses = [_pos, 30] call dep_fnc_enterablehouses; };
if ((count _validhouses) == 0) then { _validhouses = [_pos, 100] call dep_fnc_enterablehouses; };
_validhouses;