//--- bl1p
diag_log "=========== this is the Thermal check script =============";
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the crew.sqf I am not a true client";};
_layer = 85125; 


while {true} do 
{ 
	if (currentVisionMode player == 2) then
		{ 
		  	//hint "Thermals are active";
			_layer	cutText ["FLIR Mode Requires Maintenance. Please Turn off Thermals.","BLACK",0];
			waituntil {currentVisionMode player != 2};
			//player VisionMode = 1; //nope
			//true setCamUseTi 0;  //nope
			_layer cutText ["", "PLAIN"];
		};
		sleep 1; 
};  
