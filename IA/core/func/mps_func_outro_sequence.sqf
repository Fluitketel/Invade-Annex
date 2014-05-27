// Written by BON_IF
// Adpated by EightySix
// Stolen by BL1P

if (DEBUG) then 
	{
	Diag_log "I am in the MPS_FUNC_OUTRO_sequence.SQF";
	};

if(isDedicated) exitWith{diag_log "I was kicked from MPS_FUNC_OUTRO_CAMERA.SQF";};

private["_count","_titles","_time"];

[] spawn 
	{
		waitUntil {!isNil "mps_mission_finished"};

		109 cutText ["====...MUSIC TIME !!!...====","BLACK OUT",1];
		_playersNumber = {isPlayer _x} count allUnits;
		_time = 4*_playersnumber;
		playsound "MOVIN";
		if (daytime > 19.75 || daytime < 4.15) then {camUseNVG true};
		sleep 5;
		109 cutText["","BLACK IN",2];
				[player,_time] spawn mps_outro_camera;
		sleep (_time);
		110 cutText ["BL1P, Fluit and Flipped Thank YOU for playing..","BLACK OUT",34];
		sleep 60;
	};