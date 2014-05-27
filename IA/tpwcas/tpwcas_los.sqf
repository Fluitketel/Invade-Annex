/*
TPW AI LOS

Author: TPW 
Multiplayer modification: Ollem
Line of sight stuff: SaOk 
Azimuth stuff: CarlGustaffa
Version: 2.0
Last modified: 20121123
Disclaimer: Feel free to use and modify this code, on the proviso that you post back changes and improvements so that everyone can benefit from them, and acknowledge the original authors in any derivative works.

NOTE: NEEDS 1.62 BETA 94103 OR GREATER

*/ 

tpwcas_los_fnc_init = 
{
	private ["_msg","_logOnce"];
	
	if ( tpwcas_debug > 0 ) then 
		{
			_msg = format["'tpwcas_los_fnc_init' Starting TPWCAS LOS"];
			[ _msg, 9 ] call bdetect_fnc_debug;				
		};		
			
	_logOnce = true;
	
	while { true } do
	{
		if ( diag_fps > tpwcas_los_minfps ) then 
		{
			if ( tpwcas_mode == 3 ) then // dedicated server no clients - check only player detection
			{
				_nul = [playableUnits] call tpwcas_los_fnc_mainloop;
			}
			else
			{
				_nul = [allUnits] call tpwcas_los_fnc_mainloop;
			};
			
			if ( !(_logOnce) && ( tpwcas_debug > 0) ) then 
			{
				_msg = format["'tpwcas_los_fnc_init' server FPS okay - resuming TPWCAS LOS"];
				[ _msg, 10 ] call bdetect_fnc_debug;				
				_logOnce = true;				
			};			
			sleep 0.3;
		}
		else
		{
			if ( (_logOnce) && ( tpwcas_debug > 0) ) then 
			{
				_msg = format["'tpwcas_los_fnc_init' low server FPS - skipping TPWCAS LOS"];
				[ _msg, 10 ] call bdetect_fnc_debug;				
				_logOnce = false;				
			};
			sleep 1;
		};	
	};
};

// RAPIDLY TURN TO ENEMY
tpw_los_fnc_turn =
	{
	private ["_unit","_near","_i","_stance","_delta","_inc","_div"];
	_unit = _this select 0;
	_near = _this select 1;
	_delta = _this select 2;
	_stance = stance _unit;

	switch _stance do
		{
		case "prone": 
			{
			_div = 6;
			};
		case "crouch": 
			{
			_div = 4;
			};
		case "stand": 
			{
			_div = 2;
			};
		default 
			{
			_div = 2;
			};	
		};
	
	// Turn increment (smaller for lower stances ie slower)
	_inc = (_delta / _div) * 0.1; 
	_unit setvariable ["tpw_los_turning", 1]; 
	
	for "_i" from 1 to 10 do 
		{
		sleep 0.01;
		_unit setdir ((direction _unit) + _inc);
		};

		_unit setvariable ["tpw_los_turning", 0]; 	
	};

