//////////////////////////////////////////////
// HEAVY reinf script by BL1P and Fluit     //
//////////////////////////////////////////////

waitUntil {sleep 0.5; !(isNil "currentAOUp")};
waitUntil {sleep 0.5; !(isNil "currentAO")};
private ["_priorityMessageJet","_Heavyreinforcementsdead","_SERVERUNITSCHECKHre","_randHeavyChance","_SERVERUNITSCHECKHreResistance","_SERVERUNITSCHECKHre1"];

if (DEBUG) then {diag_log "===============Reading HEAVY reinforcements====================";};

ReinforcedPlane = false;
publicVariable "ReinforcedPlane";

ReinforcedTank = false;
publicvariable "ReinforcedTank";

HeavyReinforcementUnits = [];
HeavyReVehicles = [];

_SERVERUNITSCHECKHre1 = 0;
_SERVERUNITSCHECKHreResistance = 0;
_SERVERUNITSCHECKHre = 0;

while {true} do 
{
	if(DEBUG) then
		{
			sleep (10 + (random 10));
		}
		else
		{
			sleep (120 + (random 60));
		};
	
	_randHeavyChance = random 10;
		
		if(DEBUG) then
		{
			diag_log format ["_randHeavyChance = %1 PARAMS_HeavyReinforcement = %2  (%1 <= %2 ?)",_randHeavyChance,PARAMS_HeavyReinforcement];
		};
	
if ((radioTowerAlive && !ReinforcedPlane && spottedPlane) || (radioTowerAlive && !ReinforcedTank && spottedTank)) then
	{
		_SERVERUNITSCHECKHre1 = east countSide allunits;
		_SERVERUNITSCHECKHreResistance = resistance countSide allunits;
		_SERVERUNITSCHECKHre = (_SERVERUNITSCHECKHre1 + _SERVERUNITSCHECKHreResistance);
	
		sleep 1;
		if(DEBUG) then
					{
						diag_log format ["_SERVERUNITSCHECKHre1 for TOTAL BOTH HEAVY reinforcements = %1",_SERVERUNITSCHECKHre1];
					};
				
	};			
		//send plane
		if (radioTowerAlive && spottedPlane && (_SERVERUNITSCHECKHre1 < PARAMS_TOTALMAXAI) && (_randHeavyChance <= PARAMS_HeavyReinforcement)) then 
		{
			//check not already reinforced
			if !(ReinforcedPlane) then 
			{
				// clear any old triggers
				if (!isNil ("_upsZoneAir")) then {if (DEBUG) then {diag_log "_upsZoneAir was not nil removing";};deleteVehicle _upsZoneAir;};
				
				//create and check random pos
				_patrolCreatePos = [getMarkerPos currentAO, 5000,7] call dR_fnc_randomPosbl1p;
				if ((count _patrolCreatePos) == 3) then 
				{		
					//choose a random type
					_planeRandomChance = random 9;
					if (_planeRandomChance <= 4) then
					{
						//_patrolPos = getMarkerPos currentAO;
						_helo_Patrol = createGroup EAST;
						diag_log "====creating O_Plane_CAS_02_F ====";
						_helo_Array = [[_patrolCreatePos select 0,_patrolCreatePos select 1,1000], 20, ["O_Plane_CAS_02_F"] call BIS_fnc_selectRandom, east] call BIS_fnc_spawnVehicle;
						_helo_Patrol = _helo_Array select 0;
						_helo_crew = _helo_Array select 1;
						HeavyReVehicles set [count HeavyReVehicles, _helo_Array select 0];
						
						_upsZoneAir = createTrigger ["EmptyDetector", getMarkerPos currentAO];
						_upsZoneAir setTriggerArea [PARAMS_AOSize+500, PARAMS_AOSize+500, 0, false];
						
							//nul=[(leader _helo_Patrol), "aoCircle"] execVm "scripts\UPSMON.sqf";
							[(leader _helo_Patrol), "aoCircle"] execVM "UPS_BL1P.sqf";
						
						// declare some variables
						ReinforcedPlane = true;
						publicVariable "ReinforcedPlane";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf plane created variable ReinforcedPlane = %1  spottedPlane = %2 ====",ReinforcedPlane,spottedPlane];
						};
						//waituntill its dead or cant move
						waitUntil 
						{
							sleep 5; 
							!alive _helo_Patrol || {!canMove _helo_Patrol}
						};
						//destoy vehicle and pilots
						sleep 5;
						_helo_Patrol setDamage 1;
						sleep 5;
						deleteVehicle _helo_Patrol;

						{
							_x setDamage 1;
							sleep 5;
							deleteVehicle _x;
						} foreach _helo_crew;
						
						if (!isNil ("_upsZone")) then {if (DEBUG) then {diag_log "_upsZone was not nil removing";};deleteVehicle _upsZone;};
						//declare some variables
						ReinforcedPlane = false;
						publicVariable "ReinforcedPlane";
						
						spottedPlane = false;
						publicvariable "spottedPlane";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf Plane Destroyed variable ReinforcedPlane = %1 ===",ReinforcedPlane];
						diag_log format ["=== Reinf script reset spot var spottedPlane  = %1 ===",spottedPlane];
						};
					};
					//or this type
					if (_planeRandomChance > 4 ) then
					{
						//_patrolPos = getMarkerPos currentAO;
						_helo_Patrol = createGroup EAST;
						diag_log "====creating O_Heli_Attack_02_F ====";
						_helo_Array = [[_patrolCreatePos select 0,_patrolCreatePos select 1,1000], 20, ["O_Heli_Attack_02_F"] call BIS_fnc_selectRandom, east] call BIS_fnc_spawnVehicle;
						_helo_Patrol = _helo_Array select 0;
						_helo_crew = _helo_Array select 1;
						HeavyReVehicles set [count HeavyReVehicles, _helo_Array select 0];
						
						_upsZoneAir = createTrigger ["EmptyDetector", getMarkerPos currentAO];
						_upsZoneAir setTriggerArea [PARAMS_AOSize+500, PARAMS_AOSize+500, 0, false];
						
							nul=[(leader _helo_Patrol), "aoCircle"] execVm "scripts\UPSMON.sqf";
							[(leader _helo_Patrol), "aoCircle"] execVM "UPS_BL1P.sqf";
						
						// declare some variables
						ReinforcedPlane = true;
						publicVariable "ReinforcedPlane";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf plane created variable ReinforcedPlane = %1  spottedPlane = %2 ====",ReinforcedPlane,spottedPlane];
						};
						//waituntill its dead or cant move
						waitUntil 
						{
							sleep 5; 
							!alive _helo_Patrol || {!canMove _helo_Patrol}
						};
						//destoy vehicle and pilots
						sleep 5;
						_helo_Patrol setDamage 1;
						sleep 5;
						deleteVehicle _helo_Patrol;

						{
							_x setDamage 1;
							sleep 5;
							deleteVehicle _x;
						} foreach _helo_crew;
						
						if (!isNil ("_upsZone")) then {if (DEBUG) then {diag_log "_upsZone was not nil removing";};deleteVehicle _upsZone;};
						//declare some variables
						ReinforcedPlane = false;
						publicVariable "ReinforcedPlane";
						
						spottedPlane = false;
						publicvariable "spottedPlane";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf Plane Destroyed variable ReinforcedPlane = %1 ===",ReinforcedPlane];
						diag_log format ["=== Reinf script reset spot var spottedPlane  = %1 ===",spottedPlane];
						};
						
					};
						
				}
				else
				{
					diag_log "DID NOT CREATE REINFORCE PLANE NO RANDPOS";
				};
			};
		};
		// send tanks
		if (radioTowerAlive && spottedTank && (_SERVERUNITSCHECKHre1 < PARAMS_TOTALMAXAI) && (_randHeavyChance <= PARAMS_HeavyReinforcement)) then 
		{
			if !(ReinforcedTank) then 
			{
				_x = 0;
				for "_x" from 1 to 2 do //create 2 groups
				{
					//_patrolPos = getMarkerPos currentAO;
					_randomPos = [getMarkerPos currentAO, PARAMS_AOSize+1000] call dR_fnc_randomPosbl1p;
					
					_HeavyRandomChance = random 6;
					if (_HeavyRandomChance <= 3) then
					{
						_ReinfarmourGroup = createGroup east;
						if (DEBUG) then
							{
							diag_log "====creating O_MBT_02_cannon_F=====";
							};
						_armour = [_randomPos,0,"O_MBT_02_cannon_F",_ReinfarmourGroup] call BIS_fnc_spawnVehicle;
						HeavyReVehicles set [count HeavyReVehicles, _armour select 0];
						sleep 1;
						[_ReinfarmourGroup, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
						[(units _ReinfarmourGroup)] call aw_setGroupSkill;
						(vehicle (leader _ReinfarmourGroup)) spawn aw_fnc_fuelMonitor;
						if !(isNil "dep_fnc_vehicledamage") then {
						[(_armour select 0)] spawn dep_fnc_vehicledamage;
						};
									
						ReinforcedTank = true;
						publicvariable "ReinforcedTank";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf Tanks created variable ReinforcedTank = %1  spottedTank = %2 === ",ReinforcedTank,spottedTank];
						diag_log format ["_ReinfarmourGroup = %1",_ReinfarmourGroup];
						};
						{
						  HeavyReinforcementUnits set [count HeavyReinforcementUnits, _x];
						  publicVariable "HeavyReinforcementUnits";
						} forEach units _ReinfarmourGroup;
						
					};
					if (_HeavyRandomChance > 3) then
					{
						_ReinfarmourGroup = createGroup east;
						if (DEBUG) then
							{
							diag_log "====O_APC_Tracked_02_cannon_F=====";
							};
						_armour = [_randomPos,0,"O_APC_Tracked_02_cannon_F",_ReinfarmourGroup] call BIS_fnc_spawnVehicle;
						HeavyReVehicles set [count HeavyReVehicles, _armour select 0];
						sleep 1;
						[_ReinfarmourGroup, getMarkerPos currentAO,250] call dR_fnc_spawn2_perimeterPatrolBL1P;
						[(units _ReinfarmourGroup)] call aw_setGroupSkill;
						
						ReinforcedTank = true;
						publicvariable "ReinforcedTank";
						if(DEBUG) then
						{
						diag_log format ["=== Reinf Tanks created variable ReinforcedTank = %1  spottedTank = %2 === ",ReinforcedTank,spottedTank];
						diag_log format ["_ReinfarmourGroup = %1",_ReinfarmourGroup];
						};
						{
						  HeavyReinforcementUnits set [count HeavyReinforcementUnits, _x];
						  publicVariable "HeavyReinforcementUnits";
						} forEach units _ReinfarmourGroup;	
					};	
				};	
			}
			else 
			{
				// Fluit: Check if reinforcements are all dead
				_Heavyreinforcementsdead = true;
				{
				  if (alive _x) then 
				  {
						_Heavyreinforcementsdead = false;
				  };
				} forEach HeavyReinforcementUnits;

				// If all dead reset the reinforcement status
				if (_Heavyreinforcementsdead) then 
				{
					if(DEBUG) then
					{
					diag_log format ["=== Reinf Tank destroyed variable ReinforcedTank = %1 === ",ReinforcedTank];
					diag_log format ["=== Reinf script reset spot var spottedTank  = %1 === ",spottedTank];
					};	
					HeavyReinforcementUnits = [];
					publicVariable "HeavyReinforcementUnits";
						
					HeavyReVehicles = [];
					publicVariable "HeavyReVehicles";
						
					ReinforcedTank = false;
					publicVariable "ReinforcedTank";
					
					spottedTank = false;
					publicvariable "spottedTank";
				};
			};
		};
    sleep 5;
};
