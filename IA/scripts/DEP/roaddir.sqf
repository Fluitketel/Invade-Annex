// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds the direction of a road.
private ["_road","_roadsConnectedTo","_connectedRoad","_roaddir","_connected"];
_road = _this select 0;
_roadsConnectedTo = roadsConnectedTo _road;
_roaddir = 0;
_connected = count _roadsConnectedTo;
_connectedRoad = objNull;
if (_connected == 0) then {
    _roaddir = direction _road;
} else {
    if (_connected > 1) then {
        _connectedRoad = _roadsConnectedTo select (round(random (_connected - 1)));
    } else {
        _connectedRoad = _roadsConnectedTo select 0;
    };
    _roaddir = [_road, _connectedRoad] call BIS_fnc_DirTo;;
};
_roaddir;