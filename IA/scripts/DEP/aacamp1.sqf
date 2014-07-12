private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_housepos","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir;
_groups = _groups + [_campgroup];

_housepos = [_pos, 7, _dir - 90] call BIS_fnc_relPos;
_prop = "Land_Cargo_House_V3_F" createVehicle _housepos;
_prop setDir _dir - 90;
_objects = _objects + [_prop];

_newpos = [_pos, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 3, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir + 90;
_objects = _objects + [_prop];

_newpos = [_pos, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 3, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir + 90;
_objects = _objects + [_prop];

_barrels = ["Land_BarrelWater_grey_F", "Land_BarrelEmpty_grey_F", "Land_GarbageBarrel_01_F", "Land_BarrelTrash_grey_F"];
_newpos = [_housepos, 4, _dir + 200] call BIS_fnc_relPos;
_prop = (_barrels call BIS_fnc_selectRandom) createVehicle _newpos;
_prop setDir _dir;
_objects = _objects + [_prop];

_gun1 = "I_static_AA_F" createVehicle _pos;
waitUntil {alive _gun1};
_gun1 setDir _dir;
_objects = _objects + [_gun1];
_gunner1 = _campgroup createUnit ["I_G_Soldier_F", _pos, [], 0, "NONE"];
waitUntil {alive _gunner1};
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 removeEventHandler ["killed", 0];
_gunner1 addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
_totalenemies = _totalenemies + 1;

_soldier = _campgroup createUnit ["I_G_Soldier_SL_F", _housepos, [], 0, "NONE"];
_soldier removeEventHandler ["killed", 0];
_soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
_totalenemies = _totalenemies + 1;
doStop _soldier;
for "_c" from 1 to (1 + round (random 1)) do { 
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = _campgroup createUnit ["I_Soldier_AA_F", _newpos, [], 0, "NONE"];
    doStop _soldier;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    _totalenemies = _totalenemies + 1;
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = _campgroup createUnit ["I_Soldier_AAA_F", _newpos, [], 0, "NONE"];
    doStop _soldier;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    _totalenemies = _totalenemies + 1;
};
[_totalenemies,_groups,_objects];