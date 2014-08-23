bl1p_fnc_defend = 
{	
		private ["_defendMessages","_targetStartText","_TimeMessage","_dt2","_AttackAmount","_defend","_distance","_WarningHint","_randomPos","_inf_Patrol","_DEFENDSERVERUNITSCHECK","_PercentWave","_AttackResult","_arraystocleanup","_AttackResultHint","_waves","_waveRuns"];

			_defendMessages =
			[
				"OPFOR Forces incoming! Defend the BLUE target Area!"
			];

			_targetStartText = format
			[
				"<t align='center' size='2.2'>Defend Target</t><br/><t size='1.5' align='center' color='#0d4e8f'>%1</t><br/>____________________<br/>We got a problem. The enemy managed to call in land reinforcements. They are on the way to take back the last target. You need to defend it at all costs!<br/><br/>If the last man of BluFor dies in the BLUE target area OR leaves the BLUE target area the enemy have won.<br/><br/>Forces are expected to be there in a couple minutes, hurry up and dig in!<br/>____________________<br/>All orderable assets are locked down till we finish this Defend Mission",
				currentAO
			];

			GlobalHint = _targetStartText; publicVariable "GlobalHint"; hint parseText GlobalHint;
			showNotification = ["NewMainDefend", currentAO]; publicVariable "showNotification";

			publicVariable "refreshMarkers";
			publicVariable "currentAO";
			currentAOUp = true;
			publicVariable "currentAOUp";
			radioTowerAlive = false;
			publicVariable "radioTowerAlive";
			
			//--- bl1p lock assets
			UnlockAssets = false;
			publicvariable "UnlockAssets";
			
			sleep 1;
			{_x setMarkerPos (getMarkerPos currentAO);} forEach ["aoCircle_2","aoMarker_2"];
			"aoMarker_2" setMarkerText format["Defend %1",currentAO];
			"aoCircle_2" SetMarkerAlpha 1;
			"aoMarker_2" SetMarkerAlpha 1;

			sleep 10; // give ao complete hint some time to be read
			
			//Create AO detection trigger
			_dt2 = createTrigger ["EmptyDetector", getMarkerPos currentAO];
			_dt2 setTriggerArea [250, 250, 0, false];
			_dt2 setTriggerActivation ["WEST", "PRESENT", false];
			_dt2 setTriggerStatements ["this","",""];
			
			/////////wait !////////////
			waitUntil {sleep 5; count list _dt2 >= 1};
			
			_TimeMessage = format
				[
					"%1 Activated you have a few mins to prepare... Good Luck", currentAO
				];
			hqSideChat = _TimeMessage; publicVariable "hqSideChat"; [WEST,"HQ"] sideChat hqSideChat;
				if (DEBUG) then 
					{
					sleep 30;
					}
					else
					{
					sleep 150;
					};
				
			_AttackAmount = [];
			_defend = true;
			AttackReinforcementUnits = [];
			_distance = 1200;
			_waves = [1,2,3,4,5] call BIS_fnc_selectRandom; //--- random amount of waves
			_waveRuns = 1;
			ELAPSED_TIME  = 0;
			START_TIME = diag_tickTime;
			
			while {_defend} do
			{
				_x = 0;
				_AttackAmount = [3,4,5] call BIS_fnc_selectRandom; //--- random amount of squads per wave
				_distance = _distance - 100; //--- reduce distance each loop
					if (DEBUG) then
						{
							diag_log format ["_AttackAmount = %1",_AttackAmount];
						};
				sleep 0.5;
				
				//-- send incoming wave message
				_WarningHint = format
				[
					"<t align='center' size='2.2'>Defend Target</t><br/><t size='1.5' align='center'color='#0d4e8f'>%1</t><br/>____________________<br/>Enemy Spotted : %2meters from AO",currentAO,_distance
				];
				hqSideChat = _defendMessages call BIS_fnc_selectRandom; publicVariable "hqSideChat"; [WEST,"HQ"] sideChat hqSideChat;
				GlobalHint = _WarningHint; publicVariable "GlobalHint"; hint parseText GlobalHint;
				if (DEBUG) then
						{
						diag_log format ["===========_waveRuns = %1  _waves = %2==========",_waveRuns,_waves];
						};
				//--- create the waves
				for "_x" from 1 to _AttackAmount do 
				{
					
					//random radius pos from ao center
					_randomPos = [getMarkerPos currentAO, _distance] call dR_fnc_randomPosbl1p;
					
					if ((count _randomPos) == 3) then 
					{
					
						if (random 10 < 9) then 
						{
						_inf_Patrol = [_randomPos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad")] call BIS_fnc_spawnGroup;
							if(DEBUG) then
							{
							diag_log "====================================Wave infantry Attack forces created==============================";
							};
						}
						else
						{
							_roadpos = _randomPos;
							_list = _randomPos nearRoads 400;
							if (count _list > 0) then {
								_road = _list call BIS_fnc_selectRandom;
								_roadpos = getPos _road;
							};
							_inf_Patrol = createGroup east;
							_veh = [_roadpos,0,"O_APC_Wheeled_02_rcws_F",_inf_Patrol] call BIS_fnc_spawnVehicle;
							if(DEBUG) then
							{
							diag_log "====================================Wave Motorised Attack forces created==============================";
							};
						};
					
						//[_inf_Patrol, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
						//waituntil {sleep 1;alive (leader _inf_Patrol)};
						sleep 0.5;
						[_inf_Patrol, getMarkerPos currentAO,100] call dR_fnc_spawn2_randomPatrolBL1P;
						
						{
						  AttackReinforcementUnits set [count AttackReinforcementUnits, _x];
						  publicVariable "AttackReinforcementUnits";
						} forEach units _inf_Patrol;
						if(DEBUG) then
						{
						diag_log format ["Attack reinforcement count = %1",count AttackReinforcementUnits];
						};
						sleep 1;
					}
					else
					{
					 diag_log "DID NOT CREATE INF REINF FAILED ON RANDPOS";
					};
					sleep 1;
				};
				// CREATE AI End
					if (DEBUG) then
						{
						diag_log "BEFORE _DEFENDSERVERUNITSCHECK > _PercentWave";
						};
				//--- wait for wave to be almost killed
				_DEFENDSERVERUNITSCHECK = east countSide allunits;
				_PercentWave = _DEFENDSERVERUNITSCHECK / 2;
				if (DEBUG) then 
				{
				diag_log format ["_PercentWave = %1",_PercentWave];
				};
				if (_waveRuns >= _waves) then {_PercentWave = PARAMS_EnemyLeftThreshhold};
				while {_DEFENDSERVERUNITSCHECK > _PercentWave} do 
					{ 
						_DEFENDSERVERUNITSCHECK = east countSide allunits;
						if (DEBUG) then 
							{
							diag_log format ["_DEFENDSERVERUNITSCHECK = %1",_DEFENDSERVERUNITSCHECK];
							};
							
							ELAPSED_TIME = diag_tickTime - START_TIME;
							publicVariable "ELAPSED_TIME";
							if (DEBUG) then 
							{
							diag_log format ["ELAPSED_TIME = %1",ELAPSED_TIME];
							};
						if (ELAPSED_TIME >= 3600) exitwith {diag_log "====LEAVING DEFENCE WHILE LOOP because TIMER====";}; 
						if (count list _dt2 < 1) exitwith {diag_log "====LEAVING DEFENCE WHILE LOOP because No alive west in zone====";}; 
						sleep 5;
					};
					if (DEBUG) then
						{
						diag_log "AFTER _DEFENDSERVERUNITSCHECK > _PercentWave";
						};
						
					//--- clean the array ?---//
					[] spawn aw_cleanGroups;
					//--- end clean ---//
					
				//-- count wave runs
				_waveRuns = _waveRuns + 1;
				if (DEBUG) then
						{
						diag_log format ["_waveRuns = %1  _waves = %2",_waveRuns,_waves];
						};
						
				//-- set some default vars		
				AttackWon = false;
				ELAPSED = false; publicvariable "ELAPSED";
				
				//--- end checks
				if (count list _dt2 < 1) then {_defend = false ;AttackWon = false;};
				if ((ELAPSED_TIME >= 7200) && (count list _dt2 >= 1))  then {_defend = false ;AttackWon = true;ELAPSED = true; publicvariable "ELAPSED";};
				if ((_waveRuns > _waves) && (count list _dt2 >= 1)) then {_defend = false ;AttackWon = true;};
					if (DEBUG) then
						{
						diag_log format ["AttackWon = %1  _defend = %2",AttackWon,_defend];
						};
				sleep 2;
			};
			if (AttackWon) then 
			{
				_AttackResult = format
				[
					"Defended Target: %1! Welldone you held out!", currentAO
				];

				_AttackResultHint = format
				[
					
					"<t align='center' size='2.2'>Defended Target</t><br/><t size='1.5' align='center'color='#0d4e8f'>%1</t><br/>____________________<br/>Congratulations you held out!<br/>____________________<br/>Assets are Available",currentAO
				];
				if (ELAPSED) then 
					{
						_AttackResultHint = format
						[
							
							"<t align='center' size='2.2'>Defended Target</t><br/><t size='1.5' align='center'color='#0d4e8f'>%1</t><br/>____________________<br/>Enemy Forces have retreated.<br/>____________________<br/>Assets are Available",currentAO
						];
					};
					
				hqSideChat = _AttackResult; publicVariable "hqSideChat"; [WEST,"HQ"] sideChat hqSideChat;
				GlobalHint = _AttackResultHint; publicVariable "GlobalHint"; hint parseText GlobalHint;
				showNotification = ["CompletedMainDefended", currentAO]; publicVariable "showNotification";
				//--- bl1p unlock assets
				UnlockAssets = true;
				publicvariable "UnlockAssets";
			}
			else
			{
				_AttackResult = format
				[
					"Defend Target: %1 Failed!", currentAO
				];

				_AttackResultHint = format
				[
					
					"<t align='center' size='2.2'>Failed Target</t><br/><t size='1.5' align='center'color='#0d4e8f'>%1</t><br/>____________________<br/>You failed to hold out!<br/>____________________<br/>Assets are unavialble Until we clear another AO",currentAO
				];

				hqSideChat = _AttackResult; publicVariable "hqSideChat"; [WEST,"HQ"] sideChat hqSideChat;
				GlobalHint = _AttackResultHint; publicVariable "GlobalHint"; hint parseText GlobalHint;
				
				//--- bl1p unlock assets
				UnlockAssets = false;
				publicvariable "UnlockAssets";
			};
			_arraystocleanup = [];

			// clean up defend attack units
			if ((!isnil ("AttackReinforcementUnits")) && (count AttackReinforcementUnits > 0)) then {
			if (DEBUG) then
				{
					diag_log format ["AttackReinforcementUnits = %1",AttackReinforcementUnits];
				};
			_arraystocleanup set [count _arraystocleanup, AttackReinforcementUnits]; 
			};
			sleep 0.5;
			if (DEBUG) then
					{
					diag_log "===========DEFEND CLEAN UP================";
					diag_log format ["_arraystocleanup = %1",_arraystocleanup];
					diag_log format ["count of elements in _arraystocleanup = %1",count _arraystocleanup];
					};
		
				[_arraystocleanup] execVM "core\AOCleanup.sqf";
		
			//--- hide DEFEND MARKERS
			{_x setMarkerPos [0,0,0];} forEach ["aoCircle_2","aoMarker_2"];
			"aoCircle_2" SetMarkerAlpha 0;
			"aoMarker_2" SetMarkerAlpha 0;
			
			//Delete detection trigger
			deleteVehicle _dt2;
			sleep 1;
			
			//////////////////////////////////////////////////
			// --- END OF DEFEND MISSION
			//////////////////////////////////////////////////
			RunninngDefenceAO = false;
			publicvariable "RunninngDefenceAO";
};