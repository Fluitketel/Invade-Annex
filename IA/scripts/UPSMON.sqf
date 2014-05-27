// SERVER OR HEADLESS CLIENT CHECK
//if (!isServer) exitWith {};
if (!isServer && hasInterface ) exitWith {};

if (isNil("UPSMON_INIT")) then {
	UPSMON_INIT=0;
};

if (isNil("UPSMON_Night")) then {
	UPSMON_Night = false;
};

waitUntil {UPSMON_INIT==1};

if (hasInterFace) exitWith {Diag_log "I was kicked from the UPSMON.sqf I am a client";};

if(DEBUG) then
						{
							Diag_log FORMAT ["======%1 is UPSMON====",_this select 0];
						};
	

// convert argument list to uppercase
	_UCthis = [];
	for [{_i=0},{_i<count _this},{_i=_i+1}] do {
			_e=_this select _i;
			if (typeName _e=="STRING") then {_e=toUpper(_e)};
			_UCthis set [_i,_e]
		};

	if ((count _this)<2) exitWith {
		if (format["%1",_this]!="INIT") then {hint "UPSMON: Unit and marker name have to be defined!"};
	};
	
// Postioning
private ["_UCthis","_i","_e","_obj","_npc","_lastcurrpos","_grpid","_grpidx","_grpname","_side","_rnd","_bcombat_running","_areamarker","_centerpos","_centerX","_centerY","_showmarker","_exit","_members","_respawn","_respawnmax","_custom",
"_vehicles","_equipment","_membertypes","_vehicletypes","_isman","_iscar","_isboat","_isplane","_isdiver","_isSoldier","_friends","_enemies","_sharedenemy","_enemyside","_friendside","_areasize","_rangeX","_rangeY","_area","_areadir","_cosdir","_sindir",
"_orgMode","_orgSpeed","_speedmode","_behaviour","_currpos","_orgPos","_orgdir","_orgwatch","_lastpos","_fortify","_buildingdist","_grp","_template","_nowpType","_rfid","_reinforcement",
"_radiorange","_waiting","_positiontoambush","_fortifyorig","_nowp","_ambush","_areatrigger","_spawned","_vehicletypes","_initpos","_try","_bld","_bldpos","_nbrbldpos","_allpos","_bldpositions","_ocercanos","_bldnotin","_deletedead","_mincopies","_maxcopies",
"_trgside","_trgname","_flagname","_unitsIn"];

_npc = ObjNull;
_grpid =0;
_rnd = 0;
_respawnmax = 0;
_vehicles = [];
_membertypes = [];
_vehicletypes =[];
_vehicle = objnull;
_index = 0;
_wp=[];
_wptype="";
_wpformation = "VEE";
_bld = objnull;
_Mines = 3; // org 1 - ToDo set to 4 ?
_enemytanks = [];
_friendlytanks =[];
_enemytanksnear = false;
_friendlytanksnear = false;
_enemytanknear = objnull;
_NearestEnemy = objnull;
_buildingdist = 25;
_wait=90;
_side="";
_friendside=[];
_enemyside=[];
_surrender = 0;
_retreat = 0;
_inheli = false;
_spawned = false;
_nowp = false;
_unitsIn = [];
_respawn = false;
_respawnmax = 10000;
_safemode=["CARELESS","SAFE"];
_vehicles = [];


// unit that's moving
_obj = leader (_this select 0); //group or leader

if ( isnil "_obj") exitwith 
{	
	hint format ["Object: %1",_obj];
	diag_log format ["UPSMON: Object for _npc: %1",_obj];
};

_npc = _obj;
			
if (isnil "_lastcurrpos") then {_lastcurrpos = [0,0,0]};

// give this group a unique index
UPSMON_Instances = UPSMON_Instances + 1;
_grpid = UPSMON_Instances;
_grpidx = format["%1",_grpid];

_grpname = format["%1_%2",(side _npc),_grpidx];
_side = side _npc;


