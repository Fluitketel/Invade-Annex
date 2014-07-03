// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file should be executed on every client.

// Read settings
_handle = [] execVM "DEP\DEP_settings.sqf";
waitUntil {scriptDone _handle};

private ["_name","_location"];
waitUntil {!isNil "dep_locations"};

diag_log format ["Client checking %1 locations", count dep_locations];
systemChat "Dynamic Enemy Population initialized!";

_name = name player;
while {true} do {
    for "_g" from 0 to ((count dep_locations) - 1) do {
        if (((getPos player) select 2) > 80) exitWith {}; // Player is too high
        
        if ((speed player) > 120) exitWith {}; // Player is going too fast
    
        _location = dep_locations select _g;
        if !(_location select 6) then { // If location is not clear
            if (player distance (_location select 0) <= (800 + dep_size)) then {
                if !(player in (_location select 1)) then {
                    // Add to in range players
                    diag_log format ["Player %1 is entering location %2!", _name, _g];
                    _location set [1, (_location select 1) + [player]];
                    dep_locations set [_g, _location];
                    publicVariable "dep_locations";
                };
            } else {
                if (player in (_location select 1)) then {
                    // Remove from in range players
                    diag_log format ["Player %1 is leaving location %2!", _name, _g];
                    _location set [1, (_location select 1) - [player]];
                    dep_locations set [_g, _location];
                    publicVariable "dep_locations";
                };
            };
        };
        sleep 0.02;
    };
    sleep 5;
};