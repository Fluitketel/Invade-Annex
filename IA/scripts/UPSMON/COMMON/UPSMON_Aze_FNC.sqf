UPSMON_getminesclass =
{
	private ["_minesclassname","_minetype1","_minetype2","_cfgvehicles","_cfgvehicle","_inherit","_vehicle"];
	
	_minesclassname = [];
	_minetype1 = [];
	_minetype2 = [];
	
	_cfgvehicles = (configFile >> "CfgVehicles");
	
	for "_i" from 0 to (count _cfgvehicles)-1 do
	{
		_cfgvehicle = _cfgvehicles select _i;

		if(isClass _cfgvehicle) then
		{
			_inherit = inheritsFrom _cfgvehicle;
			If ((configName _inherit) == "MineBase") then
			{
				_vehicle = configName _cfgvehicle;
				_foundAT=[_vehicle,"ATMine"] call UPSMON_StrInStr; 
				_foundAPERS=[_vehicle,"APERS"] call UPSMON_StrInStr; 
				If (_foundAT) then {_minetype1 = _minetype1 + [_vehicle]};
				If (_foundAPERS) then {_minetype2 = _minetype2 + [_vehicle]};
			};	
		};
	};
	_minesclassname = [_minetype1,_minetype2];
	_minesclassname
};

UPSMON_DocreateWP = {
	private ["_npc","_targetpos","_wptype","_wpformation","_speedmode","_grp","_wp1"];
	
	_npc = _this select 0;
	_targetpos = _this select 1;
	_wptype = _this select 2;
	_wpformation = _this select 3;
	_speedmode = _this select 4;
	_Behaviour = _this select 5;
	_CombatMode = _this select 6;
	_delete = if (_this select 7 == 1) then {true} else {false};
	_index = 2;
	_grp = group _npc;
	
	{_x stop false} foreach units _npc;	
	If (_delete) then
	{
		while {(count (waypoints _grp)) > 0} do
		{
			deleteWaypoint ((waypoints _grp) select 0);
		};
		_index = 1;
	};
					
	_wp1 = _grp addWaypoint [_targetPos,_index];
	_wp1  setWaypointPosition [_targetPos,_index];
	_wp1  setWaypointType _wptype;
	_wp1  setWaypointFormation _wpformation;		
	_wp1  setWaypointSpeed _speedmode;
	_wp1 setwaypointbehaviour _Behaviour;
	_wp1 setwaypointCombatMode _CombatMode;
	
};
UPSMON_GothitParam = 
{
	private ["_npc","_gothit"];
	
	_npc = _this select 0;
	_gothit = false;
	
	If (isNil "tpwcas_running") then 
	{
		if (group _npc in UPSMON_GOTHIT_ARRAY || group _npc in UPSMON_GOTKILL_ARRAY) then
		{
			_gothit = true;
		};
	}
	else
	{
		_Supstate = [_npc] call UPSMON_supstatestatus;
		if (group _npc in UPSMON_GOTHIT_ARRAY || group _npc in UPSMON_GOTKILL_ARRAY || _Supstate >= 2) then
		{
			_gothit = true;
		};
	};
	
	_gothit
};


