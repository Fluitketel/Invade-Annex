

UPSMON_SortOutBldpos = {
	private ["_bld","_bldpos","_initpos","_allpos","_height","_checkheight","_downpos","_roofpos","_allpos"];
	_bld = _this select 0;
	_initpos = _this select 1;
	_height = 2;
	
	_bldpos = [_bld, 70] call BIS_fnc_buildingPositions;
	
	_checkheight = [_bldpos] call UPSMON_gethighestbldpos;
	
	If (_checkheight > _height) then {If (_checkheight >= 4) then {_height = _checkheight - 1.5;} else {_height = _checkheight - 0.5;};};

	_downpos = [];
	_roofpos = [];
	_allpos = [];

	{
		_bldpos1 = _x;
		_pos1 = _bldpos1 select 2;

		If (_pos1 >= _height) then {_roofpos = _roofpos + [_bldpos1];};
		If (_pos1 < _height) then {_downpos = _downpos + [_bldpos1];};
			
	} foreach _bldpos;
		
		If (_initpos == "RANDOMUP") then {_allpos = _roofpos;};
		If (_initpos == "RANDOMDN") then {_allpos = _downpos;};
		If (_initpos == "RANDOMA") then {_allpos = _roofpos + _downpos;};
		
		_allpos = _allpos call BIS_fnc_arrayShuffle;
	
	if ((count _allpos > 0) && (UPSMON_Debug > 0)) then 
	{
		{
			_ballCover = "Sign_Arrow_Large_GREEN_F" createvehicle [0,0,0];
			_ballCover setpos _x;	
		} foreach _allpos;
	};
	
	_allpos

};


UPSMON_gethighestbldpos = {
	private ["_bldpos","_result","_zbldposs","_lastzbldpos"];
	
	_bldpos = _this select 0;
	_result = 0;
	_zbldposs = [];
	_lastzbldpos = 0;
	
	
	{
		_zbldposs = _zbldposs + [_x select 2];
	} foreach _bldpos;
	
	{
		_zblpos = _x;
		If (_zblpos > _lastzbldpos) then {_result = _zblpos;} else {_result = _lastzbldpos;};
		_lastzbldpos = _x;
	} foreach _zbldposs;
	
	_result

};


UPSMON_filterbuilding = {
	
	_UPSMON_Bld_remove = ["Bridge_PathLod_base_F","Land_Slum_House03_F","Land_Bridge_01_PathLod_F","Land_Bridge_Asphalt_PathLod_F","Land_Bridge_Concrete_PathLod_F","Land_Bridge_HighWay_PathLod_F","Land_Bridge_01_F","Land_Bridge_Asphalt_F","Land_Bridge_Concrete_F","Land_Bridge_HighWay_F","Land_Canal_Wall_Stairs_F"];
    if ((typeof _this) in _UPSMON_Bld_remove) exitWith {false}; 
    if ([_this,1] call BIS_fnc_isBuildingEnterable) exitWith {true}; 
   
	false
}; 


UPSMON_Checkfreebldpos = {
	private ["_bldpos","_alturatemp","_altura","_unitnear"];
	_bldpos = _this select 0;
	_alturatemp = [];
	_altura = [];
	_unitnear = [];
	_id = -1;
	
	{
		_id = _id + 1;
		_alturatemp = _x;
		_unitnear = _alturatemp nearEntities ["CAManBase",1];
		If (count _unitnear == 0) exitwith {_altura = _alturatemp};
	} foreach _bldpos;

	_altura = [_altura,_id];
	_altura
};

UPSMON_Checkfreebldpos2 = {
	private ["_bldpos","_bldpostemp","_altura","_unitnear"];
	
	_bldpos = _this select 0;
	_bldpostemp = _bldpos;
	_id = -1;
	_unitnear = [];

	{
		_id = _id + 1;
		_altura = _x;
		_unitnear = _altura nearEntities ["CAManBase",1];
		If (count _unitnear == 0) exitwith 
		{
			_bldpostemp set [_id,"deletethis"];
			_bldpostemp = _bldpostemp - ["deletethis"];
		};
	} foreach _bldpos;

	_bldpostemp
};