//To not run all at the same time we hope to have as many seconds as id's
_rnd = _grpid;
sleep (random 0.8);

_bcombat_running = if (!isNil "bdetect_enable") then {true} else {false};

if (_bcombat_running) then {waitUntil { !(isNil "bdetect_init_done") };};

// == set "UPSMON_grpid" to units in the group and EH===============================  
	{
		_x setVariable ["UPSMON_grpid", _grpid, false];
		_x setVariable ["UPSMON_Ucthis", _Ucthis, false];
		_x setvariable ["UPSMON_Grpinfos",[side _npc,units _npc,group _npc]];
		
		sleep 0.05;
		
		
		if (side _x != civilian) then 
		{//soldiers 
			_x AddEventHandler ["hit", {nul = _this spawn UPSMON_SN_EHHIT}];	
			sleep 0.05;	
			_x AddEventHandler ["killed", {nul = _this spawn UPSMON_SN_EHKILLED}];	
			
		}
		else
		{//civ
			if (! isnil "_x") then {
				sleep 0.05;
				_x AddEventHandler ["firedNear", {nul = _this spawn UPSMON_SN_EHFIREDNEAR}];
				sleep 0.05;
				_x AddEventHandler ["killed", {nul = _this spawn UPSMON_SN_EHKILLEDCIV}];
				sleep 0.05;
			};
		};
	} foreach units _npc;


//if is vehicle will not be in units so must set manually

	if (isnil {_npc getVariable ("UPSMON_grpid")}) then {		
		_npc setVariable ["UPSMON_grpid", _grpid, false];
		_npc setvariable ["UPSMON_Grpinfos",[side _npc,units _npc,group _npc]];
		sleep 0.05;
		
		if (side _npc != civilian) then 
		{ //soldiers
			_npc AddEventHandler ["hit", {nul = _this spawn UPSMON_SN_EHHIT}];	
			sleep 0.05;
			_npc AddEventHandler ["killed", {nul = _this spawn UPSMON_SN_EHKILLED}];	
	
		}		
		else
		{ //civilian
			_npc AddEventHandler ["firedNear", {nul = _this spawn UPSMON_SN_EHFIREDNEAR}];
			sleep 0.05;	
			_npc AddEventHandler ["killed", {nul = _this spawn UPSMON_SN_EHKILLEDCIV}];
			sleep 0.05;
		};
	};

	//the index will be _grpid  

	
if (UPSMON_Debug>0) then {player sidechat format["%1: New instance %2 %3 %4",_grpidx,_npc getVariable ("UPSMON_grpid")]}; 


// == get the name of area marker ==============================================
	_areamarker = _this select 1;
	if (isNil ("_areamarker")) exitWith {
		hint "UPSMON: Area marker not defined.\n(Typo, or name not enclosed in quotation marks?)";
	};	

	// remember center position of area marker
	_centerpos = getMarkerPos _areamarker;
	_centerX = abs(_centerpos select 0);
	_centerY = abs(_centerpos select 1);
	_centerpos = [_centerX,_centerY];

	// show/hide area marker 
	_showmarker = if ("SHOWMARKER" in _UCthis) then {"SHOWMARKER"} else {"HIDEMARKER"};
	if (_showmarker=="HIDEMARKER") then 
	{
		_areamarker setMarkerPos [-abs(_centerX),-abs(_centerY)];
	};
	
	// X/Y range of target area
	_areasize = getMarkerSize _areamarker;
	_rangeX = _areasize select 0;
	_rangeY = _areasize select 1;
	_area = abs((_rangeX * _rangeY) ^ 0.5);
	
	// marker orientation (needed as negative value!)
	_areadir = (markerDir _areamarker) * -1;

	// store some trig calculations
	_cosdir=cos(_areadir);
	_sindir=sin(_areadir);

// is anybody alive in the group?
_exit = true;

