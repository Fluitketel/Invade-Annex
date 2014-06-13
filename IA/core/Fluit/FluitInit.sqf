/***************************************************************
                 FLUIT IS BEING INITIALIZED
 **************************************************************/
diag_log "Fluit is initializing...";
 
// Initialze common functions
_scriptHandle = [] execVM "core\Fluit\FluitFunctions.sqf"; 
waitUntil {scriptDone _scriptHandle};

// Initialze camp functions
_scriptHandle = [] execVM "core\Fluit\Camps\FluitCampsInit.sqf"; 
waitUntil {scriptDone _scriptHandle};

fluitfunctions = true; publicVariable "fluitfunctions"; // waitUntil {!isNil "fluitfunctions"}; to check if functions are loaded

diag_log "Fluit is successfully initialized!";
/***************************************************************
                 FLUIT SUCCESSFULLY INITIALIZED
 **************************************************************/