UPSMON_UnitWatchDir = {

	private ["_see","_infront","_uposASL","_opp","_adj","_hyp","_eyes","_obstruction","_angle","_outbuilding"];
	
	_unit = _this select 0;
	_angle = _this select 1;
	_bld = _this select 2;
	_essai = 0;
	_see = false;
	_ouverture = false;
	_findoor = false;
	_wpos = [];
	_dpos = [];
	_watch = [];
	dostop _unit;
	_windowpositions = [];
	_doorpositions = [];
	
	_outbuilding = [_unit] call UPSMON_inbuilding;
	
	
	If (!_outbuilding) then {
	
		// check window
		_windowpositions = [_bld] call UPSMON_checkwindowposition;
		sleep 0.05;
		If (count _windowpositions > 0) then 
		{
			{
				//diag_log format ["%1 %2 window %3 result %4",_unit,(ASLtoATL(eyePos _unit)),_x,(ASLtoATL(eyePos _unit)) distance _x];
				If (((ASLtoATL(eyePos _unit)) distance _x) <= 2.5) exitwith {_watch = _x;};
			} forEach _windowpositions;
	
			if (count _watch > 0) then 
			{
				_wpos = _watch;	
			};
		};
 
		// check for door
		_doorpositions = [_bld] call UPSMON_checkdoorposition;
		sleep 0.05;
			
		if (count _doorpositions == 0) then 
		{
			_exitpos = _bld buildingExit 0;
			If (count _exitpos > 0) then {_doorpositions = _doorpositions + [_bld modelToWorld _exitpos]};
		};
			
		If (count _doorpositions > 0) then 
		{
			{
				//diag_log format ["%1 %2 door %3 result %4",_unit,(ASLtoATL(eyePos _unit)),_x,(ASLtoATL(eyePos _unit)) distance _x];
				If (((ASLtoATL(eyePos _unit)) distance _x) <= 3) exitwith {_watch = _x;};
			} forEach _doorpositions;
	
			if (count _watch > 0) then 
			{
				_dpos = _watch;	
	
			};
		};	
	};
	
	_unit setvariable ["UPSMON_unitdir",[_wpos,_dpos]];
	If (count _dpos > 0) then {_watch = _dpos;_ouverture = true; _findoor = true;};
	If (count _wpos > 0) then {_watch = _wpos;_ouverture = true;_findoor = false;};
	sleep 0.05;
	If (count _watch > 0) then 
	{
		_posATL = getPosATL _unit;

		_abx = (_watch select 0) - (_posATL select 0);
		_aby = (_watch select 1) - (_posATL select 1);
		_abz = (_watch select 2) - (_posATL select 2);

		_vec = [_abx, _aby, _abz];

		// Main body of the function;
		_unit setdir 0;
		_unit setVectorDir _vec;		
		
		_unit dowatch ObjNull;
		_unit dowatch _watch;
		
		If(UPSMON_DEBUG > 0) then {
		player sidechat "DOOR";
		_ballCover2 = "Sign_Sphere25cm_F" createvehicle [0,0,0];
		_ballCover2 setposATL _watch;
		player sidechat format ["%1 watch %2",_unit,_watch];};
	};
	
	Sleep 1;
	// Check if window blocking view or search direction for AI if he doesn't watch window or door.
	If (!(_findoor)) then 
	{
		if (!(_ouverture)) then {
		_watchdir = [_unit, _bld] call BIS_fnc_DirTo;
		_watchdir = _watchdir + 180;
		_unit setdir 0;
		_unit setdir _watchdir;};
		_cansee = [_unit,getdir _unit,_ouverture] spawn UPSMON_WillSee;
	};	
};

UPSMON_checkdoorposition = {
	private ["_model_pos","_world_pos","_armor","_cfg_entry","_veh","_house","_window_pos_arr","_cfgHitPoints","_cfgDestEff","_brokenGlass","_selection_name"];
	_house = _this select 0;
	_anim_source_pos_arr = [];
	
	_cfgUserActions = (configFile >> "cfgVehicles" >> (typeOf _house) >> "UserActions");

	for "_i" from 0 to count _cfgUserActions - 1 do 
	{
		_cfg_entry = _cfgUserActions select _i;
    
		if (isClass _cfg_entry) then
		{
			_display_name = getText (_cfg_entry / "displayname");
			if (_display_name == "Open hatch" or {_display_name == "Open door"}) then
			{
				_selection_name = getText (_cfg_entry / "position");
				_model_pos = _house selectionPosition _selection_name;
				_world_pos = _house modelToWorld _model_pos;
				_anim_source_pos_arr = _anim_source_pos_arr + [_world_pos];
			};
		};
	};
	_anim_source_pos_arr
};

