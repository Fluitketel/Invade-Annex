/*
	File: fn_onTerrainChange.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Updates the players terraingrid when called.
*/
private["_type"];
_type = [_this,0,"",[""]] call BIS_fnc_param;
if(_type == "") exitWith {};
	
switch (_type) do
{
	case "none": {if(isNil "tawvd_disablenone") then {setTerrainGrid 6;};};
	case "low": {setTerrainGrid 5;};
	case "norm": {setTerrainGrid 4;};
	case "high": {setTerrainGrid 3.125;};
};