UPSMON_supstatestatus = {
	private ["_npc","_azesupstate","_tpwcas_running"];
	
	_tpwcas_running = if (!isNil "tpwcas_running") then {true} else {false};

	_npc = _this select 0;
	_azesupstate = 0;

	if (_tpwcas_running) then
	{
		{
			If (_x getvariable "tpwcas_supstate" == 3) exitwith {_azesupstate = 3;};
			If (_x getvariable "tpwcas_supstate" == 2) exitwith {_azesupstate = 2;};
		} foreach units group _npc;
	};
	
	_azesupstate
};
UPSMON_checksizetargetgrp = {
	private ["_mennear","_result","_pos","_radius"];

	_pos = _this select 0;
	_radius = _this select 1;
	_side = _this select 2;
	
	_mennear = nearestobjects [_pos,["CAManBase"],_radius];
	_result = false;
	_allied = [];
	_eny = [];

	{
		If ((alive _x) && (side _x != _side) && _npc knowsabout _x >= UPSMON_knowsAboutEnemy) then {_eny = _eny + [_x];}
	} foreach _mennear;
	

	_result = [_eny];
	_result
};
UPSMON_checkallied = {
private ["_npc","_mennear","_result","_radius"];

	_npc = _this select 0;
	_radius = _this select 1;
	_side = side _npc;
	
	_mennear = _npc nearTargets 180;
	_result = false;
	_allied = [];
	_eny = [];
	_enemySides = _npc call BIS_fnc_enemySides;
	
	{
		_unit = _x select 4;
		_unitside = _x select 2;
		If ((alive _unit) && (_unitside == _side) && !(_unit in (units _npc)) && !(captive _unit)) then {_allied = _allied + [_x];};
		If ((alive _unit) && (_unitside in _enemySides) && _npc knowsabout _unit >= UPSMON_knowsAboutEnemy) then {_eny = _eny + [_x];}
	} foreach _mennear;
	

	_result = [_allied,_eny];
	_result
};


UPSMON_WITHDRAW = {
		private ["_npc","_target","_AttackPos","_dir1","_dir2","_targetPos","_artillerysideunits","_RadioRange","_array"]; 	
		_npc = _this select 0;
		_target = _this select 1;
		_AttackPos = _this select 2;
		_RadioRange = _this select 3;
		_behaviour = "COMBAT";
		_CombatMode = "BLUE";
		// angle from unit to target
		_dir1 = [getpos _npc,_AttackPos] call UPSMON_getDirPos;
		_dir2 = (_dir1+180) mod 360;
		
		_targetPos = [_npc,_dir2,150] call UPSMON_SrchRetreatPos;
		
					
		if (UPSMON_Debug>=1) then 
		{
			"avoid" setmarkerpos _targetPos;							
		};	
		
				
		// New Code:
		If (_npc distance _target >= 200 && morale _npc < -1.2) then 
		{
			_behaviour = "CARELESS";
			
			{ 
				_x allowfleeing 1;
				_x domove _targetPos;
			} foreach units group _npc;
		} 
		else 
		{
			_CombatMode = "GREEN";
			_behaviour = "AWARE"; 
			
			{
				_x allowfleeing 0;
				_x domove _targetPos;
			} foreach units group _npc;
		};
		// end new code
					
		if (UPSMON_Debug>0) then {player sidechat format["%1 All Retreat!!!",_npc]};
		_wptype = "MOVE";
		_wpformation = "LINE";
		_speedmode = "FULL";
		[_npc,_targetpos,_wptype,_wpformation,_speedmode,_behaviour,_CombatMode,1] spawn UPSMON_DocreateWP;
};

UPSMON_getequipment = 
{
	private ["_unit","_maguniformunit","_magbackunit","_magvestunit","_uniform","_headgear","_vest","_bag","_classbag","_itemsunit","_weaponsunit","_equipmentarray"];
	_unit = _this;
	_maguniformunit = [];
	_magbackunit = [];
	_magvestunit = [];


	_uniform = uniform _unit;
	If (_uniform != "") then {_maguniformunit = getMagazineCargo uniformContainer _unit;};

	_headgear = headgear _unit;

	_vest = vest _unit;
	If (_vest != "") then {_magvestunit = getMagazineCargo vestContainer _unit;};

	_bag = unitBackpack _unit;
	_classbag = typeOf _bag;
	If (_classbag != "") then {_magbackunit = getMagazineCargo backpackContainer _unit;};


	_itemsunit = items _unit;
	_assigneditems = assignedItems _unit;
	_weaponsunit = weaponsItems _unit;


	_allmag = [] + [_maguniformunit] + [_magvestunit] + [_magbackunit];
	_equipmentarray = [_uniform,_headgear,_vest,_classbag,_itemsunit,_assigneditems,_allmag,_weaponsunit];
	_equipmentarray
};

