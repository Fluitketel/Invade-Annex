/*
	CLY Body Removal
	Author: Mika Hannola AKA Celery
	
	Description:
	Body and wreck removal script that removes things with a countdown as they come.
	
	How to use:
	[
		60, //Removal delay for bodies (-1 disables removal for this type)
		120, //Removal delay for soft vehicles (-1 disables removal for this type)
		180, //Removal delay for armored vehicles (-1 disables removal for this type)
		300, //Removal delay for aircraft (-1 disables removal for this type)
		[], //Units that aren't removed
		[], //Weapons or items that prevent units from being removed if they have them
		[], //Magazines that prevent units from being removed if they have them
		[] //Backpacks that prevent units from being removed if they have them
	] execVM "cly_bodyRemoval.sqf";
	
	All arguments are -1 or [] by default.
	
	[60] execVM "cly_bodyRemoval.sqf";
	This makes bodies disappear in 60 seconds, leaving everything else untouched.
*/

if (!isServer) exitWith {diag_log "I was kicked from the CLY remove script";};
If (DEBUG) then {diag_log "I am in the cly_removal script";};

_manDelay = [_this, 0, -1, [0]] call BIS_fnc_param;
_softDelay = [_this, 1, -1, [0]] call BIS_fnc_param;
_armorDelay = [_this, 2, -1, [0]] call BIS_fnc_param;
_airDelay = [_this, 3, -1, [0]] call BIS_fnc_param;
CLY_BR_exclusiveUnits = [_this, 4, [], [[]]] call BIS_fnc_param;
CLY_BR_exclusiveWeapons = [_this, 5, [], [[]]] call BIS_fnc_param;
CLY_BR_exclusiveMagazines = [_this, 6, [], [[]]] call BIS_fnc_param;
CLY_BR_exclusiveBackpacks = [_this, 7, [], [[]]] call BIS_fnc_param;

//Exclusiveness check
CLY_BR_exclusive =
{
	if (DEBUG) then {diag_log "Running   CLY_BR_exclusive";};
	private ["_unit", "_exclusive", "_items", "_backpack"];
	_unit = _this;
	_exclusive = true;
	//Unit not excluded
	if !(_unit in CLY_BR_exclusiveUnits) then
	{
		//No exclusive weapons
		if ({_x in weapons _unit} count CLY_BR_exclusiveWeapons == 0) then
		{
			//No exclusive items
			_items = (items _unit) + (assignedItems _unit);
			if ({_x in _items} count CLY_BR_exclusiveWeapons == 0) then
			{
				//No exclusive magazines
				if ({_x in magazines _unit} count CLY_BR_exclusiveMagazines == 0) then
				{
					//No exclusive backpack
					if !(backpack _unit in CLY_BR_exclusiveBackpacks) then
					{
						_exclusive = false;
					};
				};
			};
		};
	};
	_exclusive;
};

//Spawnable script
CLY_BR_removeScript =
{
	if (DEBUG) then {diag_log "Running   CLY_BR_removeScript";};
	_unit = _this select 0;
	_wait = _this select 1;
	sleep _wait;
	//Don't remove flag carriers
	waitUntil {isNull flag _unit};
	//Exit if unit is already gone or is excluded
	if (isNull _unit || _unit call CLY_BR_exclusive) exitWith
	{
		if (!isNull _unit) then
		{
			_unit setVariable ["CLY_BR_pending", nil];
		};
	};
	//Hide body
	if (_unit isKindOf "Man") then
	{
		if (vehicle _unit == _unit) then
		{
			hideBody _unit;
			_removeTime = time + 8;
			while {getPosATL _unit select 2 < 0.2 && time < _removeTime} do {sleep 1;};
		};
		//Remove dropped weapon
		_holder = objNull;
		_holders = getPosATL _unit nearEntities ["WeaponHolderSimulated", 10];
		if (count _holders > 0) then
		{
			_holder = _holders select 0;
		};
		deleteVehicle _holder;
	}
	//Remove bodies in a vehicle if they're waiting to be removed anyway
	else
	{
		{
			if (_x != _unit) then
			{
				if (!alive _x) then
				{
					if (_x getVariable ["CLY_BR_pending", false]) then
					{
						deleteVehicle _x;
					};
				};
			};
		} forEach crew _unit;
	};
	//Delete unit
	deleteVehicle _unit;
};

//Loop
while {true} do
{
	sleep 2;
	{
		_unit = _x;
		if !(_unit getVariable ["CLY_BR_pending", false]) then
		{
			_wait = _manDelay;
			if !(_unit isKindOf "Man") then
			{
				_wait = switch (getNumber (configFile / "CfgVehicles" / (typeOf _unit) / "type")) do
				{
					case 1 : {_armorDelay;};
					case 2 : {_airDelay;};
					default {_softDelay;};
				};
			};
			if (_wait >= 0) then
			{
				if !(_unit call CLY_BR_exclusive) then
				{
					_unit setVariable ["CLY_BR_pending", true];
					[_unit, _wait] spawn CLY_BR_removeScript;
				};
			};
		};
	} forEach allDead;
};