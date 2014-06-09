///////////////////////////////////
// edited by bl1p and fluit
// original by larrow and tg unk
///////////////////////////////////

private ["_spotter","_mortars","_sideToAttack","_targets"];

_spotter = [_this, 0, objNull, [objNull] ] call BIS_fnc_param;
_mortars = [_this, 1, [], [[]] ] call BIS_fnc_param;

_typeOFunit = typeOf _spotter;

MortarsFiring = false;
publicVariable "MortarsFiring";

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
			if (alive _spotter && !MortarsFiring) then {
				_targets set [count _targets, _targetpos];
			};
		};
	} forEach allUnits;

	if (count _targets > 0) then 
	{	
		// Start fire mission
		MortarsFiring = true;
		publicVariable "MortarsFiring";
		_target 			= _targets call BIS_fnc_selectRandom;
		_ChosentargetPos 	= [_target select 0, _target select 1, _target select 2];
		_knowsabout 		= _target select 3;
		_salvos				= 1;
		_spread				= 30;
		_nighttime 			= false;
		
		if (daytime > 19.5 || daytime < 4.5) then { _nighttime = true; };
		if (DEBUG) then {
			diag_log format ["daytime = %1",daytime];
		};
		
		if (_knowsabout >= 2.7) then { 
			_salvos = 2; 
			_spread = 25; 
		};
		if (_knowsabout >= 3) then { 
			_salvos = 3; 
			_spread = 20; 
		};
		if (_knowsabout >= 3.5) then { 
			_salvos = 4; 
			_spread = 15; 
		};
		if (_knowsabout >= 4) then { 
			_salvos = 5; 
			_spread = 10; 
		};
		
		if(DEBUG) then {
			diag_log format ["%1 - %3 - _ChosentargetPos is = %2, _knowsabout = %4, nighttime = %5",_spotter, _ChosentargetPos, _typeOFunit, _knowsabout, _nighttime];
		};
		
		// Fire flares at night!
		if (_nighttime && (_knowsabout < 3 || DEBUG)) then {
			if(DEBUG) then {diag_log "firing flare before fire mission";};
			[_ChosentargetPos, 6, "white"] spawn FireFlares;
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
					_x setVehicleAmmo 1;
					_rounds = round (random _s);
					if (_rounds < 1) then {_rounds = 1; };
					_x commandArtilleryFire [_newpos, "8Rnd_82mm_Mo_shells", _rounds];
					_x addMagazine "8Rnd_82mm_Mo_shells";
					if(DEBUG) then {
						diag_log format ["%1- %3 - fireing at = %2",_spotter, _newpos,_typeOFunit];
					};
					sleep (random 1); // Time in between each shell
				};
			}forEach _mortars;
			if (_s < _salvos) then {
				sleep (10 + (random 10)); // Time in between salvo's
			};
		};
		
		// Fire flares at night!
		if (_nighttime && (_knowsabout < 3.5 || DEBUG)) then {
			if(DEBUG) then {diag_log "firing flare after fire mission";};
			[_ChosentargetPos, 12, "white"] spawn FireFlares;
		};
		sleep ((random 30) + 45); // Time in between each fire mission
		MortarsFiring = false;
		publicVariable "MortarsFiring";
	}	else {
		sleep 10; // Time in between checks for mortar targets
	};
};