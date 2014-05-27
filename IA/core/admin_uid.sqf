// admin_uid.sqf
diag_log format ["friend = %1",(player getVariable "friend")];
 if (player getVariable "friend") then 
	{
	  player addAction ["<t color='#900000'>Debug spectate</t>", "spectator\specta.sqf"];
	};
	