//--- bl1p
diag_log "=========== this is the Thermal check script =============";
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the Thermal.sqf I am not a true client";};
_layer = 85125; 


while {true} do 
{ 
	waituntil {currentVisionMode player == 2}; 
	if (currentVisionMode player == 2) then
		{ 
			_layer	cutText ["FLIR Mode Requires Maintenance. Please Turn off Thermals.","BLACK",0];
			waituntil {currentVisionMode player != 2};
			_layer cutText ["", "PLAIN"];
		};
		sleep 1; 
};  
