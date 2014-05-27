UPSMON_getAmbushpos = {

	private ["_npc","_ambushdir","_ambushdist","_ambushType","_Mines","_npcdir","_positiontoambush","_diramb","_mineposition","_roads","_minetype1","_minetype2","_rdmdir","_gothit"];
	
	_npc = _this select 0;
	_Ucthis = _this select 1;
	_ambushdir = "";
	_ambushType = 1;
	_ambushdist = UPSMON_ambushdist;
	_Mines = 4;
	_Minestype = 1;
	
	_ambushdir = ["AMBUSHDIR:",_ambushdir,_UCthis] call UPSMON_getArg;_ambushdir = ["AMBUSHDIR2:",_ambushdir,_UCthis] call UPSMON_getArg;
	_ambushType = if ("AMBUSH2" in _UCthis) then {2} else {_ambushType};_ambushType = if ("AMBUSHDIR2:" in _UCthis) then {2} else {_ambushType};_ambushType = if ("AMBUSH2:" in _UCthis) then {2} else {_ambushType};
	if ("AMBUSHDIST:" in _UCthis) then {_ambushdist = ["AMBUSHDIST:",_ambushdist,_UCthis] call UPSMON_getArg;} else {_ambushdist = 100};

	// Mine Parameter (for ambush)	
	if ("MINE:" in _UCthis) then {_Mines = ["MINE:",_Mines,_UCthis] call UPSMON_getArg;}; // ajout
	if ("MINEtype:" in _UCthis) then {_Minestype = ["MINEtype:",_Minestype,_UCthis] call UPSMON_getArg;}; // ajout	
	

	_positiontoambush = getposATL _npc;
	
	_npcdir = getDir _npc;
	
	If (_ambushdir != "") then 
	{
		switch (_ambushdir) do 
		{
			case "NORTH": {_npcdir = 0;};
			case "NORTHEAST":{_npcdir = 45;};
			case "EAST": {_npcdir = 90;};
			case "SOUTHEAST": {_npcdir = 135;};
			case "SOUTH": {_npcdir = 180;};
			case "SOUTHWEST": {_npcdir = 225;};
			case "WEST": {_npcdir = 270;};
			case "NORTHWEST": {_npcdir = 315;};
		};
	};	


	_gothit = [_npc] call UPSMON_GothitParam;
	If (_gothit) exitwith {_positiontoambush};	
	_diramb = _npcdir;
	If ("gdtStratisforestpine" == surfaceType getPosATL _npc) then {_ambushdist = 50;};
	If ((count(nearestobjects [_npc,["house","building"],20]) > 4)) then {_ambushdist = 18;};
			
			
	//Puts a mine if near road
	if ( UPSMON_useMines && _ambushType == 1 ) then 
	{	
		if (UPSMON_Debug>0) then {player sidechat format["%1: Putting mine for ambush",_grpidx]}; 	
		if (UPSMON_Debug>0) then {diag_log format["UPSMON %1: Putting mine for ambush",_grpidx]}; 
				
		sleep 1;
		_positiontoambush = [position _npc,_diramb, 20] call UPSMON_GetPos2D;					
		_roads = (getposATL _npc) nearRoads 50; // org value 40 - ToDo check KRON_UPS_ambushdist value
				
		If (count _roads <= 0) then 
		{
			_roads = (getposATL _npc) nearRoads 100;			
		};
				
		if (count _roads > 0) then 
		{
			_roads = [_roads, [], { _npc distance _x }, "ASCEND"] call BIS_fnc_sortBy;
			
			// Thanks ARJay
			_roadConnectedTo = roadsConnectedTo (_roads select 0);
			_connectedRoad = _roadConnectedTo select 0;
			_diramb = [(_roads select 0), _connectedRoad] call BIS_fnc_DirTo;
			diag_log format ["Min: %1 Max: %2",_npcdir,_diramb];
			If ((_npcdir < 180 && _diramb  > (_npcdir + 90)) || (_npcdir > 180 && _diramb  < (_npcdir - 90))) then {_diramb = _diramb +180;diag_log format ["Min2: %1 Max2: %2 %3 %4",_npcdir,_diramb,(_npcdir < 180 && _diramb  > (_npcdir + 90)),(_npcdir > 180 && _diramb  < (_npcdir - 90))];};
		};	

		if (UPSMON_Debug>0) then {diag_log format["%1: Roads #:%2 Pos:%3 Dir:%4",_grpidx, _roads,_positiontoambush,_npcdir]}; 
				_minetype1 = UPSMON_Minestype1 call BIS_fnc_selectRandom;
				_minetype2 = UPSMON_Minestype2 call BIS_fnc_selectRandom;
				
		switch (_Minestype) do 
		{
			case "1": {_minetype2 = _minetype1;};
			case "2":{_minetype2 = _minetype2;};
			case "3": {_minetype1 = _minetype2;};
		};
		
		
		if (count _roads > 0) then 
		{
			_positiontoambush = position (_roads select 0); 
		};
		
		if (_Mines > 0) then 
		{				
			_Mine=createMine [_minetype1, _positiontoambush , [], 0]; 
			(side _npc) revealMine _Mine;	
			_Mines = _Mines -1;
		};
		if (UPSMON_Debug>0) then {diag_log format["%1 Current Roads #:%2 _Mines:%3",_grpidx, (count _roads),_Mines]}; 
		
		if (UPSMON_Debug>0) then {_ballCover2 = "Sign_Arrow_Large_BLUE_F" createvehicle [0,0,0];_ballCover2 setpos _positiontoambush;};
			
		for [{_i=_Mines}, {_i>0}, {_i=_i-1}] do
		{
			// Many thanks Shuko ...
			_max = 0; _min = 0;
			if (floor (random 4) < 2) then 
			{
				_min = _diramb + 270;
				_max = _diramb + 335;			
			}
			else
			{
				_min = _diramb + 25;
				_max = _diramb + 90;
			};
			
			_ang = _max - _min;
			// Min bigger than max, can happen with directions around north
			if (_ang < 0) then { _ang = _ang + 360 };
			if (_ang > 360) then { _ang = _ang - 360 };
			_dir = (_min + random _ang);
				
			_orgX = _positiontoambush select 0;
			_orgY = _positiontoambush select 1;
			_posX = _orgX + (((random 10) + (random 30 +5)) * sin _dir);
			_posY = _orgY + (((random 10) + (random 30 +5)) * cos _dir);
			
			
			_Mine=createMine [_minetype2, [_posX,_posY,0] , [], 0]; 
			(side _npc) revealMine _Mine;	
			if (UPSMON_Debug>0) then {_ballCover = "Sign_Arrow_Large_GREEN_F" createvehicle [0,0,0];_ballCover setpos getpos _Mine;};
			sleep 0.1;
		};
					
		if (UPSMON_Debug>0) then {diag_log format["UPSMON %1: mines left: [%2]",_grpidx, _Mines]};
				
	};
	
	_AmbushPosition = [_npc,_diramb,_ambushdir,_positiontoambush,_ambushdist] spawn UPSMON_SetAmbush;
	sleep 1;	
	
	_positiontoambush
};