tpwcas_los_fnc_mainloop =  
{
	private ["_x","_unitList","_nexttime","_unit","_near","_nearUnits","_dirto","_eyed","_eyepb","_eyepa","_eyedv","_ang","_tint","_lint","_vm","_dist","_esp","_usp","_camo","_formula","_tpwcas_los_cansee","_cover","_anim", "_upos", "_umov", "_dthstr", "_posstr", "_acePosstr", "_isNotPlayer", "_isEnemy", "_isNotCivi", "_isAlive","_revealString", "_revealNear"];
	
	if ( count _this == 1 ) then 
	{
		_unitList = _this select 0; //MP usage
	}
	else 
	{
		_unitList = allUnits; // SP usage
	};
	
	{ // start foreach
		_unit = _x; 
		_nexttime = _unit getvariable ["tpwcas_los_nexttime", -1]; 

		//SET UP INITIAL UNIT PARAMETERS
		if (_nexttime == -1) then 
		{
			_unit setvariable ["tpwcas_los_nexttime", diag_ticktime + random 1];
			_msg = format["'tpwcas_los_fnc_mainloop' - set start value for unit [%1]", _unit];
			[ _msg, 10 ] call bdetect_fnc_debug;
		};

		//IF ENOUGH TIME HAS PASSED SINCE LAST LOS CHECK	
		if ( (diag_ticktime >= _nexttime) && ((lifestate _unit == "HEALTHY") || (lifestate _unit == "INJURED")) && !(side _unit == civilian) ) then  
		{	 
			_unit setvariable ["tpwcas_los_nexttime", diag_ticktime + random 1]; 

			//FIND NEAR MEN AND CARS
			_nearUnits = (getposATL _unit) nearEntities [["CaManBase","Car_f"],tpwcas_los_maxdist]; 
			
			// start foreach
			{ 
				_near = _x;
				_tpwcas_los_cansee = -1; 

				//Check if unit has Line of Sight to unknown enemy
				if ( !(isPlayer _near) && (((side _unit) getFriend (side _near)) < 0.6) && !(side _near == civilian) && ((lifestate _near == "HEALTHY") || (lifestate _near == "INJURED")) && ((_near knowsAbout _unit) < tpwcas_los_knowsabout) ) then
				{
					_eyedv = eyedirection _near;  
					_eyed = ((_eyedv select 0) atan2 (_eyedv select 1));   
					_dirto = ([_unit, _near] call bis_fnc_dirto);  
					_ang = abs (_dirto - _eyed); 
					_eyepa = eyepos _near; 
					_eyepb = eyepos _unit; 

					if ((_ang > 120) && {_ang < 240} && {!(terrainIntersectASL [_eyepa, _eyepb])} && {!(lineIntersects [_eyepa, _eyepb])}) then
					{
						//ANYONE LESS THAN 20m WITHOUT CAMO IS FAIR GAME
						_dist = (_near distance _unit);
						_camo = getnumber (configfile >> "cfgvehicles" >> (typeof _unit) >> "camouflage");
						
						if ( _dist < tpwcas_los_mindist ) then 
						{							
							if ( _camo > 0.6 ) then 
							{
								_tpwcas_los_cansee = 200;
							};
						}
						else
						{
							//OTHER FACTORS AFFECTING VISIBILITY OF ENEMY
							_vm = (currentvisionmode _near);
							if (_vm == 1) then 
								{
								_vm = -1
								} 
								else 
								{
								_vm = 1
								}; 
								
							_esp = (abs (speed _unit));
							_usp = (abs (speed _near));
							
							//Check whether unit stands, kneels or lies'
							//_upos = 1.5; // standing
							//_GetNeckPos= _unit selectionPosition "Neck" select 2;
							//if ((_GetNeckPos < 1.39) && (_GetNeckPos >= 0.5)) then {_upos = 0.75;};  // kneel
							//if (_GetNeckPos < 0.5) then {_upos = 0.20;};	 // lying
							_stance = stance _unit;
							switch _stance do
								{
								case "STAND": 
									{
									_upos = 1.00;
									};
								case "CROUCH":
									{
									_upos = 0.75;
									};
								case "PRONE":
									{
									_upos = 0.25;
									};	
								default 
									{
									_upos = 1.00;
									};
								};
							_cover = (_camo * _upos);
						
							//MAGIC VISIBILITY FORMULA
							_tpwcas_los_cansee = ((((_vm * tpwcas_los_sunangle) * 2)  + (_esp * 6) - (_usp * 2)) * _cover) - (_dist - random 40);
							
							if (tpwcas_debug > 0) then 
							{
								_msg = format["'tpwcas_los_fnc_mainloop' - unit [%1] - enemy: [%2] - Values: vm=[%3] sun=[%4] esp=[%5] usp=[%6] dist=[%7] camo=[%8] cover=[%9] los=[%10]", _unit, _near, _vm, tpwcas_los_sunangle, _esp, _usp, _dist, _camo, _cover, _tpwcas_los_cansee];
								[ _msg, 10 ] call bdetect_fnc_debug;
							};
						};
															
						//hintsilent format ["Cover: %1 - Dist: %2 - Value: %3 - Sun: %4 - Speed: %5", _cover, _dist, _tpwcas_los_cansee, tpwcas_los_sunangle, _esp];
					}; 
							
					if (_tpwcas_los_cansee > 0) exitwith  
					//IF VISIBLE ENEMY
					{ 
						//HOW MANY DEGREES MUST UNIT TURN TO FACE ENEMY
						_dirto = ([_a, _b] call bis_fnc_dirto);  
						_unitdir = direction _unit;
						_delta = (_dirto - _unitdir);
						if (_delta <= -180) then 
							{
							_delta = 360 + _delta;
							};
						
						// ONLY RAPID TURN AND FIRE IF NOT ALREADY TURNING, AND IF MORE THAN 15 DEGREES FROM ENEMY
						_unit lookat _near; 
						if ((_turning == 0) && ((abs _delta) > 15)) then 
							{
							[_unit,_near,(floor _delta)] spawn tpw_los_fnc_turn;
							};					
					// Disabled due to possible bug with doStop ( 11-23-2012 )	
						//doStop _near;			
						
						//_near reveal _unit;
						
						//_near doWatch _unit;
						
						_near lookat _unit;
						
						_near doTarget _unit;
						
						_near dofire _unit;
						
						_unit setvariable ["tpwcas_los_nexttime", diag_ticktime + 3]; // unit has been spotted - delay LOS check for 3 seconds
						
						_near setVariable ["tpwcas_los_visstate",1]; // LOS true - ONLY USED FOR DEBUG BALL PURPOSES
							
						if (tpwcas_debug > 0) then 
						{
							_msg = format["'tpwcas_los_fnc_mainloop' unit [%1] spotted by enemy ai: [%2] - Distance: [%3] - Value: [%4]", _unit, _near, _dist, _tpwcas_los_cansee];
							[ _msg, 10 ] call bdetect_fnc_debug;
						};	
					};
				};
			} foreach _nearUnits; 
		};
	} count _unitList;
};
