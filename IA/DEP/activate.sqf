// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file spawns units at a given location.

private ["_pos","_houses","_house","_maxbuildingpos","_validhouses","_size","_buildpos","_enemyamount","_groups","_location","_num_houses","_num_buildpos","_totalenemies","_depgroup"];

//if (dep_active_locations >= dep_max_loc) exitWith {diag_log format ["Could not spawn location %1. Limit %2 reached.", _this, dep_max_loc];};

diag_log format ["Spawning location %1", _this];
dep_spawning = true;
_location = dep_locations select _this;
_pos        = _location select 0;
_size       = _location select 2;
_objects    = _location select 8;

_validhouses = [];
_groups = [];
_totalenemies = 0;
_NME_pool = ["I_G_Soldier_F","I_G_Soldier_GL_F","I_G_Soldier_AR_F","I_G_Soldier_LAT_F","I_G_medic_F","I_Soldier_AA_F","I_G_Soldier_SL_F","I_G_Soldier_M_F"];
_VEH_pool = ["O_MRAP_02_hmg_F","O_MRAP_02_gmg_F","O_APC_Tracked_02_cannon_F"];
//_ARM_pool = ["O_APC_Tracked_02_cannon_F"];

if ((_location select 1) == "roadblock") then {
    _result = [_pos, _location select 9] call dep_fnc_roadblock;
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

_houses = nearestObjects [_pos, ["House"], _size];
{	
    _house = _x;
    _i = 0;
    while {count ((_house buildingPos _i)-[0]) > 0} do {_i = _i + 1;};
    _maxbuildingpos = _i - 1;
    if (_maxbuildingpos > 0) then { _validhouses = _validhouses + [_house]; };			
} foreach _houses;
_num_houses = (count _validhouses);
_groupsperlocation = (ceil (random _num_houses));
if (_groupsperlocation < (_num_houses / 2)) then { _groupsperlocation = ceil(_num_houses / 2); };

for "_c" from 1 to _groupsperlocation do {
    if (_totalenemies >= dep_max_ai_loc) exitWith { diag_log format ["Location %1 max enemies (%2) reached, stopping spawn.", _this, dep_max_ai_loc]; };
    
    _house = _validhouses call BIS_fnc_selectRandom;
    _validhouses = _validhouses - [_house];
    
    // Get positions in building
    _buildpos = _house call dep_fnc_buildingpositions;
    _num_buildpos = (count _buildpos);
    _enemyamount = ceil (random _num_buildpos);
    if (_enemyamount < (_num_buildpos / 2)) then { _enemyamount = ceil(_num_buildpos / 2); };
    if (_enemyamount > 8) then { _enemyamount = 8; };
    
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _totalenemies = _totalenemies + _enemyamount;
    
    for "_e" from 1 to _enemyamount do {
        _newbuildpos = _buildpos call BIS_fnc_selectRandom;
        _buildpos = _buildpos - [_newbuildpos];					
        _soldiername = _NME_pool call BIS_fnc_selectRandom;
        _spawnhandle = [_depgroup, _soldiername, _newbuildpos] spawn {
            _soldier = (_this select 0) createUnit [(_this select 1), (_this select 2), [], 0, "NONE"];
            waitUntil{alive _soldier};
            _soldier removeEventHandler ["killed", 0];
            _soldier addEventHandler ["killed", {(_this select 0) execVM "scripts\DEP\cleanup.sqf"}];
            _soldier setDir (random 360);
        };
        waitUntil {scriptDone _spawnhandle};
    };
    if ((random 1) <= 0.4 && _enemyamount > 1) then {
        // Make units patrol
        for "_y" from 0 to 8 do {
            _newpos = [(getPos _house), 10, (45 * _y)] call BIS_fnc_relPos;
			_wp = _depgroup addWaypoint [_newpos, _y];
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointFormation "COLUMN";
            _wp setWaypointTimeOut [0,5,10];
			if (_y < 8) then {
				_wp setWaypointType "MOVE";
			} else {
				_wp setWaypointType "CYCLE";
			};
		};
    } else {
        doStop (units _depgroup);
    };
    sleep 0.02;
};

// Spawn vehicle?
if ((random 1) <= 0.5) then {
    _vehamount = 1 + (round (random 1));
    for "_c" from 1 to _vehamount do {
        _list = _pos nearRoads 100;
        if (count _list > 0) then {
            _road = _list call BIS_fnc_selectRandom;
            _vehname = _VEH_pool call BIS_fnc_selectRandom;
            _veh = _vehname createVehicle (getPos _road);
            _objects = _objects + [_veh];
            
            _depgroup = createGroup dep_side;
            _groups = _groups + [_depgroup];
            _soldier = _depgroup createUnit ["I_G_Soldier_F", (getPos _road), [], 0, "NONE"];
            _soldier assignAsDriver _veh;
            _soldier moveInDriver _veh;
            _soldier = _depgroup createUnit ["I_G_Soldier_F", (getPos _road), [], 0, "NONE"];
            _soldier assignAsGunner _veh;
            _soldier moveInGunner _veh;
            if (_veh isKindOf "Tank") then {
                _soldier = _depgroup createUnit ["I_G_Soldier_SL_F", (getPos _road), [], 0, "NONE"];
                _soldier assignAsCommander _veh;
                _soldier moveInCommander _veh;
            };
            sleep 1;
            _list = _pos nearRoads (_size * 3);
            for "_y" from 0 to 8 do {
                _road = _list call BIS_fnc_selectRandom;
                _list = _list - [_road];
                _wp = _depgroup addWaypoint [(getPos _road), _y];
                _wp setWaypointBehaviour "SAFE";
                _wp setWaypointSpeed "LIMITED";
                _wp setWaypointFormation "COLUMN";
                _wp setWaypointTimeOut [0,5,10];
                if (_y < 8) then {
                    _wp setWaypointType "MOVE";
                } else {
                    _wp setWaypointType "CYCLE";
                };
            };
            _totalenemies = _totalenemies + 2;
        };
    };
};
diag_log format ["%2 enemies created at location %1", _this, _totalenemies];

_location set [3, true];
_location set [4, _groups];
_location set [6, _totalenemies];
_location set [8, _objects];
dep_locations set [_this, _location];
dep_spawning = false;