UPSMON_DOATTACK = {
	private ["_npc","_attackPos","_dist","_noveh","_noveh2","_gothit","_closeenough","_dir1","_dir2","_wptype","_wpformation","_result","_targetPos","_speedmode","_Behaviour","_grpid","_nofollow","_targetdist"];
	
	_npc = _this select 0;
	_attackPos = _this select 1;
	_dist = _this select 2;
	_noveh = _this select 3;
	_noveh2 = _this select 4;
	_grpid = _this select 5;
	_nofollow = _this select 6;
	_buildingdist = _this select 7;
	_typeofgrp = _this select 8;
	
	_currpos = getpos _npc;
	_gothit = [_npc] call UPSMON_GothitParam;
	
	(group _npc ) enableAttack false;
	{_x stop false} foreach units _npc;		
	_closeenough = UPSMON_closeenough;	
	// get position of spotted unit in player group, and watch that spot
	if (UPSMON_Debug>0 ) then {[_attackPos,"ColorRed"] call fnc_createMarker;};										
			
	// angle from unit to target
	_dir1 = [getpos _npc,_attackPos] call UPSMON_getDirPos;
	_dir2 = _dir1+180;	

						
	//Establish the type of waypoint
	//DESTROY has worse behavior with and sometimes do not move
	_wptype = "MOVE";
	_wpformation = "VEE";
	_CombatMode = "YELLOW";
			
	//Set speed and combat mode 
	_rnd = random 100;
	If (!("ship" in _typeofgrp) && !("air" in _typeofgrp)) then
	{
		If (_dist > _closeenough/2 || !("infantry" in _typeofgrp)) then 
		{
			_result = [_npc,_dir2,_attackPos,0] call UPSMON_SrchFlankPos1;
			_targetPos = _result select 0;
		}
		else
		{

			_targetPos = _attackPos;
			_wptype = "SAD";
			
		};
		if ( _dist <= _closeenough ) then 
		{	
			//If we are so close we prioritize discretion fire
			if ( _dist <= _closeenough/2 ) then 
			{	

				//Close combat modeo	
				_wpformation = "LINE";
				If (("car" in _typeofgrp) || ("tank" in _typeofgrp)) then {_wpformation = "WEDGE";};
			
				// _rnd < 80
				if (morale _npc > 0 && _gothit) then 
				{           
					_Behaviour =  "COMBAT";
					_CombatMode = "RED";
					_speedmode = "FULL";
					(group _npc ) enableAttack true;
				} 
				else 
				{
					_Behaviour =  "STEALTH"; // ToDo check impact "STEALTH";
					_speedmode = "LIMITED";
				};	
					
				 // MOVE
				
			} 
			else 
			{
				//If the troop has the role of not moving tend to keep the position	 
				If (("car" in _typeofgrp) || ("tank" in _typeofgrp)) then {_wpformation = "WEDGE";};					

				// _rnd = 80
				if (!_gothit) then 
				{
					_Behaviour =  "COMBAT";
					_speedmode = "NORMAL";
				} 
				else 
				{
					_Behaviour =  "STEALTH";
					_speedmode = "LIMITED";
				};
						
			};								
		} 
	else	
	{	
				
		if (_dist <= (_closeenough + UPSMON_safedist)) then 
		{

			_speedmode = "NORMAL";
					
			if (morale _npc > 0 && !_gothit && (random 100 > 70)) then 
			{
				_Behaviour = "AWARE";
			} 
			else 
			{
				_Behaviour = "STEALTH";
			};
					
									
		} 
		else 
		{
					
			//In May distance of radio patrol act..
			if (( _dist <  UPSMON_sharedist )) then 
			{
				//Platoon from the target must move fast and to the point
				_Behaviour =  "AWARE"; 
				_speedmode = "FULL";
				_wpformation = "STAG COLUMN";
			} 
			else 
			{
				//Platoon very far from the goal if not move nomove role
				_Behaviour =  "SAFE"; 
				_speedmode = "FULL";	
				_wpformation = "COLUMN";  //COLUMN						
												
			};
		};	
	};
	}
	else
	{
			If ("air" in _typeofgrp) then
			{
				_Behaviour =  "COMBAT";
				_speedmode = "FULL";
				if ( _dist <= 400 ) then 
				{
					_targetPos = _attackPos;
					_wptype = "SAD"; // MOVE
					_CombatMode = "RED";
					
				}
				else
				{
						
					_result = [_npc,_dir2,_attackPos,0] call UPSMON_SrchFlankPosforPlane;
					_targetPos = _result select 0;
				};
			}
			else
			{
				_Behaviour =  "COMBAT";
				_speedmode = "FULL";
				if ( _dist <= 400 && surfaceiswater _targetPos) then 
				{
					_targetPos = _attackPos;
					_wptype = "SAD"; // MOVE
					_CombatMode = "RED";
				}
				else
				{
						
					_result = [_npc,_dir2,_attackPos,0] call UPSMON_SrchFlankPosforboat;
					_targetPos = _result select 0;
					If (!surfaceiswater _targetpos) then {_targetpos = _currpos;};

				};
			};
				
		};
	
		_targetPos = [_targetPos select 0,_targetPos select 1,0];			
		
		//Establecemos el target
		UPSMON_targetsPos set [_grpid,_targetPos];				
		
		_targetdist = [getpos _npc,_targetPos] call UPSMON_distancePosSqr;				
						
		if (_nofollow=="NOFOLLOW") then 
		{
			_targetPos = [_targetPos,_centerpos,_rangeX,_rangeY,_areadir] call UPSMON_stayInside;
			_targetdist = [getpos _npc,_targetPos] call UPSMON_distancePosSqr;
		};
		
		_GetIn_NearestVehicles = false;
		_timebldsrch = 0;
		
		_timebldchk = _npc getvariable "UPSMON_Grpsearchingbld";
		If (IsNil "_timebldchk") then {_timebldsrch = time; {_x setvariable ["UPSMON_Grpsearchingbld",_timebldsrch];} foreach units _npc;};
		
		if (morale _npc > -1
		&& _wptype == "SAD"
		&& _targetdist < 50
		&& (time >= (_npc getvariable "UPSMON_Grpsearchingbld"))) then
		{
			[_npc,50,true,10,false] spawn UPSMON_moveNearestBuildings;
			_timebldsrch = time + 60;
			{_x setvariable ["UPSMON_Grpsearchingbld",_timebldsrch];} foreach units _npc;
			_GetIn_NearestVehicles = true;
		};
		
		
		if (!("Ship" countType [vehicle (_npc)]>0) && (!("ship" in _typeofgrp) && !("air" in _typeofgrp) && !("car" in _typeofgrp) && !("tank" in _typeofgrp))) then 
		{
			If (!_gothit && ( _targetdist >= 1000)) then
			{
				if (!_noveh && !(_npc getvariable "UPSMON_DskHeli") && (_targetpos select 0 != 0 && _targetpos select 1 != 0)) then 
				{
					if (( vehicle _npc == _npc ) && ( _dist > UPSMON_sharedist )) then 
					{
						_GetIn_NearestVehicles = true;
						_targetpos = [_npc,_grpid,_targetpos] call UPSMON_DOfindvehicle;
					};
	
				};
			};
		};
		
		if ((!_GetIn_NearestVehicles) && !_noveh2) then
		{
			if ((!("ship" in _typeofgrp) && !("air" in _typeofgrp) && !("car" in _typeofgrp) && !("tank" in _typeofgrp))) then
			{
				if ( _dist >= 400 || !_gothit) then 
				{
					_GetIn_NearestVehicles = true;
					[_npc,_grpid,150] call UPSMON_DOfindCombatvehicle;
				};
		
			};
		};

		UPSMON_targetsPos set [_grpid,_targetPos];
		[_npc,_targetpos,_wptype,_wpformation,_speedmode,_Behaviour,_CombatMode,1] spawn UPSMON_DocreateWP;

};

