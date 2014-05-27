UPSMON_Artyhq = {
	
	_artillerysideunits = _this select 0;
	_firemission = _this select 1;
	_radiorange = _this select 2;
	_npcpos = _this select 3;
	_roundsask = _this select 4;
	_targetpos = _this select 5;
	
	_arti = [_artillerysideunits,_firemission,_RadioRange,_npcpos] call UPSMON_selectartillery;
	if (UPSMON_Debug>0) then {player sidechat format ["Arti: %1",_arti];};
	If !(IsNull _arti) then {
	[_arti,_firemission,_targetpos,_roundsask,_npcpos] spawn UPSMON_artilleryTarget;};
	
};

UPSMON_selectartillery = {

	private ["_support","_artiarray","_askMission","_RadioRange","_arti","_rounds","_artiarray","_artillerysideunits","_npc","_support","_artibusy"];
	
	_artillerysideunits = _this select 0;
	_askMission = _this select 1;
	_RadioRange = _this select 2;
	_npcpos = _this select 3;
	
	_arti = ObjNull;
	_rounds = 0;
	_artiarray = [_artillerysideunits, [], { _npcpos distance _x }, "ASCEND"] call BIS_fnc_sortBy;
	{
		_support = (vehicle _x) getVariable "UPSMON_ArtiOptions";
		if (!alive _x) then
		{
			_artibattery  = _support select 5;
			{
				If (alive _x) exitwith {_arti = _x; (vehicle _arti) setVariable ["UPSMON_ArtiOptions",_support];};
			} foreach _artibattery;
		};
		If (alive _x) then
		{
			_artibusy  = _support select 0;
		
			Switch (_askmission) do {
				case "HE": {
					_rounds = (_support select 1) select 2;
				};
		
				case "WP": {
					_rounds = (_support select 1) select 1;
				};
		
				case "FLARE": {
					_rounds = (_support select 1) select 0;
				};
	
			};
		
			If (!_artibusy && _x distance _npcpos <= _RadioRange && _rounds > 0) exitwith {_arti = _x;};
			if (UPSMON_Debug>0) then {diag_log format ["Busy:%1 Distance:%2 RadioRange:%3 Rounds:%4",_artibusy,_x distance _npcpos,_RadioRange,_rounds];};
		};
		
	} ForEach _artiarray;

	_arti
	
};
UPSMON_artilleryTarget = {
	
	private ["_support","_askBullet","_target","_arti","_missionabort","_rounds","_range","_area","_maxcadence","_mincadence","_askmission","_fire","_artibusy","_targetpos","_auxtarget","_npc"];
	_arti = _this select 0;
	
	_support = (vehicle _arti) getVariable "UPSMON_ArtiOptions";
	
	If (isnull (gunner _arti) 
	&& !(canmove (gunner _arti))) 
	exitwith 
	{
		if (UPSMON_Debug>0) then {player sidechat "ABORT: no gunner";};
	};
	
	// If (count _support <= 0 ) exitwith {if (UPSMON_Debug>0) then {player sidechat "ABORT: no support";};};
	
	
	_askMission = _this select 1;
	_targetpos = _this select 2;
	_roundsask = _this select 3;
	_npcpos = _this select 4;
	
	_artibusy  = _support select 0;
	_rounds = _support select 1;					
	_area = _support select 2;	
	_maxcadence = _support select 3;	
	_mincadence = _support select 4;
	_batteryunits = _support select 5;

	_askbullet = "";
	_missionabort = false;
	_foundshell=false;
	_foundrocket=false;
	_foundsmoke=false;
	_foundillum=false;
	_totalrounds = 0;
	
	_side = side gunner _arti;
	_munradius = 100;	

	Switch (_askmission) do {
		case "HE": {
			_cfgArtillerymag = getArray (configFile >> "cfgVehicles" >> (typeOf _arti) >> "Turrets" >> "MainTurret" >> "magazines");
			{
				_foundshell=[_x,"shells"] call UPSMON_StrInStr;
				_foundshell=[_x,"HE"] call UPSMON_StrInStr;
				_foundrocket=[_x,"rockets"] call UPSMON_StrInStr;
				If (_foundshell || _foundrocket) exitwith {_askbullet = _x; _munradius = 250; if (_foundrocket) then {_munradius = 400;};};
			} foreach _cfgArtillerymag;
			_totalrounds = _rounds select 2;
		};
		
		case "WP": {
			_cfgArtillerymag = getArray (configFile >> "cfgVehicles" >> (typeOf _arti) >> "Turrets" >> "MainTurret" >> "magazines");
			{
				_foundsmoke=[_x,"smoke"] call UPSMON_StrInStr;
				_foundsmoke=[_x,"WP"] call UPSMON_StrInStr;
				If (_foundsmoke) exitwith {_askbullet = _x; _munradius = 100;};
			} foreach _cfgArtillerymag;
			_totalrounds = _rounds select 1;
		};
		
		case "FLARE": {
			_cfgArtillerymag = getArray (configFile >> "cfgVehicles" >> (typeOf _arti) >> "Turrets" >> "MainTurret" >> "magazines");
			{
				_foundillum=[_x,"Flare"] call UPSMON_StrInStr;
				_foundillum=[_x,"ILLUM"] call UPSMON_StrInStr;
				If (_foundillum) exitwith {_askbullet = _x; _munradius = 0;};
			} foreach _cfgArtillerymag;
			_totalrounds = _rounds select 0;
		};
	
	};
	
	If(_artibusy || _totalrounds <=0) 
	exitwith 
	{
		if (UPSMON_Debug>0) then {player sidechat format ["ABORT: Arti: %1",_artibusy];};
	};
	
	switch (_side) do {
		case West: {
			UPSMON_ARTILLERY_WEST_UNITS = UPSMON_ARTILLERY_WEST_UNITS - [_arti];
		};
		case EAST: {
			UPSMON_ARTILLERY_EAST_UNITS = UPSMON_ARTILLERY_EAST_UNITS - [_arti];
		};
		case resistance: {
			UPSMON_ARTILLERY_GUER_UNITS = UPSMON_ARTILLERY_GUER_UNITS - [_arti];
		};
	};
		
		
	(vehicle _arti) setVariable ["UPSMON_ArtiOptions",[true,_rounds,_area,_maxcadence,_mincadence,_batteryunits]];

	If (_foundsmoke) 
	then 
	{ 
		_vcttarget = [_npcpos, _targetpos] call BIS_fnc_dirTo;
		_dist = (_npcpos distance _targetpos)/2;
		_targetPos = [_npcpos,_vcttarget, _dist] call UPSMON_GetPos2D;
	};
	
	
		if (!isnil "_targetPos" || count _targetPos > 0) then 
		{
			//If target in range check no friendly squad near									
			if ((_targetPos inRangeOfArtillery [[_arti], _askbullet])) 
			then 
			{
				//Must check if no friendly squad near fire position

				{	
					if (!isnull _x && _side == side _x) then 
					{																								
						if ((round([position _x,_targetPos] call UPSMON_distancePosSqr)) <= (_munradius)) exitwith {_targetpos = [];};
					};										
				} foreach UPSMON_NPCs;
			}
			else
			{
				_missionabort = true; 
				if (UPSMON_Debug>0) then {player sidechat "Arti not in range";};
			};
			
		};
	
	If (count _targetPos > 0) then 
	{	
	
		if (UPSMON_Debug>0) then {player sidechat "FIRE";};
		[_arti,_targetPos,_area,_maxcadence,_mincadence,_askbullet,_support,_totalrounds] spawn UPSMON_artillerydofire;

	}
	else
	{
		if (UPSMON_Debug>0) then {player sidechat "ABORT: no more target";}; 
		_missionabort = true
	};
	
	If (_missionabort) then
	{
	
		if (UPSMON_Debug>0) then {player sidechat "ABORT: no more target";};
		
			switch (_side) do {
		case West: {
			UPSMON_ARTILLERY_WEST_UNITS = UPSMON_ARTILLERY_WEST_UNITS + [_arti];
		};
		case EAST: {
			UPSMON_ARTILLERY_EAST_UNITS = UPSMON_ARTILLERY_EAST_UNITS + [_arti];
		};
		case resistance: {
			UPSMON_ARTILLERY_GUER_UNITS = UPSMON_ARTILLERY_GUER_UNITS + [_arti];
		};
	
		};
		
		(vehicle _arti) setVariable ["UPSMON_ArtiOptions",[false,_rounds,_area,_maxcadence,_mincadence,_batteryunits]];
	};
};