UPSMON_SetAmbush = {

	private ["_npc","_ambushdir","_ambushdist","_ambushType","_Mines","_npcdir","_positiontoambush","_diramb","_mineposition","_roads","_minetype1","_minetype2","_rdmdir","_gothit"];
	_npc = _this select 0;
	_diramb = _this select 1;
	_ambushdir = _this select 2;
	_positiontoambush = _this select 3;
	_ambushdist = _this select 4;

	
	_AmbushPosition = [_npc,_diramb,_positiontoambush,_ambushdist] call UPSMON_FindAmbushPos;
	sleep 0.05;
	
										
	if (!alive _npc || !canmove _npc || isplayer _npc ) exitwith {};
	
	_gothit = [_npc] call UPSMON_GothitParam;
	player sidechat format ["%1 %2",_AmbushPosition,_gothit];
	If (!_gothit) then 
	{
			
		If ((count ([(nearestObjects [_AmbushPosition, ["house","building"], 30]), { _x call UPSMON_filterbuilding } ] call BIS_fnc_conditionalSelect)) > 3) then 
		{
			_OCercanos = [ (nearestObjects [_AmbushPosition, ["house","building"], 50]), { _x call UPSMON_filterbuilding } ] call BIS_fnc_conditionalSelect;
			_allpos = [];
			_nbbldpos = 0;
			_bldpositions = [];
			
			{
				_allpos = [_x,"RANDOMUP"] call UPSMON_SortOutBldpos;
				_allpos = [_allpos] call UPSMON_Checkfreebldpos2;
				_nbbldpos = _nbbldpos + (count _allpos);
				_bldpositions = _bldpositions + [[_x,_allpos]];
				If (_nbbldpos >= 3*(count units _npc)) exitwith {_bldpositions};
			}foreach _OCercanos;
			If (_nbbldpos > 0) then {[units _npc,_bldpositions,_npc] spawn UPSMON_SpawninBuildings;};
		} 
		else 
		{
			_dist = 100;
			player sidechat "Spawn to cover";
			[_npc,_positiontoambush,_dist,_AmbushPosition] call UPSMON_fnc_find_cover;
		};
			
	}
	else
	{
		(group _npc) setCombatMode "YELLOW";
	};
	
};