UPSMON_checkwindowposition = {
	private ["_model_pos","_world_pos","_armor","_cfg_entry","_veh","_house","_window_pos_arr","_cfgHitPoints","_cfgDestEff","_brokenGlass","_selection_name"];
	_house = _this select 0;
	_window_pos_arr = [];

	_cfgHitPoints = (configFile >> "cfgVehicles" >> (typeOf _house) >> "HitPoints");

	for "_i" from 0 to count _cfgHitPoints - 1 do 
	{
		_cfg_entry = _cfgHitPoints select _i;
    
		if (isClass _cfg_entry) then
		{
			_armor = getNumber (_cfg_entry / "armor");

			if (_armor < 10) then
			{
				_cfgDestEff = (_cfg_entry / "DestructionEffects");
				_brokenGlass = _cfgDestEff select 0;
				_selection_name = getText (_brokenGlass / "position");
				_model_pos = _house selectionPosition _selection_name;
				_world_pos = _house modelToWorld _model_pos;
				_window_pos_arr = _window_pos_arr + [_world_pos];
			};
		};
	};
	_window_pos_arr
};


UPSMON_WillSee = {
// garrison func from ....
	private ["_see","_infront","_opp","_adj","_hyp","_eyes","_obstruction","_angle"];

	_unit = _this select 0;
	_angle = _this select 1;
	_window = _this select 2;
	_essai = 0;

	If (count _this > 3) then {_essai = _this select 3;};

	_eyes = eyepos _unit;

	_hyp = 10;
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
	if (UPSMON_DEBUG > 0) then {diag_log format ["Unit: %1 See:%2 Essai:%3",_unit,_see,_essai];};
	
	If (!_see && _essai < 30) exitwith 
	{
		_essai = _essai + 1;
		If (_window) then {_angle = _angle + 2} else {_angle = random 360};
		[_unit,_angle,_window,_essai] call UPSMON_WillSee;
	};

	If (_see && _essai > 0) then 
	{
		_posATL = getPosATL _unit;

		_abx = (_infront select 0) - (_posATL select 0);
		_aby = (_infront select 1) - (_posATL select 1);
		_abz = (_infront select 2) - (_posATL select 2);

		_vec = [_abx, _aby, _abz];

		// Main body of the function;

		_unit setVectorDir _vec;
		sleep 0.02;
		_unit dowatch ObjNull;
		_unit dowatch [_infront select 0,_infront select 1, _posATL select 2];
		
		if (UPSMON_DEBUG > 0) then {_ballCover = "Sign_Arrow_Large_BLUE_F" createvehicle [0,0,0];
		 _ballCover setposATL [_infront select 0,_infront select 1, _posATL select 2];};
	};
};



UPSMON_Inbuilding = {
private ["_Inbuilding","_posunit","_unit","_abovehead","_roof"];
	_unit = _this select 0;

	_posunit = [(getposASL _unit) select 0,(getposASL _unit) select 1,((getposASL _unit) select 2) + 0.5];
	_abovehead = [_posunit select 0,_posunit select 1,(_posunit select 2) + 20];

	_roof = (lineintersectswith [_posunit,_abovehead,_unit]) select 0;

	_Inbuilding = if (isnil("roof")) then {false} else {true};

_Inbuilding
};


