
// tpwcas_fnc_run_for_it: civilians will run in random directions due to shooting

//======================================================================================================================================================================================================

tpwcas_fnc_run_for_it =
{
	private ["_unit","_cover","_factorX","_factorY","_coverPosition","_coverDist","_coverTarget","_cPos","_vPos","_debug_flag","_dist","_shooter","_continue","_logOnce","_startTime","_checkTime","_stopped","_tooFar","_tooLong","_elapsedTime"];
	
	_unit 	=	_this select 0;
	
	_shooter = _unit getVariable "tpwcas_shooter";
	
	_unit setVariable ["tpwcas_cover", 1];	
	
	_cPos = (getPosATL _unit);
	
	_cover = random 3;
	if ( _cover > 1.5 ) then 
	{
		_factorY = 90;
	}
	else
	{
		_factorY = -90;
	};
	
	_vPos = [vectorDir _shooter, _factorY] call BIS_fnc_rotateVector2D;
	
	_factorX = random 225;
	
	//set move position to 125 to (350 m away from the shooting
	_coverPosition = [((_cPos select 0) + ((125 + _factorX) * (_vPos select 0))), ((_cPos select 1) + ((125 + _factorX) * (_vPos select 1)))];
	
	while { (surfaceIsWater _coverPosition) } do
	{
		if (tpwcas_debug == 2) then 
		{
			diag_log format ["Civilian Unit [%1] coverPosition is water - looking for new position", _unit];
		};
		
		_vPos = [vectorDir _shooter, _factorY * ((random 2) - 1)] call BIS_fnc_rotateVector2D;
		_factorX = random 125;
		//set move position to 125 to 350 m away from the shooting
		_coverPosition = [((_cPos select 0) + ((125 + _factorX) * (_vPos select 0))), ((_cPos select 1) + ((125 + _factorX) * (_vPos select 1)))];
	};
	
	//Visual Debug
	if (tpwcas_debug > 0) then 
	{		
		_debug_flag = "Flag_FD_Red_F" createVehicle _coverPosition;
		_debug_flag setPosATL [_coverPosition select 0, _coverPosition select 1, getTerrainHeightASL _coverPosition];
	};
		
	doStop _unit;
	sleep 0.1;
	_unit forceSpeed -1;
	_unit moveTo _coverPosition;	
	_coverDist = round ( _unit distance _coverPosition );
	_stopped = false;
	_continue = true;
	_logOnce = true;
	_startTime = time;
	_checkTime = (_startTime + (0.3 * _coverDist) + 10);
	
	while { _continue } do 
	{
		if ( _logOnce && (tpwcas_debug == 2) ) then 
		{
			diag_log format ["Civilian Unit [%1] fleeing to location [%2] - [%3] m", _unit, _coverPosition, _coverDist];
			_logOnce = false;
		};
		
		_dist = round ( _unit distance _coverPosition );
		
		if ( !( unitReady _unit ) && ( _dist > 3 ) && ( alive _unit )) then
		{
			//if unit takes too long to reach cover or moves too far out stop at current location
			_tooFar = ( _dist > ( _coverDist + 20 ));
			_tooLong = ( time > _checkTime );
			_elapsedTime = ( time - _startTime );
			
			if ( _tooFar || _tooLong ) exitWith
			{
				_coverPosition = getPosATL _unit;
				_unit forceSpeed -1;
				_unit doMove _coverPosition;

				_stopped = true;
				_continue = false;
				
				if (tpwcas_debug > 0) then 
				{
					if (tpwcas_debug == 2) then 
					{
						diag_log format ["Civilian Unit [%1] moving wrong way to cover [%2]: [%3] m - drop here - tooFar: [%4] - tooLong: [%5] - ([%6] seconds)", _unit, _cover, _dist, _tooFar, _tooLong, _elapsedTime];
					};
					[['red', _coverPosition],"tpwcas_fnc_debug_smoke",true,false] spawn BIS_fnc_MP;
					if !(isDedicated) then {
						['red', _coverPosition] spawn tpwcas_fnc_debug_smoke;
					};
					sleep 1;
					deleteVehicle _debug_flag;
				};
			};
			sleep 1;
		}
		else
		{	
			if (tpwcas_debug > 0) then 
			{
				if (tpwcas_debug == 2) then 
				{
					diag_log format ["Civilian Unit [%1] reached cover [%2]: [%3] m - [%6] seconds", _unit, _cover, _dist, _tooFar, _tooLong, _elapsedTime];
				};
		
				[['blue', _coverPosition],"tpwcas_fnc_debug_smoke",true,false] spawn BIS_fnc_MP;

				if (hasInterface) then {
					['blue', _coverPosition] spawn tpwcas_fnc_debug_smoke;
				};
				
				sleep 1;
				deleteVehicle _debug_flag;
			};
			_continue = false;
		};
	};
	
	_unit setUnitPos "down"; 
	
	doStop _unit;
	sleep (random 25);
	
	_unit setUnitPos "auto"; 
	
	//doMove:
	//Order the given unit(s) to move to the given position (without radio messages). 
	//After reaching his destination, the unit will immediately return to formation (if in a group),
	//or order his group to form around his new position (if a group leader). 
	_coverPosition = getPosATL _unit;
	_unit forceSpeed -1;
	_unit doMove _coverPosition;
	
	if (tpwcas_debug > 0) then 
	{
		if (tpwcas_debug == 2) then 
		{
			diag_log format ["Civilian Unit [%1] reached cover [%2]: [%3] m - [%6] seconds", _unit, _cover, _dist, _tooFar, _tooLong, _elapsedTime];
		};

		[['green', _coverPosition],"tpwcas_fnc_debug_smoke",true,false] spawn BIS_fnc_MP;

		if (hasInterface) then {
			['green', _coverPosition] spawn tpwcas_fnc_debug_smoke;
		};
	};
	
	//reset run to cover value
	_unit setVariable ["tpwcas_cover", 0];
};
