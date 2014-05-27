///////////////////////////////////
// edited by bl1p 
// original by larrow and tg unk
///////////////////////////////////


private ["_spotter","_sideToAttack","_targets","_sampos","_spotterType","_planeclass","_tankclass","_typeVeh","_debugCounter"];

spotted = false;
publicvariable "spotted";

spottedPlane = false;
publicvariable "spottedPlane";

spottedTank = false;
publicvariable "spottedTank";

_spotter = _this select 0;
_spotterType = typeOf _spotter;
if(DEBUG) then
	{
	diag_log format ["=======%1  is a REINFORCEMENT spotter==========",_spotterType];
	};

_planeclass = ["B_Plane_CAS_01_F","B_Heli_Attack_01_F"];
_tankclass = ["B_MBT_01_cannon_F","B_MBT_01_TUSK_F","O_MBT_02_cannon_F","O_APC_Tracked_02_AA_F","B_APC_Tracked_01_AA_F"];

MarkerNameVar = []; // create array for marker names

if ( isNull _spotter || { !((typeOf _spotter) isKindOf "MAN") } ) then { "You must supply a unit for the spotter" call BIS_fnc_error; };

_sideToAttack = [];
{
	if (_x getFriend (side _spotter) < 0.6 ) then {
		_sideToAttack set [count _sideToAttack, _x];
	};
}forEach [opfor,west,independent];
sleep 1;
//diag_log format ["_sideto attack = %1",_sideToAttack];
_debugCounter = 1;

while {alive _spotter} do 
{
	
	_debugCounter = _debugCounter + 1;
	//inf
	if (radioTowerAlive && !spotted ) then 
	{
		_targets = [];
		// look for infantry units
		{
		
			if(DEBUG) then
				{
					if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 0 } ) then 
						{
							diag_log format ["Reinforcement - %1 knowsabout = %2",_spotter, (_spotter knowsAbout _x)];
						};
				};
		
			if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x >= 1.5 } ) then 
				{
					_targets set [count _targets, _x];
				};
		
		} forEach allUnits;
		sleep 5;
		// if infantry make sure 3 or more are spotted
			if (count _targets >= 3) then
				{
					if(DEBUG) then
					{
						diag_log format ["_target = %1 targets >=3 calling reinforcements",_targets];
					};
					spotted = true;
					publicvariable "spotted";	
				};
			if (DEBUG && (count _targets >= 1)) then
				{
					if(DEBUG) then
					{
						diag_log format ["_target = %1 targets >=3 calling reinforcements",_targets];
					};
					spotted = true;
					publicvariable "spotted";
				};	
		//diaglog
			if(DEBUG) then
			{
				if (count _targets > 0) then
				{
					diag_log format ["_targets = %1",count _targets];
				};
			};
		
	};
	// plane
	if (radioTowerAlive && !spottedPlane) then 
	{
		// look for vehicles
		{
				if(DEBUG) then
				{
					if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 0 } ) then 
						{
							diag_log format ["Reinforcement - %1 knowsabout = %2",_spotter, (_spotter knowsAbout _x)]; 
						};
				};		
			if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x >= 1.5 } ) then 
				{
					_targets set [count _targets, _x];
					{
						_typeVeh = typeOf _x;
						//is it a plane
						if (_typeVeh in _planeclass && !spottedPlane) then
							{
								if(DEBUG) then
								{
								diag_log format ["_typeVeh is %1 calling plane",_typeVeh];
								};
								spottedPlane = true;
								publicvariable "spottedPlane";
							};
					} foreach _targets;
					sleep 1;
				};
		
		} forEach vehicles;
		sleep 5;
	};
	// tanks
	if (radioTowerAlive && !spottedTank) then 
	{
		// look for vehicles
		{
			if(DEBUG) then
			{
				if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 0 } ) then 
					{
						diag_log format ["Reinforcement - %1 knowsabout = %2",_spotter, (_spotter knowsAbout _x)]; 
					};
			};		
			if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x >= 1.5 } ) then 
				{
					_targets set [count _targets, _x];
					{
						_typeVeh = typeOf _x;
						// is it a tank	
						if (_typeVeh in _tankclass && !spottedTank) then
							{
								if(DEBUG) then
								{
								diag_log format ["_typeVeh is %1 calling tanks",_typeVeh];
								};
								spottedTank = true;
								publicvariable "spottedTank";
							};
					} foreach _targets;
					sleep 1;
				};
		} forEach vehicles;
		sleep 5;
	
	};
	sleep 10;
};