// Written by BON_IF
// Adpated by EightySix
// Stolen by BL1P

if (Debug) then 
	{
	Diag_log "I am in the MPS_FUNC_OUTRO_CAMERA.SQF";
	};

if(isDedicated) exitWith{diag_log "I was kicked from MPS_FUNC_OUTRO_CAMERA.SQF";};

_object = _this select 0;
_totaltime = _this select 1;

_x = getPos _object select 0;
_y = getPos _object select 1;

_pos = [position _object,random 360,2000,true,2] call mps_new_position;

_camera = "camera" camCreate [_x + random 15,_y + random 15,5 + random 15];
_camera camSetTarget _object;
_camera camSetFOV 0.700;
_camera camCommit 0;
WaitUntil{camCommitted _camera && time > 0};

_camera cameraEffect ["internal","back"];
showcinemaborder false;

CAM_STATIC = {
	_time = _this;

	_xpos = getPos _object select 0;
	_ypos = getPos _object select 1;
	_zpos = getPosATL _object select 2;

	_camera camSetPos [_xpos + _dx*sin(getDir _object) - _dy*cos(getDir _object), _ypos + _dx*cos(getDir _object) + _dy*sin(getDir _object), _zpos+_dz];
	_camera camSetTarget _object;
	_camera camSetFOV 0.900;
	_camera camCommit 0;
	WaitUntil{camCommitted _camera};

	_dx = 1.5;
	if(vehicle _object != _object) then {_dx = 4;};
	_camera camSetPos [_xpos + _dx*sin(getDir _object) - _dy*cos(getDir _object), _ypos + _dx*cos(getDir _object) + _dy*sin(getDir _object), _zpos+_dz];
	_camera camSetTarget _object;
	_camera camSetFOV 0.900;
	_camera camCommit _time;
	WaitUntil{camCommitted _camera};
};

_playersNumber = {isPlayer _x} count allUnits;
{
	_dx = 5; _dy = 2 - random 4; _dz = 1 + random 2;
	if(isPlayer _x) then{
		_object = vehicle _x;
		if(vehicle _object != _object) then {_dx = 12;};
		110 cutText [format["%1",name _x],"PLAIN DOWN",0];
		(_totaltime/_playersNumber) call CAM_STATIC;
	};
} foreach allUnits;

	_xpos1 = _pos select 0;
	_ypos1 = _pos select 1;
	_zpos1 = _pos select 2;

	_camera camSetPos [_xpos1, _ypos1, _zpos1 + 1800];
	_camera camSetTarget _object;
	_camera camSetFOV 0.900;
	_camera camCommit 40;
	WaitUntil{camCommitted _camera};

if(true) exitWith{
	player cameraEffect ["terminate","back"];
	camDestroy _camera;
};