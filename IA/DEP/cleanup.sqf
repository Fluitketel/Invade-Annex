// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file deletes the enemy body after death.
private ["_unit"];
_unit = _this;
sleep 120;
hideBody _unit;
sleep 30;
deleteVehicle _unit;