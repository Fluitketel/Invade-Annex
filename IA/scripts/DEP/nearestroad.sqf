// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds the nearest road in a given radius.

_pos = _this select 0;
_radius = _this select 1;

_list = _pos nearRoads _radius;
_smallestdistance = _radius;
_road = objNull;
{
    _currentdistance = _pos distance _x;
    if (_currentdistance < _smallestdistance) then 
    {
        _smallestdistance = _currentdistance;
        _road = _x;
    };
} forEach _list;
_road;