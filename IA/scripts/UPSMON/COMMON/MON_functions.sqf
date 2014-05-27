
// ---------------------------------------------------------------------------------------------------------
//Función que devuelve el valor negativo o positivo del seno en base a un angulo
UPSMON_GetSIN = {
	private["_dir","_sin","_cos"];	
	_dir=_this select 0; 
	if (isnil "_dir") exitWith {}; 
		 if (_dir<90)  then  
		 {
			_sin=1;
		 } else 
		{ 
			if (_dir<180) then 
			{
				_sin=-1;
			} else 
			{ 
				if (_dir<270) then 
				{
					_sin=-1;
				}
				else 
				{
					_sin=1;
				};				
			};
		};
	_sin
};

// ---------------------------------------------------------------------------------------------------------
//Función que devuelve el valor negativo o positivo del coseno en base a un angulo
UPSMON_GetCOS = {
	private["_dir","_cos"];	
	_dir=_this select 0; 
	if (isnil "_dir") exitWith {}; 
		 if (_dir<90)  then  
		 {
			_cos=1;
		 } else 
		{ 
			if (_dir<180) then 
			{
				_cos=1;
			} else 
			{ 
				if (_dir<270) then 
				{
					_cos=-1;
				}
				else 
				{
					_cos=-1;
				};				
			};
		};
	_cos
};

// ---------------------------------------------------------------------------------------------------------
//Función que devuelve una posición en 2D a partir de otra, una dirección y una distancia
//param1: posición
//param2: dirección
//param3: distancia
//Retorna vector de posicion en 2D [0,0]
UPSMON_GetPos2D =
{
	private ["_pos","_dir","_dist","_cosU","_cosT","_relTX","_sinU","_sinT","_relTY","_newPos","_newPosX","_newPosY" ];
	_pos = _this select 0;
	_dir = _this select 1;
	_dist = _this select 2;
			
			if (isnil "_pos") exitWith {}; 
			_targetX = _pos select 0; _targetY = _pos select 1; 
			
			//Calculamos posición 	
			_cosU = [_dir] call UPSMON_GetCOS;		_sinU = [_dir] call UPSMON_GetSIN;			
			_cosT = abs cos(_dir);				_sinT = abs sin(_dir);
			_relTX = _sinT * _dist * _cosU;  	_relTY = _cosT * _dist * _sinU;
			_newPosX = _targetX + _relTX;		_newPosY = _targetY + _relTY;		
			_newPos = [_newPosX,_newPosY];
			_newPos;
};

////// Order //////////////////////////////////////////
//Mueve al soldado adelante
UPSMON_domove = {
	private["_npc","_dir1","_targetPos","_dist"];	
	_npc = _this select 0;
	_dist = _this select 1;
	if ((count _this) > 2) then {_dir1 = _this select 2;} else{_dir1 = getDir _npc;};
	
	sleep 0.05;	
	if (!alive _npc  || !canmove _npc ) exitwith{};
	
	_targetPos = [position _npc,_dir1, _dist] call UPSMON_GetPos2D;		
	//If position water and not boat, plane nor diver no go
	
	if (surfaceIsWater _targetPos && { !( _npc iskindof "boat" || _npc iskindof "air" || ["diver", (typeOf (leader _npc))] call BIS_fnc_inString ) } ) exitwith 
	{
		if (UPSMON_Debug>0) then { 
		diag_log format ["UPSMON 'UPSMON_domove' exit: targetPos is water: [%1] - [%2] - [%3]", _npc iskindof 'boat', _npc iskindof 'air', ['diver', (typeOf (leader _npc))] call BIS_fnc_inString];
		};
	};	
	_npc doMove _targetPos;	
};	

//Función que detiene al soldado y lo hace esperar x segundos
UPSMON_doStop = {
	private["_sleep","_npc"];	
	
	_npc = _this select 0;
	_sleep = _this select 1;		
	
	sleep 0.05;	
	if (!alive _npc  || !canmove _npc ) exitwith{};
	if 	( _sleep == 0 ) then {_sleep = 0.1};	
	
	//Restauramos valores por defecto de movimiento
	if 	((_npc getvariable "UPSMON_FORTIFY") select 1) then 
	{	
		dostop _npc ;
		_npc disableAI "TARGET";
	} 
	else 
	{
		dostop _npc ;
		sleep _sleep;	
		[_npc] spawn UPSMON_cancelstop;
	};
};

//Función que detiene al soldado y lo hace esperar x segundos
UPSMON_cancelstop = {
	private["_npc"];
	_npc = _this select 0;
	_npc stop false;
};

//Function for order a unit to exit if no gunner
//Parámeters: [_npc]
//	<-	_npc: 
UPSMON_GetOut = 
{
		private["_vehicle","_npc","_getout" ,"_gunner"];	
				
		_npc = _this;
		_vehicle = vehicle (_npc);	
		_gunner = objnull;
		_gunner = gunner _vehicle;	
		
		sleep 0.05;	
		if (!alive _npc) exitwith{};
		
		//If no leave the vehicle gunner
		if ( isnull _gunner || !alive _gunner  || !canmove _gunner || (_gunner != _npc && driver _vehicle != _npc && commander _vehicle != _npc) ) then { 			
			[_npc] allowGetIn false;
			_npc spawn UPSMON_doGetOut;										 
			unassignVehicle _npc;
			
			//sleep 0.2;
		};	
	};	

//Function for order a unit to exit
//Parámeters: [_npc]
//	<-	_npc: 	
UPSMON_doGetOut = {	
	private["_vehicle","_npc","_getout" ,"_gunner","_groupOne","_timeout","_dir"];	
			
	_npc = _this;
	_vehicle = vehicle (_npc);	
	
	sleep 0.05;	
	if (_vehicle == _npc) exitwith{};	

	//Wait until vehicle is stopped
	waituntil {!alive _npc || !canmove _npc || !alive _vehicle || ( (abs(velocity _vehicle select 0)) <= 0.5 && (abs(velocity _vehicle select 1)) <= 0.5 )
							 || ( _vehicle iskindof "Air" && ((getposATL _vehicle) select 2) <= 2.5)};	

	if (!alive _npc || !canmove _npc) exitwith{};	
	unassignVehicle _npc;	
	_npc action ["getOut", _vehicle];
	doGetOut _npc;
	[_npc] allowGetIn false;	
	nul = [_npc] spawn UPSMON_cancelstop;
	
	waituntil {!alive _npc || !canmove _npc || vehicle _npc == _npc};	
	if (!alive _npc || !canmove _npc) exitwith{};
		
	if (leader _npc != _npc) then {
		//Moves out with dispersion of 45º
		_dir = getDir _npc;	
		_dir = _dir + 45 - (random 90);
		nul = [_npc,25,_dir] spawn UPSMON_domove;
		//if (UPSMON_Debug>0 ) then { player globalchat format["%1 Moving away from %2 %2º",_npc, typeof _vehicle,_dir];};	
	};
};




//Function to surrender AI soldier
//Parámeters: [_npc]
//	<-	 _npc: soldier to surrender
UPSMON_surrended = {
	private ["_npc","_vehicle"];
	_npc = _this select 0;

	if (!alive _npc || !canmove _npc) exitwith {};
	
	_npc addrating -1000;
	_npc setcaptive true;	
	sleep 0.5;
	
	_vehicle = vehicle _npc;
	
	if ( _npc != _vehicle || !(_npc iskindof "Man" )) then {		
		_vehicle setcaptive true;	
		
		if ( "Air" countType [_vehicle]>0) then {											
			
			//Si acaba de entrar en el heli se define punto de aterrizaje
			if (_npc == driver _vehicle ) then { 
				[_vehicle,getpos _vehicle] call UPSMON_MoveHeliback;							
			};				
		} else {			
			_npc spawn UPSMON_doGetOut;			
		};	
		
		//Esperamos a que esté parado		
		waituntil {_npc == vehicle _npc || !alive _npc};
	};	
	
	if (!alive _npc || !canmove _npc) exitwith {};
	_npc setcaptive true;
	_npc stop true;

	_npc setunitpos "UP";	
	removeAllWeapons _npc;	
	sleep 1;
	_npc playMoveNow "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";

};

