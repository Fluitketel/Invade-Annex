if(isDedicated) exitWith {};
waitUntil {!isNull player && player == player};
[] execVM "taw_vd\functions.sqf";
tawvd_action = player addAction["<t color='#FFFFFF'>View Distance Settings</t>","taw_vd\open.sqf",[],-99,false,false,"",''];

if(isNil {tawvd_foot}) then 
{
	tawvd_foot = viewDistance;
	tawvd_car = viewDistance;
	tawvd_air = viewDistance;
};

[] spawn 
{
	private["_old","_recorded"];
	while {true} do
	{
		_recorded = vehicle player;
		if(!alive player) then
		{
			_old = player;
			_old removeAction tawvd_action;
			waitUntil {alive player};
			tawvd_action = player addAction["<t color='#FFFFFF'>View Distance Settings</t>","taw_vd\open.sqf",[],-99,false,false,"",''];
		};
		
		if((vehicle player) isKindOf "Man" && viewdistance != tawvd_foot) then
		{
			setViewDistance tawvd_foot;
		};
		
		if((vehicle player) isKindOf "LandVehicle" || (vehicle player) isKindOf "Ship" && viewdistance != tawvd_car) then
		{
			setViewDistance tawvd_car;
		};
		
		if((vehicle player) isKindOf "Air" && viewdistance != tawvd_air) then
		{
			setViewDistance tawvd_air;
		};
		waitUntil {_recorded != vehicle player || !alive player};
		sleep 1;
	};
};