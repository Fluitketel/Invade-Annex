private ["_pos","_group","_list","_road","_wp"];
_pos = _this select 0;
_group = _this select 1;

_list = _pos nearRoads 1000;
for "_y" from 0 to 8 do {
    _road = _list call BIS_fnc_selectRandom;
    _list = _list - [_road];
    _wp = _group addWaypoint [(getPos _road), _y];
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
true;