UPSMON_DOPATROL = {
	private ["_npc","_wpformation","_speedmode","_areamarker","_wptype","_targetpos","_targetdist","_noveh","_dist","_onroad","_Behaviour"]; 
	
	_npc = _this select 0;
	_wpformation = _this select 1;
	_speedmode = _this select 2;
	_areamarker = _this select 3;
	_noveh = _this select 4;
	_dist = _this select 5;
	_onroad = _this select 6;
	_grpid = _this select 7;
	_Behaviour = _this select 8;
	_combatmode = _this select 9;
	_typeofgrp = _this select 10;
	
	_wptype = "MOVE";
	_targetpos = [_npc,_areamarker,_onroad,_typeofgrp] call UPSMON_SrchPtrlPos;
	_targetdist = [getpos _npc,_targetPos] call UPSMON_distancePosSqr;
	{_x setvariable ["UPSMON_searchingpos",true];} foreach units _npc;
	
	if (( _targetdist >= ( UPSMON_searchVehicledist )) && (!("ship" in _typeofgrp) && !("air" in _typeofgrp) && !("car" in _typeofgrp) && !("tank" in _typeofgrp))) then 
	{
		if (!_noveh && !(_npc getvariable "UPSMON_DskHeli") && (_targetpos select 0 != 0 && _targetpos select 1 != 0)) then 
		{
			if (( vehicle _npc == _npc ) && ( _dist > UPSMON_sharedist )) then 
			{
				_targetpos = [_npc,_grpid,_targetpos] call UPSMON_DOfindvehicle;
			};
	
		};
	};
	
	[_npc,_targetpos,_wptype,_wpformation,_speedmode,_Behaviour,_CombatMode,1] spawn UPSMON_DocreateWP;
	UPSMON_targetsPos set [_grpid,_targetPos];
	{_x setvariable ["UPSMON_searchingpos",false];} foreach units _npc;
};

