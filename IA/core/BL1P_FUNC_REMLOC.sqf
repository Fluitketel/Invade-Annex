//--- notworking yet

BL1P_FUNC_REMLOC =
{
	private ["_Players", "_locAIs", "_remAIs","_AmountAlowedOnServer"];

	_Players = {(alive _x)&&(isPlayer _x)} count allUnits;
	sleep 0.2;
	_locAIs = {(alive _x)&&(local _x)} count allUnits;
	sleep 0.2;
	_remAIs = ({alive _x} count allUnits) - _Players - _locAIs;
	sleep 0.2;
	
	
	sleep 0.4;
	_Remloc = [_Players,_locAIs,_remAIs];
	_Remloc;
	diag_log format ["=========== _Remloc = %1 ============= ",_Remloc];
	//--- get the % allowed on server from total amount allowed
	_AmountAlowedOnServer = PARAMS_TOTALMAXAI / 10 * PARAMS_SERVERMAXAI;
		if (DEBUG) then
		{
			diag_log format ["_AmountAlowedOnServer = %1",_AmountAlowedOnServer];
		};
	//--- set on server variable true while lower than %	
	if (_locAIs < _AmountAlowedOnServer) then 
	{
	PlaceOnServer = true;publicVariable "PlaceOnServer";
	PlaceOnHeadless = false;publicVariable "PlaceOnHeadless";
		if (DEBUG) then
		{
			diag_log format ["_locAIs (%1) < _AmountAlowedOnServer (%2)",_locAIs,_AmountAlowedOnServer];
			diag_log format ["PlaceOnServer = %1 PlaceOnHeadless = %2",PlaceOnServer,PlaceOnHeadless];
		};
	};
	//--- set on server false set on headless true once server % equal or greater than the %
	if (_locAIs >= _AmountAlowedOnServer) then 
	{
	PlaceOnHeadless = true;publicVariable "PlaceOnHeadless";
	PlaceOnServer = false;publicVariable "PlaceOnServer";
		if (DEBUG) then
		{
			diag_log format ["_locAIs (%1) < _AmountAlowedOnServer (%2)",_locAIs,_AmountAlowedOnServer];
			diag_log format ["PlaceOnServer = %1 PlaceOnHeadless = %2",PlaceOnServer,PlaceOnHeadless];
		};
	};
	//-- when server AI and headless AI are equal or greater than the allowed max set both server and headless var to false
	if (_locAIs + _remAIs >= PARAMS_TOTALMAXAI) then 
	{
	PlaceOnServer = false;publicVariable "PlaceOnServer";
	PlaceOnHeadless = false;publicVariable "PlaceOnHeadless";
		if (DEBUG) then
		{
			diag_log format ["_locAIs (%1) + _remAIs (%2) >= PARAMS_TOTALMAXAI (%3)",_locAIs,_remAIs,PARAMS_TOTALMAXAI];
			diag_log format ["PlaceOnServer = %1 PlaceOnHeadless = %2",PlaceOnServer,PlaceOnHeadless];
		};
	};
};