UPSMON_addequipment = {
	private ["_unit","_clonearray","_uniform","_headgear","_vest","_classbag","_itemsunit","_assigneditems","_allmag","_weaponsunit","_index","_array1","_array2","_magazineName","_count","_weapon","_item1","_item2","_item3"];
	_unit = _this select 0;

	_clonearray = _this select 1;
	_uniform = _clonearray select 0;
	_headgear = _clonearray select 1;
	_vest = _clonearray select 2;
	_classbag = _clonearray select 3;
	_itemsunit = _clonearray select 4;
	_assigneditems = _clonearray select 5;
	_allmag = _clonearray select 6;
	_weaponsunit = _clonearray select 7;


	removeAllAssignedItems _unit;
	removeHeadgear _unit;
	removeAllItemsWithMagazines _unit;
	removeAllWeapons _unit;
	removeAllContainers _unit;

	If (_uniform != "") then {_unit addUniform _uniform;};
	If (_vest != "") then {_unit addVest _vest;};
	If (_headgear != "") then {_unit addHeadgear _headgear;};
	If (_classbag != "") then {_unit addBackpack _classbag;};

	{
		_unit addItem _x;
	} foreach _itemsunit;

	{
		_unit addItem _x;
		_unit assignItem _x;
	} foreach _assigneditems;

	{
		If (count _x > 0) then 
		{
			_array1 = _x select 0;
			_array2 = _x select 1;
			_index = -1;
			{
				_index = _index + 1;
				_magazineName = _x;
				_count = _array2 select _index;
				_unit addMagazines [_magazineName, _count];
			} foreach _array1;
		};
	} foreach _allmag;

	_index = -1;

	{
		_index = _index +1;
		_weapon = _x select 0;
		_item1 = _x select 1;
		_item2 = _x select 2;
		_item3 = _x select 3;
		_magweapon1 = (_x select 4) select 0;
		_magweapon2 = "";
		if (count _x > 5) then {_magweapon2 = (_x select 5) select 0};
	
		if (_index == 0) then {{_item = _x; If (_item != "") then {_unit addPrimaryWeaponItem _item;}} foreach [_item1,_item2,_item3];};
		if (_index == 1) then {};
		if (_index == 2) then {{_item = _x; If (_item != "") then {_unit addHandgunItem _item;}} foreach [_item1,_item2,_item3];};
	
		_unit addMagazineGlobal _magweapon1;
		If (_magweapon2 != "") then {_unit addMagazineGlobal _magweapon2;};
		_unit addWeaponGlobal _weapon;
	} foreach _weaponsunit;
};

UPSMON_checkmunition = {
	private ["_npc","_units","_result","_unit","_weapon","_magazineclass","_magazines","_result1","_result2","_weapon","_sweapon","_mags","_magazinescount","_smagazineclass"];
	
	_npc = _this select 0;
	_units = units _npc;
	_result = [];
	_result1 = [];
	_result2 = [];
	_minmag = 2;	

	{
		If (!IsNull _x && alive _x && vehicle _npc == _npc) then
		{
			_unit = _x;
			_weapon = currentweapon _unit;
			_sweapon = secondaryWeapon _unit;
			_magazineclass = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
			_smagazineclass = [];
			If (_sweapon != "") then {_smagazineclass = getArray (configFile / "CfgWeapons" / _sweapon / "magazines");}; 
			
			if (count _magazineclass > 0) then 
			{
				_mags = magazinesAmmoFull _unit;
				_magazinescount = 0;
				{_magclass = _x; _magazinescount1 = {(_x select 0) == _magclass} count _mags;_magazinescount = _magazinescount + _magazinescount1;} foreach _magazineclass;
				If (_magazinescount <= 2 && !(_unit in _result1)) then {_result1 = _result1 + [_unit]};
			};
			
			if (count _smagazineclass > 0) then 
			{
				_mags = magazinesAmmoFull _unit;
				_magazinescount = 0;
				{_magclass = _x; _magazinescount1 = {(_x select 0) == _magclass} count _mags;_magazinescount = _magazinescount + _magazinescount1;} foreach _smagazineclass;
				If (_magazinescount <= 0 && !(_unit in _result2)) then {_result2 = _result2 + [_unit]};
			};
			
		};
		
	} foreach _units;

	_result = _result + [_result1];
	_result = _result + [_result2];
	_result
	
};