if (UPSMON_Debug>0) then {diag_log format["UPSMON - npc [%1] - typename [%2] - typeof [%3] - units [%4]",_npc, typename _npc, typeof _npc, units (group _npc)];};	
	
	if ( !isNull _npc && { typeName _npc=="OBJECT" } ) then 
	{		
		if (!isNull group _npc) then 
		{
			_npc = ([_npc,units (group _npc)] call UPSMON_getleader);
		}
		else 
		{
			_vehicles = [_npc,2] call UPSMON_nearestSoldiers;
			if (count _vehicles>0) then 
			{
				_npc = [_vehicles select 0,units (_vehicles select 0)] call UPSMON_getleader;
			};
		};
	}
	else 
	{
		if (count _obj>0) then {
			_npc = [_obj,count _obj] call UPSMON_getleader;			
		};
	};
	
	// set the leader in the vehilce
	if (!(_npc iskindof "Man")) then { 
		if (!isnull(commander _npc) ) then {
			_npc = commander _npc;
		}else{
			if (!isnull(driver _npc) ) then {
				_npc = driver _npc;
			}else{			
				_npc = gunner _npc;	
			};	
		};
		group _npc selectLeader _npc;
	};

// ===============================================	
	if (alive _npc) then {_exit = false;};	
	if (UPSMON_Debug>0 && _exit) then {player sidechat format["%1 There is no alive members %1 %2 %3",_grpidx,typename _npc,typeof _npc, count units _npc]};	

	
	// exit if something went wrong during initialization (or if unit is on roof)
	if (_exit) exitWith {
		if (UPSMON_DEBUG>0) then {hint "Initialization aborted"};
	};



// remember the original group members, so we can later find a new leader, in case he dies
	_members = units _npc;
	UPSMON_Total = UPSMON_Total + (count _members);

// respawn
	_respawn = if ("RESPAWN" in _UCthis) then {true} else {false};
	_respawn = if ("RESPAWN:" in _UCthis) then {true} else {false};
	if (_respawn) then {_respawnmax = ["RESPAWN:",_respawnmax,_UCthis] call UPSMON_getArg;};
//Custom loadout
	_custom = if ("CUSTOM" in _UCthis) then {true} else {false};
	

//Fills member soldier types
	{	
		if (vehicle _x != _x ) then {
			_vehicles = _vehicles - [vehicle _x];
			_vehicles = _vehicles + [vehicle _x];
		};
		_equipment = [];
		
		If (_custom && _respawn && vehicle _x == _x) then {_equipment = _x call UPSMON_getequipment};
		_membertypes = _membertypes + [[typeof _x,_equipment]];
	} foreach _members;

//Fills member vehicle types
	{
		_vehicletypes = _vehicletypes + [typeof _x];
	} foreach _vehicles;

// what type of "vehicle" is _npc ?
	_isman = "Man" countType [ vehicle _npc]>0;
	_iscar = "LandVehicle" countType [vehicle _npc]>0;
	_isboat = "Ship" countType [vehicle _npc]>0;
	_isplane = "Air" countType [vehicle _npc]>0;
	_isdiver = ["diver", (typeOf (leader _npc))] call BIS_fnc_inString;
	
	//diag_log format ["UPSMON diver: %1: %2", typeOf (leader _npc), ['diver', (typeOf (leader _npc))] call BIS_fnc_inString];

// we just have to brute-force it for now, and declare *everyone* an enemy who isn't a civilian // ToDo rewrite using getFriend
	_isSoldier = _side != civilian;

	_friends=[];
	_enemies=[];	
	_sharedenemy=0;

	if (_isSoldier) then {
		switch (_side) do {
		case west:
			{ 	_sharedenemy=0; 
				_friendside = [west];
				_enemyside = [east];				
			};
		case east:
			{  _sharedenemy=1; 
				_friendside = [east];
				_enemyside = [west];
			};
		case resistance:
			{ 
			 _sharedenemy=2; 
			 _enemyside = UPSMON_Res_enemy;
			 
				if (!(east in _enemyside)) then {	
					_friendside = [east];
				}; 
				if (!(west in _enemyside)) then {
					_friendside = [west];
				};			 
			};
		};
	};
	
	if (_side in UPSMON_Res_enemy) then {
		_enemyside = _enemyside + [resistance];
	}else {
		_friendside = _friendside + [resistance];	
	};
	sleep .05;	