//Throw a grenade
UPSMON_throw_grenade = {
	private["_target","_npc"];	
	_npc = _this select 0;
	_target = _this select 1;		
	sleep random 1.5;
	if (!alive _npc || (vehicle _npc) != _npc || !canmove _npc) exitwith{};	
	[_npc,_target] call UPSMON_dowatch;
	sleep 0.5;
			
	_npc addMagazine "SmokeShell";
	_npc selectWeapon "throw";
	sleep .1;
	_npc forceWeaponFire ["SmokeShellMuzzle","SmokeShellMuzzle"];
	sleep 1;
	_npc lookat ObjNull;
};

// Función para  mirar en una dirección
UPSMON_dowatch = {
	private["_target","_npc"];		
	_npc = _this select 0;
	_target = [(_this select 1) select 0,(_this select 1) select 1,1];	

	if (!alive _npc) exitwith{};
	_npc lookat ObjNull;
	_npc lookat _target;

};

//Establece el tipo de posición
UPSMON_setUnitPos = {
	private["_pos","_npc"];	
	_npc = _this select 0;
	_pos = _this select 1;	
	if (isnil "_npc") exitWith {}; 
	sleep 0.5;
	if (!alive _npc || !canmove _npc || _npc != vehicle _npc || !(_npc iskindof "Man")) exitwith{};
	_npc setUnitPos _pos;
	sleep 1;
};
//Establece el tipo de posición
UPSMON_setUnitPosTime = {
	private["_pos","_npc"];	
	_npc = _this select 0;
	_pos = _this select 1;	
	_time = _this select 2;
	
	if (!alive _npc || !canmove _npc) exitwith{};
	_npc setUnitPos _pos;
	sleep _time;
	_npc setUnitPos "AUTO";
	sleep 1;
};


//Función que mueve al soldado a la posición de conductor
//Parámeters: [_npc,_vehicle]
//	<-	 _npc: unit to move to driver pos
//	<-	 _vehicle
UPSMON_movetoDriver = {
	private["_vehicle","_npc"];		
	_npc = _this ;
	_vehicle = vehicle _npc;

	//Si está muerto
	if (vehicle _npc == _npc || !alive _npc || !canmove _npc || !(_npc iskindof "Man")) exitwith{};
	
	if (isnull(driver _vehicle) || !alive(driver _vehicle) || !canmove(driver _vehicle)) then { 	
		//if (UPSMON_Debug>0) then {player sidechat format["%1: Moving to driver of %2 ",_npc,typeof _vehicle]}; 	
		 _npc action ["getOut", _vehicle];
		 doGetOut _npc;
		WaitUntil {vehicle _npc==_npc || !alive _npc || !canmove _npc};
		//Si está muerto
		if (!alive _npc || !canmove _npc) exitwith{};		
		unassignVehicle _npc;
		_npc assignasdriver _vehicle;
		_npc moveindriver _vehicle;
	};
};

//Función que mueve al soldado a la posición de conductor
//Parámeters: [_npc,_vehicle]
//	<-	 _npc: unit to move to driver pos
//	<-	 _vehicle
UPSMON_movetogunner = {
	private["_vehicle","_npc"];		
	_npc = _this ;
	_vehicle = vehicle _npc;
	
	sleep 0.05;
	//Si está muerto
	if (vehicle _npc == _npc || !alive _npc || !canmove _npc || !(_npc iskindof "Man")) exitwith{};
	
	if (isnull(gunner _vehicle) || !alive(gunner _vehicle) || !canmove(gunner _vehicle)) then { 	
		if (UPSMON_Debug>0) then {player sidechat format["%1: Moving to gunner of %2 ",_npc,typeof _vehicle]}; 	
		 _npc action ["getOut", _vehicle];
		 doGetOut _npc;
		WaitUntil {vehicle _npc==_npc || !alive _npc || !canmove _npc};
		//Si está muerto
		if (!alive _npc || !canmove _npc) exitwith{};		
		unassignVehicle _npc;
		_npc assignasgunner _vehicle;
		_npc moveingunner _vehicle;
	};
};

////////////////////////////////////////// Get Nearest Vehicle //////////////////////////////