UPSMON_analysegrp = {
	private ["_npc","_units","_assignedvehicles","_typeofgrp","_capacityofgrp","_result","_vehicleClass","_MagazinesUnit","_Cargo","_gunner","_ammo","_irlock","_laserlock","_airlock"];
	_npc = _this select 0;
	_assignedvehicles = [];
	_typeofgrp = [];
	_capacityofgrp = [];
	_result = [];
	
	if !(alive _npc) exitwith {_result = _result + [_typeofgrp];
	_result = _result + [_capacityofgrp];
	_result = _result + [_assignedvehicles];
	_result;};
	
	_units = units _npc;

	
	{
		If (alive _x) then
		{

			if ((vehicle _x) != _x && !(Isnull assignedVehicle _x) && !(_x in (assignedCargo assignedVehicle _x))) then 
			{
				if (!((assignedVehicle _x) in _assignedvehicles)) then 
				{
					_vehicle = assignedVehicle _x;
					_assignedvehicles set [count _assignedvehicles, _vehicle];
					_MagazinesUnit=(magazines _vehicle);
					_Cargo  = getNumber  (configFile >> "CfgVehicles" >> typeof _vehicle >> "transportSoldier");
					_gunner = gunner _vehicle;
					
					{
						_ammo = tolower gettext (configFile >> "CfgMagazines" >> _x >> "ammo");
						_irlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "irLock");
						_laserlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "laserLock");
						_airlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "airLock");
						_hit	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "hit");
					
						if (_airlock==1 && (_ammo iskindof "BulletBase") && !("aa1" in _capacityofgrp)) then
						{_capacityofgrp = _capacityofgrp + ["aa1"]};
						if (_airlock==2 && !(_ammo iskindof "BulletBase") && !("aa2" in _capacityofgrp)) then
						{_capacityofgrp = _capacityofgrp + ["aa2"]};
						if ((_irlock>0 || _laserlock>0) && 
						((_ammo iskindof "RocketBase") || (_ammo iskindof "MissileBase")) && !("at2" in _capacityofgrp)) then
						{_capacityofgrp = _capacityofgrp + ["at2"]};
						if (_ammo iskindof "ShellBase" && !("at3" in _capacityofgrp)) then
						{_capacityofgrp = _capacityofgrp + ["at3"]};
						if (_ammo iskindof "BulletBase" && (_hit >= 40) && !("at1" in _capacityofgrp)) then
						{_capacityofgrp = _capacityofgrp + ["at1"]};
					} foreach _MagazinesUnit;
					
					if (_vehicle iskindof "car" && !("car" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["car"];};
					if (_vehicle iskindof "tank" && !("tank" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["tank"];};
					if (_vehicle iskindof "Wheeled_APC_F" && !("apc" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["apc"];};
					if (_vehicle iskindof "air" && !("air" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["air"];};
					if (_vehicle iskindof "Ship" && !("ship" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["ship"];};
					if (_cargo > 2 && !("transport" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["transport"];};
					if (!(Isnull _gunner) && !("armed" in _typeofgrp)) then 
					{_typeofgrp = _typeofgrp + ["armed"];};
					
				};		
			}
			else
			{
				//_sweapon = secondaryWeapon _unit;
				//If (_sweapon != "") then {_smagazineclass = getArray (configFile / "CfgWeapons" / _sweapon / "magazines");};
				_MagazinesUnit=(magazines _x);
					
				{
					_ammo = tolower gettext (configFile >> "CfgMagazines" >> _x >> "ammo");
					_irlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "irLock");
					_laserlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "laserLock");
					_airlock	= getNumber (configfile >> "CfgAmmo" >> _ammo >> "airLock");
					

					if (_airlock==2 && !(_ammo iskindof "BulletBase") && !("aa2" in _capacityofgrp)) then
					{_capacityofgrp = _capacityofgrp + ["aa2"]};
					if ((_irlock>0 || _laserlock>0) && 
					((_ammo iskindof "RocketBase") || (_ammo iskindof "MissileBase")) && !("at2" in _capacityofgrp)) then
					{_capacityofgrp = _capacityofgrp + ["at2"]};
					if ((_irlock==0 || _laserlock==0) && 
					((_ammo iskindof "RocketBase") || (_ammo iskindof "MissileBase")) && !("at1" in _capacityofgrp)) then
					{_capacityofgrp = _capacityofgrp + ["at1"]};
				} foreach _MagazinesUnit;
				
				if (!("infantry" in _typeofgrp)) then 
				{_typeofgrp = _typeofgrp + ["infantry"];};
			};
		};
	
	} foreach units _npc;
	
	_result = _result + [_typeofgrp];
	_result = _result + [_capacityofgrp];
	_result = _result + [_assignedvehicles];
	_result;
};

