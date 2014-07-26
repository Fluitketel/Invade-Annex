// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file tells a group to patrol around the nearest house.
private ["_pos","_group","_validhouses","_wp","_grouppos"];
_group  = _this select 0;
_pos    = getPos (leader _group);

_validhouses = [_pos] call dep_fnc_findnearhouses;

_grouppos = _pos;
if ((count _validhouses) > 0) then { 
    _house = _validhouses call BIS_fnc_selectRandom;
    _grouppos = getPos _house;
};

for "_y" from 0 to 8 do {
    _newpos = [_grouppos, 10, (45 * _y)] call BIS_fnc_relPos;
    _wp = _group addWaypoint [_newpos, _y];
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointFormation "COLUMN";
    _wp setWaypointTimeOut [0,5,10];
    if (_y < 8) then {
        _wp setWaypointType "MOVE";
    } else {
        _wp setWaypointType "CYCLE";
    };
};