//Function to spawn all units of squad to near buildings
UPSMON_SpawninBuildings = {
	private ["_npc","_altura","_pos","_bld","_bldpos","_posinfo","_blds","_cntobjs1","_bldunitin","_i","_minpos","_blds2"];
	_minpos  = 1;


	_units = _this select 0;
	_blds = _this select 1;
	_leader = _this select 2;

	
	_altura = [];
	_pos =0;
	_bld = objnull;
	_bldpos =[];
	_cntobjs1=0;
	_bldunitsin=[];
	_movein=[];
	_blds2 =[];

	//if (UPSMON_Debug>0) then {player globalchat format["MON_moveBuildings _units=%1 _blds=%2",count _units, count _blds];	};	
	if (UPSMON_Debug>0) then {diag_log format["MON_moveBuildings _units=%1 _blds=%2",count _units, count _blds];};	
	{
		_bld 		= _x select 0;
		_bldpos 	= _x select 1; 
		if ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};

		if ( count _bldpos >= _minpos ) then {
			_cntobjs1 = 1;		
			_movein = [];
			_i = 0;
		if (count _bldpos >= 3) then { _cntobjs1 =   round(random 1) + 2;};
		if (count _bldpos >= 8) then { _cntobjs1 =   round(random 2)  + 5;};
		if (count _bldpos >= 10) then {_cntobjs1 =   round(random 3)  + 6;};
		
			//Buscamos una unidad cercana para recorrerlo
			{							
				if (_x iskindof "Man" && canmove _x && alive _x && vehicle _x == _x && _i < _cntobjs1) then{
					_movein = _movein + [_x];
					_i = _i + 1;						
				};
			} foreach  _units;		
			
			
						
			if (count _movein > 0) then 
			{
				_bldunitsin = _bldunitsin + _movein;	
				_units = _units - _bldunitsin;					
				{
					if ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};
					if (UPSMON_Debug>0) then {diag_log format["_units=%3 _bldunitsin %4 _movein=%1 %2 %5",_movein, typeof _bld, count _units, count _bldunitsin,_x];};	
					If (count _bldpos > 0) then
					{
						_result = [_bldpos] call UPSMON_Checkfreebldpos;
						_altura = _result select 0;
						_id = _result select 1;
						If (count _altura > 0) then
						{
							_x setpos _altura;
							dostop _x; 
							[_x,getdir _x,_bld] spawn UPSMON_UnitWatchDir;
							_bldpos set [_id,"deletethis"];
							_bldpos = _bldpos - ["deletethis"];
						}
						else
						{
							_units = _units + [_x];
						};
					}
					else
					{
						_units = _units + [_x];
					};
					
				} foreach _movein;
												
			};	
		};
		if (count _units == 0) exitwith {_units};	
	} foreach _blds;
	
	//If need to enter all units in building and rest try with a superior lvl
	if (count _units > 0) then {
		_minpos = _minpos;
		//diag_log format["blds: %1",_blds];
		{
			_bld = _x select 0;
			_bldpos = _x select 1;
			if ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};
			_bldpos = [_bldpos] call UPSMON_Checkfreebldpos2;
			if (count _bldpos > 0) then {_blds2 = _blds2 + [[_bld,_bldpos]];} else {_bldpos = [_bld,"RANDOMA"] call UPSMON_SortOutBldpos;_bldpos = [_bldpos] call UPSMON_Checkfreebldpos2; if (count _bldpos > 0) then {_blds2 = _blds2 + [[_bld,_bldpos]];};};
		} foreach _blds;
		if (count _blds2 > 0 ) then {
			[_units, _blds2,_leader] spawn UPSMON_SpawninBuildings;
			_bldunitsin = _bldunitsin + _units;
		};
	};
	if (count _units > 0) then {{_x dofollow _leader} foreach _units; };
};

//Función que retorna array de arrays con edificios y sus plantas
//Parámeters: [_object,(_distance,_minfloors)]
//	<-	_object: soldier to get near buildings 
//	<-	_distance: distance to search buildings (optional, 25 by default)
//	<- 	_minfloors:  min floors of building (optional) if not especified  min floors is 2
// 	->	 [_bld,_bldpos] 
UPSMON_GetNearestBuildings = {
	private ["_object","_altura","_pos","_bld","_bldpos","_posinfo","_minfloors","_OCercanos","_distance","_blds","_bldpositions"];
	_distance = 25;
	_minfloors = 2;
	_altura = 0;
	_blds = [];

	_object = _this select 0;
	if ((count _this) > 1) then {_distance = _this select 1;};
	if ((count _this) > 2) then {_minfloors = _this select 2;};	
 
	_nbbldpos =0;
	_bld = objnull;
	_bldpositions = [];

	//La altura mínima es 2 porque hay muchos edificios q devuelven 2 de altura pero no se puede entrar en ellos.
	if ( _minfloors == 0  ) then {
		_minfloors = 2;
	 };	
											
	_OCercanos = [ (nearestObjects [_object, ["house","building"], _distance]), { _x call UPSMON_filterbuilding } ] call BIS_fnc_conditionalSelect;
	
	
	{
		_allpos = [_x,"RANDOMA"] call UPSMON_SortOutBldpos; 
		_allpos = [_allpos] call UPSMON_Checkfreebldpos2;
		_nbbldpos = _nbbldpos + (count _allpos);
		if (damage _x <= 0 && _nbbldpos > 0) then {_bldpositions = _bldpositions + [[_x,_allpos]];};
	} foreach _OCercanos;
		
	_bldpositions;
};