UPSMON_DODEFEND = {
	private ["_npc","_dist","_target","_fortify","_wptype","_targetPos","_Gothit","_Behaviour","_wpformation","_speedmode","_grpid","_buildingdist"];
	_npc = _this select 0;
	_dist = _this select 1;
	_target = _this select 2;
	_wpformation = _this select 3;
	_speedmode = _this select 4;
	_behaviour = _this select 5;
	_grpid = _this select 6;
	_buildingdist = _this select 7;
	_attackpos = _this select 8;
	_typeofgrp = _this select 9;
	
	_wptype = "HOLD";				
	_targetPos = getpos _npc;
	_Gothit = [_npc] call UPSMON_GothitParam;
	(group _npc ) enableAttack false;
	_CombatMode = "YELLOW";
	

	[_npc,_targetpos,_wptype,_wpformation,_speedmode,_Behaviour,_CombatMode,1] spawn UPSMON_DocreateWP;
	_dir1 = [getpos _npc,_attackPos] call UPSMON_getDirPos;
	_dir2 = _dir1+180;
	
	if (UPSMON_useStatics && (vehicle _npc == _npc) && !_Gothit ) then
	{
		If ((random 100) < 80) then 
		{
			[_npc,_grpid,_buildingdist] call UPSMON_Dofindstatic;
		};
	};
	
	_delete = 1;
	
	If ((IsNull _target || _dist >= 400)) then 
	{
		_hidepos = false;
		_terrainscan = _targetPos call UPSMON_sample_terrain;
		If ((_terrainscan select 0) == "inhabited") then
		{
			[_npc,50,false,50,true] call UPSMON_moveNearestBuildings;
			_Behaviour = "COMBAT";
			_speedmode = "FULL";
			_hidepos = true;
		};
		
		If ((_terrainscan select 0) == "forest" || ((_terrainscan select 0) == "meadow" && (_terrainscan select 1) > 100)) then
		{
			_Behaviour =  "STEALTH";
			_speedmode = "LIMITED";
			//_objects = [ (nearestObjects [_targetPos, [], 50]), { _x call UPSMON_fnc_filter } ] call BIS_fnc_conditionalSelect;
			//if (count _objects > 0) then
			//{
				_hidepos = true;
				//_lookpos = [getposATL _npc,_dir2, 20] call UPSMON_GetPos2D;
				//[_npc,_lookpos,50,_targetPos,units _npc] call UPSMON_fnc_find_cover2;
			//};
		};
		
		if (!_hidepos) then
		{
			_bestplaces = selectBestPlaces [getposATL _npc,60,"(50 * trees) + (3 * hills) + (5 * houses) -(1000 * Sea)",5,1];
			If (count _bestplaces > 0) then
			{
				_Behaviour =  "STEALTH";
				_speedmode = "LIMITED";
				_targetPos = (_bestplaces select 0) select 0;
				
				[_npc,_targetpos,"MOVE",_wpformation,"FULL",_Behaviour,_CombatMode,1] spawn UPSMON_DocreateWP;
				_delete = 0;
			};
		};
	};
	[_npc,_targetpos,_wptype,_wpformation,_speedmode,_Behaviour,_CombatMode,_delete] spawn UPSMON_DocreateWP;
};

