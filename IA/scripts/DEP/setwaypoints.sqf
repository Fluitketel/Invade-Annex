// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file sets the waypoints for a group.
private ["_group","_waypoints","_wp"];
_group  = _this select 0;
_waypoints  = _this select 1;

diag_log format ["restoring group %2 wps: %1", _waypoints, _group];
_y = 0;
{
    _wp = _group addWaypoint [(_x select 0), _y];
    _wp setWaypointBehaviour    (_x select 1);
    _wp setWaypointSpeed        (_x select 2);
    _wp setWaypointFormation    (_x select 3);
    _wp setWaypointTimeOut      (_x select 4);
    _wp setWaypointType         (_x select 5);

    _y = _y + 1;
} forEach _waypoints;