// global unit variable to externally influence script 
//call compile format ["UPSMON_%1=1",_npcname];


// set first target to current position (so we'll generate a new one right away)
_currPos = getpos _npc;
_orgPos = _currPos;
_orgDir = getDir _npc; 
_lastpos = _currPos;

_target = objnull;

_fortify = false;
_blds = [];
_buildingdist= 25;//Distance to search buildings near 
_grp = grpnull;
_grp = group _npc;
_template = 0;
_nowpType = 1;
_rfid = 0;
_RadioRange = 8000;

// remember the original mode & speed
_orgMode = "SAFE";
_orgSpeed = speedmode _npc;
_speedmode= "LIMITED";
_orgformation = "STAG COLUMN";

_Behaviour = _orgMode;

_waiting = 0;
_positiontoambush = [0,0,0];
_Patrlbld = false;
_grpmission = "PATROL";


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ***************************************** optional arguments *****************************************************************//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// set If enemy detected reinforcements will be sent REIN1
_rfid = ["REINFORCEMENT:",0,_UCthis] call UPSMON_getArg; // rein_#
_reinforcement= if ("REINFORCEMENT" in _UCthis) then {"REINFORCEMENT"} else {"NOREINFORCEMENT"}; //rein_yes
If (_reinforcement == "REINFORCEMENT") then {
	switch (_side) do {
		case West: {
		if (isnil "UPSMON_REINFORCEMENT_WEST_UNITS") then  {UPSMON_REINFORCEMENT_WEST_UNITS = []};
		UPSMON_REINFORCEMENT_WEST_UNITS = UPSMON_REINFORCEMENT_WEST_UNITS + [_npc];
		PublicVariable "UPSMON_REINFORCEMENT_WEST_UNITS";		
		};
		case EAST: {
		if (isnil "UPSMON_REINFORCEMENT_EAST_UNITS") then  {UPSMON_REINFORCEMENT_EAST_UNITS = []};
		UPSMON_REINFORCEMENT_EAST_UNITS = UPSMON_REINFORCEMENT_EAST_UNITS + [_npc];
		PublicVariable "UPSMON_REINFORCEMENT_EAST_UNITS";	
		};
		case INDEPENDENT: {
		if (isnil "UPSMON_REINFORCEMENT_GUER_UNITS") then  {UPSMON_REINFORCEMENT_GUER_UNITS = []};
		UPSMON_REINFORCEMENT_GUER_UNITS = UPSMON_REINFORCEMENT_GUER_UNITS + [_npc];
		PublicVariable "UPSMON_REINFORCEMENT_GUER_UNITS";			
		};
	};
};


//fortify group in near places
_fortify= if ("FORTIFY" in _UCthis) then {true} else {false};
_fortifyorig = if ("FORTIFY" in _UCthis) then {true} else {false};

	
// don't make waypoints
_nowp = if ("NOWP" in _UCthis || "NOWP2" in _UCthis || "NOWP3" in _UCthis) then {true} else {false};
_nowpType = if ("NOWP2" in _UCthis) then {2} else {_nowpType}; _nowpType = if ("NOWP3" in _UCthis) then {3} else {_nowpType};
	
//Ambush squad will no move until in combat or so close enemy
_ambush= if (("AMBUSH" in _UCthis) || ("AMBUSHDIR:" in _UCthis) || ("AMBUSH2" in _UCthis) || ("AMBUSHDIR2:" in _UCthis)) then {true} else {false};
	
