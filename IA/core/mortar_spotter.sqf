///////////////////////////////////
// edited by bl1p and fluit
// original by larrow and tg unk
///////////////////////////////////

private ["_spotter","_mortars","_sideToAttack","_targets"];

_spotter = [_this, 0, objNull, [objNull] ] call BIS_fnc_param;
_mortars = [_this, 1, [], [[]] ] call BIS_fnc_param;

_typeOFunit = typeOf _spotter;

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
	_targets = [];
	{
		if(DEBUG) then
		{
			if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 0 } ) then {
				diag_log format ["MORTAR - %1 - %3 - knowsabout = %2",_spotter, (_spotter knowsAbout _x),_typeOFunit];
			};
		};
		
		if (side _x in _sideToAttack && { alive _x && _spotter knowsAbout _x > 2.5 } ) then {
			_targetpos = getPos _x;
			_targetpos set [3, (_spotter knowsAbout _x)]; // Add knowsabout to target position
			sleep 10 + (random 5); // Time to transmit fire mission to mortar crew
			if (alive _spotter) then {
				_targets set [count _targets, _targetpos];
			};
		};
	} forEach allUnits;

	if (count _targets > 0) then 
	{	
		// Start fire mission
		_target 			= _targets call BIS_fnc_selectRandom;
		_ChosentargetPos 	= [_target select 0, _target select 1, _target select 2];
		_knowsabout 		= _target select 3;
		_salvos				= 1;
		_spread				= 30;
		
		if (_knowsabout >= 3) then { 
			_salvos = 3; 
			_spread = 20; 
		};
		if (_knowsabout >= 3.5) then { 
			_salvos = 5; 
			_spread = 10; 
		};
		
		if(DEBUG) then {
			diag_log format ["%1 - %3 - _ChosentargetPos is = %2, _knowsabout = %4",_spotter, _ChosentargetPos, _typeOFunit, _knowsabout];
		};
		
		// Fire salvo's
		for "_s" from 1 to _salvos do {
			if(DEBUG) then {
				diag_log format ["Mortars firing salvo %1 of %2",_s, _salvos];
			};
			sleep (5 + (random (_salvos * 3))); // Simulate time to arm and align mortars for fire mission
			{
				if (alive _x) then {
					_newpos = [_ChosentargetPos, _spread, random 360] call BIS_fnc_relPos;
					if !("8Rnd_82mm_Mo_shells" in (magazines _x)) then {
						_x addMagazine "8Rnd_82mm_Mo_shells"; // Add HE shell to magazines if out of ammo
					};
					//_x commandArtilleryFire [_newpos, (magazines _x) select 0, 1];
					_x commandArtilleryFire [_newpos, "8Rnd_82mm_Mo_shells" select 0, 1]; // Stops unit from firing smoke?
					_x addMagazine "8Rnd_82mm_Mo_shells";
					if(DEBUG) then {
						diag_log format ["%1- %3 - fireing at = %2",_spotter, _newpos,_typeOFunit];
					};
					sleep (random 2); // Time in between each shell
				};
			}forEach _mortars;
			if (_s < _salvos) then {
				sleep (10 + (random 10)); // Time in between salvo's
			};
		};
		sleep ((random 30) + 45); // Time in between each fire mission
	}	else {
		sleep 10; // Time in between checks for mortar targets
	};
};