////////////////////////////////////////////////////////////////////// Target Module ////////////////////////////////////////////////////////

UPSMON_TargetAcquisition = {

	private ["_npc","_shareinfo","_closeenough","_NearestEnemy","_sharedenemy","_target","_dist3","_targets","_dist","_opfknowval","_newtarget","_newattackPos","_targetsnear","_attackPos","_Enemies"];
	
	_npc = _this select 0;
	_shareinfo = _this select 1;
	_closeenough = _this select 2;
	_flankdir = _this select 3;
	_timeontarget = _this select 4;
	_timeinfo = _this select 5;
	_react = _this select 6;

	
	_NearestEnemy = objNull;
	_target = objNull;
	_opfknowval = 0;
	_attackPos = [0,0];
	_Enemies = [];
	_targetsnear = false;
	
		
	_Enemies = [_npc] call UPSMON_findnearestenemy;
	
	If (count _Enemies > 0) then
	{
		_NearestEnemy = (_Enemies select 0) select 0;
	};

		If (IsNull _NearestEnemy) then 
		{	
			//Reveal targets found by members to leader
			{
				_Enemies = [_x] call UPSMON_findnearestenemy;
				
				If (count _Enemies > 0) then
				{
					_NearestEnemy = (_Enemies select 0) select 0;
				};
				
				if ((!IsNull _NearestEnemy) && (_x knowsabout _NearestEnemy > UPSMON_knowsAboutEnemy) 
				&& (_npc knowsabout _NearestEnemy <= UPSMON_knowsAboutEnemy)) then 	
				{		
				
					if (_npc knowsabout _NearestEnemy <= UPSMON_knowsAboutEnemy ) then 	
					{		 
						_npc reveal [_NearestEnemy,_x knowsabout _NearestEnemy];	
					};
				

					_target = _NearestEnemy;
					_opfknowval = _npc knowsabout _target;
					_NearestEnemy setvariable ["UPSMON_lastknownpos", (_Enemies select 0) select 1, false];						
					if (UPSMON_Debug>0) then {diag_log format["%1: %2 added to targets",typeof _x, typeof _target]}; 						
				};
			} foreach units (group _npc);
		}
		else
		{
			_target = _NearestEnemy;
			_opfknowval = _npc knowsabout _target;
			_NearestEnemy setvariable ["UPSMON_lastknownpos",(_Enemies select 0) select 1, false];
		};

		//Resets distance to target
		_dist = 10000;
		
		
		//Gets  current known position of target and distance
		if ( !isNull (_target) && alive _target ) then 
		{
			_newattackPos = _target getvariable ("UPSMON_lastknownpos");
			
			if ( !isnil "_newattackPos" ) then {
				_attackPos=_newattackPos;	
				//Gets distance to target known pos
				_dist = ([getpos _npc,_attackPos] call UPSMON_distancePosSqr);				
			};
			//Shareinfo with allied
			If (_shareinfo=="SHARE" && _timeinfo > 10) then
			{
				//player sidechat "Share Info";
				_timeinfo = 0;
				[_enemies,_npc] spawn UPSMON_Shareinfos;
			};
		};
					
		If (_dist <= 300) then {_targetsnear = true;};
		
		_newtarget = _target;
			
		_lastTarget = (_npc getvariable "UPSMON_Lastinfos") select 4;			
			//If you change the target changed direction flanking initialize
			if (!isNull (_newtarget) && alive _newtarget && (_newtarget != _lastTarget || isNull (_lastTarget)) ) then {
				_timeontarget = time + UPSMON_maxwaiting; 
				_flankdir= if (random 100 <= 10) then {0} else {_flankdir};
				_react = UPSMON_react;
				_attackPos = _newtarget getvariable ("UPSMON_lastknownpos");
				_target = _newtarget;			
			};	
		
		_result = [_Enemies,_target,_dist,_opfknowval,_targetsnear,_attackPos,_timeontarget,_flankdir,_timeinfo,_react];
		
		_result
};

