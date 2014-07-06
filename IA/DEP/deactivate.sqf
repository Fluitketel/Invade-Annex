// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file cleans up a location after it is deactivated.

private ["_location"];
diag_log format ["Despawning location %1", _this];
_location = dep_locations select _this;

{
    {
        if (!isNull _x) then { 
            deleteVehicle _x; 
        };
    } forEach (units _x);
    if ((count units _x) == 0) then {
        deleteGroup _x;
    };
} foreach (_location select 4);

{
    if (!isNull _x) then { 
        deleteVehicle _x; 
    };
} foreach (_location select 8);

_location set [3, false];
_location set [4, []];
_location set [6, 0];
_location set [8, []];
dep_locations set [_this, _location];