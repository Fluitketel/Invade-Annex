private ["_arraystocleanup"];
_arraystocleanup = _this select 0;
{
	if (!isNil ("_x")) then 
    {
        [_x] spawn dR_fnc_deleteOldAOUnits;
    };
	
} forEach _arraystocleanup;