// Range of AI radio so AI can call Arty or Reinforcement
if ("RADIORANGE:" in _UCthis) then {_RadioRange = ["RADIORANGE:",_RadioRange,_UCthis] call UPSMON_getArg;}; // ajout

	
// set behaviour modes (or not)
if ("CARELESS" in _UCthis) then {_orgMode = "CARELESS"}; 
if ("SAFE" in _UCthis) then {_orgMode = "SAFE"};
if ("AWARE" in _UCthis) then {_orgMode = "AWARE"}; 
if ("COMBAT" in _UCthis) then {_orgMode = "COMBAT"}; 
if ("STEALTH" in _UCthis) then {_orgMode = "STEALTH"}; 

If ("COLUMN" in _UCthis) then {_orgformation = "COLUMN";};
If ("STAG COLUMN" in _UCthis) then {_orgformation = "STAG COLUMN";};
If ("WEDGE" in _UCthis) then {_orgformation = "WEDGE";};
If ("VEE" in _UCthis) then {_orgformation = "VEE";};
If ("LINE" in _UCthis) then {_orgformation = "LINE";};
	
// set initial speed
_noslow = if ("NOSLOW" in _UCthis) then {"NOSLOW"} else {"SLOW"};
if (_noslow=="NOSLOW") then {
	_speedmode = "FULL";		
}; 


// "area cleared" trigger activator
	_areatrigger = if ("TRIGGER" in _UCthis) then {"TRIGGER"} else {if ("NOTRIGGER" in _UCthis) then {"NOTRIGGER"} else {"SILENTTRIGGER"}};

	// suppress fight behaviour
	if ("NOAI" in _UCthis) then {_isSoldier=false};


	//spawned for squads created in runtime
	_spawned= if ("SPAWNED" in _UCthis) then {true} else {false};
	if (_spawned) then {
		if (UPSMON_Debug>0) then {player sidechat format["%1: squad has been spawned, respawns %2",_grpidx,_respawnmax]}; 	
		switch (side _npc) do {
			case west:
			{ 	UPSMON_AllWest=UPSMON_AllWest + units _npc; 
			};
			case east:
			{  	UPSMON_AllEast=UPSMON_AllEast + units _npc; };
			case resistance:
			{  	
				UPSMON_AllRes=UPSMON_AllRes + units _npc; 
				if (east in UPSMON_Res_enemy ) then {	
					UPSMON_East_enemies = UPSMON_East_enemies+units _npc;
				} else {
					UPSMON_East_friends = UPSMON_East_friends+units _npc;
				}; 
				if (west in UPSMON_Res_enemy ) then {
					UPSMON_West_enemies = UPSMON_West_enemies+units _npc;
				} else {
					UPSMON_West_friends = UPSMON_West_friends+units _npc;
				};				
			};		
		};
		if (side _npc != civilian) then {call (compile format ["UPSMON_%1_Total = UPSMON_%1_Total + count (units _npc)",side _npc]);}; 	
	
		_vehicletypes = ["VEHTYPE:",_vehicletypes,_UCthis] call UPSMON_getArg; 
	
	};

// set drop units at random positions
	_initpos = "ORIGINAL";
	if ("RANDOM" in _UCthis) then {_initpos = "RANDOM"};
	if ("RANDOMUP" in _UCthis) then {_initpos = "RANDOMUP"}; 
	if ("RANDOMDN" in _UCthis) then {_initpos = "RANDOMDN"};
	if ("RANDOMA" in _UCthis) then {_initpos = "RANDOMA"};
	// don't position groups or vehicles on rooftops
	if ((_initpos!="ORIGINAL") && (!_isman)) then {_initpos="RANDOM"};