//Function to move al units of squad to near buildings
//Parámeters: [_npc,(_patrol,_minfloors)]
//	<-	 _npc: lider
//	<-	 _distance: distance to search buildings (optional, 25 by default)
//	<-	 _patrol: wheter must patrol or not
UPSMON_moveNearestBuildings = {
	private ["_npc","_altura","_pos","_bld","_bldpos","_posinfo","_blds","_distance","_cntobjs1","_bldunitin","_blddist","_patrol","_wait","_all"];
	_distance = 30;
	_altura = 0;
	_patrol = false;	
	_wait=60;
	_all = false;

	
	_npc = _this select 0;
	if ((count _this) > 1) then {_distance = _this select 1;};
	if ((count _this) > 2) then {_patrol = _this select 2;};
	if ((count _this) > 3) then {_wait = _this select 3;};
	if ((count _this) > 4) then {_all = _this select 4;};

 
	_pos =0;
	_bld = objnull;
	_bldpos =[];
	_cntobjs1=0;
	_bldunitsin=[];
	_units=[];
	_blds=[];
	
	//If all soldiers move leader too
	if (_all) then {
		_units = (units _npc);
	}else{
		_units = (units _npc) - [_npc];
	}; 
	
	{
		if (_x iskindof "Man" && unitReady _x && _x == vehicle _x && canmove _x && alive _x && canstand _x) then {_bldunitsin = _bldunitsin + [_x]}
	}foreach _units;
	
	if (count _bldunitsin == 0) exitwith {};		
	
	//Obtenemos los edificios cercanos al lider
	_blds = [_npc,_distance] call UPSMON_GetNearestBuildings;		
	
	if (count _blds==0) exitwith {_blds};
	
	//Movemos a la unidades a los edificios cercanos.
	[_bldunitsin, _blds, _patrol,_wait,_all] spawn UPSMON_moveBuildings;
	
	_blds
};


