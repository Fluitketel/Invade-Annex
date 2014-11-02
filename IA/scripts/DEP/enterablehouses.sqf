// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds enterable houses in a given area.
private ["_houses", "_pos", "_size", "_house", "_maxbuildingpos"];
_pos = _this select 0;
_size = _this select 1;

_pos set [2, 0];

_validhouses = [];
_houses = nearestObjects [_pos, ["House"], _size];
{	
    _enterable = [_x] call dep_fnc_isenterable;
    if (_enterable) then { 
        _validhouses = _validhouses + [_x]; 
    };    
} foreach _houses;
_validhouses;