UPSMON_artillerydofire = {
	 
		private ["_smoke1","_i","_area","_position","_maxcadence","_mincadence","_sleep","_nbrbullet","_rounds","_arti","_timeout","_bullet"];
		
		_arti = _this select 0;
		_position  = _this select 1;	
		_area = _this select 2;	
		_maxcadence = _this select 3;	
		_mincadence = _this select 4;	
		_bullet = _this select 5;
		_support = _this select 6;
		_totalrounds = _this select 7;
		
		_supportrounds = _support select 1;
		_batteryunits = _support select 5;
		_support2 = [];
		
		_rounds = 3;
		
		_foundshell=[_bullet,"shells"] call UPSMON_StrInStr;
		_foundshell=[_bullet,"HE"] call UPSMON_StrInStr;
		_foundrocket=[_bullet,"rockets"] call UPSMON_StrInStr;
		_foundsmoke=[_bullet,"smoke"] call UPSMON_StrInStr;
		_foundsmoke=[_bullet,"WP"] call UPSMON_StrInStr;
		_foundillum=[_bullet,"Flare"] call UPSMON_StrInStr;
		_foundillum=[_bullet,"ILLUM"] call UPSMON_StrInStr;
		
		If (_foundshell || _foundrocket) then 
		{
			_support2 = [false,[_supportrounds select 0, _supportrounds select 1, (_supportrounds select 2) - 5],_support select 2, _support select 3,_support select 4,_batteryunits];
			_rounds = 5;
			_found155=[_bullet,"155mm"] call UPSMON_StrInStr;
			_found122=[_bullet,"Sh_122"] call UPSMON_StrInStr;
			If (_found155 || _found122) then {_rounds = 3;};
		};
		If (_foundrocket) then {_rounds = 2;};
		If (_foundsmoke) then 
		{
			_rounds = 5;
			_support2 = [false,[_supportrounds select 0, (_supportrounds select 1) - 5, _supportrounds select 2],_support select 2, _support select 3,_support select 4,_batteryunits];
		};
			
		If (_rounds > _totalrounds) then {_rounds = _totalrounds;};
		
		If (_foundillum)
		then {[] spawn UPSMON_Flaretime;
		_support2 = [false,[(_supportrounds select 0) - 3, _supportrounds select 1, _supportrounds select 2],_support select 2, _support select 3,_support select 4,_batteryunits];};
		
		_area2 = _area * 1.4;
		
		if (UPSMON_Debug>0) then { player globalchat format["artillery doing fire on %1",_position] };	
		If (UPSMON_DEBUG > 0) then {[_position,"ColorRed"] call fnc_createMarker;};
		sleep 5;
		_batteryunits = _batteryunits + [_arti];
		_i = 0;
		
		while {_i<_rounds && count _batteryunits > 0} do
		{
			{
				if (alive _x) then
				{
					_i=_i+1;
					(vehicle _x) addMagazine _bullet;
					(vehicle _x) commandArtilleryFire [[(_position select 0)+ random _area2 - _area, (_position select 1)+ random  _area2 - _area, 0], _bullet, 1];	
					//Swap this
					_x setVehicleAmmo 1;
				}
				else
				{
					_batteryunits = _batteryunits - [_x];
				};
			} foreach _batteryunits;
			
			_sleep = random _maxcadence;			
			if (_sleep < _mincadence) then {_sleep = _mincadence};
			sleep _sleep;
		};
		
	sleep 20;
	If (alive _arti) then
	{
		_side = side gunner _arti;

		switch (_side) do {
		case West: {
			UPSMON_ARTILLERY_WEST_UNITS = UPSMON_ARTILLERY_WEST_UNITS + [_arti];
		};
		case EAST: {
			UPSMON_ARTILLERY_EAST_UNITS = UPSMON_ARTILLERY_EAST_UNITS + [_arti];
		};
		case resistance: {
			UPSMON_ARTILLERY_GUER_UNITS = UPSMON_ARTILLERY_GUER_UNITS + [_arti];
		};
	
		};
		
		(vehicle _arti) setVariable ["UPSMON_ArtiOptions",_support2];
	};
};


UPSMON_Flaretime = {
	UPSMON_FlareInTheAir = true;
	sleep 120;
	UPSMON_FlareInTheAir = false;
	Publicvariable "UPSMON_FlareInTheAir";
};