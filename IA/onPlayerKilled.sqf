//--- bl1p on player killed auto ran by engine on players death
//--- Remove 2 points when player killed
	addToScore = [player, -2]; publicVariable "addToScore";

if (DEBUG) then 
	{
		diag_log format ["Player Score from on player respawn = %1",score player];
	};
	
	TotalRespawns = TotalRespawns + 1;publicVariable "TotalRespawns";