//Función que busca vehiculos cercanos y hace entrar a las unidades del lider
//Parámeters: [_grpid,_npc]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_npc: lider
//	->	_getin: true if any getin
UPSMON_GetIn_NearestVehicles = {
	private["_vehicles","_npc","_units","_unitsIn","_grpid","_getin","_subs","_isdiver"];
	_grpid = _this select 0;	
	_npc = _this select 1;				
	
	_vehicles=[[]];
	_air=[[]];
	_subs=[[]];
	_units = [];
	_unitsIn = [];
	_getin=false;
	
	if (leader _npc == _npc) then {
		_units = units _npc;
	} else {
		_units = _units + [_npc];
	};
	
	{
		if ( (_x!= vehicle _x && !((vehicle _x) iskindof "StaticWeapon" )) || !(_x iskindof "Man") || !alive _x || !canmove _x || !canstand _x) then {_units = _units-[_x];};
	}foreach _units;
	
	_unitsIn = _units;
	
	//First catch combat vehicles
	if ( (count _units) > 0) then 
	{	
		_air = [_npc,200] call UPSMON_NearestsAirTransports;
		{if (_npc knowsabout (_x select 0) <= 0.5) then{ _air = _air - [_x]};}foreach _air;
		_units = [_grpid, _units, _air, false] call UPSMON_selectvehicles;				
	};
	sleep 0.01;
	if ( (count _units) > 1) then 
	{	
		_vehicles = [_npc,200,true] call UPSMON_NearestsLandCombat;
		{if (_npc knowsabout(_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
		_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;		
	};		
	sleep 0.01;
	if ( (count _units) > 0) then 
	{	
		_vehicles = [_npc,200] call UPSMON_NearestsLandTransports;
		{if (_npc knowsabout (_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
		_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;		
	};
	sleep 0.01;
	if ( (count _units) > 0) then 
	{	
		//_isdiver = ["diver", (typeOf (leader _npc))] call BIS_fnc_inString;
		//if ( _isDiver ) then 
		if ( surfaceIsWater getPosASL _npc ) then // either diver or AI floating in the water
		{
			_vehicles = [_npc,200] call UPSMON_Nearestsboats;
			diag_log format ["UPSMON: boats: [%1]", _vehicles];			
			{if (_npc knowsabout (_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
			_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;		
		};
	};
	sleep 0.01;
	if ( (count _units) > 0 &&  (count _vehicles) > 0) then 
	{
		sleep 1;
		_vehicles = _vehicles + _air;
		_units = [_grpid, _units, _vehicles, true] call UPSMON_selectvehicles;
	};	
	sleep 0.01;
	_unitsIn = _unitsIn - _units;

	_unitsIn;
	//sleep 0.05;
};

//Función que busca vehiculos cercanos y hace entrar a las unidades del lider
//Parámeters: [_grpid,_npc]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_npc: lider
//	->	_getin: true if any getin
UPSMON_GetIn_NearestCombat = {
	private["_vehicles","_npc","_units","_unitsIn","_grpid","_getin","_dist","_all"];
	_grpid = _this select 0;	
	_npc = _this select 1;		
	_dist = _this select 2;	
	_all = _this select 3;	
	
	_vehicles=[[]];
	_units = [];
	_unitsIn = [];
	_getin=false;
	
	if (leader _npc == _npc) then {
		_units = units _npc;
	} else
	{
		_units = _units + [_npc];
	};
	
	{
		if ( (_x!= vehicle _x && !((vehicle _x) iskindof "StaticWeapon" )) || !(_x iskindof "Man") || !alive _x || !canmove _x || !canstand _x) then {_units = _units-[_x];};
	}foreach _units;
	
	//If suficient units leader will not get in
	if !(_all) then {
		if (count _units > 2 ) then {_units = _units - [leader _npc]};	
	};
	
	_unitsIn = _units;
	
	//We need 2 units available if not any leave vehicle to another squad	
	if ( (count _units) > 1) then {	
		_vehicles = [_npc,_dist,_all] call UPSMON_NearestsAirCombat;
		{if (_npc knowsabout (_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
		_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;				
	};
	sleep 0.05;
	
	if ( (count _units) > 1) then {	
		_vehicles = [_npc,_dist,_all] call UPSMON_NearestsLandCombat;
		{if (_npc knowsabout(_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
		_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;		
	};
	
	_unitsIn = _unitsIn - _units;

	 _unitsIn;
};

//Función que busca vehiculos cercanos y hace entrar a las unidades del lider
//Parámeters: [_grpid,_npc]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_npc: lider
//	->	_getin: true if any getin
UPSMON_GetIn_NearestBoat = {
	private["_vehicles","_npc","_units","_unitsIn","_grpid","_getin","_dist"];
	_grpid = _this select 0;	
	_npc = _this select 1;		
	_dist = _this select 2;		
	
	_vehicles=[[]];
	_units = [];
	_unitsIn = [];
	_getin=false;
	
	if (leader _npc == _npc) then {
		_units = units _npc;
	} else
	{
		_units = _units + [_npc];
	};
	
	{
		if ( (_x!= vehicle _x && !((vehicle _x) iskindof "StaticWeapon" )) || !(_x iskindof "Man") || !alive _x || !canmove _x || !canstand _x) then {_units = _units-[_x];};
	}foreach _units;
	
	_unitsIn = _units;
	
	//We need 2 units available if not any leave vehicle to another squad	
	if ( (count _units) > 0) then {			
		_vehicles = [_npc,_dist] call UPSMON_Nearestsboats;
		{if (_npc knowsabout (_x select 0) <= 0.5) then{ _vehicles = _vehicles - [_x]};}foreach _vehicles;
		_units = [_grpid, _units, _vehicles, false] call UPSMON_selectvehicles;			
	};
	
	if ( (count _units) > 1 &&  (count _vehicles) > 0) then {
		sleep 1;
		_units = [_grpid, _units, _vehicles, true] call UPSMON_selectvehicles;
	};
	
	_unitsIn = _unitsIn - _units;
	_unitsIn;
};

//Función que busca staticos cercanos y hace entrar a las unidades del lider
//Parámeters: [_grpid,_npc]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_npc: lider
//	->	_getin: true if any getin
UPSMON_GetIn_NearestStatic = {
	private["_vehicles","_npc","_units","_unitsIn","_grpid","_getin","_count"];
	_grpid = _this select 0;	
	_npc = _this select 1;	
	_count = 0;
	_distance = 100;		
	if ((count _this) > 2) then {_distance = _this select 2;};	
	
	_vehicles=[];
	_units = units _npc;
	_unitsIn = [];
	_getin=false;
	
	//Buscamos staticos cerca
	_vehicles = [_npc,_distance] call UPSMON_NearestsStaticWeapons;

	if (UPSMON_Debug>0 ) then {diag_log format["%1: Found %2 estatic weapons %3 ",_grpid,count _vehicles,_npc]};
	if ( count _vehicles == 0) exitwith {_unitsIn;};	
	
	_units = _units - [_npc];

	
	//Solo tomamos las unidades vivas y que no estén en vehiculo
	{
		if ( (_x iskindof "Man") && _x == vehicle _x && alive _x && canmove _x && canstand _x) then {
			_unitsIn = _unitsIn + [_x];			
		};
	}foreach _units;
	
	//Intentamos tomar solo las que estén disponibles
	_units = [];
	{
		if (unitready _x) then {
			_units = _units + [_x];			
		};
	}foreach _unitsin;	
	
	//Si hay unidades disponibles las usamos
	if (count _units > 0) then {
		_unitsIn = _units;
	};
	
	if (UPSMON_Debug>0 ) then {diag_log format["%1: Found %2 estatic weapons %3 men available",_grpid,count _vehicles, count _unitsIn]}; 
	
	 _units = _unitsIn;
	if ( count _unitsIn > 0) then {		
		_units = [_grpid, _units, _vehicles, true] call UPSMON_selectvehicles;				
	};
	
	_unitsIn = _unitsIn - _units;

	_unitsIn;
};

//Function to assign units to vehicles
//Parámeters: [_grpid,_unitsin,_vehicle]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_units: array of units to getin
//	<-	_vehicles: array of vehicles to use
//	->	_untis:  array of units getin
UPSMON_selectvehicles = {
	private["_vehicles","_emptypositions","_units","_unitsIn","_i","_grpid","_vehgrpid","_unit","_wp","_any","_index","_cargo"];
	_grpid = _this select 0;	
	_units = _this select 1;
	_vehicles = _this select 2;	
	_any = _this select 3;	//meter en cualquier vehiculo
	
	_wp = [];	
	_vehicle = [];
	_unitsIn = [];
	_emptypositions = 0;
	_i = 0;
	_vehgrpid = 0;
	_unit = objnull;
	_index = 0;
	_cargo = [];	
	
  	{
		if ((count _units) == 0 )  exitwith {};
		
		_vehicle = _x select 0 ;
		_emptypositions = _x select 1;		
		_unitsIn = [];
		_i = 0;
		_vehgrpid = _vehicle getVariable ["UPSMON_grpid", 0];
		_cargo = _vehicle getVariable ["UPSMON_cargo", [] ];
		//if ( isNil("_vehgrpid") ) then {_vehgrpid = 0;};	
		//if ( isNil("_cargo") ) then {_cargo = [];};		

		//Asignamos el vehiculo a a la escuadra si contiene las posiciones justas
		//Assign the vehicle to the group
		if (_vehgrpid == 0) then {
			_vehicle setVariable ["UPSMON_grpid", _grpid, false];		
			_vehicle setVariable ["UPSMON_cargo", _unitsIn, false];						
			_vehgrpid = _grpid;				
		};	
		
		{
			if (!alive _x || !canmove _x) then 
			{
				_cargo = _cargo - [_x]; 
			};
		} foreach _cargo;
		
		_emptypositions = _emptypositions - (count _cargo - count ( crew _vehicle) );		

				
		if (UPSMON_Debug>0) then {diag_log format["%1 %2 positions=%3 cargo=%4 crew=%5",_grpid, typeof _vehicle, _emptypositions, count _cargo,count (crew _vehicle)]};
		
		//ahora buscamos en cualquier vehiculo
		//look for vehicle and count spaces
		if ( _vehgrpid == _grpid || (_emptypositions > 0 && _any)) then 
		{
			while {_i < _emptypositions && _i < count _units} do
			{
				_unit = _units select _i;		
				_unitsIn = _unitsIn + [_unit];				
				_i = _i + 1;
			};
			_units = _units - _unitsIn;
			
			if ( (count _unitsIn) > 0) then 
			{			
				//Metemos las unidades en el vehiculo
				//Let units board vehicle
				[_grpid,_unitsIn,_vehicle] spawn UPSMON_UnitsGetIn;	
				if (UPSMON_Debug>0 ) then {player sidechat format["%1: Get in %2 %3 units of %4 available",_grpid,typeof _vehicle,count _unitsIn,_emptypositions]}; 				
				if (UPSMON_Debug>0 ) then {diag_log format["UPSMON %1: Moving %3 units into %2 with %4 positions",_grpid,typeof _vehicle,count _unitsIn,_emptypositions]}; 
			};
		};		
		_index 	= _index  + 1;
		sleep 0.05;
	} foreach _vehicles;
	
	_units;
 };


//Funcion que mete la tropa en el vehiculo
//Parámeters: [_grpid,_unitsin,_vehicle]
//	<-	_grpid: id of group to assign to vehicle
//	<-	_unitsin: array of units to getin
//	<-	_vehicle
UPSMON_UnitsGetIn = {
	private["_grpid","_vehicle","_npc","_driver","_gunner", "_unitsin", "_units" , "_Commandercount","_Drivercount","_Gunnercount","_cargo",
			"_Cargocount","_emptypositions","_commander","_vehgrpid","_cargo"];	
			
	_grpid = _this select 0;
	_unitsin = _this select 1;
	_vehicle = _this select 2;
	
	_units = _unitsin;				
	_driver = objnull;
	_gunner = objnull;	
	_commander	= objnull;
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
	_cargo = [];
	
	_Cargocount = (_vehicle) emptyPositions "Cargo";
	_Gunnercount = (_vehicle) emptyPositions "Gunner"; 
	_Commandercount = (_vehicle) emptyPositions "Commander"; 
	_Drivercount = (_vehicle) emptyPositions "Driver"; 					

	//Obtenemos el identificador del vehiculo
	_vehgrpid = _vehicle getvariable ("UPSMON_grpid");
	_cargo = _vehicle getvariable ("UPSMON_cargo");
	if ( isNil("_vehgrpid") ) then {_vehgrpid = 0;};	
	if ( isNil("_cargo") ) then {_cargo = [];};			

	_cargo = _cargo - _unitsin; //Para evitar duplicados
	_cargo = _cargo + _unitsin; //Añadimos a la carga
	_vehicle setVariable ["UPSMON_cargo", _cargo, false];			

	//Hablitamos a la IA para entrar en el vehiculo
	//Tell AI to get in vehicle
	{		
		[_x,0] call UPSMON_dostop;
		
		if ("StaticWeapon" countType [vehicle (_x)]>0) then 
		{
			_x spawn UPSMON_doGetOut;
		};			

		unassignVehicle _x;				
		_x spawn UPSMON_Allowgetin;						
	} foreach _units;				
	
	//Assigned to the leader as commander or cargo		
	{
		if ( _vehgrpid == _grpid && _x == leader _x && _Commandercount > 0 ) exitwith
		{
			_Commandercount = 0;
			_commander = _x;		
			_commander assignAsCommander _vehicle;			
			_units = _units - [_x];
			[_x] orderGetIn true;
		};

		if ( _x == leader _x && _Cargocount > 0 ) exitwith
		{
			_x assignAsCargo _vehicle;	
			_units = _units - [_x];
			_Cargocount = _Cargocount - 1;
			[_x] orderGetIn true;
		};
	} foreach _units;			
	//if (UPSMON_Debug>0 ) then {player sidechat format["%1: _vehgrpid %2 ,_Gunnercount %3, %4",_grpid,_vehgrpid,_Gunnercount,count _units]}; 	
				
	//Si el vehiculo pertenece al grupo asignamos posiciones de piloto, sinó solo de carga
	//Make sure some AI will get in as driver (and if available as gunner(s))
	if ( _vehgrpid == _grpid ) then 
	{		
		//Asignamos el conductor
		if ( _Drivercount > 0 && count (_units) > 0 ) then 
		{ 
			_driver =  _units  select (count _units - 1);									
			[_driver,_vehicle,0] spawn UPSMON_assignasdriver;	
			_units = _units - [_driver];
		};
		
		//Asignamos el artillero
		if ( _Gunnercount > 0 && count (_units) > 0 ) then 
		{ 				
			_gunner = [_vehicle,_units] call UPSMON_getNearestSoldier;				
			[_gunner,_vehicle] spawn UPSMON_assignasgunner;					
			_units = _units - [_gunner];
		};					
	};
	
	//if (UPSMON_Debug>0 ) then {player sidechat format["%1: _vehgrpid=%2 units=%4",_grpid,_vehgrpid,_cargocount,count _units]}; 	
	//Movemos el resto como carga
	if ( _Cargocount > 0 && count (_units) > 0 ) then 
	{ 	
		{			 
			_x assignAsCargo _vehicle;				
			[_x] orderGetIn true;		
			sleep 0.05;			
		} forEach _units;  
	};	
	
	{						
		[_x] spawn UPSMON_avoidDissembark;				
	} forEach _unitsin - [_driver] - [_gunner] -[_commander]; 
	
};

 UPSMON_avoidDissembark = {
	private["_npc","_vehicle","_timeout"];
	
	_npc = _this select 0;
	_vehicle = vehicle _npc ;
	
	_timeout = 120;
	_timeout = time + _timeout;
	
	while {_npc == vehicle _npc && alive _npc && canmove _npc && time < _timeout} do {
		sleep 1;
	};
		
	if (!alive _npc || !canmove _npc || time >= _timeout || driver vehicle _npc == _npc) exitwith{};	
	_npc stop true;
	
	while {_npc != vehicle _npc && alive _npc && canmove _npc} do {sleep 1;};
	_npc stop false;
	sleep 0.5;	
	
	if (!alive _npc || !canmove _npc) exitwith{};		
};


//Función que devuelve un vehiculo de transporte cercano	
//Parámeters: [_npc]
//	<-	_npc: object for  position search
//	->	_vehicle:  vehicle
 UPSMON_NearestLandTransport = {
	private["_vehicle","_npc","_transportSoldier","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount"];	
	
	_npc = _this;				

	_OCercanos = [];
	_transportSoldier = 0;
	_vehicle = objnull;
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
		
	
	//Buscamos objetos cercanos
	_OCercanos = _npc nearentities [["Car","TANK","Truck","Motorcycle"], 150];		
	
	{
		_Cargocount = (_x) emptyPositions "Cargo";
		_Gunnercount = (_x) emptyPositions "Gunner"; 
		_Commandercount = (_x) emptyPositions "Commander"; 
		_Drivercount = (_x) emptyPositions "Driver"; 
		
		_transportSoldier = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
		
		//ToDo check impact (locked _x != 2)
		if ((locked _x == 1 || locked _x == 0 || locked _x == 3)  && canMove _x && _transportSoldier >= count (units _npc)
			&& (_drivercount > 0 || side _npc == side _x )) exitwith {_vehicle = _x;};
	}foreach _OCercanos;
	
	_vehicle;
};	
	
//Función que devuelve un array con los vehiculos terrestres más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_NearestsLandTransports = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;					
		
	_OCercanos = [];
	_emptypositions = 0;
	_vehicles = [];
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
	
	//Buscamos objetos cercanos
	_OCercanos = _npc nearentities [["Car","TANK","Truck","Motorcycle"], _distance];
		
	{
		_Cargocount = (_x) emptyPositions "Cargo";
		_Gunnercount = (_x) emptyPositions "Gunner"; 
		_Commandercount = (_x) emptyPositions "Commander"; 
		_Drivercount = (_x) emptyPositions "Driver"; 
		
		_emptypositions = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
		
		//ToDo check impact (locked _x != 2)
		if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && _emptypositions > 0 && canMove _x
			&& (_drivercount > 0 || side _npc == side _x )) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
	}foreach _OCercanos;
	
	_vehicles;
};	

//Función que devuelve un array con los vehiculos terrestres más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_NearestsLandCombat = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance","_all"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;		
	_all = _this select 2;		
		
	_OCercanos = [];
	_emptypositions = 0;
	_vehicles = [];
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
	
	//Buscamos objetos cercanos
	_OCercanos = _npc nearentities [["Car","TANK","Truck","Motorcycle"] , _distance];
		
	{
		if (_all) then {
			_Cargocount = (_x) emptyPositions "Cargo";
		};
		_Gunnercount = (_x) emptyPositions "Gunner"; 
		_Drivercount = (_x) emptyPositions "Driver"; 
		_Commandercount = (_x) emptyPositions "Commander"; 
		
		_emptypositions = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
		
		//ToDo check impact (locked _x != 2)
		if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && (_Gunnercount > 0) && (canMove _x)
			&& (_drivercount > 0 || side _npc == side _x )) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
	}foreach _OCercanos;
	
	_vehicles;
};		

//Función que devuelve un array con los vehiculos aereos más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_NearestsAirTransports = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;					
		
	_OCercanos = [];
	_emptypositions = 0;
	_vehicles = [];
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
	
	//Searching for close vehicle objects
	_OCercanos = _npc nearentities ["Helicopter", _distance];
		
	{
		_Cargocount = (_x) emptyPositions "Cargo";
		_Gunnercount = (_x) emptyPositions "Gunner"; 
		_Commandercount = (_x) emptyPositions "Commander"; 
		_Drivercount = (_x) emptyPositions "Driver"; 
		
		_emptypositions = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
		
		//ToDo check impact (locked _x != 2)
		if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && _emptypositions > 0 && canMove _x
			&& (_drivercount > 0 || side _npc == side _x ) && (getposATL _x select 2) <= 5) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
	}foreach _OCercanos;
	
	_vehicles;
};	
	
//Function that returns an array with the closest air vehicles
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_NearestsAirCombat = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance","_all"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;		
	_all  = _this select 2;	
		
	_OCercanos = [];
	_emptypositions = 0;
	_vehicles = [];
	_Cargocount = 0;
	_Gunnercount = 0;
	_Commandercount = 0;
	_Drivercount = 0;
	
	
	
	//Buscamos objetos cercanos
	_OCercanos = _npc nearentities ["Helicopter", _distance];
		
	{
		if (_all) then {
			_Cargocount = (_x) emptyPositions "Cargo";
		};
		
		// _Gunnercount = [_x] call RAF_numberOfTurrets;
		_Gunnercount = (_x) emptyPositions "Gunner"; 
		_Drivercount = (_x) emptyPositions "Driver"; 
		_Commandercount = (_x) emptyPositions "Commander"; 
		
		_emptypositions = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
		
		//ToDo check impact (locked _x != 2)
		if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && _Gunnercount > 0 && canMove _x
			&& (_drivercount > 0 || side _npc == side _x )) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
	}foreach _OCercanos;
	_vehicles //return
};		

//Función que devuelve un array con los vehiculos staticos más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_NearestsStaticWeapons = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;					
		
		_OCercanos = [];
		_emptypositions = 0;
		_vehicles = [];
		_Cargocount = 0;
		_Gunnercount = 0;
		_Commandercount = 0;
		_Drivercount = 0;
		
		//Buscamos objetos cercanos
		_OCercanos = _npc nearentities ["StaticWeapon" , _distance];
			
		{
			_Gunnercount = (_x) emptyPositions "Gunner"; 			
			_emptypositions = _Gunnercount;
			
			//ToDo check impact (locked _x != 2)
			if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && alive _x && _emptypositions > 0 ) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
		}foreach _OCercanos;
		
		_vehicles //return
	};		
	
//Función que devuelve un array con los vehiculos marinos más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
 UPSMON_Nearestsboats = {
		private["_vehicles","_npc","_emptypositions","_OCercanos","_driver", "_Commandercount","_Drivercount","_Gunnercount","_Cargocount","_distance"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;					
		
		_OCercanos = [];
		_emptypositions = 0;
		_vehicles = [];
		_Cargocount = 0;
		_Gunnercount = 0;
		_Commandercount = 0;
		_Drivercount = 0;
		
		//Buscamos objetos cercanos
		_OCercanos = _npc nearentities ["Ship" , _distance];
			
		{
			_Cargocount = (_x) emptyPositions "Cargo";
			_Gunnercount = (_x) emptyPositions "Gunner"; 
			_Commandercount = (_x) emptyPositions "Commander"; 
			_Drivercount = (_x) emptyPositions "Driver"; 
			
			_emptypositions = _Cargocount + _Gunnercount + _Commandercount + _Drivercount;
			
			//ToDo check impact (locked _x != 2)
			if ((locked _x == 1 || locked _x == 0 || locked _x == 3) && _emptypositions > 0 && canMove _x && (_drivercount > 0 || side _npc == side _x )) then { _vehicles = _vehicles + [[_x,_emptypositions]];};
		}foreach _OCercanos;
		
		_vehicles //return
	};
	
//Function to delay the taking of the steering wheel and the vehicle will not have time to rise and	
 UPSMON_assignasdriver = {
	private["_vehicle","_driver","_wait"];	
	_driver =  _this  select 0;
	_vehicle = _this select 1;		
	_wait = _this select 2;		
	
	[_driver,_wait] spawn  UPSMON_dostop;
	sleep _wait;
	
	unassignVehicle _driver;
	_driver assignasdriver _vehicle;
	[_driver] orderGetIn true;	

	//if ( UPSMON_Debug>0) then {player sidechat format["%1: assigning to driver of %2 ",_driver,  typeof _vehicle]}; 
};

 UPSMON_assignasgunner = {
	private["_vehicle","_gunner","_dist"];	
	_gunner =  _this  select 0;
	_vehicle = _this select 1;	
	_dist=0;
	
	_gunner assignasgunner _vehicle;
	[_gunner] orderGetIn true;	
	
	waituntil  { _gunner != vehicle _gunner || !alive _gunner || !canmove _gunner ||!alive _vehicle || !canfire _vehicle};
	
	if ( alive _gunner && alive _vehicle && canmove _gunner && canfire _vehicle) then {				
		_dist = _gunner distance _vehicle;
		if (_dist < 3) then {
			_gunner moveInTurret [_vehicle, [0]] ;	
		};		
	};
};


//Allow getin
UPSMON_Allowgetin = {
	//Hablitamos a la IA para entrar en el vehiculo		
	[_this] allowGetIn true;		
};
	

//If every on is outside, make sure driver can move
 UPSMON_checkleaveVehicle={
	_npc = _this select 0;
	_vehicle = _this select 1;
	_driver = _this select 2;
	_in = false;
	
	//Take time to go all units
	sleep 5;
	{
		if (_x != vehicle _x) then {_in = true};
	}foreach units _npc;
	
	
	// if no one is inside
	if (!_in) then {
		_driver enableAI "MOVE"; 
		sleep 1;
		_driver stop false;
		sleep 1;
		_driver leaveVehicle _vehicle; 
		sleep 1;
 	};
 };
 
 ///////////////////////////////////////////////////////////////////////
///////////////////////////////////////// helicopter Module ////////////////////////////////////////////////////////////////////////	
//Function for exiting of heli	
//Parámeters: [_heli,_targetPos,_atdist]
//	<-	_heli: 
//	<-	_targetPos:  position for exiting(if no waypoint used)
//	<- 	_atdist:  distance for doing paradrop or landing
UPSMON_doParadrop = {
	if (UPSMON_Debug>0) then { player globalchat format["Mon_doParadrop started"];};
	private["_heli","_startpos","_npc","_getout" ,"_gunner","_targetpos","_helipos","_dist","_index","_grp","_wp","_targetPosWp","_targetP","_units","_crew","_timeout","_jumpers"];				
	_heli = _this select 0;
	_npc = _this select 1;
	_paradrop = _this select 2;
	
	_targetPos = [0,0];
	_atdist = 550 * ((random 0.4) + 1);
	_flyInHeight =  UPSMON_flyInHeight;	
	If (_paradrop) then {_flyInHeight = UPSMON_paraflyinheight;};
	_timeout=0;
	sleep 1;
	_startpos = getpos _heli; 
	//Gets optional parameters
	if ((count _this) > 3) then {_targetPos = _this select 3;};
	if ((count _this) > 4) then {_atdist = _this select 4;};
	if ((count _this) > 5) then {_flyInHeight = _this select 5;};		
	if ((count _this) > 6) then {_startpos = _this select 6;};
	
	_helipos = [0,0];
	_targetposWp = [0,0];
	_gunner = objnull;
	_gunner = gunner _heli;		
	_dist = 1000000;
	_index = 0;
	_wp = [];
	_units =[];
	_crew =[];
	_jumpers = [];
	_targetPos2 = [];
	_try = 0;
	
	waituntil {count crew _heli > 0 || !alive _heli || !canmove _heli};
	
	iF (!alive _heli || !canmove _heli || count crew _heli == 0) exitwith {};
	
	_units = units _npc;
	_grp = group _npc;
	_driver = driver _heli;
	[_driver,100] call UPSMON_Domove;
	_npc setVariable ["UPSMON_movetolanding",true];
	[_driver] join grpNull;
	if (!(isnull gunner _heli)) then {[gunner _heli] join _driver;};
	
	while {(count (waypoints group (driver _heli))) > 0} do
	{
		deleteWaypoint ((waypoints group (driver _heli)) select 0);
	};
	
	_heli domove _targetPos;
	If (!_paradrop) then
	{
		while {(count (waypoints group (driver _heli))) > 0} do
		{
			deleteWaypoint ((waypoints group (driver _heli)) select 0);
		};
			
		_wp1 = (group _driver) addWaypoint [_targetPos, 1];																								
		//We define the parameters of the new waypoint				
		_wp1  setWaypointType "MOVE";						
		_wp1  setWaypointPosition [_targetPos, 1];		
		_wp1  setWaypointSpeed "FULL";
		_wp1  setWaypointBehaviour "CARELESS";
	};
	
	while {_dist >= _atdist && alive _heli && canmove _heli && count crew _heli > 0} do 
	{			
		If ((getPosATL (vehicle _npc)) select 2 < _flyInHeight) then {_driver flyInHeight _flyInHeight;};
		//if (UPSMON_Debug>0) then {player sidechat format ["flyinheight: %1",getPosATL (vehicle _npc) select 2];};	
		_targetPosWp = _targetPos;
		
		_helipos = getposATL (vehicle _heli);	
		_dist = round([_helipos,_targetPosWp] call UPSMON_distancePosSqr);
		if (UPSMON_Debug>0 ) then {diag_log format["UPSMON 'MondoParaDrop' - Going to dropzone _dist=%1, _atdist=%2", _dist, _atdist ];};	
		sleep 1;
	};
	
	if (!alive _heli || count crew _heli == 0) exitwith{};
	
	_crew = crew _heli;

	// Jump
	if (!(surfaceIsWater (getposATL _heli)) && _paradrop) then { 	
		//moving hely for avoiding stuck
		if (UPSMON_Debug>0 ) then {_heli globalchat format["doing paradrop high %1 dist=%2",(position _heli) select 2,_dist,_atdist];};

		_jumpers = [_heli] call UPSMON_FN_unitsInCargo;	

	
		If ((getPosATL _heli) select 2 < _flyInHeight) then {(vehicle (driver _heli)) flyInHeight _flyInHeight;};
		
		//Do paradrop
		[_jumpers,_heli] spawn {
			_jumpers = _this select 0;
			_heli = _this select 1;
			{
				_x disableCollisionWith _heli;
				unassignVehicle _x;	
				_x action ["EJECT", _heli];
				//doGetOut _x;
				[_x] allowGetIn false;	
				sleep 0.35;
				_chute = createVehicle ["NonSteerable_Parachute_F", (getPos _x), [], 0, "NONE"];
				_chute setPos (getPos _x);
				_x moveinDriver _chute;				
				sleep 0.5;
			} forEach _jumpers;
		};	
		
		_driver flyInHeight (_flyInHeight + 50);
	
	
		
		//Clear Hely vars
		_heli setVariable ["UPSMON_grpid", 0, false];			
		_heli setVariable ["UPSMON_cargo", [], false];
		{if (!IsNull _x && alive _x) then {_x setvariable ["UPSMON_DskHeli",false];};} forEach _jumpers;		
			
		
		If (alive _heli || canmove _heli || !isnull _heli) then {_pos2= [getposATL _driver,getdir _driver, 300] call UPSMON_GetPos2D; _driver domove [_pos2 select 0, _pos2 select 1, _flyInHeight + 50]; sleep 1; [_heli,_startpos] spawn UPSMON_MoveHeliback;};
		
		{if (!IsNull _x && alive _x) then {_x setvariable ["UPSMON_DskHeli",true];};} forEach _jumpers;
		
			
		{if (alive _x && canmove _x) exitwith { _x domove _targetPos;}}foreach _jumpers;	

	} else {
		//land
		
		if (((getposATL _heli) select 2) >= 30 && !surfaceIsWater _helipos || !canmove _heli || !_paradrop) then 
		{	
			
		    [_heli,_startpos,_targetPos,_npc] spawn UPSMON_landHely;				
		} 
		else {				
			If (alive _heli && canmove _heli && count crew _heli > 0) then {
				if (UPSMON_Debug>0 ) then {_heli globalchat format["%1 failed paradrop, trying another time",typeof _heli];};
				//Try another time
				If ((getPosATL (vehicle _npc)) select 2 < _flyInHeight) then {(vehicle (driver _heli)) flyInHeight _flyInHeight;};
				sleep 1;
				[_heli,_npc,_paradrop,_targetPos,_atdist*1.5,_flyingheigh,_startpos] spawn UPSMON_doParadrop; 
			};
		};
	};	
};			

//Lands hely	
UPSMON_landHely = {
	private["_heli","_npc","_crew","_NearestEnemy","_timeout","_landing","_targetpos","_jumpers","_startpos"];				
	_heli = _this select 0;
	_startpos = _this select 1;
	_crew =[];
	_jumpers = [];
	_targetpos=_this select 2;
	_npc = _this select 3;
	_timeout = 0;
	_landing = false;
	
	sleep 0.05;	
	if (!alive _heli  || !canmove _heli) exitwith{};
	_crew = crew _heli;
	_driver = driver _heli;
	_h = "Land_HelipadEmpty_F" createVehicleLocal _targetpos;
	sleep 0.1;
	//Checks hely is already landing
	_landing = _heli getVariable "UPSMON_landing";	
	
	if (isnil ("_landing")) then {_landing=false; _heli setVariable ["UPSMON_landing", false, false];};
	if (_landing) exitwith {};
	
	//Orders to land heli	
	_heli land "GET OUT";
	if (UPSMON_Debug>0 ) then {player globalchat format["%1 is landing",typeof _heli];};
	
	//Puts a mark for knowing hely is landing
	_heli setVariable ["UPSMON_landing", true, false];	
	_timeout = 100 + time;
	//Waits for land position	
	waituntil {!alive _heli || toUpper(landResult _heli) != "NOTREADY" || (landResult _heli) == "" || _timeout > time};	
	if (alive _heli && (toUpper(landResult _heli) == "NOTFOUND" || (landResult _heli) == "")) exitwith { 
		if (UPSMON_Debug>0 ) then { player globalchat format["%1 no landing zone, doing paradrop",typeof _heli];};
		_heli setVariable ["UPSMON_landing", false, false];	
		[_heli,_npc,false,_targetpos,50,UPSMON_flyinheight,_startpos] spawn UPSMON_doparadrop;
	};		
	
	//1rt try-Waits until velocity and heigh are good for getting out
	_timeout = time + 200; 
	waituntil {!alive _heli || time > _timeout || ((abs(velocity _heli select 2)) <= 0.5 && ((getposATL _heli) select 2) < 3)};
		
	//2nd try-Waits until velocity and heigh are good for getting out
	if (((getposATL _heli) select 2) > 2 && ((getposATL _heli) select 2) < 30 && !surfaceiswater position _heli) then { 
		_heli land "GET OUT";
		_timeout = 160 + time;	
		 waituntil {!alive _heli || time > _timeout || ( (abs(velocity _heli select 2)) <= 1 && ((getposATL _heli) select 2) <= 4)};	
		
		if (UPSMON_Debug>0 ) then { player globalchat format["landing: time: %1 velocity: %2 High: %3",time > _timeout,(abs(velocity _heli select 2)),(position _heli) select 2];};
		
		//Failed landing doing paradrop
		if ( ((getposATL _heli) select 2) > 30) exitwith { 
			if (UPSMON_Debug>0 ) then { player globalchat format["%1 landing timeout, doing paradrop",typeof _heli];};
			_heli setVariable ["UPSMON_landing", false, false];	
			sleep 1;
			[_heli,_npc,true,_targetpos,50,UPSMON_flyinheight,_startpos] spawn UPSMON_doparadrop;
		};
	};	
	
	//Chechs if alive before continuing
	if (!alive _heli) exitwith{};

	_jumpers = [_heli] call UPSMON_FN_unitsInCargo;	

	
	
	//dogetout each of _jumpers
	{
		unassignVehicle _x;	
		_x action ["GETOUT", _heli];
		doGetOut _x;
		[_x] allowGetIn false;		
		sleep 0.5;
	} forEach _jumpers;
	
	_npc = leader (_jumpers select 0);
	_npc setvariable ["UPSMON_DskHeli",true];
	_timeout = 100 + time;
	
	//Waits until all getout of heli
	{
		waituntil {!canmove _x || !alive _x || movetofailed _x  || time > _timeout || isTouchingGround _x};
		_x switchMove "AmovPercMstpSrasWrflDnon";
	} forEach _jumpers;
	
	sleep 6;
	_heli land "NONE";
	sleep 0.5;
	[_heli,_startpos] spawn UPSMON_MoveHeliback;
	deletevehicle _h;
	// If leader alive sets combat mode							
	if (alive _npc && canmove _npc) then {	
		//Gets nearest known enemy for putting in combat mode
		_NearestEnemy = _npc findNearestEnemy _npc;
		if (!isnull _NearestEnemy ) then {
			_npc setBehaviour "AWARE"; 
			_groupOne = group _npc;
			_groupOne setFormation "DIAMOND";			
		};	
		
		//Moves to current target Position
		_grpid = _npc getvariable "UPSMON_grpid";
		if !(isnil "_grpid") then {
			_targetpos =(UPSMON_targetsPos select _grpid);
			if (UPSMON_Debug>0) then { player globalchat format["%1 landed, moving to %2 %3",_grpid,_targetpos,count UPSMON_targetsPos];};
		};			
	};
	
	sleep 6;
	//Quitamos el id al vehiculo para que pueda ser reutilizado
	_heli setVariable ["UPSMON_grpid", 0, false];	
	_heli setVariable ["UPSMON_cargo", [], false];	
	_heli setVariable ["UPSMON_landing", false, false];	
	_npc setvariable ["UPSMON_DskHeli",false];
	_npc setVariable ["UPSMON_movetolanding",false];
	
};

UPSMON_MoveHeliback = {
	
	_heli = _this select 0;
	_startpos = _this select 1;
	
	_heli doMove _startpos;
	
	(driver _heli) flyInHeight UPSMON_flyInHeight;
	if (UPSMON_Debug>0) then {player sidechat "Heli Go back";};
	sleep 3;
	_heli domove _startpos;
	
	(driver _heli) stop false;
	
	//_wp2 = (group (driver _heli)) addWaypoint [_startpos, 2];																								
	//We define the parameters of the new waypoint				
	//_wp2  setWaypointType "MOVE";						
	//_wp2  setWaypointPosition [_startpos, 2];		
	//_wp2  setWaypointSpeed "FULL";
	
	// New code
	_timeout = time + 600; 
	waituntil {!alive _heli || time > _timeout || ((_heli distance _startpos) < 100)};
	
	//_wp3 = (group (driver _heli)) addWaypoint [_startpos, 3];																								
	//We define the parameters of the new waypoint				
	//_wp3  setWaypointType "GETOUT";						
	//_wp3  setWaypointPosition [_startpos, 3];		
	//_wp3  setWaypointSpeed "FULL";
	
	_heli land "LAND";
	_timeout = 120 + time;
	waituntil {!alive _heli || time > _timeout || ( (abs(velocity _heli select 2)) <= 0.7 && ((getposATL _heli) select 2) <= 0.8)};
};

//Controls that heli not stoped flying
UPSMON_HeliStuckcontrol = {
	private["_heli","_landing","_stuckcontrol","_dir1","_targetPos","_lastpos"];				
	_heli = _this select 0;
	
	_landing = false;
	_stuckcontrol = false;
	_targetPos=[0,0,0];
	_dir1 = 0;
	
	sleep 0.05;	
	if ( !alive _heli  || !canmove _heli ) exitwith{};
	
	//Checks stuckcontrol not active
	_stuckcontrol = _heli getVariable "UPSMON_stuckcontrol";
	if (isnil ("_stuckcontrol")) then {_stuckcontrol=false};	
	if (_stuckcontrol) exitwith {};
	
	_heli setVariable ["UPSMON_stuckcontrol", true, false];													
	//if (UPSMON_Debug>0 ) then {player globalchat format["%1 stuck control begins",typeof _heli];};
	
	//Stuck loop control
	while {(alive _heli) && (count crew _heli) > 0 } do {	
		sleep 5;		
		if ((abs(velocity _heli select 0)) <= 5 && (abs(velocity _heli select 1)) <= 5 && (abs(velocity _heli select 2)) <= 5 && ((position _heli) select 2) >= 30) then {
		
			_landing = _heli getVariable "UPSMON_landing";	
			if (isnil ("_landing")) then {_landing=false;};
			
			if (!_landing) then {		
				//moving hely for avoiding stuck
				[_heli,800] spawn UPSMON_domove;					
				if (UPSMON_Debug>0 ) then {player GLOBALCHAT format["%1 stucked at %2m height, moving",typeof _heli,(position _heli) select 2];};
				sleep 25;			
			};			
		};
	};	
	//if (KRON_UPS_Debug>0 ) then {player globalchat format["%1 exits from stuck control",typeof _heli];};
	_heli setVariable ["UPSMON_stuckcontrol", false, false];
};

//Function that checks is gunner is alive, if not moves a cargo
UPSMON_Gunnercontrol = {
	private["_vehicle","_gunnercontrol","_hasgunner","_crew","_crew2"];				
	_vehicle = _this select 0;

	_targetPos=[0,0,0];
	_dir1 = 0;
	_gunnercontrol = false;
	_hasgunner = (_vehicle) emptyPositions "Gunner" > 0 || !isnull gunner _vehicle; 
	_crew = [];
	_crew2 = []; //Without driver and gunner
	
	sleep 0.05;	
	if ( !alive _vehicle  || !canmove _vehicle ) exitwith{};
	
	//Checks stuckcontrol not active
	_gunnercontrol = _vehicle getVariable "UPSMON_gunnercontrol";
	if (isnil ("_gunnercontrol")) then {_gunnercontrol=false};	
	if (_gunnercontrol) exitwith {};
	
	_vehicle setVariable ["UPSMON_gunnercontrol", true, false];													
	
	_crew = crew _vehicle;
	//gunner and driver loop control
	while {	alive _vehicle && canmove _vehicle && count _crew > 0} do {
		_crew = crew _vehicle;
		{
			if (!canmove _x || !alive _x) then {_crew = _crew -[_x];};
		}foreach _crew;
		
		//Driver control	
		if ((isnull (driver _vehicle) || !alive (driver _vehicle) || !canmove (driver _vehicle)) && count _crew > 0) then {
			_crew2 = _crew - [gunner _vehicle];
			if (count _crew2 > 0) then {
				(_crew2 select (count _crew2 - 1)) spawn UPSMON_movetodriver;
			};
		};	
		
		//Gunner control	
		if ( _hasgunner && (isnull (gunner _vehicle) || !alive (gunner _vehicle) || !canmove (gunner _vehicle)) && count _crew > 1) then {
			_crew2 = _crew - [driver _vehicle];
			if (count _crew2 > 0) then {
				(_crew2 select (count _crew2 - 1)) spawn UPSMON_movetogunner;
			}else{
				(_crew select 0) spawn UPSMON_movetogunner;
			};
		};
		sleep 20;		
		//if (UPSMON_Debug>0 ) then {player globalchat format["%1 crew=%2",typeof _vehicle, count _crew];};		
	};	
	//if (UPSMON_Debug>0 ) then {player globalchat format["%1 exits from gunner control",typeof _vehicle];};
	_vehicle setVariable ["UPSMON_gunnercontrol", false, false];
};
 
 

//Returns leader if was dead
UPSMON_getleader = {
	private ["_npc","_members","_side"];
	
	_npc = _this select 0;	
	_members = _this select 1;
	_side = (_npc getvariable "UPSMON_Grpinfos") select 0;
	
	//sleep 0.05;
	if (!alive _npc ) then 
	{	
		UPSMON_NPCs = UPSMON_NPCs - [_npc];
		
		switch (_side) do 
		{
			case West: 
			{
				if (_npc in UPSMON_REINFORCEMENT_WEST_UNITS) then  {UPSMON_REINFORCEMENT_WEST_UNITS = UPSMON_REINFORCEMENT_WEST_UNITS - [_npc]};	
			};
			case EAST: 
			{
				if (_npc in UPSMON_REINFORCEMENT_EAST_UNITS) then  {UPSMON_REINFORCEMENT_EAST_UNITS = UPSMON_REINFORCEMENT_EAST_UNITS - [_npc]};
			};
			case resistance: 
			{
				if (_npc in UPSMON_REINFORCEMENT_GUER_UNITS) then  {UPSMON_REINFORCEMENT_GUER_UNITS = UPSMON_REINFORCEMENT_GUER_UNITS - [_npc]};		
			};
	
		};
		
		//soldier not in vehicle takes the lead or not in tank vehicle
		{
			if (alive _x && !isPlayer _x && canmove _x) then
			{
				if (_x == vehicle _x || vehicle _x iskindof "TANK" || vehicle _x iskindof "Wheeled_APC") exitwith 
				{				
					_npc = _x;				
				};
			};
		} foreach _members;					
		
		//if no soldier out of vehicle takes any
		if (!alive _npc ) then 
		{
			{
				if (alive _x && canmove _x) exitwith {_npc = _x;};
			} foreach _members;	
		};

		//If not alive or already leader or is player exits
		if (isPlayer _npc || !alive _npc || !canmove _npc ) then 
		{
			{
				if (alive _x && !isPlayer _x) exitwith {_npc = [_npc, _members] call UPSMON_getleader;};
			} foreach _members;				
		};	

		if (leader _npc == _npc) exitwith {_npc};			
		
		//Set new _npc as leader		
		group _npc selectLeader _npc;					
	};
	_npc // return		
};	

UPSMON_getNearestSoldier = {
	private["_units","_obj","_near"];
		
	_obj = _this select 0;
	_units = _this select 1;
	
	_near = objnull;
	
	{
		if (isnull _near) then {
			_near = _x;
		} else {
			if ( _x distance _obj < _near distance _obj ) then {_near = _x;};
		};
	}foreach _units;
	_near;
};

//Función que devuelve un array con los vehiculos terrestres más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
UPSMON_nearestSoldiers = {
	private["_vehicles","_npc","_soldiers","_OCercanos","_distance","_side"];	
				
	_npc = _this select 0;	
	_distance = _this select 1;					
	
	if (isnull _npc) exitwith {};
	
	_OCercanos = [];
	_soldiers = [];
	
	//Buscamos objetos cercanos
	_OCercanos = _npc nearentities ["Man" , _distance];					
	_OCercanos = _OCercanos - [_npc];			
	
	{			
		if (canmove _x ) then { _soldiers = _soldiers + [_x];};
	}foreach _OCercanos;
	
	_soldiers;
};

//Función que devuelve un array con los vehiculos terrestres más cercanos
//Parámeters: [_npc,_distance]
//	<-	_npc: object for  position search
//	<-	_distance:  max distance from npc
//	->	_vehicles:  array of vehicles
UPSMON_deadbodies = {
		private["_vehicles","_npc","_bodies","_OCercanos","_distance","_side"];	
					
	_npc = _this select 0;	
	_distance = _this select 1;					
	//_side = _this select 2;	
		
		_OCercanos = [];
		_bodies = [];
		
		//Buscamos objetos cercanos
		_OCercanos = nearestObjects [_npc, ["Man"] , _distance];
			
		{			
			if (_npc knowsabout _x >0.5 && (!canmove _x || !alive _x)) then { _bodies = _bodies + [_x];};
		}foreach _OCercanos;
		
		_bodies;
	};

/////////////////////////////////////
// ArmA 3 MP object init functions
UPSMON_fnc_setVehicleInit = {
	private ["_netID","_unit","_unitinit"];
	
	_netID = _this select 0;
	_unit = objectFromNetID _netID;
	_unitinit = _this select 1;
	_unitstr = "_unit";
	
	_index=[_unitinit,"this",_unitstr] call UPSMON_Replace;
	
	call compile format ["%1",_index];
	
	if (UPSMON_Debug>0) then { diag_log format ["UPSMON 'UPSMON_fnc_setVehicleInit': %1 %2 %3",_unitinit,_index,_unit]; };
};

UPSMON_fnc_setVehicleVarName = {
	private ["_netID","_unit","_unitname"];
	
	_netID = _this select 0;
	_unit = objectFromNetID _netID;
	_unitname = _this select 1;
	
	_unit setVehicleVarName _unitname;
	_unit call compile format ["%1=_This; PublicVariable ""%1""",_unitname];
	
	if (UPSMON_Debug>0) then { diag_log format ["UPSMON 'UPSMON_fnc_setVehicleVarName': %1=_This; PublicVariable ""%1""",_unitname]; };
};

