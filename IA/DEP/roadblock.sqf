dep_fnc_roadblock = {
    private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_gate", "_groups", "_totalenemies", "_objects"];
    _pos    = _this select 0; // roadblock position
    _dir    = _this select 1; // roadblock direction
    
    _groups = [];
    _totalenemies = 0;
    _objects = [];
    
    _campgroup = createGroup dep_side;
    _groups = _groups + [_campgroup];
    _campgroup setFormDir _dir;

    _gate = "Land_BarGate_F" createVehicle _pos;
    waitUntil {alive _gate};
    _gate setDir _dir;
    _objects = _objects + [_gate];

    _newpos = [_gate, 6, _dir] call BIS_fnc_relPos;
    _newpos = [_newpos, 11, _dir - 90] call BIS_fnc_relPos;
    _prop = "Land_Sign_WarningMilitaryArea_F" createVehicle _newpos;
    _prop setDir _dir + 180;
    _objects = _objects + [_prop];

    _newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
    _newpos = [_newpos, 11, _dir - 90] call BIS_fnc_relPos;
    _prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];
    _newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
    _newpos = [_newpos, 16, _dir - 90] call BIS_fnc_relPos;
    _prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];
    _newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
    _newpos = [_newpos, 3, _dir + 90] call BIS_fnc_relPos;
    _prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];
    _newpos = [_gate, 7, _dir] call BIS_fnc_relPos;
    _newpos = [_newpos, 7, _dir + 90] call BIS_fnc_relPos;
    _prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];

    _newpos = [_gate, 9, _dir + 180] call BIS_fnc_relPos;
    _newpos = [_newpos, 4, _dir + 90] call BIS_fnc_relPos;
    _prop = "Land_Razorwire_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];
    _newpos = [_gate, 9, _dir + 180] call BIS_fnc_relPos;
    _newpos = [_newpos, 13, _dir - 90] call BIS_fnc_relPos;
    _prop = "Land_Razorwire_F" createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];

    _newpos = [_gate, 4, _dir + 180] call BIS_fnc_relPos;
    _newpos = [_newpos, 5, _dir + 90] call BIS_fnc_relPos;
    _prop = (["Flag_CSAT_F","Land_TTowerSmall_1_F","Land_FieldToilet_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];

    _newpos = [_gate, 14, _dir - 90] call BIS_fnc_relPos;
    if (random 1 > 0.5) then {
        _prop = "Land_BagBunker_Small_F" createVehicle _newpos;
        _prop setDir (_dir + 180);
    } else {
        _prop = "Land_Cargo_House_V3_F" createVehicle _newpos;
        _prop setDir (_dir - 90);
    };
    _objects = _objects + [_prop];

    _prop = (["Box_East_Ammo_F", "Box_East_AmmoOrd_F", "Box_East_Grenades_F", "Box_East_Ammo_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
    _prop setDir _dir;
    _objects = _objects + [_prop];
    sleep 0.5;

    _campgun1group = createGroup dep_side;
    _groups = _groups + [_campgun1group];
    _campgun1group setFormDir _dir;
    _newpos = [_gate, 6, _dir + 90] call BIS_fnc_relPos;
    _gun1 = objNull;
    if (random 1 < 0.3) then {
        _gun1 = "O_GMG_01_high_F" createVehicle _newpos;
    } else {
        _gun1 = "O_HMG_01_high_F" createVehicle _newpos;
    };
    waitUntil {alive _gun1};
    _objects = _objects + [_gun1];
    _gun1 setDir _dir;
    _newpos = [_newpos, 1, (_dir + 180)] call BIS_fnc_relPos;
    _gunner1 = _campgun1group createUnit ["I_G_Soldier_F", _newpos, [], 0, "NONE"];
    waitUntil {alive _gunner1};
    _gunner1 assignAsGunner _gun1;
    _gunner1 moveInGunner _gun1;
    _gunner1 setDir _dir;
    _totalenemies = _totalenemies + 1;

    sleep 1;
    _newpos = [_gate, 4, _dir + 180] call BIS_fnc_relPos;
    _newpos = [_newpos, 4, _dir  - 90] call BIS_fnc_relPos;
    _soldier = _campgroup createUnit ["I_G_Soldier_SL_F", _newpos, [], 0, "NONE"];
    _totalenemies = _totalenemies + 1;
    doStop _soldier;
    for "_c" from 1 to (1 + round (random 1)) do
    {
        _newpos = [_newpos, round (random 6), random 360] call BIS_fnc_relPos;
        _soldier = _campgroup createUnit ["I_G_Soldier_LAT_F", _newpos, [], 0, "NONE"];
        _totalenemies = _totalenemies + 1;
        waitUntil {alive _soldier};
        doStop _soldier;
        
        _newpos = [_newpos, round (random 6), random 360] call BIS_fnc_relPos;
        _soldier = _campgroup createUnit ["I_G_Soldier_GL_F", _newpos, [], 0, "NONE"];
        _totalenemies = _totalenemies + 1;
        waitUntil {alive _soldier};
        doStop _soldier;
    };
    [_totalenemies, _groups, _objects];
};