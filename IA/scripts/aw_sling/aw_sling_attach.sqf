_helo = _this select 0;

if(getPos _helo select 2 > 17) exitWith{hint "Too High To Sling";};

_nearUnits = (getPos _helo) nearEntities [["Car","Motorcycle","Tank","Ship"],17];
if(count _nearUnits < 1) exitWith{hint "No Sling Targets";};

//Add size checks here
_heavyCant = ["C_Van_01_box_F"];
_mediumCant = ["Tank","Wheeled_APC_F","Truck_F"];
_lightCant = _mediumCant + ["MRAP_02_base_F","MRAP_01_base_F","MRAP_03_base_F","Offroad_01_base_F","Boat_Armed_01_base_F"];

_cantLift = [];
if((_helo isKindOf "Heli_Light_01_base_F") OR (_helo isKindOf "Heli_Light_02_base_F")) then {_cantLift = _lightCant};
if((_helo isKindOf "Heli_Transport_01_base_F")) then {_cantLift = _mediumCant};
if((_helo isKindOf "Heli_Transport_02_base_F")) then {_cantLift = _heavyCant};

//Check for vehicles not too heavy to lift
_targets = [];
for [{_y=0},{_y<(count _nearUnits)},{_y=_y+1}] do
{
	_testUnit = _nearUnits select _y;
	_add = true;
	{
		if((_testUnit isKindOf _x) OR (count (crew _testUnit) > 0)) then {_add = false};
	}forEach _cantLift;
	if(_add) then {_targets = _targets + [_testUnit]};
};
if(count _targets < 1) exitWith{hint "No Valid Sling Load Targets (Too Heavy/Units In Cargo)";};


//Find closest valid unit to sling
_target = _targets select 0;
for [{_x=1},{_x<(count _targets)},{_x=_x+1}] do
{
	_testUnit = _targets select _x;
	if(([getPos _target select 0,getPos _target select 1,0] distance [getPos _helo select 0,getPos _helo select 1,0]) < ([getPos _testUnit select 0,getPos _testUnit select 1,0] distance [getPos _helo select 0,getPos _helo select 1,0])) then {_target = _testUnit};
};

//Find sling position
_minZ = (((boundingBox _helo) select 0) select 2) - 1;
_midY = (((boundingBox _helo) select 1) select 1) / 3;
_attachPoint = [0,_midY,_minZ];

//Attach
_target attachTo [_helo,_attachPoint];
_helo setVariable ["aw_sling_attached",true,true];
_helo setVariable ["aw_sling_object",_target,true];
//[_helo] execVM "scripts\aw_sling\aw_sling_heightDisplay.sqf";