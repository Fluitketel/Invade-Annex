private ["_arraystocleanup"];
_arraystocleanup = _this select 0;
{
	if (!isNil ("_x")) then 
    {
        [_x] spawn AW_fnc_deleteOldAOUnits;
    };
	
} forEach _arraystocleanup;


