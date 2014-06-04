//--- BL1P THIS SCRIPT IS AUTO RAN BY BIS ON PlAYER RESPAWN
	if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the onPlayerrespawn.sqf I am not a true client";};
    
	_unit = _this select 0;
	_corpse = _this select 1;

//--- BL1P Reset player slot on join to counter the effects of diconnect while in revive bleedout.
	_unit setcaptive false; 
	_unit enableSimulation true; 
	_unit switchMove "";
	Uncon = false;publicvariable "Uncon";

//--- Fluit: Reset the number of times revived
	_unit setVariable ["revives", 0, true];

//--- BL1P stop acre when uncon
	if (acre_enabled) then 
	{
		_ret = [false] call acre_api_fnc_setSpectator;
	};

//--- BL1P remove corpses of players
	sleep 20;
	hideBody _corpse;
	sleep 5;
	deleteVehicle _corpse; 
	
