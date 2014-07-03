// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file cleans up a location after it is deactivated.

private ["_groups","_marker","_location"];
diag_log format ["Despawning location %1", _this];
_location = dep_locations select _this;
_groups = _location select 3;

{
    {
        if (!isNull _x) then { 
            deleteVehicle _x; 
        };
    } forEach (units _x);
    if (count units _x == 0) then {
        deleteGroup _x;
    };
} foreach _groups;
_location set [3, []];
dep_locations set [_this, _location];
dep_active_locations = dep_active_locations - 1;
publicVariable "dep_locations";
true;