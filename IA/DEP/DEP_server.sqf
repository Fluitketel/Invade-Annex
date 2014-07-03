// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file should be executed on the server only.

// Read settings
_handle = [] execVM "DEP\DEP_settings.sqf";
waitUntil {scriptDone _handle};

// Register the functions
dep_fnc_locations   = compile preprocessFile "DEP\DEP_locations.sqf";
dep_fnc_spawn       = compile preprocessFile "DEP\DEP_spawn.sqf";
dep_fnc_despawn     = compile preprocessFile "DEP\DEP_despawn.sqf";

private ["_location","_grp","_alive","_avoid"];
_handle = [] call dep_fnc_locations;

waitUntil {!isNil "dep_locations"};

dep_active_locations = 0;
diag_log format ["Server checking %1 locations", count dep_locations];

/*
Location array meaning:
0   location (x, y, z)
1   player activating the location (array of players)
2   active state (true/false)
3   enemy groups in location (array of groups)
4   time last check that location is active
5   total enemy amount
6   location cleared (true/false)
*/

while {true} do {
    for "_g" from 0 to ((count dep_locations) - 1) do {
        _location = dep_locations select _g;
        
        // Check if location should be marked as clear
        if ((_location select 2) && ((_location select 5) > 0) && !(_location select 6)) then {
            _alive = 0;
            {
                _grp = _x;
                {
                    if (alive _x) then { _alive = _alive + 1; };
                } foreach (units _grp);
            } foreach (_location select 3);
            //diag_log format ["Enemies in location %1: %2 of %3.", _g, _alive, (_location select 5)];
            if ((_alive / (_location select 5)) < 0.1) then {
                // If number of enemies alive below 10% concider this location clear.
                diag_log format ["Cleared location %1", _g];
                _location set [6, true];
                dep_locations set [_g, _location];
                publicVariable "dep_locations";
            };
        };
        
        if (count (_location select 1) > 0) then {
            _location set [4, time];
            dep_locations set [_g, _location];
            publicVariable "dep_locations";
            if (!(_location select 2) && !(_location select 6)) then {
                // Activate location
                diag_log format ["Activating location %1", _g];
                _location set [2, true];
                dep_locations set [_g, _location];
                publicVariable "dep_locations";
                _null = _g call dep_fnc_spawn;
            };
        } else {
            if (_location select 2) then {
                // Deactivate
                if ((time - (_location select 4)) > (60 * 2) ) then {
                    diag_log format ["Deactivating location %1", _g];
                    _null = _g call dep_fnc_despawn;
                    _location set [2, false];
                    dep_locations set [_g, _location];
                    publicVariable "dep_locations";
                };
            };
        };
        sleep 0.02;
    };
    sleep 2;
};