UPSMON_DOREINF = {
	private ["_npc","_targetpos","_speedmode","_wptype","_wpformation","_typeofgrp"];
	
	_npc = _this select 0;
	_targetpos = _this select 1;
	_dist = _this select 2;
	_typeofgrp = _this select 3;
	
	{_x enableAI "TARGET"} foreach units _npc;
	_speedmode = "FULL";
	If (UPSMON_DEBUG > 0) then {[_targetpos,"ColorBlue"] call fnc_createMarker;};
	_wptype ="MOVE";
	_wpformation = "COLUMN";
	_behaviour = "SAFE";
	_combatmode = "WHITE";
	
	_targetdist = [getpos _npc,_targetPos] call UPSMON_distancePosSqr;
	
	if (( _targetdist >= ( UPSMON_searchVehicledist )) && (!("ship" in _typeofgrp) && !("air" in _typeofgrp) && !("car" in _typeofgrp) && !("tank" in _typeofgrp))) then 
	{
		if (!_noveh && !(_npc getvariable "UPSMON_DskHeli") && (_targetpos select 0 != 0 && _targetpos select 1 != 0)) then 
		{
			if (( vehicle _npc == _npc ) && ( _dist > UPSMON_sharedist )) then 
			{
				_targetpos = [_npc,_grpid,_targetpos] call UPSMON_DOfindvehicle;
			};
	
		};
	};
	
	[_npc,_targetpos,_wptype,_wpformation,_speedmode,_behaviour,_combatmode,1] spawn UPSMON_DocreateWP;
};