//set Is a template for spawn module?
	_template = ["TEMPLATE:",_template,_UCthis] call UPSMON_getArg;
	//Fills template array for spawn
	if (_template > 0 && !_spawned) then {
		UPSMON_TEMPLATES = UPSMON_TEMPLATES + ( [[_template]+[_side]+[_membertypes]+[_vehicletypes]] );
		//if (UPSMON_Debug>0) then {diag_log format["%1 Adding TEMPLATE %2 _spawned %3",_grpidx,_template,_spawned]};	
		//if (UPSMON_Debug>0) then {player globalchat format["TAR_TEMPLATES %1",count TAR_TEMPLATES]};		
	};


// make start position random 
	if (_initpos!="ORIGINAL") then {
		// find a random position (try a max of 20 positions)
		_try=0;
		_bld=0;
		_bldpos= [];
		_nbbldpos=0;
		_allpos = [];
		_bldpositions = [];
		if (_initpos=="RANDOM") then
		{
			while {_try<20} do {
				_currPos = [];
				if (_isboat || _isDiver) then {_currPos = [_npc,[_centerX,_centerY,_rangeX,_rangeY,_areadir],0,0,1,1,false] call UPSMON_FindPos;} else {_currPos=[_npc,[_centerX,_centerY,_rangeX,_rangeY,_areadir],0,0,0.7,0,false] call UPSMON_FindPos;};
		
				if (count _currPos > 0) then {_try=99};
				_try=_try+1;
				sleep .01;
			};
			
			
		};
		
		If ((_initpos=="RANDOMUP") || (_initpos=="RANDOMDN") || (_initpos=="RANDOMA")) then
		{
			_OCercanos = [ (nearestObjects [[_centerX,_centerY,0], ["house","building"], _area]), { _x call UPSMON_filterbuilding } ] call BIS_fnc_conditionalSelect;
			_OCercanos = _OCercanos call BIS_fnc_arrayShuffle;
			
			{
				_allpos = [_x,_initpos] call UPSMON_SortOutBldpos;
				_allpos = [_allpos] call UPSMON_Checkfreebldpos2;
				_nbbldpos = _nbbldpos + (count _allpos);
				If (count _allpos > 0) then {_bldpositions = _bldpositions + [[_x,_allpos]];};
				If (_nbbldpos >= 3*(count units _npc)) exitwith {_bldpositions};
			}foreach _OCercanos;
			
		};
		
		if (_nbbldpos < (count units _npc) ) then 
		{
			if (count _currPos == 0) then {_currPos = getPos _npc;};
			{ //man
				if (vehicle _x == _x) then 
				{
					_targetpos = _currPos findEmptyPosition [5, 50];
					sleep .05;						
					if (count _targetpos <= 0) then {_targetpos = _currpos};
					_x setpos _targetpos;	
				};
			} foreach units _npc; 
						
			{ // vehicles
				_targetpos = [];
				If (!_isboat) then {_targetpos = _currPos findEmptyPosition [10, 50];};
				sleep .05;						
				if (count _targetpos <= 0) then {_targetpos = _currpos};
				_x setPos _targetpos;
			} foreach _vehicles;
		} 
		else 
		{
		// put the unit on top of a building
			[units _npc,_bldpositions,_npc] spawn UPSMON_SpawninBuildings;
			_currPos = getPos _npc;
			_nowp=true; // don't move if on roof		
		};
	};
	
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// delete dead units ==============================================================================
	_deletedead = ["DELETE:",0,_UCthis] call UPSMON_getArg;
	if (_deletedead>0) then {
		{
			_x addEventHandler['killed',format["[_this select 0,%1] spawn UPSMON_deleteDead",_deletedead]];
			sleep 0.01;
		}forEach _members;
	};

// units that can be left for area to be "cleared" =============================================================================================
	_zoneempty = ["EMPTY:",0,_UCthis] call UPSMON_getArg;


	


	
_behaviour = _orgMode;
_npc setbehaviour _Behaviour;
_npc setspeedmode _speedmode;

