diag_log " * Fluit camps are initializing...";

_scriptHandle = [] execVM "core\Fluit\Camps\FluitSAM.sqf"; 
waitUntil {scriptDone _scriptHandle};
_scriptHandle = [] execVM "core\Fluit\Camps\FluitHMG.sqf"; 
waitUntil {scriptDone _scriptHandle};
_scriptHandle = [] execVM "core\Fluit\Camps\FluitAT.sqf"; 
waitUntil {scriptDone _scriptHandle};
_scriptHandle = [] execVM "core\Fluit\Camps\FluitAA.sqf"; 
waitUntil {scriptDone _scriptHandle};
_scriptHandle = [] execVM "core\Fluit\Camps\FluitMortar.sqf"; 
waitUntil {scriptDone _scriptHandle};
_scriptHandle = [] execVM "core\Fluit\Camps\FluitRoadblock.sqf"; 
waitUntil {scriptDone _scriptHandle};

diag_log " * Done initializing Fluit camps!";