UPSMON_DOfindvehicle = {
	private ["_npc","_unitsIn","_grpid","_targetpos","_timeout","_vehicle","_vehicles","_isFlat","_rnd","_flyInHeight","_paradrop","_centerX2","_centerpos2","_rangeX2","_areadir2","_sindir2","_cosdir2","_tries","_P","_targetPosTemp","_GetOutDist"];
	
	_npc = _this select 0;
	_grpid = _this select 1;
	_targetpos = _this select 2;
	
			
	_unitsIn = [_grpid,_npc] call UPSMON_GetIn_NearestVehicles;						
						
	if ( count _unitsIn > 0) then 
	{		
		_npc setbehaviour "SAFE";
		_npc setspeedmode "FULL";
		_timeout = time + 60;
							
		_vehicle = objnull;
		_vehicles = [];
		{ 
			waitUntil { (vehicle _x != _x) || { time > _timeout } || { moveToFailed _x } || { !canMove _x } || { !canStand _x } || { !alive _x } }; 
								
			if ( vehicle _x != _x && (isnull _vehicle || _vehicle != vehicle _x)) then 
			{
				_vehicle = vehicle _x ;
				_vehicles = _vehicles + [_vehicle]
			};								
		} foreach _unitsIn;

		If ("Ship" countType [vehicle (_npc)]>0) then 
		{
			_isFlat = _targetpos isflatempty [0,10,1,0,1,false];
			If (count _isFlat > 0) then {_targetpos = ASLtoATL _isFlat;};
		};
							
		If ("LandVehicle" countType [vehicle (_npc)]>0) then 
		{
			//check for roads
			_roads = _targetpos nearRoads 100;
			if (count _roads == 0) then
			{
				_isFlat = _targetpos isflatempty [10,10,0.7,10,0,false];
				If (count _isFlat > 0) then {_targetpos = ASLtoATL _isFlat;};
				//[_npc,_targetpos] spawn UPSMON_dotransport;
			}
			else
			{
				_targetpos = position (_roads select 0);
			};
			
		};
							
		if ( "Air" countType [vehicle (_npc)]>0) then 
		{											
			_rnd = (random 2) * 0.1;
			_flyInHeight = round(UPSMON_flyInHeight * (0.9 + _rnd));
			vehicle _npc flyInHeight _flyInHeight;
			_Ucthis = _npc getvariable "UPSMON_Ucthis";
			_paradrop = if ("LANDDROP" in _UCthis) then {false} else {true};
			//If you just enter the helicopter landing site is defined
									
			If (!_paradrop) then 
			{
				player sidechat "LANDDROP started";
				_centerX2 = abs(_targetpos select 0); _centerY2 = abs(_targetpos select 1);
				_centerpos2 = [_centerX2,_centerY2];
				_rangeX2 = 200; _rangeY2 = 200;
				_areadir2 = (0) * -1;
	
				// store some trig calculations
				_cosdir2=cos(_areadir2);
				_sindir2=sin(_areadir2);
	
				_tries=0;
				_P = true;

				while { _P && (_tries<50)} do 
				{
					_tries=_tries+1;
					_targetPosTemp = [_centerX2,_centerY2,_rangeX2,_rangeY2,_cosdir2,_sindir2,_areadir2] call UPSMON_randomPos;
		
					_isFlat = _targetPosTemp isflatempty [10,10,0.4,10,0,false];

					If (count _isFlat > 0) then {_targetpostemp = _isFlat;};
					If ((!surfaceIsWater _targetpostemp) && count _isFlat > 0) then {_P = false; _targetpos = ASLtoATL (_targetPosTemp);};
					sleep 0.05;
				};
			};
										
			_GetOutDist = UPSMON_paradropdist * ((random 0.4) + 1);
			[vehicle _npc,_npc,_paradrop,_TargetPos,_GetOutDist,_flyInHeight] spawn UPSMON_doParadrop; // org _flyInHeight shay_gman changed from MON_doParadrop to MON_landHely
			//Execute control stuck for helys
			
			//[vehicle _npc] spawn UPSMON_HeliStuckcontrol;
			//if (UPSMON_Debug>0 ) then {player sidechat format["%1: flyingheiht=%2 paradrop at dist=%3",_grpidx, _flyInHeight, _GetOutDist,_rnd]}; 
						
		};
	};
	_targetpos;
};


UPSMON_DOfindCombatvehicle = {
	private ["_npc","_unitsIn","_grpid","_dist","_vehicle"];
	
	_npc = _this select 0;
	_grpid = _this select 1;
	_dist = _this select 2;
	//Get in combat vehicles				
	_unitsIn = [];					
	_unitsIn = [_grpid,_npc,_dist,false] call UPSMON_GetIn_NearestCombat;	
	_timeout = time + 30;
				
	if ( count _unitsIn > 0) then 
	{							
		//if (UPSMON_Debug>0 ) then {player sidechat format["%1: Geting in combat vehicle targetdist=%2",_grpidx,_npc distance _target]}; 																						
		_npc setbehaviour "SAFE";
		_npc setspeedmode "FULL";						
						
		{ 
			waituntil {vehicle _x != _x || !canmove _x || !canstand _x || !alive _x || time > _timeout || movetofailed _x}; 
		}foreach _unitsIn;
						
		// did the leader die?
		_npc = [_npc,units _npc] call UPSMON_getleader;							
		if (!alive _npc || !canmove _npc || isplayer _npc ) exitwith {};								
						
		//Return to combat mode
		_npc setbehaviour _Behaviour;
		_npc setformation "COLUMN";
		_timeout = time + 30;
		{ 
			waituntil {vehicle _x != _x || !canmove _x || !alive _x || time > _timeout || movetofailed _x}; 
		}foreach _unitsIn;
						
		{								
			if ( vehicle _x  iskindof "Air") then 
			{
				//moving hely for avoiding stuck
				if (driver vehicle _x == _x) then {
					_vehicle = vehicle (_x);									
					nul = [_vehicle,1000] spawn UPSMON_domove;	
					//Execute control stuck for helys
					[_vehicle] spawn UPSMON_HeliStuckcontrol;
					//if (UPSMON_Debug>0 ) then {diag_log format["UPSMON %1: Getting in combat vehicle - distance: %2 m",_grpidx,_npc distance _target]}; 	
				};									
			};
							
			if (driver vehicle _x == _x) then 
			{
				//Starts gunner control
				nul = [vehicle _x] spawn UPSMON_Gunnercontrol;								
			};
		} foreach _unitsIn;									
	};		
};