UPSMON_FindAmbushPos = {

	private ["_npc","_diramb","_ambushdir","_positiontoambush","_ambushdist","_AmbushPosition","_AmbushPositions","_markerstr"];
	_npc = _this select 0;
	_diramb = _this select 1;
	_positiontoambush = _this select 2;
	_ambushdist = _this select 3;
		
	//diag_log format ["Min: %1 Max: %2",_positiontoambush,_diramb];
	
	_AmbushPosition = [_positiontoambush,(_diramb + 180), _ambushdist] call UPSMON_GetPos2D;
	_AmbushPosition = [_AmbushPosition select 0,_AmbushPosition select 1,0];
	_AmbushPositions = [_positiontoambush,_diramb,_ambushdist] call UPSMON_fnc_Overwatch;
			
			
	if (count _AmbushPositions > 0) then 
	{
		_AmbushPositions = [_AmbushPositions, [], {_npc distance _x}, "DESCEND"] call BIS_fnc_sortBy;
		_AmbushPosition = _AmbushPositions select 0;
	
	};
	
	_AmbushPosition
};

UPSMON_fnc_Overwatch = {
	private ["_position","_dirposamb","_distance","_man","_i","_obspos","_FS","_insight"];
	_position = _this select 0;
	_dirposamb = _this select 1;
	_distance = _this select 2;
	
	_i = 0;
	_obspos = [];


	_loglos = "logic" createVehicleLocal [0,0,0];
	_orig = "RoadCone_F" createVehicleLocal _position;
	hideObject _orig;
	while {count _obspos < 3 && _i < 50} do
	{
		
		// Many thanks Shuko ...
		_max = 0; _min = 0;
		_min = _diramb + 290;
		_max = _diramb + 70;		
		
		_ang = _max - _min;
		// Min bigger than max, can happen with directions around north
		if (_ang < 0) then { _ang = _ang + 360 };
		_dir = (_min + random _ang);
		_distancetemp = random _distance;
		If (_distancetemp < _distance) then {_distancetemp = _distancetemp + (_distance/2);};
		
		_orgX = _position select 0;
		_orgY = _position select 1;
		_posX = _orgX - ((_distance) * sin _dir);
		_posY = _orgY - ((_distance) * cos _dir);
		
		_obspos1 = [_posX,_posY,0];

		_dest = "RoadCone_F" createVehicleLocal _obspos1;
		hideObject _dest;
		_los_ok = [_loglos,_orig,_dest,20, 0.5] call mando_check_los;

		If (_los_ok) then 
		{
			_objects = [ (nearestObjects [_obspos1, [], 100]), { _x call UPSMON_fnc_filter } ] call BIS_fnc_conditionalSelect;
			_height1 = (getposASL _dest) select 2;
			_height2 = (getposASL _orig) select 2;
			If (count _objects < 10 && _height1 <= _height2) then
			{
				_los_ok = false;
			};
			If (count (_obspos1 nearRoads 50) > 0) then
			{
				_los_ok = false;
			};
		};
		
		if (_los_ok) then 
		{
			_obspos = _obspos + [_obspos1];
			if (UPSMON_Debug>0) then 
			{
				diag_log format["Positions #:%1",_obspos1];
				//Make Marker
				_markerstr = createMarker[format["markername%1_%2",_i,name _npc],_obspos1];
				_markerstr setMarkerShape "ICON";
				_markerstr setMarkerType "mil_flag";
				_markerstr setMarkerColor "ColorGreen";
				_markerstr setMarkerText format["markername%1_%2",_i,_npc];
			};
		};

		sleep 0.05;
		deletevehicle _dest;
		_i = _i +1;
	};
	
	
	deletevehicle _loglos;
	deletevehicle _orig;
	_obspos
};

