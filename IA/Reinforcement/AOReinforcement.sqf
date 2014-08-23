//////////////////////////////////////////////
// LIGHT reinf script by BL1P and Fluit     //
//////////////////////////////////////////////


waitUntil {sleep 0.5; !(isNil "currentAOUp")};
waitUntil {sleep 0.5; !(isNil "currentAO")};
private ["_priorityMessageHelo", "_reinforcementsdead","_SERVERUNITSCHECKRE","_roadList","_road","_roadPos","_SERVERUNITSCHECKRE1","_SERVERUNITSCHECKREresistance"];

if (DEBUG) then {diag_log "===============Reading LIGHT reinforcements====================";};

Reinforced = false;
publicVariable "Reinforced";

ReinforcementUnits = [];
ReinforcementVehicles = [];

_SERVERUNITSCHECKRE = 0;

while {true} do 
{
	if(DEBUG) then
		{
			sleep (10 + (random 10));
		}
		else
		{
			sleep (180 + (random 120))
		};
		
		_randReinfChance = random 10;
		if(DEBUG) then
					{
						diag_log format ["_randReinfChance = %1 PARAMS_AOReinforcement = %2 (%1 <= %2 ?)",_randReinfChance,PARAMS_AOReinforcement];
					};
					
					
		if (radioTowerAlive && !Reinforced && spotted) then
			{
				_SERVERUNITSCHECKRE1 = east countSide allunits;
				_SERVERUNITSCHECKREresistance = resistance countSide allunits;
				_SERVERUNITSCHECKRE = (_SERVERUNITSCHECKRE1 + _SERVERUNITSCHECKREresistance);
				sleep 1;
				if(DEBUG) then
							{
								diag_log format ["_SERVERUNITSCHECKRE for TOTAL LIGHT reinforcements = %1",_SERVERUNITSCHECKRE];
							};
			};	
			
        if (radioTowerAlive && spotted  && (_SERVERUNITSCHECKRE < PARAMS_TOTALMAXAI) && (_randReinfChance <= PARAMS_AOReinforcement)) then //is tower alive and is spotted and server isnt over loaded
		{
			if !(Reinforced) then // is it already reinforced 
			{
				
					_randreinforce = random 10;
					//_randreinforce = 7; used to force a group
					if (_randreinforce <= 6) then //infantry
					{
						
						_x = 0;
						for "_x" from 1 to 3 do //create 3 groups
						{
							if(DEBUG) then
							{
							diag_log "====================================starting infantry reinforcmenets==============================";
							diag_log format ["Reinforce = %1",Reinforced];
							};
							//random radius pos from ao center
							_randomPos = [getMarkerPos currentAO, PARAMS_AOSize+750] call dR_fnc_randomPosbl1p;
							if ((count _randomPos) == 3) then 
							{
								_inf_Patrol = [_randomPos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad")] call BIS_fnc_spawnGroup;
							
								[_inf_Patrol, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x];
								  publicVariable "ReinforcementUnits";
								} forEach units _inf_Patrol;
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true;
								publicVariable "Reinforced";
								sleep 1;
							}
							else
							{
							 diag_log "DID NOT CREATE INF REINF FAILED ON RANDPOS";
							};
						};
					};
					// add new here
				if (_randreinforce > 6 && _randreinforce <=8) then //light armour
				{
					
					_x = 0;
					for "_x" from 1 to 3 do //create 2 groups
					{
					if(DEBUG) then
					{
						diag_log "====================================starting CARS GMG reinforcmenets==============================";
						diag_log format ["Reinforce = %1",Reinforced];
					};	
						//random radius pos from ao center
						_Arm_Patrol = createGroup east;
						_randomPos = [getMarkerPos currentAO, PARAMS_AOSize+1000] call dR_fnc_randomPosbl1p;
						if ((count _randomPos) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPos nearRoads 2000;
							
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};	
							
							_veh = [_roadPos,0,"O_MRAP_02_gmg_F",_Arm_Patrol] call BIS_fnc_spawnVehicle;
							ReinforcementVehicles set [count ReinforcementVehicles, _veh select 0];
							
							[_Arm_Patrol, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
							
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _Arm_Patrol;
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}
						else
						{
						diag_log "DID NOT CREATE CARS REINF FAILED ON RANDPOS";
						};
					};
				};
				if (_randreinforce > 8) then
				{
					
					_x = 0;
					for "_x" from 1 to 2 do //create 3 groups
					{
						if(DEBUG) then
						{
						diag_log "====================================starting light arm reinforcmenets==============================";
						diag_log format ["Reinforce = %1",Reinforced];
						};
						//random radius pos from ao center
						_randomPos = [getMarkerPos currentAO, PARAMS_AOSize+1000] call dR_fnc_randomPosbl1p;
						
						if ((count _randomPos) == 3) then 
						{
						
							//find a road if posible
							_roadList = _randomPos nearRoads 2000;
							
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
							_Arm_Patrol = createGroup east;
							_veh = [_randomPos,0,"O_APC_Wheeled_02_rcws_F",_Arm_Patrol] call BIS_fnc_spawnVehicle;
							ReinforcementVehicles set [count ReinforcementVehicles, _veh select 0];
							
							[_Arm_Patrol, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
							
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _Arm_Patrol;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}
						else
						{
						diag_log "DID NOT CREATE ARMOUR REINF FAILED ON RANDPOS";
						};
					};
				};
				if(DEBUG) then
				{
				diag_log format ["TOTAL reinforcement count = %1",count ReinforcementUnits];
				};
			} 
			else 
			{
				// Fluit: Check if reinforcements are all dead
				_reinforcementsdead = true;
				{
				  if (alive _x) then {
						_reinforcementsdead = false;
				  };
				} forEach ReinforcementUnits;

				// If all dead reset the reinforcement status
				if (_reinforcementsdead) then 
				{
						
						Reinforced = false;
						publicVariable "Reinforced";
						ReinforcementUnits = [];
						publicVariable "ReinforcementUnits";
						
						ReinforcementVehicles =[];
						publicVariable "ReinforcementVehicles";
						// reset spotters
						spotted = false;
						publicvariable "spotted";
				};
			};
		};
sleep 30;
};