UPSMON_Dofindstatic = {
	private ["_npc","_unitsIn","_grpid","_buildingdist"];
	_npc = _this select 0;
	_grpid = _this select 1;
	_buildingdist = _this select 2;
	
//If use statics are enabled leader searches for static weapons near.
	_unitsIn = [_grpid,_npc,_buildingdist] call UPSMON_GetIn_NearestStatic;			
				
	if ( count _unitsIn > 0) then 
	{									
		_npc setspeedmode "FULL";					
		_timeout = time + 60;
					
		{ 
			waituntil {vehicle _x != _x || { time > _timeout } || { movetofailed _x } || { !canmove _x } || { !alive _x } }; 
		} foreach _unitsIn;
	};
					
};

UPSMON_dotransport = {
	if (UPSMON_Debug>0) then { player globalchat format["Mon_landtransport started"];};
	private["_transport","_npc","_getout" ,"_gunner","_targetpos","_helipos","_dist","_index","_grp","_wp","_targetPosWp","_targetP","_units","_crew","_timeout","_jumpers"];				
	_npc = _this select 0;
	_transport = vehicle _npc;
	_targetPos = _this select 1;
	_atdist = UPSMON_closeenoughV  * ((random .4) + 0.6);
	_landonBeh = ["CARELESS","SAFE","AWARE","COMBAT"];

							

	If (vehicle _npc iskindof "TANK" || vehicle _npc iskindof "Wheeled_APC_F") then
	{
		_atdist =  UPSMON_closeenough  * ((random .4) + 0.6);
	};

	_gothit = [_npc] call UPSMON_GothitParam;
	_target = (_npc getvariable "UPSMON_Grpstatus") select 4;
	_enydistance = 1000;
	If (!IsNull _target) then
	{_enydistance = [getposATL _transport,getposATL _target] call UPSMON_distancePosSqr;};
	_dist = [getposATL _transport,_targetPos] call UPSMON_distancePosSqr;
	
	waituntil {count crew _transport > 0 || !alive _transport || !canmove _transport};
	
	while { (_dist >= _atdist) && alive _transport && canmove _transport && count crew _transport > 0 && !_gothit && alive _npc && _enydistance >= UPSMON_closeenough * 1.5} do 
	{			
		_gothit = [_npc] call UPSMON_GothitParam;
		_dist = [getposATL _transport,_targetPos] call UPSMON_distancePosSqr;
		_target = (_npc getvariable "UPSMON_Grpstatus") select 4;
		If (!IsNull _target) then
		{_enydistance = [getposATL _transport,getposATL _target] call UPSMON_distancePosSqr;};
		if (UPSMON_Debug>0 ) then {diag_log format["UPSMON 'landtransport' - Going to dropzone _dist=%1, _atdist=%2", _dist, _atdist ];};	
		sleep 1;
	};
	
	if (!alive _transport) exitwith{};
			
	// did the leader die?
	_npc = [_npc,units _npc] call UPSMON_getleader;							
	if (!alive _npc || !canmove _npc || isplayer _npc ) exitwith {};
	
	_vehicles = [_npc] call UPSMON_FN_vehiclesUsedByGroup; // vehicles use by the group			
	{
		_dogetout = [_x] call UPSMON_FN_unitsInCargo; // units cargo in the vehicle
		_driver = driver _x;

		if ( count _dogetout > 0 ) then 
		{					
			// All units disembark if the vehicle is a Car
			if (isnull (gunner _x)) then
			{
				//Stop the veh for 5.5 sek		
				Dostop _x;					
				sleep 0.8; // give time to actualy stop
				
				{					
					unassignVehicle _x;	
					_x action ["getOut", _x];
					doGetOut _x;
					[_x] allowGetIn false;	
					[_x] spawn UPSMON_cancelstop;
					sleep 0.3;												
				} foreach _dogetout;				

				//We removed the id to the vehicle so it can be reused
				_x setVariable ["UPSMON_grpid", 0, false];	
				_x setVariable ["UPSMON_cargo", [], false];	
						
				// [_npc,_x, _driver] spawn UPSMON_checkleaveVehicle; // if every one outside, make sure driver can walk
				_driver enableAI "MOVE";
				_driver stop false;
				_driver spawn UPSMON_GetOut;
				sleep 0.01;		
			}
			else
			{
				//Stop the veh for 5.5 sek		
				Dostop _x;		
				sleep 0.8; // give time to actualy stop
				
				{					
					unassignVehicle _x;	
					_x action ["getOut", _x];
					doGetOut _x;
					[_x] allowGetIn false;	
					[_x] spawn UPSMON_cancelstop;
					sleep 0.3;												
				} foreach _dogetout;				

				//We removed the id to the vehicle so it can be reused
				_x setVariable ["UPSMON_grpid", 0, false];	
				_x setVariable ["UPSMON_cargo", [], false];	
						
				[_npc,_x, _driver] spawn UPSMON_checkleaveVehicle; // if every one outside, make sure driver can walk					
			};
		};			
	} foreach _vehicles;

};