//If a soldier has a useful building takes about ======================================================================================================================		
	If (_nowp) then {_grpmission = "ATEASE";};
	
	if (_fortify) then 
	{			
		_unitsIn = [_grpid,_npc,150] call UPSMON_GetIn_NearestStatic;
		_units = _members;
		if ( count _unitsIn > 0 ) then { sleep 10; _units = units _npc - [_unitsIn];};
		_blds = [_npc,70,false,9999,true] call UPSMON_moveNearestBuildings;
		_grpmission = "FORTIFY";
		If (count _blds == 0) then {_lookpos = [getposATL _npc,getdir _npc, 20] call UPSMON_GetPos2D;[_npc,_lookpos,50,getpos _npc,_units] call UPSMON_fnc_find_cover2;};
	};
	
	If (_ambush) then 
	{
		{
			_x setvariable ["UPSMON_AMBUSHFIRE",false];
			If !(isNil "bdetect_enable") then {_x setVariable ["bcombat_task", [ "", "mydummytask", 100, [] ] ];};
		} foreach units _npc;
		_nowp = true;	
		_positiontoambush = [_npc,_Ucthis] call UPSMON_getAmbushpos;
		_grpmission = "AMBUSH";
		_nowp = true;
	};
	

	
	// did the leader die?
	_npc = [_npc,_members] call UPSMON_getleader;							
	if (!alive _npc || !canmove _npc || isplayer _npc ) exitwith {_exit=true;};
	
	{
		_x setvariable ["UPSMON_Grpstatus",[_grpmission,"GREEN",_grpmission,[0,0,UPSMON_minreact],ObjNull,[0,0]]];
		_x setvariable ["UPSMON_Lastinfos",[[0,0,0],"MOVE",[0,0,0],0,objNull,0,units _npc,0]];
		_x setvariable ["UPSMON_RadioRange",_RadioRange];
		_x setvariable ["UPSMON_Origin",[_orgMode,_speedmode,_orgpos,_orgformation]];
		_x setvariable ["UPSMON_NOWP",[_nowp,_nowptype]];
		_x setvariable ["UPSMON_Fortify",[_fortifyorig,_fortify]];
		_x setvariable ["UPSMON_REINFORCEMENTSENT",[false,0]];
		_x setvariable ["UPSMON_REINFORCEMENT",_reinforcement];
		_x setvariable ["UPSMON_TimeArtillery",30];
		_x setvariable ["UPSMON_RFID",_rfid];
		_x setvariable ["UPSMON_disembarking",time];
		_x setvariable ["UPSMON_RESPAWNARRAY",[_membertypes,_vehicletypes]];
		_x setvariable ["UPSMON_TIMEONTARGET",[0,0]];
		_x setvariable ["UPSMON_makenewtarget",true];
		_x setvariable ["UPSMON_Positiontoambush",_positiontoambush];
		_x setvariable ["UPSMON_Deletegroup",false];
		_x setvariable ["UPSMON_DskHeli",false];
		_x setvariable ["UPSMON_REACT",[0,0,UPSMON_minreact]];
		_x setvariable ["UPSMON_PosToRenf",[0,0]];
		_x setvariable ["UPSMON_searchingpos",false];
	} foreach units _npc;
	
	
// how many group clones? =========================================================================
// TBD: add to global side arrays?

	_mincopies = ["MIN:",0,_UCthis] call UPSMON_getArg;
	_maxcopies = ["MAX:",0,_UCthis] call UPSMON_getArg;
	if (_mincopies>_maxcopies) then {_maxcopies=_mincopies};
	if (_maxcopies>140) exitWith {hint "Cannot create more than 140 groups!"};
	
	if (_maxcopies>0) then 
	{
		_Ucthis = ["MIN:",0,_UCthis] call UPSMON_setArg;
		_Ucthis = ["MAX:",0,_Ucthis] call UPSMON_setArg;
		[_Ucthis,_mincopies,_maxcopies] call UPSMON_Clones;
	};
	
//Assign the current leader of the group in the array of group leaders
If (!(_npc in UPSMON_NPCs)) then {UPSMON_NPCs = UPSMON_NPCs + [_npc];};