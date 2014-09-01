// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file returns the waypoints of a group.
private ["_group","_waypoints","_waypoint","_amount","_pos"];
_group  = _this select 0;

_wps = waypoints _group;
_amount = count _wps;

_waypoints = [];
for "_y" from 1 to _amount do {
    _i = _y - 1;
    _pos = waypointPosition [_group, _i];
    if ((_pos select 0) > 0 && (_pos select 1 > 0)) then {
        _waypoint = [];
        _waypoint set [0, waypointPosition  [_group, _i]];
        _waypoint set [1, waypointBehaviour [_group, _i]];
        _waypoint set [2, waypointSpeed     [_group, _i]];
        _waypoint set [3, waypointFormation [_group, _i]];
        _waypoint set [4, waypointTimeout   [_group, _i]];
        _waypoint set [5, waypointType      [_group, _i]];
        _waypoints = _waypoints + [_waypoint];
    };
};
_waypoints;