//Function to move al units of squad to near buildings
//Parámeters: [_npc,(_patrol,_minfloors)]
//	<-	 _units: array of units
//	<-	 _blds: array of buildingsinfo [_bld,pos]
//	<-	 _patrol: wheter must patrol or not
//	->	_bldunitsin: array of units moved to builidings
UPSMON_moveBuildings = {
	private ["_npc","_altura","_pos","_bld","_bldpos","_posinfo","_blds","_cntobjs1","_bldunitin","_blddist","_i","_patrol","_wait","_all","_minpos","_blds2","_timesrchbld"];
	_patrol = false;
	_wait = 60;
	_minpos  = 2;
	_all = false;
	_timesrchbld = 0;

	_units = _this select 0;
	_blds = _this select 1;
	if ((count _this) > 2) then {_patrol = _this select 2;};
	if ((count _this) > 3) then {_wait = _this select 3;};
	if ((count _this) > 4) then {_all = _this select 4;};
	if ((count _this) > 5) then {_minpos = _this select 5;};
	if ((count _this) > 6) then {_timesrchbld = _this select 6;};
	
	If (_timesrchbld > 5) exitwith {};
	
	_altura = 0;
	_pos =0;
	_bld = objnull;
	_bldpos =[];
	_cntobjs1=0;
	_bldunitsin=[];
	_movein=[];
	_blds2 =[];

	_UPSMON_Bld_ruins = ["Land_Unfinished_Building_01_F","Land_Unfinished_Building_02_F","Land_d_Stone_HouseBig_V1_F","Land_d_Stone_Shed_V1_F","Land_u_House_Small_02_V1_F","Land_i_Stone_HouseBig_V1_F","Land_u_Addon_02_V1_F","Land_Cargo_Patrol_V1_F"];
	//if (UPSMON_Debug>0) then {player globalchat format["MON_moveBuildings _units=%1 _blds=%2",count _units, count _blds];	};	
	//if (UPSMON_Debug>0) then {diag_log format["MON_moveBuildings _units=%1 _blds=%2",count _units, count _blds];};	
	(group (_units select 0)) setSpeedmode "FULL";
	{
		_bld 		= _x select 0;
		_bldpos 	= _x select 1; 
		if ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};
		
		if ( count _bldpos >= _minpos ) then {
			_cntobjs1 = _minpos;		
			_movein = [];
			_i = 0;		
			
			if (_patrol) then {
				if (count _bldpos <= 3) then { _cntobjs1 =  1;};
				if (count _bldpos > 3) then { _cntobjs1 =   round(random 2) + 1;};
				if (count _bldpos >= 8) then { _cntobjs1 =   round(random 2)  + 3;};
				if (count _bldpos >= 10) then { _cntobjs1 =   round(random 3)  + 4;};
			} else {	
				if (count _bldpos == 2) then { _cntobjs1 =  1;};
				if (count _bldpos >= 5) then { _cntobjs1 =   round(random 2) + 3;};
				if (count _bldpos >= 8) then { _cntobjs1 =   round(random 3)  + 4;};
				if (count _bldpos >= 10) then { _cntobjs1 =   round(random 4)  + 6;};
			};					
		
			//Buscamos una unidad cercana para recorrerlo
			// && unitReady _x
			{							
				if (_x iskindof "Man" && canmove _x && alive _x && vehicle _x == _x && _i < _cntobjs1) then{
					_movein = _movein + [_x];
					_i = _i + 1;						
				};
			} foreach  _units;		
			
			if (UPSMON_Debug>0) then {player globalchat format["_units=%3 _bldunitsin %4 _movein=%1",_movein, typeof _bld, count _units, count _bldunitsin];};
			if (UPSMON_Debug>0) then {diag_log format["_units=%3 _bldunitsin %4 _movein=%1 %2 %5",_movein, typeof _bld, count _units, count _bldunitsin,_x];};	
						
			if (count _movein > 0) then {
				_bldunitsin = _bldunitsin + _movein;	
				_units = _units - _bldunitsin;					
				if (_patrol) then {
					{
						[_x,_bld,_bldpos] spawn UPSMON_patrolBuilding;	
					}foreach _movein;
				} else {
					
					{
						If ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};
						If (count _bldpos > 0) then 
						{
							_altura = _bldpos select 0;

							[_x,_bld,_altura,_wait,_blds] spawn UPSMON_movetoBuilding;
							_bldpos set [0,"deletethis"];
							_bldpos = _bldpos - ["deletethis"];

						}
						else
						{
							_units = _units + [_x];
						};
					}foreach _movein;
				};								
			};	
		};
		If (!(typeof _bld in _UPSMON_Bld_ruins) && !_patrol) then {
		[_bld] execvm "Scripts\UPSMON\COMMON\UPSMON_CloseDoor.sqf";};
		if (count _units == 0) exitwith {};
		
	}foreach _blds;	
	
	//If need to enter all units in building and rest try with a superior lvl
	if ( _all && count _units > 0 ) then {
		_minpos = _minpos;
				
		{
			_bld 		= _x select 0;
			_bldpos 	= _x select 1;
			If ("deletethis" in _bldpos) then {_bldpos = _bldpos - ["deletethis"];};
			//_bldpos = [_bldpos] call UPSMON_Checkfreebldpos2;
			if (count _bldpos > 0) then {_blds2 = _blds2 + [[_bld,_bldpos]];};
		} foreach _blds;
		if (count _blds2 > 0 ) then {
			_timesrchbld = _timesrchbld + 1;
			[_units, _blds2, _patrol,_wait,_all,1,_timesrchbld] spawn UPSMON_moveBuildings;	
		};
		if (UPSMON_Debug>0) then {player globalchat format["UPSMON_moveBuildings exit _units=%1 _blds=%2",count _units, count _blds2];	};	
		if (UPSMON_Debug>0) then {diag_log format["UPSMON_moveBuildings exit _units=%1 _blds=%2",count _units, count _blds2];};	
		_bldunitsin = _bldunitsin + _units;
	};
};

