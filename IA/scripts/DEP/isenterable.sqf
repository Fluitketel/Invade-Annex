// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file checks if a house is enterable.

private ["_house", "_maxbuildingpos"];

_house = _this select 0;

_maxbuildingpos = 0;
while {count ((_house buildingPos _maxbuildingpos)-[0]) > 0} do {
    _maxbuildingpos = _maxbuildingpos + 1;
};

if (_maxbuildingpos > 0) then { 
    true; 
} else {
    false;
};