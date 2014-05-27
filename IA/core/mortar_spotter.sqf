///////////////////////////////////
// edited by bl1p and fluit
// original by larrow and tg unk
///////////////////////////////////

private ["_spotter","_mortars","_sideToAttack","_targets","_debugCounter"];

_spotter = [_this, 0, objNull, [objNull] ] call BIS_fnc_param;
_mortars = [_this, 1, [], [[]] ] call BIS_fnc_param;

_typeOFunit = typeOf _spotter;
_debugCounter = 1;

if (DEBUG) then 
	{
		diag_log format ["========%1 is a MORTAR SPOTTER==========",_spotter];
	};

if ( isNull _spotter || { !((typeOf _spotter) isKindOf "MAN") } ) then { "You must supply a unit for the spotter" call BIS_fnc_error; };
if ( count _mortars < 1 ) then { "You must supply atleast one mortar" call BIS_fnc_error; };
{
	if ( !( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _x >> "availableForSupportTypes")) ) ) then {
		(format ["Mortar %1 is not a valid Artillary support unit",_forEachIndex]) call BIS_fnc_error;
	};
}forEach _mortars;

_sideToAttack = [];
{
	if (_x getFriend (side _spotter) < 0.6 ) then {
		_sideToAttack set [count _sideToAttack, _x];
	};
}forEach [opfor,west,independent];

while { { alive _x; }count _mortars > 0 } do 
{
	
	_debugCounter = _debugCounter + 1;
	
	_targets = [];
	{
		if(DEBUG) then
		{
		if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 0 } ) then {
			diag_log format ["MORTAR - %1 - %3 - knowsabout = %2",_spotter, (_spotter knowsAbout _x),_typeOFunit];
		};
		};
		
		if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 2 } ) then {
			_targetpos = getPos _x;
			sleep 10;
			if (alive _spotter) then {
				_targets set [count _targets, _targetpos];
			};
		};
	} forEach allUnits;

	if (count _targets > 0) then 
	{
		
		_ChosentargetPos = _targets select (floor (random (count _targets)));
		//_chosenTarget = _targets select (floor (random (count _targets)));
		//_ChosentargetPos = getPos _chosenTarget;
		
		if(DEBUG) then
		{
		diag_log format ["%1 - %3 - _ChosentargetPos is = %2",_spotter, _ChosentargetPos,_typeOFunit];
		};
			
		{
			if (alive _x) then {
				_x commandArtilleryFire [_ChosentargetPos, (magazines _x) select 0, floor (random 6)+2];
				_x addMagazine "8Rnd_82mm_Mo_shells";
				if(DEBUG) then
				{
				diag_log format ["%1- %3 - fireing at = %2",_spotter, _ChosentargetPos,_typeOFunit];
				};
				sleep 15;
			};
		}forEach _mortars;
		sleep ((floor random 30) + 45);
	};
	sleep 10;
};