private ["_npc","_lastcurrpos","_lastknown","_lastwptype","_lastpos","_timeontarget","_react","_waiting","_membertypes","_vehicletypes","_makenewtarget","_reinforcementsent","_reinforcement","_newpos","_grpid","_Ucthis","_grpidx","_grpidname","_side","_members","_grp","_isSoldier","_exit","_fightmode","_fortifyorig","_fortify","_wp","_targetPos","_surrender",
"_retreat","_pause","_nomove","_onroad","_nosmoke","_nofollow","_shareinfo","_noveh","_noveh2","_radiorange","_orgMode","_orgspeed","_orgpos","_speedmode","_behaviour","_nowp","_nowtype","_ambush","_fixedtargetPos","_areasize","_rangeX","_rangeY","_area","_areadir","_cosdir","_sindir",
"_areamarker","_centerpos","_centerX","_centerY","_mindist","_sokilled","_sowounded","_gothit","_Supstate","_Arrayofnearestunit","_alliednear","_enynear","_surrended","_closeenough","_target","_targetdead","_linkactivate","_isman","_iscar","_isboat","_isplane","_isdiver",
"_rfid","_rfidcalled","_buildingdist","_TargetSearch","_Enemies","_target","_dist","_opfknowval","_targetsnear","_attackPos","_timeontarget","_targetdead","_flankdir","_fightmode","_newattackPos","_dist","_enemytanksnear","_friendlytanksnear","_dir1","_mineposition","_roads","_artillerysideunits",
"_arti","_nbrTargets","_targettext","_wptype","_smoke","_unitsin","_GetOutDist","_timeout","_landing","_fm","_targetX","_targetY","_wpformation","_index"];

_rfidcalled = false;
_nowpType = 1;
_linkdistance = 100;
_RadioRange = 10000;

_surrender = 0;
_retreat = 0;
_fortify = false;
_buildingdist = 25;

_target = ObjNull;
_newtarget=objnull;
_targetdist = 1000;
_makenewtarget = true;
_reinforcementsent = false;

_react = 0;
_lastreact = UPSMON_minreact;
_minreact = UPSMON_minreact;

_timeontarget = 0;
_waiting = 0;
_wait=90;
_timeout = 0;
_newpos = false;
_index = 0;

_surrended = false;
_supressed = false;
_alliednear = 0;
_enynear = 0;
_dist2 = 0;
_GetOutDist = 0;
_unitsIn = [];

_wp=[];
_wptype="MOVE";
_lastwptype = "MOVE";
_wpformation = "VEE";
_rstuckControl = 0;
_flyInHeight = 0;
_cargo = [];
_landing=false;
_safemode=["CARELESS","SAFE"];

_opfknowval = 0;
_lastknown = 0;
_targetsnear = false;
_attackPos 	= [0,0];
_targetdead = false;
_flankdir = 0;
_fightmode = "WALK";
_newattackPos = [0,0];
_fixedtargetpos = [0,0];
_fm = 0;


_wptype = "MOVE";
_pursue= false;
_waiting = 0;

_fortifyorig= false;
_targettext ="currPos";
_swimming = false;
_deadBodiesreact = UPSMON_deadBodiesReact; 
_nbrwoundedunit =0;
_closeenough = UPSMON_closeenough;
_closenoughV = UPSMON_closeenoughV;
_ambushed = false;
_enemytanknear = objNull;
_enemystaticnear = objNull;
_enemyairnear = objnull;
_surrended = false;
_assignedvehicle = [];

// ***********************************************************************************************************
// ************************************************ MAIN LOOP ************************************************
// ***********************************************************************************************************
	