UPSMON_dodisembark = {
	if (UPSMON_Debug>0) then { player globalchat format["Mon_disembark started"];};
	private["_transport","_npc","_getout" ,"_gunner","_targetpos","_helipos","_dist","_index","_grp","_wp","_targetPosWp","_targetP","_units","_crew","_timeout","_jumpers"];				

	_transport = _this select 0;
	
	
	if (!alive _transport) exitwith{};
	
		_dogetout = [_transport] call UPSMON_FN_unitsInCargo; // units cargo in the vehicle
		_driver = driver _transport;

		if ( count _dogetout > 0 ) then 
		{					
			// All units disembark if the vehicle is a Car
			if (isnull (gunner _transport)) then
			{
				//Stop the veh for 5.5 sek		
				Dostop _driver;					
				sleep 0.8; // give time to actualy stop
				
				{					
					unassignVehicle _transport;	
					_x action ["getOut", _transport];
					doGetOut _x;
					[_x] allowGetIn false;
					_x leaveVehicle _transport;
					sleep 0.1;												
				} foreach _dogetout;				

				//We removed the id to the vehicle so it can be reused
				_transport setVariable ["UPSMON_grpid", 0, false];	
				_transport setVariable ["UPSMON_cargo", [], false];	
						
				// [_npc,_x, _driver] spawn UPSMON_checkleaveVehicle; // if every one outside, make sure driver can walk
				unassignVehicle _driver;
				_driver action ["getOut", _transport];
				doGetOut _driver;
				[_driver] allowGetIn false;	
				_driver enableAI "MOVE";
				_driver stop false;
				_driver leaveVehicle _transport;
				sleep 0.01;		
			}
			else
			{
				//Stop the veh for 5.5 sek		
				Dostop _driver;		
				sleep 0.8; // give time to actualy stop
				
				{					
					unassignVehicle _transport;	
					_x action ["getOut", _transport];
					doGetOut _x;
					[_x] allowGetIn false;	
					_x stop false;
					sleep 0.1;												
				} foreach _dogetout;				

				//We removed the id to the vehicle so it can be reused
				_transport setVariable ["UPSMON_grpid", 0, false];	
				_transport setVariable ["UPSMON_cargo", [], false];	
				_driver stop false;	
				//[_npc,_transport, _driver] spawn UPSMON_checkleaveVehicle; // if every one outside, make sure driver can walk					
			};
		};			

};