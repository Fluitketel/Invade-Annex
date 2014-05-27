private ["_canDeleteGroup","_group","_groups","_units"];
while {true} do
{
	sleep 1200;
	if (DEBUG) then {diag_log "========= Cleaning and deleting groups... ========";};
	
	//{
	//	deleteVehicle _x;
	//} forEach allDead;
	
	//if (DEBUG) then {diag_log "Dead bodies deleated...";};
	
	_groups = allGroups;

	for "_c" from 0 to ((count _groups) - 1) do
	{
		_canDeleteGroup = true;
		_group = (_groups select _c);
		if (!isNull _group) then
		{
			_units = (units _group);
			{
				if (alive _x) then { _canDeleteGroup = false; };
			} forEach _units;
		};
		if (_canDeleteGroup && !isNull _group) then { deleteGroup _group; };
	};
	
	if (DEBUG) then {diag_log "============== Empty Groups deleated... ============";};
};