while {upsmon_enabled} do 
{
	_cycle = 2;
	
	{
		_npc = _x;
		_exit = false;
		

		_lastcurrpos = (_npc getvariable "UPSMON_Lastinfos") select 0;
		_lastknown = (_npc getvariable "UPSMON_Lastinfos") select 3;
		_lastwptype = (_npc getvariable "UPSMON_Lastinfos") select 1;
		_lastpos = (_npc getvariable "UPSMON_Lastinfos") select 2;
		_flankdir = (_npc getvariable "UPSMON_Lastinfos") select 5;
		_lastmembers = (_npc getvariable "UPSMON_Lastinfos") select 6;
		_timeinfo = (_npc getvariable "UPSMON_Lastinfos") select 7;
		_timeontarget = (_npc getvariable "UPSMON_TIMEONTARGET") select 0;
		_timeonalert = (_npc getvariable "UPSMON_TIMEONTARGET") select 1;
		_react = (_npc getvariable "UPSMON_REACT") select 0;
		_lastreact = (_npc getvariable "UPSMON_REACT") select 1;
		_minreact = (_npc getvariable "UPSMON_REACT") select 2;
		_membertypes = (_npc getvariable "UPSMON_RESPAWNARRAY") select 0;
		_vehicletypes = (_npc getvariable "UPSMON_RESPAWNARRAY") select 1;
		_makenewtarget = _npc getvariable "UPSMON_makenewtarget";
		_reinforcementsent = (_npc getvariable "UPSMON_REINFORCEMENTSENT") select 0;
		_reinforcement = _npc getvariable "UPSMON_REINFORCEMENT";
		_timereinforcement =(_npc getvariable "UPSMON_REINFORCEMENTSENT") select 1;
		_timeartillery = _npc getvariable "UPSMON_TimeArtillery";
	
	
		_react= _react + 3;	
		_lastreact = _lastreact + 3;
		_timeinfo = _timeinfo + 2;
		_timereinforcement = _timereinforcement + 2;
		_timeartillery = _timeartillery + 3;
		
		_grpid = _npc getvariable "UPSMON_grpid";
		_Ucthis = _npc getvariable "UPSMON_Ucthis";
		_grpidx = format["%1",_grpid];
		_grpname = format["%1_%2",(side _npc),_grpidx];
	
		_side = (_npc getvariable "UPSMON_Grpinfos") select 0;
		_members = (_npc getvariable "UPSMON_Grpinfos") select 1;
		_grp = (_npc getvariable "UPSMON_Grpinfos") select 2;
	
		_isSoldier = true;
		_fightmode = "WALK";
	
		_fortifyorig = (_npc getvariable "UPSMON_Fortify") select 0;
		_fortify = (_npc getvariable "UPSMON_Fortify") select 1;
		
		//Sets min units alive for surrender
		if !( _side == civilian ) then 
		{ 
			_surrender = call (compile format ["UPSMON_%1_SURRENDER",_side]); 
			_retreat = call (compile format ["UPSMON_%1_SURRENDER",_side]); 
		};

		// wait at patrol end points
		_pause = if ("NOWAIT" in _UCthis) then {"NOWAIT"} else {"WAIT"};
		_nomove  = if ("NOMOVE" in _UCthis || _fortify) then {"NOMOVE"} else {"MOVE"};

		// create _targerpoint on the roads only (by this group)
		_onroad = if ("ONROAD" in _UCthis) then {true} else {false};
		// do not use smoke (by this group)
		_nosmoke = if ("NOSMOKE" in _UCthis) then {true} else {false};
	
		// don't follow outside of marker area
		_nofollow = if ("NOFOLLOW" in _UCthis) then {"NOFOLLOW"} else {"FOLLOW"};
		// share enemy info 
		_shareinfo = if ("NOSHARE" in _UCthis) then {"NOSHARE"} else {"SHARE"};
	
		// suppress fight behaviour
		if ("NOAI" in _UCthis || side _npc == civilian) then {_isSoldier=false};	
	
		// do not search for vehicles (unless in fight and combat vehicles)
		_noveh = if ("NOVEH" in _UCthis || "NOVEH2" in _UCthis) then {true} else {false};	
		_noveh2 = if ("NOVEH2" in _UCthis) then {true} else {false};	// Ajout
	
		_radiorange = _npc getvariable "UPSMON_RadioRange";
		_orgMode = (_npc getvariable "UPSMON_Origin") select 0;
		_orgSpeed = (_npc getvariable "UPSMON_Origin") select 1;
		_orgpos = (_npc getvariable "UPSMON_Origin") select 2;
		_wpformation = (_npc getvariable "UPSMON_Origin") select 3;
	
		_speedmode = _orgSpeed;
		_behaviour = behaviour _npc;
	
		_nowp = (_npc getvariable "UPSMON_NOWP") select 0;
		_nowtype = (_npc getvariable "UPSMON_NOWP") select 1;
		
		_grpmission = (_npc getvariable "UPSMON_Grpstatus") select 0;
		_lastgrpmission = (_npc getvariable "UPSMON_Grpstatus") select 2;
		
		_fixedtargetPos = [0,0];
		_targetpos = _lastpos;
	
		//========================= Marker caracteristics =================================================
			_areamarker = _Ucthis select 1;
	
			// remember center position of area marker
			_centerpos = getMarkerPos _areamarker;
			_centerX = abs(_centerpos select 0);
			_centerY = abs(_centerpos select 1);
			_centerpos = [_centerX,_centerY];
	
			// X/Y range of target area
			_areasize = getMarkerSize _areamarker;
			_rangeX = _areasize select 0;
			_rangeY = _areasize select 1;
			_area = abs((_rangeX * _rangeY) ^ 0.5);
			// marker orientation (needed as negative value!)
			_areadir = (markerDir _areamarker) * -1;
		//===================================================================================================
	
		_sokilled = false;
		_sowounded = false;
		_gothit = false;
		_Supstate = random 100 < 40;
		_newpos = false;
		_pursue = false;
		_supressed = false;
		_dist = 1000;
		_targetdist = 10000;
		_colorstatus = (_npc getvariable "UPSMON_Grpstatus") select 1;
		
		_atcapacity = false;
		_aacapacity = false;
		_needsupport = false;
		_typeofgrp = ["infantry"];
		_hascapacity = true;
		
		_CombatMode = "YELLOW";
		
		// did the leader die?
		_npc = [_npc,_members] call UPSMON_getleader;							
		if (!alive _npc || !canmove _npc || isplayer _npc ) then {_exit=true;};
		
		// EXIT FROM LOOP =======================================================================================================
		// nobody left alive, exit routine
		if (count units _npc == 0 || _npc getvariable "UPSMON_Deletegroup") then 
		{
			_exit=true;
		}; 
	
		//exits from loop
		if (_exit) exitwith {[_npc,_Ucthis,_target,_orgpos,_surrended,_closeenough,_grpidx,_membertypes,_vehicletypes,_side] call UPSMON_Respawngrp;};

		//=============================================================================================================================	
		
		If (UPSMON_Debug > 0) then {diag_log format ["%1 begin check",_grpid];};
		
		//Assign the current leader of the group in the array of group leaders
		If (!(_npc in UPSMON_NPCs)) then {UPSMON_NPCs = UPSMON_NPCs + [_npc];};
		if (_reinforcement == "REINFORCEMENT") then 
		{
			switch (_side) do 
			{
				case West: 
				{
					if (!(_npc in UPSMON_REINFORCEMENT_WEST_UNITS) && (IsNull _target) && !_reinforcementsent) then  {UPSMON_REINFORCEMENT_WEST_UNITS = UPSMON_REINFORCEMENT_WEST_UNITS + [_npc]};	
				};
				case EAST: 
				{
					if (!(_npc in UPSMON_REINFORCEMENT_EAST_UNITS) && (IsNull _target) && !_reinforcementsent) then  {UPSMON_REINFORCEMENT_EAST_UNITS = UPSMON_REINFORCEMENT_EAST_UNITS + [_npc]};
				};
				case resistance: 
				{
					if (!(_npc in UPSMON_REINFORCEMENT_GUER_UNITS) && (IsNull _target) && !_reinforcementsent) then  {UPSMON_REINFORCEMENT_GUER_UNITS = UPSMON_REINFORCEMENT_GUER_UNITS + [_npc]};		
				};
	
			};
		};

		// current position
		_currPos = getposATL _npc; _currX = _currPos select 0; _currY = _currPos select 1;
		// Variable check if Unit is HIT / WOUNDED / KILLED ===========================================================================
		// CHECK IF did anybody in the group got hit or die? 
	
		If (isNil "tpwcas_running") then 
		{
			If (isNil "bdetect_enable") then
			{ 
				if (group _npc in UPSMON_GOTHIT_ARRAY || group _npc in UPSMON_GOTKILL_ARRAY) then
				{
					_gothit = true;
						If (_Supstate) then {_supressed = true} else {_supressed = false};
						if (group _npc in UPSMON_GOTHIT_ARRAY) then
						{
							_sowounded = true;
							_nbrwoundedunit = 0;
							{
								If (lifestate _x == "INJURED") then {_nbrwoundedunit = _nbrwoundedunit +1;};
							}Foreach units _npc;
						}
						else
						{
							_sokilled = true;
							UPSMON_GOTKILL_ARRAY = UPSMON_GOTKILL_ARRAY - [group _npc];
						};
						UPSMON_GOTHIT_ARRAY = UPSMON_GOTHIT_ARRAY - [group _npc];
					};
				}
				else
				{
					_Supstate = _npc getVariable ["bcombat_suppression_level", 0];
					if (_Supstate >= 20) then
					{
						_gothit = true;
						If (_Supstate >= 75) then {_supressed = true} else {_supressed = false};
					};
		
					if (group _npc in UPSMON_GOTHIT_ARRAY || group _npc in UPSMON_GOTKILL_ARRAY) then
					{
						_gothit = true;
			
						if (group _npc in UPSMON_GOTHIT_ARRAY) then
						{
							_sowounded = true;
							_nbrwoundedunit = 0;
							{
								If (lifestate _x == "INJURED") then {_nbrwoundedunit = _nbrwoundedunit +1;};
							}Foreach units _npc;
						}
						else
						{
							_sokilled = true;
							UPSMON_GOTKILL_ARRAY = UPSMON_GOTKILL_ARRAY - [group _npc];
						};
						UPSMON_GOTHIT_ARRAY = UPSMON_GOTHIT_ARRAY - [group _npc];
					};
				};
			
			} 
			else 
			{
				_Supstate = [_npc] call UPSMON_supstatestatus; 
				if (_Supstate >= 2) then
				{
					_gothit = true;
					_Supstate = [_npc] call UPSMON_supstatestatus;
					If (_Supstate == 3) then {_supressed = true} else {_supressed = false};
				};
		
				if (group _npc in UPSMON_GOTHIT_ARRAY || group _npc in UPSMON_GOTKILL_ARRAY) then
				{
					_gothit = true;
					_Supstate = [_npc] call UPSMON_supstatestatus;
					If (_Supstate == 3) then {_supressed = true} else {_supressed = false};
			
					if (group _npc in UPSMON_GOTHIT_ARRAY) then
					{
						_sowounded = true;
						_nbrwoundedunit = 0;
						{
							If (lifestate _x == "INJURED") then {_nbrwoundedunit = _nbrwoundedunit +1;};
						}Foreach units _npc;
					}
					else
					{
						_sokilled = true;
						UPSMON_GOTKILL_ARRAY = UPSMON_GOTKILL_ARRAY - [group _npc];
					};
					UPSMON_GOTHIT_ARRAY = UPSMON_GOTHIT_ARRAY - [group _npc];
				};
			};

		//If (_nbrwoundedunit > 0) then {_react = (-2) * _nbrwoundedunit;_morale = -0.2;};
		//If (count _lastmembers > count units _npc) then {_react = -5;_morale = -0.5;};
		
		//Variables to see if the leader is in a vehicle
		_isman = "Man" countType [ vehicle _npc]>0;
		_incar = "LandVehicle" countType [vehicle (_npc)]>0;
		_inheli = "Air" countType [vehicle (_npc)]>0;
		_inboat = "Ship" countType [vehicle (_npc)]>0;
		_isdiver = ["diver", (typeOf (leader _npc))] call BIS_fnc_inString;


		// if the AI is a civilian we don't have to bother checking for enemy encounters
		if (_isSoldier) then 
		{
			_linkactivate = false;
			_pursue = false;
			
			_unitsneedammo = [_npc] call UPSMON_checkmunition;
			_grpcomposition = [_npc] call UPSMON_analysegrp;
			if (UPSMON_Debug>0) then {diag_log format ["_grpcomposition:%1 _unitsneedammo:%2",_grpcomposition,_unitsneedammo];};
			_typeofgrp = _grpcomposition select 0;
			_capacityofgrp = _grpcomposition select 1;
			_assignedvehicle = _grpcomposition select 2;
			
			_artillerysideFire = call (compile format ["UPSMON_ARTILLERY_%1_FIRE",_side]);
			switch (_side) do 
			{
				case West: 
				{
					_artillerysideunits = UPSMON_ARTILLERY_WEST_UNITS;
				};
				case EAST: 
				{
					_artillerysideunits = UPSMON_ARTILLERY_EAST_UNITS;
				};
				case resistance: 
				{
					_artillerysideunits = UPSMON_ARTILLERY_GUER_UNITS; 
				};
	
			};
			
			
			// set target tolerance high for choppers & planes
			if ("air" in _typeofgrp) then {_closeenough = UPSMON_closeenough * 2};
			
			//=====================================================================================================
			// REFINFORCEMENT = true
			//=====================================================================================================	
		
			//If the group is strengthened and the enemies have been detected are sent to target
			_rfid = _npc getvariable "UPSMON_RFID";
			if (isnil "_rfid") then {_rfid=0};
			
			if (_rfid > 0 ) then 
			{
				_rfidcalled = false; // will be TRUE when variable in triger will be true.
				if !(isnil (compile format ["UPSMON_reinforcement%1",_rfid])) then {_rfidcalled= call (compile format ["UPSMON_reinforcement%1",_rfid])};													
			};
		
			//Reinforcement control
			if (_reinforcement == "REINFORCEMENT" || _rfid > 0) then 
			{
				// (global call  OR id call) AND !send yet
				if ( (UPSMON_reinforcement || _rfidcalled) && (!_reinforcementsent)) then 
				{				
					If (_rfidcalled) then 
					{
						_fixedtargetPos = call (compile format ["UPSMON_reinforcement%1_pos",_rfid]); // will be position os setfix target of sending reinforcement
						if (isnil "_fixedtargetPos") then 
						{
							_fixedtargetPos =[0,0];
						}else{
							_fixedtargetPos =  [abs(_fixedtargetPos select 0),abs(_fixedtargetPos select 1)];
						};
					} 
					else 
					{
						_fixedtargetPos = _npc getvariable "UPSMON_PosToRenf";
					};
				
					If (format ["%1",_fixedtargetPos] != "[0,0]" && (_lastpos select 0 != _fixedtargetPos select 0 && _lastpos select 1 != _fixedtargetPos select 1)) then 
					{ 
						_reinforcementsent=true;
						_fortify = false;
						_minreact = UPSMON_minreact;			
						_react = _react + 100;					
						_nowp = false;
						_targetpos = _fixedtargetpos;
						_grpmission = "REINF";
						
						[_npc,_targetpos,_dist,_typeofgrp] call UPSMON_DOREINF;
					};
					//if (UPSMON_Debug>0) then {player sidechat format["%1 called for reinforcement %2",_grpidx,_fixedtargetPos]};	
				} else {
					// !(global or id call) AND send
					if (!(UPSMON_reinforcement || _rfidcalled) && _reinforcementsent) then 
					{
						_fixedtargetPos = [0,0];
						_attackPos = [0,0];
						//_fortify = _fortifyorig;
						_reinforcementsent=false;
						if (_rfid > 0 ) then 
						{
							call (compile format ["UPSMON_reinforcement%1_pos = [0,0]",_rfid]);
							call (compile format ["UPSMON_reinforcement%1 = false",_rfid]);
						};
						if (UPSMON_Debug>0) then {diag_log format["%1 reinforcement canceled",_grpidx]};	
					};
				};
			};
		//----------- END REINFORCEMENT -------------

			
//*********************************************************************************************************************
// 											ACQUISITION OF TARGET 	
//*********************************************************************************************************************		
	
		_TargetSearch 	= [];
		_Enemies = [];
	
		_TargetSearch 	= [_npc,_shareinfo,_closeenough,_flankdir,_timeontarget,_timeinfo,_react] call UPSMON_TargetAcquisition;
		_Enemies 		= _TargetSearch select 0;
		_target 		= _TargetSearch select 1;
		_dist 			= _TargetSearch select 2;
		_opfknowval 	= _TargetSearch select 3;
		_targetsnear 	= _TargetSearch select 4;
		_attackPos 		= _TargetSearch select 5;
		_timeontarget 	= _TargetSearch select 6;
		_flankdir 		= _TargetSearch select 7;
		_timeinfo 		= _TargetSearch select 8;
		_react			= _TargetSearch select 9;

	if (UPSMON_Debug>0) then {diag_log format ["group:%1 target:%2 dist:%3 opfknowval:%4 targetsnear:%5 attackPos:%6 timeinfo:%7",_grpidx,_target,_dist,_opfknowval,_targetsnear,_attackPos,_timeinfo];};
	
	//If knowledge of the target increases accelerate the reaction
	if (_opfknowval > _lastknown ) then {
		_react = _react + 20;
	};
////////////////////////////////////////// TARGET FOUND ////////////////////////////////////////////////////////////////
	
	//Gets  current known position of target and distance
		if ( !isNull (_target) && alive _target && (_grpmission != "AMBUSH")) then 
		{
			//Enemy detected
			if (_colorstatus != "YELLOW" ) then 
			{
				_colorstatus = "YELLOW";
				_CombatMode = "YELLOW";
				
				
				if (UPSMON_Debug>0) then {player sidechat format["%1: Enemy detected %2",_grpidx, typeof _target]}; 	
				
				if (_nowpType == 1) then {
					_nowp = false;
				};
			

				_newattackPos = _target getvariable ("UPSMON_lastknownpos");
			
				if ( !isnil "_newattackPos" ) then 
				{
					_attackPos=_newattackPos;	
					//Gets distance to target known pos
					_dist = ([_currpos,_attackPos] call UPSMON_distancePosSqr);	
					//Looks at target known pos
					_members lookat _attackPos;							 				
				};
			};

			//If use statics are enabled leader searches for static weapons near or fire artillery.
			// Tanks enemies are contabiliced
			
			// Check if there are big targets (tank, APC, static or Air unit)
			_enemytanksnear = false;
			_enemyStaticsnear = false;
			_enemyAirsnear = false;
			_enemytankposition = [0,0];
			_enemyStaticposition = [0,0];
			_enemyAirposition = [0,0];
				
			{
				if (("Tank" countType [vehicle (_x select 0)] > 0 || "Wheeled_APC" countType [vehicle (_x select 0)] >0 
					|| "Tank" countType [vehicle (_x select 0)] > 0 || "Wheeled_APC" countType [vehicle (_x select 0)] >0) 
					&& alive (_x select 0) && canMove (_x select 0))
					exitwith { _enemytanksnear = true; _enemytanknear = (_x select 0); _enemytankposition = (_x select 1);};
					
				if ( "StaticWeapon" countType [vehicle (_x select 0)] > 0 && alive (_x select 0) && canMove (_x select 0))
					exitwith { _enemyStaticsnear = true; _enemyStaticnear = (_x select 0);_enemyStaticposition = (_x select 1);};
					
				if ( "Air" countType [vehicle (_x select 0)] > 0 && alive (_x select 0) && canMove (_x select 0))
					exitwith { _enemyAirsnear = true; _enemyAirnear = (_x select 0);_enemyAirposition = (_x select 1);};
					
			} foreach _Enemies;
			if (DEBUG) then 
			{
			//diag_log format ["enytank:%1 enyair:%2",_enemytanksnear,_enemyAirsnear];
			};
			// Check if group can defeat them
			If (_enemytanksnear) then
			{
				if (!(isnull _enemytanknear) && alive _enemytanknear) then
				{
					If ("Tank" countType [vehicle _enemytanknear] > 0) then
					{
						If ("at2" in _capacityofgrp || "at3" in _capacityofgrp) then
						{
							_hascapacity = true;
							If (_enemytanknear != _target && !_targetsnear) then {_target = _enemytanknear; _attackPos = _enemytankposition; _dist = ([_currpos,_attackPos] call UPSMON_distancePosSqr);};
						}
						else
						{
							_hascapacity = false;
						};
						
						if (!_hascapacity && UPSMON_useMines && !_supressed) then
						{
							_ATmine = false;
							_Atunit = ObjNull;
							
							{If (alive _x && ("ATMine" in (magazines _x))) exitwith {_ATmine = true; _Atunit = _x;};} foreach units _npc;
							
							if (_ATmine) then
							{
								_friendlytanksnear = false;
								{
									if (!( alive _x && canMove _x)) then {_friendlytanks = _friendlytanks - [_x]};
									if (alive _x && canMove _x && _npc distance _x <= _closeenough + UPSMON_safedist ) exitwith { _friendlytanksnear = true;}; 
								}foreach _friendlytanks;
								
								if (!_friendlytanksnear && random(100)<40 ) then 
								{
									_dir1 = [_currPos,position _enemytanknear] call UPSMON_getDirPos;
									_mineposition = [position _npc,_dir1, 25] call UPSMON_GetPos2D;	
									_roads = _mineposition nearroads 50;
									if (count _roads > 0) then {_mineposition = position (_roads select 0);};
									[_npc,_mineposition] call UPSMON_CreateMine;													
								};	
							};
						};
					}
					else
					{
						If ("at2" in _capacityofgrp || "at3" in _capacityofgrp || "at1" in _capacityofgrp) then
						{
							_hascapacity = true;
							If (_enemytanknear != _target && !_targetsnear) then {_target = _enemytanknear; _attackPos = _enemytankposition; _dist = ([_currpos,_attackPos] call UPSMON_distancePosSqr);};
						}
						else
						{
							_hascapacity = false;
						};
					};
				};
			};
			
			If (_enemyAirsnear) then
			{
				if (!(isnull _enemyAirnear) && alive _enemyAirnear) then
				{
					If ("aa2" in _capacityofgrp || "aa1" in _capacityofgrp) then
					{
						_hascapacity = true;
						If (_enemyAirnear != _target && !_targetsnear) then {_target = _enemyAirnear; _attackPos = _enemyAirposition; _dist = ([_currpos,_attackPos] call UPSMON_distancePosSqr);};
					}
					else
					{
						_hascapacity = false;
					};
				};
			};
			
			// If unit has target make them fight unless they have a nowp2 or 3 parameter or fortify and not flee
			if (!_nowp 
				&& _grpmission != "FORTIFY"
				&& !(fleeing _npc)) then 
			{
				if ((_react >= UPSMON_react && _lastreact >=_minreact) || (count(waypoints group _npc)== 0 && _lastgrpmission == "ATTACK")) then
				{
					if (UPSMON_Debug>0) then {diag_log format["%1: attack Target",_grpidx]};
					_grpmission = "ATTACK"; 
					_pursue = true;
				};
			};
					

			
	//////////// ARTI REACTION ///////////////////////////////////////////////////////////
	
	// If the group is in inferiority call artillery
	_nbrTargets = [_target,50,_side] call UPSMON_checksizetargetgrp;
	_nbrTargets = count _nbrTargets;
	_outbuilding = [_target] call UPSMON_inbuilding;
	
	If (_artillerysideFire
		&& _RadioRange > 0
		&& (_grpmission != "RETREAT")) then
	{
		
		If (count _artillerysideunits > 0
			&& _timeartillery >= 30
			&& !(_target iskindof "Air")) then
		{
			// Ask for Flare if night and don't know enough about eny
			If (UPSMON_Night 
				&& !(UPSMON_FlareInTheAir)
				&& _npc knowsabout _target < 1.9
				&& !("armed" in _typeofgrp)) then 
			{	
				_timeartillery = 0;
				[_artillerysideunits,"FLARE",_RadioRange,getpos _npc,3,_attackpos] spawn UPSMON_Artyhq;
			};
			
			// Artillery on the armored vehicle
			If (_enemytanksnear 
				&& !(isnull _enemytanknear)
				&& alive _enemytanknear
				&& ((speed _enemytanknear) <= 5)) then 
			{
				if (_dist >= 200
					&& _npc knowsabout _enemytanknear >= 1.9
					&& morale _npc > -1
					&& (!_hascapacity || _dist >= 1000)) then
				{
					_timeartillery = 0;
					[_artillerysideunits,"HE",_RadioRange,getpos _npc,2,getpos _enemytanknear] spawn UPSMON_Artyhq;
				};
			};
			
			If (_enemyStaticsnear 
				&& !(isnull _enemyStaticnear)
				&& alive _enemyStaticnear) then 
			{
				If (_dist >= 180
					&& _npc knowsabout _enemyStaticnear >= 1.9
					&& morale _npc > -1) then
				{
					_timeartillery = 0;
					[_artillerysideunits,"HE",_RadioRange,getpos _npc,2,getpos _enemyStaticnear] spawn UPSMON_Artyhq;
				};
			};
			
			If (morale _npc > -1 
				&& (_dist >= 200 && ("infantry" in _typeofgrp))
				&& _npc knowsabout _target >= 1.9) then 
			{
				If (_nbrTargets >= 3 || !_outbuilding || _dist >= 600) then
				{
					_timeartillery = 0;
					[_artillerysideunits,"HE",_RadioRange,getpos _npc,4,_attackpos] spawn UPSMON_Artyhq;
				};
			};
			
		};
	};
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								
		if (UPSMON_Debug>0) then {diag_log format["Artillery condition artillerysideFire: %1 RadioRange: %2 Knowval: %3 timeartillery: %4 nbrTargets: %5",_artillerysideFire,_RadioRange,_npc knowsabout _target,_timeartillery,_nbrTargets]};
	
			//if (UPSMON_Debug>0) then {diag_log format["Reinforcement condition Supressed: %1 Morale: %2 members: %3 unit: %4 Wounded: %5 Targets: %6 reinforcementSent : %7 Reinforcement: %8",_supressed,morale _npc,count _members, count (units _npc),_nbrwoundedunit,(_nbrTargets > (count units _npc) *2),_reinforcementsent,UPSMON_reinforcement]};
			If (!_reinforcementsent && UPSMON_reinforcement) then
			{
				If (!("air" in _typeofgrp) && !("ship" in _typeofgrp)) then
				{
					If (("tank" in _typeofgrp) || ("armed" in _typeofgrp) || ("apc" in _typeofgrp)) then
					{
						If (!_hascapacity) then
						{
							if (UPSMON_Debug>0) then {diag_log format["%1 ask for reinforcement",_grpid]};
							If (_grpmission != "FORTIFY") then {_grpmission = "DEFEND";};
							_reinforcementsent = [getpos _npc,_attackpos,_radiorange,_side,_Enemies,_nbrTargets,_enemytanknear,_npc] spawn UPSMON_Askrenf;
							_reinforcementsent = true;
						};
					}
					else
					{
						if (_supressed  || ((count _members / 2) >= (count (units _npc)) - _nbrwoundedunit) || (morale _npc < -0.6 && (count _Enemies) > (count units _npc)) || !_hascapacity) then
						{
							if (UPSMON_Debug>0) then {diag_log format["%1 ask for reinforcement",_grpid]};
							If (_grpmission != "FORTIFY") then {_grpmission = "DEFEND";};
							_reinforcementsent = [getpos _npc,_attackpos,_radiorange,_side,_Enemies,_nbrTargets,_enemytanknear,_npc] spawn UPSMON_Askrenf;
							_reinforcementsent = true;
						};
					};
				};
			};
			
			
		/////// Group supressed /////////
			If (_grpmission != "FORTIFY" && ("infantry" in _typeofgrp) && !("air" in _typeofgrp)) then
			{
				If (_supressed || morale _npc < -0.8) then
				{
					if (UPSMON_Debug>0) then {diag_log format["UPSMON: gothit: group %1 supressed by fire so defend",_grpidx]};											
				
					//The unit is deleted, delete the current waypoint	
					_grpmission = "DEFEND";
					_wpformation = "LINE";
					_speedmode = "LIMITED";
					_behaviour = "STEALTH";
					
					
				};
			};
		
		////// RETREAT ////////////
			If ( UPSMON_RETREAT && ((random 100)<= _retreat) && _grpmission != "FORTIFY") then
			{
				If ((morale _npc < -1.1) && !_supressed && ("infantry" in _typeofgrp)) then
				{
					_grpmission = "RETREAT";
					if (_fortify) then {{_x enableAI "TARGET";} foreach units (group _npc);} else {(group _npc) enableAttack false;};
					
					If (_artillerysideFire
					&& _RadioRange > 0 
					&& count _artillerysideunits > 0
					&& !(_target iskindof "Air")
					&&	_timeartillery >= 30
					&& _dist >= 200) then 
					{
						_timeartillery = 0;
						[_artillerysideunits,"WP",_RadioRange,getpos _npc,3,_attackpos] spawn UPSMON_Artyhq;
					};
					
					[_npc,_target,_AttackPos,_RadioRange,_timeinfo,_dist] spawn UPSMON_WITHDRAW;
					
					if ((random 100) < 15 && { !_nosmoke } ) then 
					{	
						[_npc,getpos _target] call UPSMON_throw_grenade;
					};
				};
			};	

			//Checks if surrender is enabled
			If ( UPSMON_SURRENDER 
			&& { ("infantry" in _typeofgrp) } 
			&& { alive _npc }
			&& { ((random 100) <= _surrender)}) then
			{
				if (_gothit || fleeing _npc) then
				{
					_Arrayofnearestunit = [_npc,180] call UPSMON_checkallied;
					_alliednear = count (_Arrayofnearestunit select 0);
					_enynear = count (_Arrayofnearestunit select 1);
				
					If ((morale _npc < -1.1 && _supressed && _alliednear < _enynear) || (_alliednear < _enynear && (count units _npc) == count ((_unitsneedammo) select 0))) then
					{
						_surrended = true;
					};
				};
			};
	
			//If surrended exits from script
			if (_surrended) exitwith 
			{	
				{
					[_x] spawn UPSMON_surrended;
				}foreach units group _npc;
		
				if (UPSMON_Debug>0) then {_npc globalchat format["%1: %2 SURRENDED",_grpidx,_side]};		
			};
				
	}; // alive and not null target
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// use smoke when hit or s/o killed	
	//If under attack or increasing knowledge speeds up the response and regain control of the AI
	if ((_sowounded || _gothit || _sokilled || _supressed) && !(_grpmission == "RETREAT")) then 
	{ 
		if (!_supressed) then {_react = _react + 30};
		
		If (!IsNull _target && alive _target && !_fortify) then 
		{
			_makenewtarget = false;
			
			If (_dist > (_closeenough * 2) || _sokilled) then 
			{
				_Behaviour =  "STEALTH";	
				_speedmode = "NORMAL";
				if (behaviour _npc != "AWARE" || behaviour _npc != "STEALTH" || behaviour _npc != "COMBAT") then {_npc setBehaviour _Behaviour;};
				
				if (!_nosmoke && random 100 < UPSMON_USE_SMOKE && _sokilled && (morale _npc < 0) && isNil "bdetect_enable") then 
				{
					{
						If (alive _x && ( "SmokeShell" in (magazines _x))) then
						{
							_smoke = true;
							If (isNil "tpwcas_running" && _x getvariable "tpwcas_supstate" >= 2) then {_smoke = false;};
							If (_smoke) then {nul= [_x,_attackpos] spawn UPSMON_throw_grenade;};
						};
					} foreach units (group _npc);
				};		
			}
			else
			{			
				_pause="NOWAIT";				
				_speedmode = "LIMITED";						
				_Behaviour = "COMBAT";
				if (behaviour _npc != "STEALTH" || behaviour _npc != "COMBAT") then {_npc setBehaviour _Behaviour;};
				
				if (!_nosmoke && random 100 < UPSMON_USE_SMOKE && count _members >= (count (units _npc)) - _nbrwoundedunit && isNil "bdetect_enable") then 
				{
					{
						If (alive _x && ( "SmokeShell" in (magazines _x))) then
						{
							_smoke = true;
							If (isNil "tpwcas_running" && _x getvariable "tpwcas_supstate" >= 2) then {_smoke = false;};
							If (_smoke) then {nul= [_x,_attackpos] spawn UPSMON_throw_grenade;};
						};
					} foreach units (group _npc);
				};					
			};
		}
		else 
		{
			_colorstatus = "ORANGE";				
			_pause="NOWAIT";
			If (_grpmission != "FORTIFY" && _grpmission != "AMBUSH" && !("air" in _typeofgrp || "ship" in _typeofgrp || "car" in _typeofgrp || "tank" in _typeofgrp)) then {if (UPSMON_Debug>0) then {diag_log format["%1: attacked but no target so defend",_grpidx]}; _grpmission = "DEFEND";};
			_speedmode = "FULL";						
			_Behaviour = "AWARE";
			_wpformation = "DIAMOND";
			if (behaviour _npc != "AWARE" || behaviour _npc != "STEALTH" || behaviour _npc != "COMBAT") then {_npc setBehaviour _Behaviour;};
			_makenewtarget = true;

			if (!_nosmoke && random 100 < UPSMON_USE_SMOKE && count _members >= (count (units _npc)) - _nbrwoundedunit) then 
			{
				{
						If (alive _x && ("SmokeShell" in (magazines _x))) then
						{
							_smoke = true;
							If (isNil "tpwcas_running" && _x getvariable "tpwcas_supstate" >= 2) then {_smoke = false;};
							If (_smoke) then {_smokeposition = [getpos _x,((getdir _x) + (random 70)), (random 100) + 50] call UPSMON_GetPos2D; nul= [_x,_smokeposition] spawn UPSMON_throw_grenade;};							
						};					
					
				} foreach units (group _npc);
			};
		};
		
		if (_colorstatus != "YELLOW") then 
		{
			if (_nowpType != 3) then 
			{
				_nowp = false;
			};
		};
	};	
	

		if (_grpmission == "RETREAT") then
		{
			if (morale _npc > 0.8) then
			{
				_grpmission = "DEFEND";
				_wpformation = "DIAMOND";
				_speedmode = "LIMITED";
				_behaviour = "STEALTH";		
			};
		};
		
		//If the enemy has moved away from the radio coverage is not a reinforcement sent we will have lost track
		if (_lastgrpmission != "PATROLALERT"
		&& _grpmission != "REINF"
		&& _grpmission != "RETREAT"
		&& _grpmission != "FORTIFY"
		&& _grpmission != "AMBUSH"
		&& !(fleeing _npc)
		&& _lastgrpmission == "ATTACK") then 
		{	
			If (!isnull(_target) 
				&& _dist < 15
				&& _colorstatus != "GREEN"
				&& _npc knowsabout _target < UPSMON_knowsAboutEnemy
				&& _timeontarget > time) then
			{
				//If squad is near last position and no target clear position of target
				if (UPSMON_Debug>0) then {diag_log format["%1: Target lost",_grpidx]};
				_speedmode = _orgSpeed;	
				_Behaviour = "AWARE";			
				_grpmission = "PATROLALERT";
				_colorstatus = "BLUE";
				_timeonalert = 0;
				_makenewtarget = true; //Go back to the original position
			};

		};
		
		If (_grpmission == "PATROLALERT") then
		{
			If (_timeontarget == 0) then {_timeonalert = time + 90;};
			_centerX = _lastpos select 0;
			_centerY = _lastpos select 1;
			_rangeX = 100;
			_rangeY = 100;
			_areadir = 0;
			If (time > _timeonalert) then {_grpmission = "PATROL";_Behaviour = _orgMode;_targetdead=true;_colorstatus = "GREEN";_target = objnull;};
		};
		

		//If there is no objective order is canceled persecution
		//If captive or surrended do not pursue
		if (_grpmission != "REINF"
		&& _grpmission != "PATROLALERT"
		&& _grpmission != "RETREAT"
		&& _grpmission != "FORTIFY"
		&& _grpmission != "AMBUSH"
		&& !(fleeing _npc)) then 
		{
			if ((isNull (_target)
			|| {captive _target})
			&& _colorstatus != "ORANGE") then
			{
				if (UPSMON_Debug>0) then {diag_log format["%1: Target null",_grpidx]};
				_grpmission = "PATROL";
				_Behaviour = _orgMode;
				_colorstatus = "GREEN";
			};
		};	
		
		
		//If in safe mode if find dead bodies change behaviour
		if ((_colorstatus == "GREEN") && _deadBodiesReact && (IsNull _target))then 
		{
			_unitsin = [_npc,_buildingdist] call UPSMON_deadbodies;
			//_firenear = _npc getvariable "UPS_hear" select 0;
			//|| _firenear
			if (count _unitsin > 0) then { 
				if (!_isSoldier) then {
					_npc setSpeedMode "FULL";					
				} else {
					_Behaviour =  "AWARE";
					_speedmode = "LIMITED";
					_colorstatus = "BLUE";
					//_wpformation = "";
					_npc setBehaviour _Behaviour;
					if (UPSMON_Debug>0) then {player sidechat format["%1 dead bodies found! set %2",_grpidx,_Behaviour]};	
				}; 
			};
		};
		

//**********************************************************************************************************************
// 										END ACQUISITION OF TARGET 	
//**********************************************************************************************************************	

		
		//Ambush ==========================================================================================================
		if (_grpmission == "AMBUSH") then 
		{
			_nowp = true;
			_ambushwait = 10000;
			
			_linked = if ("LINKED:" in _UCthis) then {true} else {false};
			_linkdistance = ["LINKED:",_linkdistance,_UCthis] call UPSMON_getArg;
			_ambushwait = ["AMBUSH:",_ambushwait,_UCthis] call UPSMON_getArg; _ambushwait = ["AMBUSH2:",_ambushwait,_UCthis] call UPSMON_getArg;
			_ambush2 = if ("AMBUSH2:" in _UCthis || "AMBUSH2" in _UCthis || "AMBUSHDIR2:" in _UCthis) then {true} else {false};
			_ambushdistance = [getposATL _npc,(_npc getvariable "UPSMON_Positiontoambush")] call UPSMON_distancePosSqr;
			_targetdistance = 1000;
			_targetknowaboutyou = 0;
			
			if !(isnull _target) then {_targetdistance = [getposATL _npc,getposATL _target] call UPSMON_distancePosSqr;_targetknowaboutyou = _target knowsabout _npc;}; 
			//Ambush enemy is nearly aproach
			//_ambushdist = 50;		
			// replaced _target by _NearestEnemy
		
			_gothit = [_npc] call UPSMON_GothitParam;
			If (_linked) then {{If (_npc distance _x <= _linkdistance && _x getvariable "UPSMON_AMBUSHFIRE" && side _x == _side) exitwith {_linkactivate = true};} foreach UPSMON_NPCs};
			
			If (_npc knowsabout _target >= 4) then {_ambushwait = _ambushwait - 1;};
			
			if ((_gothit  || _linkactivate || (_ambushwait <= 0))
			||((!isNull (_target) && "Air" countType [_target]<=0) && ((_targetdistance <= _ambushdistance)||(_target distance (_npc getvariable "UPSMON_Positiontoambush") < 20) || (_npc knowsabout _target > 3 && _ambush2)))) then
			{ 
				sleep ((random 1) + 1); // let the enemy then get in the area 
				
				if (UPSMON_Debug>0) then {diag_log format["%1: FIREEEEEEEEE!!! Gothit: %2 linkactivate: %3 Distance: %4 PositionToAmbush: %5 AmbushWait:%6 %7",_grpidx,_gothit,_linkactivate,(_targetdistance <= _ambushdistance),_target distance (_npc getvariable "UPSMON_Positiontoambush") < 20,_ambushwait <= 0,(_npc knowsabout _target > 3 && _ambush2)]};
			
				_npc setBehaviour "COMBAT";
				_CombatMode = "YELLOW";
				
				{
					_x setvariable ["UPSMON_AMBUSHFIRE",true];
					If !(isNil "bdetect_enable") then {_x setVariable ["bcombat_task", nil];};
				} foreach units _npc;
				
				_nowp = false;
				_ambush = false;
				_linkactivate = false;
								
				//No engage yet
				_grpmission = "DEFEND";
				_wpformation = "LINE";
				_speedmode = "LIMITED";
			};			
		}; 
		
		//END Ambush ==========================================================================================================	
		// did the leader die?
		_npc = [_npc,_members] call UPSMON_getleader;							
		if (!alive _npc || !canmove _npc || isplayer _npc ) then {[_npc,_Ucthis,_target,_orgpos,_surrended,_closeenough,_grpidx,_membertypes,_vehicletypes,_side] call UPSMON_Respawngrp;};
		If (!(_npc in UPSMON_NPCs)) then {UPSMON_NPCs = UPSMON_NPCs + [_npc];};
		
		//If no fixed target check if current target is available
		if (format ["%1",_fixedtargetPos] != "[0,0]") then {	
			//If fixed target check if close enough or near enemy and gothit
			if (([_currpos,_fixedtargetpos] call UPSMON_distancePosSqr) < 100 || !Isnull _target) then {		
				_attackPos=_fixedtargetPos;
				_grpmission == "ATTACK";
			} else {
				_targetpos = _fixedtargetPos;
				_grpmission = "REINF";				
			};
		};	
		
	
		if (_inheli) then {
			_heli = vehicle _npc;  // ToDo check if this is indeed heli an not AI himself
			if (!isnil "_heli") then 
			{
				_landing = _heli getVariable "UPSMON_landing";
				if (isnil ("_landing")) then {_landing=false;};
				if (_landing) then {	
					_grpmission = "DEFEND";
					_wpformation = "DIAMOND";
					_speedmode = "FULL";
				};
			};
		};
		
		


		
// **********************************************************************************************************************
//   								COMBAT ORDERS
// **********************************************************************************************************************

		// UPSMON GROUP DEFEND Their position
		if (_grpmission == "DEFEND" && (_lastgrpmission != "DEFEND") && !_nowp) then 
		{
			_react = 0;
			_lastreact = 0;
			if (UPSMON_Debug>0) then {diag_log format["UPSMON: Group %1 is in defense",_grpidx]};
			
			_lastwptype = "HOLD";
			[_npc,_dist,_target,_wpformation,_speedmode,_behaviour,_grpid,_buildingdist,_attackpos,_typeofgrp] spawn UPSMON_DODEFEND;
		};		
	
		// UPSMON GROUP ATTACK AND PURSUE NEAREST TARGET
		if (_grpmission == "ATTACK" && _pursue && !_nowp) then 
		{		
			if (UPSMON_Debug>0) then {diag_log format["UPSMON: Group %1 is in pursue",_grpidx]};  	
			_react = 0;	
			_lastreact = 0;
			_timeontarget = time + UPSMON_maxwaiting; 
			_fm = 1;
			_pause="NOWAIT";
	
			// did the leader die?
			_npc = [_npc,_members] call UPSMON_getleader;							
			if (!alive _npc || { isplayer _npc } || (isNil("_npc")) || _npc getvariable "UPSMON_Deletegroup") exitwith {[_npc,_Ucthis,_target,_orgpos,_surrended,_closeenough,_grpidx,_membertypes,_vehicletypes,_side] call UPSMON_Respawngrp;_cycle = 0;};		
			If (!(_npc in UPSMON_NPCs)) then {UPSMON_NPCs = UPSMON_NPCs + [_npc];};
			
			[_npc,_attackPos,_dist,_noveh,_noveh2,_grpid,_nofollow,_buildingdist,_typeofgrp] spawn UPSMON_DOATTACK;
			
		};	//END PURSUE
		
		//Is updated with the latest value, changing the target
		_lastknown = _opfknowval; 
		
		If (_colorstatus == "YELLOW") then
		{
			if ( _dist <= _closeenough ) then 
			{	
				//If we are so close we prioritize discretion fire
				if ( _dist <= _closeenough/2 ) then 
				{	
					_react = _react + UPSMON_react / 2;
					_minreact = UPSMON_minreact / 2;
					_wptype = "SAD";
				} 
				else 
				{
					//If the troop has the role of not moving tend to keep the position	
					_minreact = UPSMON_minreact/1.5;					
				};								
			} 
			else	
			{	
				
				if (_dist <= (_closeenough + UPSMON_safedist)) then 
				{
					_minreact = UPSMON_minreact;						
				} 
				else 
				{
					
					//In May distance of radio patrol act..
					if (( _dist <  UPSMON_sharedist )) then 
					{
						_minreact = UPSMON_minreact * 2;
					} 
					else 
					{
						//Platoon very far from the goal if not move nomove role
						_minreact = UPSMON_minreact * 3;						
												
					};
				};	
			};
		};
		
		If (_grpmission == "FORTIFY" && !(IsNull _target) && alive _target && _dist <= _closeenough && _timeontarget > time) then
		{
			_timeontarget = time + 20; 
			{
				_outbuilding = [_x] call UPSMON_inbuilding;
				if (alive _x && !_outbuilding && unitready _x) then {[_x,_dist,_supressed] spawn UPSMON_unitdefend;};
			} foreach units _npc;
		};
	}; //((_isSoldier)
	
	



// **********************************************************************************************************************
//   								PATROL ORDERS
// **********************************************************************************************************************
		if ((_grpmission == "PATROL" || _grpmission == "PATROLALERT") && !_nowp && !(fleeing _npc)) then 
		{
			_gothit = false;
			_targetdead	= true;
			_speedmode = _orgSpeed;
			_reinforcementsent = false;
			(group _npc) enableAttack false;
			if (_lastgrpmission == "ATTACK") then {{_x dofollow _npc;} foreach (units _grp - [_npc]);};
		
			//Gets distance to targetpos
			_targetdist = [_currPos,_targetPos] call UPSMON_distancePosSqr;	
		
			if (isNil "_lastcurrpos") then
			{
				_lastcurrpos = [0,0];
			};
		
			//Stuck control
			if (alive _npc
			&& canmove _npc 
			&& _lastcurrpos select 0 == _currpos select 0 
			&& _lastcurrpos select 1 == _currpos select 1
			&& (_timeontarget > time)
			&& !("Air" countType [vehicle (_npc)]>0)) then 
			{
				[_npc] call UPSMON_cancelstop;	
				_makenewtarget = true;
		
				if (UPSMON_Debug>0) then {player sidechat format["%1 stucked, moving",_grpidx]};	
				if (UPSMON_Debug>0) then {diag_log format["%1 stuck for %2 seconds - trying to move again",_grpidx, _timeontarget]};	
			};
		
			//rStuckControl !R					
			if (_lastcurrpos select 0 == _currpos select 0 
			&& _lastcurrpos select 1 == _currpos select 1
			&& (_timeontarget > time)
			&& !("Air" countType [vehicle (_npc)]>0)) then 
			{
				if (UPSMON_Debug>0) then {player sidechat format["%1 !RstuckControl try to move",_grpidx]};
				if (vehicle _npc != _npc) then 
				{
					_rstuckControl = _rstuckControl + 1;
							
					if (_rstuckControl > 1) then 
					{
						_jumpers = crew (vehicle _npc);
						{
							_x spawn UPSMON_doGetOut;	
							sleep 0.5;
						} forEach _jumpers;
					} 
					else 
					{	
						nul = [vehicle _npc, 25] spawn UPSMON_domove;
					}
				}
				else 
				{
					nul = [_npc, 25] spawn UPSMON_domove;
				};
			}
			else 
			{
				_rstuckControl = 0;
			};	
			_islanding = _npc getVariable "UPSMON_movetolanding";
			_index = currentWaypoint (group _npc);
			
			_targetdist = 10000;
			
			If (count(waypoints group _npc)> 0) then
			{
				_wppos = waypointPosition [group _npc,count(waypoints group _npc)-1];
				_targetdist = [getpos _npc,_wppos] call UPSMON_distancePosSqr;
			};
			
			if ((_inheli && isnil ("_islanding")) && (_targetdist <= (30 + _flyInHeight) || moveToFailed _npc || moveToCompleted _npc)) then
			{
				_makenewtarget=true;
				_Behaviour = _orgMode;
			};
			
			
			if ((_targetdist <= 10 || moveToFailed _npc || moveToCompleted _npc) && !(_npc getvariable "UPSMON_searchingpos")) then 
			{
				_makenewtarget=true;
				_Behaviour = _orgMode;
			};
			
			if (_makenewtarget) then
			{
				_gothit = false;
				_react = 0;		
				_lastreact = 0;	
				_makenewtarget = false;				
				_timeontarget = time + 60; 
				
				[_npc,_wpformation,_speedmode,[_centerX,_centerY,_rangeX,_rangeY,_areadir],_noveh,_dist,_onroad,_grpid,_Behaviour,_combatmode,_typeofgrp] spawn UPSMON_DOPATROL;
			};
		};
		
		// Is the group has vehicle
		if (UPSMON_Debug>0) then {player sidechat format ["%1 %2",_assignedvehicle,_targetPos];};
		If (count _assignedvehicle > 0 && count(waypoints group _npc)> 0 && _issoldier && !(_npc getvariable "UPSMON_searchingpos")) then
		{

			_wppos = waypointPosition [group _npc,count(waypoints group _npc)-1];
			_targetdist = [getposATL _npc,_wppos] call UPSMON_distancePosSqr;
		
			//Check if vehicle is stucked or enemy unit near and has a cargo
			{
				_vehicle = vehicle _x;
				if (UPSMON_Debug>0) then {diag_log format ["%1 %2 %3 %4",_assignedvehicle,_vehicle iskindof "air",_vehicle iskindof "StaticWeapon",(_vehicle iskindof "MAN")];};
				if (!(_vehicle iskindof "AIR") && !(_vehicle iskindof "StaticWeapon") && !(_vehicle iskindof "MAN")) then
				{
					_get_out_dist = UPSMON_closeenoughV  * ((random .4) + 1);
					If (_vehicle iskindof "TANK" || _vehicle iskindof "Wheeled_APC_F" || !(IsNull (gunner _vehicle))) then {_get_out_dist = UPSMON_closeenough  * ((random .4) + 0.8);};
					_unitsincargo = [_vehicle] call UPSMON_FN_unitsInCargo;
					_timedsk = 0;
					
					_timechk = _vehicle getvariable "UPSMON_disembarking";
					If (Isnil "_timechk") then {_timedsk = time; _vehicle setvariable ["UPSMON_disembarking",_timedsk]; if (UPSMON_Debug>0) then {player sidechat format ["_timedsk: %1",_timedsk];};};
					
					if (UPSMON_Debug>0) then {diag_log format ["time:%1 lasttime: %2 targetdist:%3 Cargo:%4 _get_out_dist:%5",time, _vehicle getvariable "UPSMON_disembarking",_targetdist,_unitsincargo,_get_out_dist];};
					
					if (time >= (_vehicle getvariable "UPSMON_disembarking")) then
					{
						if (!(canmove _vehicle) 
						|| !(alive (driver _vehicle)) 
						|| ((_dist <= _get_out_dist || _gothit || _targetdist <= (200 * ((random .4) + 1))) && count _unitsincargo > 0)) then
						{
							[_vehicle] spawn UPSMON_dodisembark;
							_timedsk = time + 20;
							_vehicle setvariable ["UPSMON_disembarking",_timedsk];
						};
					};
				};
			} foreach _assignedvehicle;
		};

		//	if (UPSMON_Debug>0) then {player sidechat format["%1 rea=%2 wai=%3 tim=%4 tg=%5 %6",_grpidx,_react,_waiting,_timeontarget,typeof _target,alive _target]};							
			
		//If in hely calculations must done faster
		if (_inheli && _npc == (vehicle _npc)) then 
		{
			_flyInHeight = UPSMON_flyInHeight;
			If ((getPosATL (vehicle _npc)) select 2 < UPSMON_flyInHeight && !(_npc getvariable "UPSMON_DskHeli")) then {vehicle _npc flyInHeight _flyInHeight;};
			_speedmode = "FULL";
		};
			
		// did the leader die?
		_npc = [_npc,units _npc] call UPSMON_getleader;							
		if (!alive _npc || !canmove _npc || isplayer _npc ) exitwith {[_npc,_Ucthis,_target,_orgpos,_surrended,_closeenough,_grpidx,_membertypes,_vehicletypes,_side] call UPSMON_Respawngrp;};			
		If (!(_npc in UPSMON_NPCs)) then {UPSMON_NPCs = UPSMON_NPCs + [_npc];};			
		_lastwptype = _wptype;
		_lastgrpmission = _grpmission;
									
				
		//if (UPSMON_Debug>0) then {player sidechat format["%1: %2 %3 %4 %5 %6 %7 %8 %9 %10",_grpidx, _wptype, _targettext,_dist, _speedmode, _unitpos, _Behaviour, _wpformation,_fightmode,count waypoints _grp];};											

		if ((_exit) || (isNil("_npc")) || _npc getvariable "UPSMON_Deletegroup") exitwith
		{
			[_npc,_Ucthis,_target,_orgpos,_surrended,_closeenough,_grpidx,_membertypes,_vehicletypes,_side] call UPSMON_Respawngrp;
		}; 
		
		//Refresh position vector
		//UPSMON_targetsPos set [_grpid,_targetPos];
		_lastpos=_targetPos;
		_lastreact = _react;
	
		{
			_x setvariable ["UPSMON_Lastinfos",[_lastcurrpos,_lastwptype,_lastpos,_lastknown,_target,_flankdir,units _npc,_timeinfo]];
			_x setvariable ["UPSMON_TIMEONTARGET",[_timeontarget,_timeonalert]];
			_x setvariable ["UPSMON_NOWP",[_nowp,_nowptype]];
			_x setvariable ["UPSMON_Fortify",[_fortifyorig,_fortify]];
			_x setvariable ["UPSMON_makenewtarget",_makenewtarget];
			_x setvariable ["UPSMON_REINFORCEMENTSENT",[_reinforcementsent,_timereinforcement]];
			_x setvariable ["UPSMON_TimeArtillery",_timeartillery];
			_x setvariable ["UPSMON_Grpstatus",[_grpmission,_colorstatus,_lastgrpmission,[_react,_lastreact,_minreact],_target,_targetpos]];
			_x setvariable ["UPSMON_REACT",[_react,_lastreact,_minreact]];
		} foreach units _npc;
		
		sleep 0.3;
	} count UPSMON_NPCs > 0;
	
	sleep _cycle;
	
}; //loop