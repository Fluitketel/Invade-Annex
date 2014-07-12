private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_ammo","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir + 180;
_groups = _groups + [_campgroup];

_ammo = "Box_East_WpsLaunch_F" createVehicle _pos;
_ammo setDir _dir;
_objects = _objects + [_ammo];

_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
_prop setDir _dir + 90;
_objects = _objects + [_prop];

_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
_prop setDir _dir + 90;
_objects = _objects + [_prop];

_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
_prop setDir _dir - 90;
_objects = _objects + [_prop];

_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_HBarrierWall6_F" createVehicle _newpos;
_prop setDir _dir - 90;
_objects = _objects + [_prop];

_newpos = [_ammo, 10, _dir] call BIS_fnc_relPos;
_tower = "Land_HBarrierTower_F" createVehicle _newpos;
_tower setDir _dir + 180;
_objects = _objects + [_tower];

_newpos = [_ammo, 5, _dir + 180] call BIS_fnc_relPos;
_gun1 = "O_static_AA_F" createVehicle _newpos;
waitUntil {alive _gun1};
_gun1 setDir _dir + 180;
_objects = _objects + [_gun1];
_newpos = [_newpos, 1, _dir] call BIS_fnc_relPos;
_gunner1 = _campgroup createUnit ["I_G_Soldier_F", _newpos, [], 0, "NONE"];
waitUntil {alive _gunner1};
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 removeEventHandler ["killed", 0];
_gunner1 addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
_totalenemies = _totalenemies + 1;

_newpos = [_ammo, 11, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
_prop setDir _dir;
_objects = _objects + [_prop];

_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir - 90] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_F" createVehicle _newpos;
_prop setDir _dir + 30;
_objects = _objects + [_prop];

_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 90] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_F" createVehicle _newpos;
_prop setDir _dir - 30;
_objects = _objects + [_prop];

_soldier = _campgroup createUnit ["I_G_Soldier_SL_F", getPos _tower, [], 0, "NONE"];
doStop _soldier;
_soldier removeEventHandler ["killed", 0];
_soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
_totalenemies = _totalenemies + 1;
for "_c" from 1 to (1 + round (random 1)) do
{ 
    _newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
    _soldier = _campgroup createUnit ["I_Soldier_AA_F", _newpos, [], 0, "NONE"];
    doStop _soldier;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    _totalenemies = _totalenemies + 1;
    
    _newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
    _soldier = _campgroup createUnit ["I_Soldier_AAA_F", _newpos, [], 0, "NONE"];
    doStop _soldier;
    _soldier removeEventHandler ["killed", 0];
    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1cleanup.sqf", dep_directory]}];
    _totalenemies = _totalenemies + 1;
};
[_totalenemies,_groups,_objects];