//Function to move a unit to a position in a building
//Parámeters: [_npc,(_patrol,_minfloors)]
//	<-	 _npc: soldier
//	<-	 _bld: building
//	<-	 _altura: building
//	<-	 _wait: time to wait in position
UPSMON_movetoBuilding = {

	private ["_npc","_altura","_bld","_wait","_dist","_retry","_soldiers"];
	_wait = 60; // 60
	_timeout = 120; // 120
	_dist = 0;
	_retry = false;	
		
	_npc = _this select 0;
	_bld = _this select 1;
	_altura = _this select 2;
	_blds = [];
	
	if ((count _this) > 3) then {_wait = _this select 3;};
	if ((count _this) > 4) then {_blds = _this select 4;};

	//Si está en un vehiculo ignoramos la orden
	if (vehicle _npc != _npc || !alive _npc || !canmove _npc) exitwith{};
	
	//Si ya está en un edificio ignoramos la orden
	_inbuilding = _npc getvariable ("UPSMON_inbuilding");
	if ( isNil("_inbuilding") ) then {_inbuilding = false;};	
	if (_inbuilding)  exitwith{};
	
	diag_log format["%4|_bld=%1 | %2 | %3",typeof _bld, _npc, typeof _npc ,_altura];
	_oldposnpc = getpos _npc;	
	_npc domove _altura; 	
	_npc setVariable ["UPSMON_inbuilding", _inbuilding, false];		
	_npc setvariable ["UPSMON_buildingpos", nil, false];
	
	sleep 1;
	If (_oldposnpc distance (getpos _npc) < 1) then {_npc domove _altura; _npc forcespeed 1;};
	_timeout = time + _timeout;

	if (UPSMON_Debug>0) then {player globalchat format["%4|_bld=%1 | %2 | %3",typeof _bld, _npc, typeof _npc ,_altura];};	
	//if (UPSMON_Debug>0) then {diag_log format["%4|_bld=%1 | %2 | %3",typeof _bld, _npc, typeof _npc ,_altura];};
	
	waitUntil {(_npc distance _altura <= 1) || !alive _npc || !canmove _npc || _timeout < time};
	
	if ((_npc distance _altura <= 1) && alive _npc && canmove _npc) then {					
		_soldiers = [_npc,0.5] call UPSMON_nearestSoldiers;			
		//If more soldiers in same floor see to keep or goout.
		if (count _soldiers > 0) then {					
			{
				if (!isnil{_x getvariable ("UPSMON_buildingpos")}) exitwith {_retry = true};								
			}foreach _soldiers;				
		};		
			
		if (!_retry) then {
			_npc setvariable ["UPSMON_buildingpos",[_bld,_altura], false];	
			sleep 0.1;
			[_npc,_wait] spawn UPSMON_dostop;
			sleep 1;
			[_npc,getdir _npc,_bld] spawn UPSMON_UnitWatchDir;
			if (!isNil "tpwcas_running") then {_npc setvariable ["tpwcas_cover", 2];};
		};	
	};
	
	if (_npc distance _altura > 1) then {_retry = true};
	
	if (!alive _npc || !canmove _npc) exitwith{};	
	_npc setVariable ["UPSMON_inbuilding", false, false];			
	
	//hint format ["Unit has moved to %1 %2 %3 Retry: %4",_altura,_npc distance _altura <= 0.5,_timeout < time,_retry];
	//Down one position.
	if (_retry ) then {		
		_allpos = [_bld,"RANDOMA"] call UPSMON_SortOutBldpos;
		_result = [_allpos] call UPSMON_Checkfreebldpos;
		_altura = _result select 0;
		_bldposfound = false;
		diag_log format["%4|_bld=%1 | %2 | %3 | retry: %4",typeof _bld, _npc, typeof _npc ,_altura,_retry];		
		If (count _altura > 0) then {[_npc,_bld,_altura] spawn UPSMON_movetoBuilding; _bldposfound = true;}
		else {
		{
		_bldpos = _x select 1;
		_altura = [_bldpos] call UPSMON_Checkfreebldpos; 
		if (count (_altura select 0) > 0) exitwith {[_npc,_bld,(_altura select 0)] spawn UPSMON_movetoBuilding;_bldposfound = true;};} foreach _blds;};
		If (!_bldposfound) then {_lookpos = [getposATL _npc,getdir _npc, 20] call UPSMON_GetPos2D;[_npc,_lookpos,50,getpos _npc,[_npc]] call UPSMON_fnc_find_cover2;};
	};
};


