squad_mgmt_action = player addAction [
		("<t color='#ff8000'>" + "Squad Management" + "</t>"), 
		Compile preprocessFileLineNumbers "DOM_squad\open_dialog.sqf", [], -80, false
	];

// Init functions
call Compile preprocessFileLineNumbers "DOM_squad\x_netinit.sqf";
if (!isDedicated) then {
	call Compile preprocessFileLineNumbers "DOM_squad\x_uifuncs.sqf";
	
	[] spawn 
{
private["_old","_recorded"];
	if(!alive player) then
		{
		_old = player;
		_old removeAction squad_mgmt_action;
		waitUntil {alive player};
		
	squad_mgmt_action = player addAction [
		("<t color='#0ff8000'>" + "Squad Management" + "</t>"), 
		Compile preprocessFileLineNumbers "DOM_squad\open_dialog.sqf", [], -80, false
	];
};
};

	private "_playerRespawn";
	_playerRespawn = player addEventHandler ["Respawn", {_this Call Compile preprocessFileLineNumbers "DOM_squad\onPlayerRespawn.sqf";}]; 
	
};
