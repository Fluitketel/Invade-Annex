// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file disables an IED.

private ["_ied","_wire","_wrongwire","_unit","_params"];
_ied = _this select 0;
_unit = _this select 1;
_params = _this select 3;

_wire = _params select 0;
_wrongwire = round random 2;

_ied setVariable ["workingon",true,true];
_unit playMove "AinvPknlMstpSlayWrflDnon_medic";
sleep 6;

if (_wire == _wrongwire) then {
    systemChat "Wrong wire!";
    sleep 5;
    _boomtype = ["Bomb_03_F", "Bomb_04_F", "Bo_GBU12_LGB"] select round random 2;
    _boomtype createVehicle (position _ied);
    deleteVehicle _ied;
} else {
    _ied setVariable ["IED",false,true];
    systemChat "IED disabled";
};