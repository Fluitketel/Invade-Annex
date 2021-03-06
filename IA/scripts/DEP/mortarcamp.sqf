// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file spawns a mortar camp.

private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_center", "_amountofmortars","_totalenemies","_groups","_objects"];
_pos 				= _this select 0; // Camp position
_dir 				= _this select 1; // Camp direction
_amountofmortars 	= 1 + (round random 2);

_totalenemies = 0;
_groups = [];
_objects = [];

_center = "Box_East_AmmoVeh_F" createVehicle _pos;
_center setDir _dir;

_newpos = [_center, 8, _dir] call BIS_fnc_relPos;
_prop = (["Land_i_Stone_Shed_V1_F", "Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir _dir;

_newpos = [_prop, 3, (_dir + 270)] call BIS_fnc_relPos;
_prop = (["Land_FieldToilet_F", "Land_LampShabby_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir _dir;

_newpos = [_center, 7, (_dir + 45)] call BIS_fnc_relPos;
_prop = "Land_PowerGenerator_F" createVehicle _newpos;
_prop setDir (_dir + 110);

_prop = "Land_CanisterFuel_F" createVehicle _newpos;
_prop setDir _dir;

_wall = ["Land_Mound01_8m_F", "Land_HBarrier_5_F"] call BIS_fnc_selectRandom;
_newpos = [_center, 10, (_dir + 270)] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
_prop = _wall createVehicle _newpos;
_prop setDir (_dir + 270);

_newpos = [_center, 10, (_dir + 270)] call BIS_fnc_relPos;
_newpos = [_newpos, 2, (_dir + 180)] call BIS_fnc_relPos;
_prop = _wall createVehicle _newpos;
_prop setDir (_dir + 270);

_pallets = ["Land_Pallet_MilBoxes_F", "Land_PaperBox_open_full_F", "Land_Pallets_stack_F"];
_newpos = [_center, 7, (_dir + 180)] call BIS_fnc_relPos;
_prop = (_pallets call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir _dir;
_newpos = [_center, 7, (_dir + 150)] call BIS_fnc_relPos;
_prop = (_pallets call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir (_dir + 30);


_newpos = [_center, 10, (_dir + 200)] call BIS_fnc_relPos;
_prop = (["Land_Cargo20_military_green_F", "Land_Cargo20_grey_F", "Land_Cargo20_sand_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir (_dir + 15);

if ((round random 1) < 0.5) then {
    _mortardefgroup = createGroup dep_side;
    _groups = _groups + [_mortardefgroup];
    _mortardefgroup setFormDir _dir;
    _newpos = [_center, 10, (_dir + 45)] call BIS_fnc_relPos;
    _soldier = [_mortardefgroup, dep_u_g_sl, _newpos] call dep_fnc_createunit;
    _soldier = [_mortardefgroup, dep_u_g_at, _newpos] call dep_fnc_createunit;
    _soldier = [_mortardefgroup, dep_u_g_ar, _newpos] call dep_fnc_createunit;
    _soldier = [_mortardefgroup, dep_u_g_medic, _newpos] call dep_fnc_createunit;
    _soldier = [_mortardefgroup, dep_u_g_gl, _newpos] call dep_fnc_createunit;
    _totalenemies = _totalenemies + 5;
    [_mortardefgroup, 25] spawn dep_fnc_unitpatrol;
};

_mortargroup = createGroup dep_side;
_groups = _groups + [_mortargroup];
_mortargroup setFormDir _dir;
_newdir = _dir;
for "_c" from 1 to _amountofmortars do {
    _newdir = _newdir + (360 / _amountofmortars);
    _newpos = [_center, 1, _newdir] call BIS_fnc_relPos;
    _mortar = "I_G_Mortar_01_F" createVehicle _newpos;
    _objects = _objects + [_mortar];
    _mortar setDir _newdir;
    _mortar addEventHandler["Fired",{if (!isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 1; };}];
    _mortar addEventHandler["GetIn",{if (isPlayer (gunner _mortar)) then { _mortar setVehicleAmmo 0; };}];
    _soldier = [_mortargroup, dep_u_g_soldier, _pos] call dep_fnc_createunit;
    _totalenemies = _totalenemies + 1;
    _soldier assignAsGunner _mortar;
    _soldier moveInGunner _mortar;
};

[_totalenemies,_groups,_objects];