UPSMON_CanSee = {
	private ["_see","_infront","_uposASL","_opp","_adj","_hyp","_eyes","_obstruction","_angle"];

	_unit = _this select 0;
	_angle = _this select 1;
	_hyp = _this select 2;


	_eyes = eyepos _unit;

	
	_adj = _hyp * (cos _angle);
	_opp = sqrt ((_hyp*_hyp) - (_adj * _adj));

	
	_infront = if ((_angle) >=  180) then 
	{
		[(_eyes select 0) - _opp,(_eyes select 1) + _adj,(_eyes select 2)]
	} 
	else 
	{
		[(_eyes select 0) + _opp,(_eyes select 1) + _adj,(_eyes select 2)]
	};

	_obstruction = (lineintersectswith [_eyes,_infront,_unit]) select 0;


	_see = if (isnil("_obstruction")) then {true} else {false};

	_see
};


//Function to put a mine
//Parámeters: [_npc,(_position)]
//	<-	 _npc: leader
// 	<-	 _position:location for mine (optional)
UPSMON_CreateMine = {
	private ["_npc","_rnd","_soldier","_mine","_dir","_position"];
	_position = [0,0];
	_minetype = "ATMine";
	
	_soldier = _this select 0;
	
	//if (UPSMON_Debug>0) then { diag_log format ["sol: %1",_soldier]; }; 
	
	 if ((count _this) > 1) then {_position = _this select 1;};
	 if ((count _this) > 2) then {_minetype = _this select 2;};
	 
	_mine = objnull;
	_rnd = 0;
	_dir = 0;
	_mineposee = false;
	
	
	//leader only control not work
	//Si está en un vehiculo ignoramos la orden
	if (isnil "_soldier") exitWith {};
	if (!(_soldier iskindof "Man" ) || _soldier != vehicle _soldier || !alive _soldier || !canstand _soldier) exitwith {false};		
	_soldier enableAI "MOVE";
	_soldier setUnitPos "UP";
	//Animación para montar el arma
	if ((count _this) > 1) then {
		_mineposee = [_soldier,_position,_minetype] call UPSMON_doCreateMine;
		if (UPSMON_Debug>0) then { diag_log format ["UPSMON 'MON_CreateMine': sol: %1 - pos: %2",_soldier, _position]; }; 
	}else{
		_mineposee = [_soldier] call UPSMON_doCreateMine;
		if (UPSMON_Debug>0) then { diag_log format ["UPSMON 'MON_CreateMine': sol: %1",_soldier]; }; 
	};
	
	waituntil {_mineposee || !alive _soldier || !canstand _soldier};
	If (_mineposee) exitwith 
	{
	true;
	};
	false;
};

UPSMON_doCreateMine = {
	private ["_npc","_rnd","_soldier","_mine","_dir","_position"];
	_position = [0,0];
	_minetype = "ATMine";
	 
	_soldier = _this select 0;
	if (isnil "_soldier") exitWith {false;}; 
	if ((count _this) > 1) then {_position = _this select 1;};
	if ((count _this) > 2) then {_minetype = _this select 2;};
	

	//If not is Man or dead exit
	if (!(_soldier iskindof "Man" ) || _soldier != vehicle _soldier || !alive _soldier || !canstand _soldier) exitwith {false;};		
	
	
	
	if ((count _this) > 1) then {
		_soldier domove _position;
		if (! isnil "_soldier") then {
			waituntil {unitReady _soldier || moveToCompleted _soldier || moveToFailed _soldier || !alive _soldier || !canstand _soldier}};
	};

	if (moveToFailed _soldier || !alive _soldier || _soldier != vehicle _soldier || !canmove _soldier) exitwith {false;};	

	//Crouche
	//_soldier playMove "ainvpknlmstpslaywrfldnon_1";

	sleep 1;
	if (isnil "_soldier") exitWith {false;}; 
	if (!alive _soldier || !canstand _soldier) exitwith {false;};

	
	_dir = getdir _soldier;	
	_position = [position _soldier,_dir, 0.5] call UPSMON_GetPos2D;
	if (_minetype == "ATMine") then
	{
		_mine = createMine [_minetype, _position , [], 0];
		(side _soldier) revealMine _Mine;
	}
	else
	{
		[_position,_soldier,_minetype] spawn 
		{
			_position = _this select 0;
			_soldier = _this select 1;
			_minetype = _this select 2;
			waituntil {_position distance _soldier > 20}; 
			_mine = createMine [_minetype, _position , [], 0];
			(side _soldier) revealMine _Mine;
		};
	};
	//Prepare mine
	//_soldier playMoveNow "AinvPknlMstpSlayWrflDnon_medic";
	sleep 1;
	
	//Return to formation
	if (isnil "_soldier") exitWith {true;}; 
	
	true;
};