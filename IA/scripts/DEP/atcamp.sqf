// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file spawns an AT camp.

private ["_pos", "_dir", "_newpos", "_newdir", "_campgroup", "_prop", "_soldier", "_numberofbarriers","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir;
_groups = _groups + [_campgroup];

_prop = "CamoNet_INDP_open_F" createVehicle _pos;
_prop setDir (_dir + 180);

if (random 1 < 0.5) then {
    //_campgun1group = createGroup dep_side;
    //_campgun1group setFormDir _dir;
    //_groups = _groups + [_campgun1group];
    _gun1 = objNull;
    if (random 1 < 0.3) then {
        _gun1 = "I_HMG_01_high_F" createVehicle _pos;
    } else {
        _gun1 = "I_static_AT_F" createVehicle _pos;
    };
    waitUntil {alive _gun1};
    _gun1 setDir _dir;
    _objects = _objects + [_gun1];
    _newpos = [_pos, 1, (_dir + 180)] call BIS_fnc_relPos;
    _gunner1 = [_campgroup, dep_u_g_soldier, _newpos] call dep_fnc_createunit;
    _gunner1 assignAsGunner _gun1;
    _gunner1 moveInGunner _gun1;
    _gunner1 setDir _dir;
    _gunner1 removeEventHandler ["killed", 0];
    _gunner1 addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    _totalenemies = _totalenemies + 1;
};

_numberofbarriers = 10;
_newdir = 0;
for "_c" from 1 to _numberofbarriers do
{
    _newpos = [_pos, 9, _newdir] call BIS_fnc_relPos;
    _prop = "Land_CncBarrier_F" createVehicle _newpos;
    waitUntil {alive _prop};
    _prop setDir _newdir;
    _newdir = _newdir + (360 / _numberofbarriers);
};

_prop = (["Box_East_Ammo_F", "Box_East_AmmoOrd_F", "Box_East_Grenades_F", "Box_East_Ammo_F"] call BIS_fnc_selectRandom) createVehicle _pos;
_prop setDir _dir;

_soldier = [_campgroup, dep_u_g_sl, _pos] call dep_fnc_createunit;
doStop _soldier;
for "_c" from 1 to (1 + round (random 1)) do { 
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, dep_u_g_at, _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, ([dep_u_g_medic, dep_u_g_ar, dep_u_g_gl] call BIS_fnc_selectRandom), _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
};
[_totalenemies,_groups,_objects];