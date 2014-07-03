// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file spawns units at a given location.

private ["_pos","_houses","_house","_maxbuildingpos","_validhouses","_size","_buildpos","_enemyamount","_groups","_location","_num_houses","_num_buildpos","_totalenemies","_depgroup"];

if (dep_active_locations >= dep_max_loc) exitWith {diag_log format ["Could not spawn location %1. Limit %2 reached.", _this, dep_max_loc];};

diag_log format ["Spawning location %1", _this];
_location = dep_locations select _this;
_pos = _location select 0;
_size = 250;
_validhouses = [];
_groups = [];
_totalenemies = 0;
_NME_pool = ["I_G_Soldier_F","I_G_Soldier_GL_F","I_G_Soldier_AR_F","I_G_Soldier_LAT_F","I_G_medic_F","I_Soldier_AA_F","I_G_Soldier_SL_F","I_G_Soldier_M_F"];

_houses = nearestObjects [_pos, ["House"], (_size / 1.5)];
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
    _buildpos = _house call BuildingPositions;
    _num_buildpos = (count _buildpos);
    _enemyamount = ceil (random _num_buildpos);
    if (_enemyamount < (_num_buildpos / 2)) then { _enemyamount = ceil(_num_buildpos / 2); };
    
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _totalenemies = _totalenemies + _enemyamount;
    
    for "_e" from 1 to _enemyamount do {
        _newbuildpos = _buildpos call BIS_fnc_selectRandom;
        _buildpos = _buildpos - [_newbuildpos];					
        _soldiername = _NME_pool call BIS_fnc_selectRandom;
        _spawnhandle = [_depgroup, _soldiername, _newbuildpos] spawn {
            _soldier = (_this select 0) createUnit [(_this select 1), (_this select 2), [], 0, "NONE"];
            _soldier removeEventHandler ["killed", 0];
            _soldier addEventHandler ["killed", {(_this select 0) execVM "DEP\DEP_cleanup.sqf"}];
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
    sleep 2;
};
diag_log format ["%2 enemies created at location %1", _this, _totalenemies];
_location = dep_locations select _this;
_location set [3, _groups];
_location set [5, _totalenemies];
dep_locations set [_this, _location];
dep_active_locations = dep_active_locations + 1;
publicVariable "dep_locations"; 
true;