//Función para mover a una unidad al edificio más cercano
//Parámeters: [_npc,_bld,(_BldPos)]
//	<-	 _npc: soldier to move
// 	<-	 _bld:building to patrol
//	<-	 _BldPos: positions of builiding (optional)
UPSMON_patrolBuilding = {
	private ["_npc","_bld","_bldpos","_posinfo","_minfloors","_OCercanos","_distance","_timeout","_pos","_inbuilding","_rnd","_NearestEnemy","_patrolto","_time"];
	_bldpos = 0;
	_pos = 0;
	_timeout = 0;
	_i = 1;
	_inbuilding = false;
	_rnd = 0;
	_patrolto = 0;
	_NearestEnemy = objnull;
	_time = 0;

	_npc = _this select 0;
	_bld = _this select 1;
	if ((count _this) > 2) then {_bldpos = _this select 2;}; 
	
	
	if (_i > count _bldpos) then {_i = (count _bldpos) -1};
	
	if (UPSMON_Debug>0) then {player globalchat format["%1 PatrolTo %2 in %3",_npc,typeof _bld,_bldpos];};	
	//Si ya está  muerto o no se puede mover se ignora
	if (!(_npc iskindof "Man") || !alive _npc || !canmove _npc) exitwith{};
	
	//Si ya está en un edificio ignoramos la orden
	_inbuilding = _npc getvariable ("UPSMON_inbuilding");
	if ( isNil("_inbuilding") ) then {_inbuilding = false;};	
	
	//Asignamos el vehiculo a a la escuadra si contiene las posiciones justas
	if (!_inbuilding) then {
		_inbuilding	 = true;
		_npc setVariable ["UPSMON_inbuilding", _inbuilding, false];
		_timeout = time + 20;
		
		//player sidechat format["%1 patrol building %2 from %3 to %4",typeof _npc, typeof _bld,_i, _patrolto];					
		
		while { _time <= 50 && alive _npc && canmove _npc} do{
			
			_patrolto = round (random (count _bldpos));
			if (_patrolto > count _bldpos) then {_patrolto = (count _bldpos) - 1};
			
			_npc domove (_bldpos select _patrolto); 	
			
			_time = _time + 3;			
			waitUntil {(_npc distance (_bldpos select _i) <= 1) || moveToFailed _npc || !alive _npc || _time < time};
			
			if ((_npc distance (_bldpos select _i) <= 1)) then {
				_timeout = time + 20;
				dostop _npc;
				sleep 3;
			} else {
				if (moveToFailed _npc  || !canmove _npc || !alive _npc || _timeout < time) then {
					//player sidechat format["%1 Cancelando patrulla en %2",_npc, typeof _bld];	
				};		
			};			
			sleep 0.05;
		};
		
		//Si está en un vehiculo ignoramos la orden
		if (!alive _npc || !canmove _npc) exitwith{};
		
		//Volvemos con el lider
		_npc domove	(position leader _npc);
		
		//Marcamos que ya hemos finalizado
		sleep 20; //Damos tiempo para salir del edificio
		_npc setVariable ["UPSMON_inbuilding", false, false];			
	};		
};

UPSMON_unitdefend = {
	private ["_unit","_dist","_issupressed","_isprone","_cansee","_watch","_posATL","_vec","_unit","_bld"];
	
	_unit = _this select 0;
	_dist = _this select 1;
	_issupressed = _this select 2;
	
	_isprone = unitpos _unit == "DOWN";
	
	
	If (!_issupressed) then 
	{
		_cansee = [_unit,getdir _unit,10] call UPSMON_CanSee;
		If (_isprone && !_cansee) then {_unit setunitpos "MIDDLE";sleep 0.1; _cansee = [_unit,getdir _unit,10] call UPSMON_CanSee;};
		If (!_cansee) then {_unit setunitpos "UP";};
		
		_unitdirchk = _unit getvariable "UPSMON_unitdir";
		
		
		if (!(IsNil "_unitdirchk") && !_cansee) then 
		{
			_watch = [];
			If (_dist <= 150 && random 100 < 60) then {_watch = (_unit getvariable "UPSMON_unitdir") select 1} else {_watch = (_unit getvariable "UPSMON_unitdir") select 0};
			_posATL = getPosATL _unit;
			If (count _watch > 0) then{
				_abx = (_watch select 0) - (_posATL select 0);
				_aby = (_watch select 1) - (_posATL select 1);
				_abz = (_watch select 2) - (_posATL select 2);

				_vec = [_abx, _aby, _abz];

				// Main body of the function;
				_unit setdir 0;
				_unit setVectorDir _vec;		
		
				sleep 0.1;
				_unit dowatch ObjNull;
				_unit dowatch _watch;
				sleep 0.5;
			}
			else
			{
				If (!_cansee) then {[_unit,getdir _unit,false] spawn UPSMON_WillSee;};
			};
		
		}
		else
		{
			If (!IsNil "_unitdirchk" && random 100 < 30) then 
			{
				_bld = (_unit getvariable "UPSMON_buildingpos") select 0;
				_bldpos = [_bld, 70] call BIS_fnc_buildingPositions;
				_result = [_bldpos] call UPSMON_Checkfreebldpos;
				_altura = _result select 0;
				If (count _altura > 0) then {[_unit,_bld,_altura,10] spawn UPSMON_movetoBuilding;};
			};
		};
	};
};