UPSMON_findnearestenemy = {
	private["_npc","_targets","_enemies","_enemySides","_side","_unit"];
	_npc = _this select 0;
	_enemies = [];
	_targets = [];
	
	if (_npc isKindof "CAManBase") then 
	{_targets = _npc nearTargets 900;};
	if (_npc isKindof "car") then 
	{
		If ((!isNull gunner (vehicle _npc)) && (gunner (vehicle _npc) == _npc) ) then 
		{_targets = _npc nearTargets 1500;} else {_targets = _npc nearTargets 500;};
	};
	if (_npc isKindof "Tank" || _npc isKindof "Wheeled_APC") then 
	{
		If (((!isNull gunner (vehicle _npc)) && (gunner (vehicle _npc) == _npc)) || ((!isNull commander (vehicle _npc)) && (commander (vehicle _npc) == _npc))) then 
		{_targets =  _npc nearTargets 1700;} else {_targets = _npc nearTargets 500;};
	};
	if (_npc isKindof "StaticWeapon") then 
	{_targets = _npc nearTargets 1000;};
	if (_npc isKindof "air") then 
	{
		if ((driver (vehicle _npc) == _npc) || ((!isNull gunner (vehicle _npc)) && (gunner (vehicle _npc) == _npc))) then 
		{_targets = _npc nearTargets 2500;};
	};
	
	_enemySides = _npc call BIS_fnc_enemySides;
	
	
	
	{
		_position = (_x select 0);
		_unit = (_x select 4);
		_side = (_x select 2);

		if ((_side in _enemySides) && (count crew _unit > 0)) then
		{
			If (_npc knowsabout _unit >= UPSMON_knowsAboutEnemy) then
			{
				if ((side driver _unit) in _enemySides) then
				{
					_enemies set [count _enemies, [_unit,_position]];
				};
			};
		};
	} forEach _targets;

	If (count _enemies > 0) then
	{
		_enemies = [_enemies, [], { _npc distance (_x select 0) }, "ASCEND"] call BIS_fnc_sortBy;

	};
	if (UPSMON_Debug>0) then {diag_log format ["Targets found by %1: %2",_npc,_enemies];};
	
	_result = _enemies;
	_result
};

UPSMON_Shareinfos = {

	_enemies = _this select 0;
	_npc = _this select 1;
	_arrnpc = UPSMON_NPCs - [_npc];
	_side = side _npc;
	_pos = getpos _npc;
	_alliednpc = [];
	
	{
		If (_side == side _x  
		&& _pos distance _x  <= UPSMON_sharedist && alive _x && !IsNull _x) then {_alliednpc = _alliednpc + [_x];};
	} count _arrnpc > 0;
			
	{
		_npc2 = _x;
		{
			_enemy = _x select 0;
			If (!(IsNull _enemy) 
			&& alive _enemy) then 
			{
				_npc2 reveal [_enemy,1.9];
				if (UPSMON_Debug>0) then {diag_log format ["Target shared by RR to %2: %3",_alliednpc,_enemy];};
			};
		} foreach _enemies;
	} count _alliednpc > 0;
		
};