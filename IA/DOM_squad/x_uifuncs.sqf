// by Xeno
#define THIS_FILE "x_uifuncs.sqf"
#include "x_setup.sqf"

#define CTRL(A) (_disp displayCtrl A)

FUNC(squadmanagementfill) = {
	private ["_disp", "_units", "_i", "_helper", "_ctrl", "_ctrl2", "_sidegrppl", "_grptxtidc", "_grplbidc", "_grpbutidc", "_curgrp", "_leader", "_unitsar", "_name", "_isppp", "_index", "_pic", "_diff"];
	disableSerialization;
	_disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
	
	_units = if (isMultiplayer) then {playableUnits} else {switchableUnits};
	if (isNil QGVAR(SQMGMT_grps)) then {
		GVAR(SQMGMT_grps) = [];
	} else {
		for "_i" from 0 to (count GVAR(SQMGMT_grps) - 1) do {
			_helper = GVAR(SQMGMT_grps) select _i;
			if (isNull _helper) then {
				GVAR(SQMGMT_grps) set [_i, -1];
			} else {
				if (count (units _helper) == 0) then {
					GVAR(SQMGMT_grps) set [_i, -1];
				};
			};
		};
		GVAR(SQMGMT_grps) = GVAR(SQMGMT_grps) - [-1];
	};
	
	for "_i" from 0 to 49 do {
		_ctrl = _disp displayCtrl (4000 + _i);
		_ctrl ctrlShow true;
		_ctrl = _disp displayCtrl (3000 + _i);
		_ctrl ctrlShow true;
		_ctrl ctrlSetText ("Join");
		_ctrl ctrlEnable true;
		_ctrl = _disp displayCtrl (2000 + _i);
		_ctrl ctrlShow true;
		_ctrl = _disp displayCtrl (1000 + _i);
		_ctrl ctrlShow true;
		_ctrl = _disp displayCtrl (6000 + _i);
		_ctrl ctrlShow false;
		_ctrl = _disp displayCtrl (7000 + _i);
		_ctrl ctrlShow false;
	};
	
	_sidegrppl = side (group player);
	{
		if (!((group _x) in GVAR(SQMGMT_grps)) && {side (group _x) getFriend _sidegrppl >= 0.6}) then {
			GVAR(SQMGMT_grps) set [count GVAR(SQMGMT_grps), group _x];
		};
	} forEach _units;
	
	_grptxtidc = 4000;
	_grplbidc = 2000;
	_grpbutidc = 3000;
	_grplockidc = 6000;
	_grplockbutidc = 7000;
	{
		_ctrl = CTRL(_grptxtidc);
		if (group player != _x) then {
			_ctrl ctrlSetText (str(_x));
		} else {
			_ctrl ctrlSetText (str(_x) + " *");
		};
		
		_lockedgr = GV(_x,GVAR(locked));
		if (isNil "_lockedgr") then {_lockedgr = false};
		if (_lockedgr) then {
			CTRL(_grplockidc) ctrlShow true;
		};
		if (player == leader _x) then {
			CTRL(_grplockbutidc) ctrlShow true;
			CTRL(_grplockbutidc) ctrlSetText (if (_lockedgr) then {"Unlock"} else {"Lock"});	
		};
		
		_curgrp = _x;
		_leader = objNull;
		_unitsar = [];
		{
			if (_x != leader _curgrp) then {
				_unitsar set [count _unitsar, _x];
			} else {
				_leader = _x;
			};
		} forEach (units _curgrp);
		if (!isNull _leader) then {
			_unitsar = [_leader] + _unitsar;
		};
		
		_ctrl = CTRL(_grplbidc);
		lbClear _ctrl;
		_ctrl lbSetCurSel -1;
		{
			_name = name _x;
			if (!isPlayer _x) then {
				_name = _name + " (" + "A.I" + ")";
			};
			_name_data = name _x;
			_isppp = false;
			if (_x == player) then {
				_isppp = true;
				_ctrl2 = CTRL(_grpbutidc);
				if (count _unitsar > 1) then {
					_ctrl2 ctrlSetText "Leave";
				} else {
					_ctrl2 ctrlShow false;
				};
			};
			_index = _ctrl lbAdd _name;
			_ctrl lbSetData [_index, _name_data];
			if (_isppp) then {
				_ctrl lbSetColor [_index, [1,1,1,1]];
			};
			_ipic = getText (configFile >> "cfgVehicles" >> (typeOf _x) >> "picture");
			_pic = if (_ipic == "") then {
				"#(argb,8,8,3)color(1,1,1,0)"
			} else {
				getText(configFile>>"CfgVehicleIcons">>_ipic)
			};
			_ctrl lbSetPicture [_index, _pic];
		} forEach _unitsar;
		if (count (units _x) >= 32) then {
			_ctrl2 = CTRL(_grpbutidc);
			_ctrl2 ctrlEnable false;
		};
		__INC(_grptxtidc);
		__INC(_grplbidc);
		__INC(_grpbutidc);
		__INC(_grplockidc);
		__INC(_grplockbutidc);
	} forEach GVAR(SQMGMT_grps);
	
	if (_grptxtidc < 4049) then {
		_diff = 4049 - _grptxtidc;
		for "_i" from (49 - _diff) to 49 do {
			_ctrl = _disp displayCtrl (4000 + _i);
			_ctrl ctrlShow false;
			_ctrl = _disp displayCtrl (3000 + _i);
			_ctrl ctrlShow false;
			_ctrl = _disp displayCtrl (2000 + _i);
			_ctrl ctrlShow false;
			_ctrl = _disp displayCtrl (1000 + _i);
			_ctrl ctrlShow false;
		};
	};
	ctrlSetFocus CTRL(9999);
};

FUNC(squadmgmtlockbuttonclicked) = {
	private ["_grp", "_lockedgr", "_disp", "_ctrl", "_ctrl2"];
	_grp = group player;
	_lockedgr = GV(_grp,GVAR(locked));
	disableSerialization;
	_disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
	_ctrl = _disp displayCtrl _this;
	_ctrl2 = _disp displayCtrl (6000 + (_this - 7000));
	if (!isNil "_lockedgr" && {_lockedgr}) then {
		_grp setVariable [QGVAR(locked), false];
		_ctrl ctrlSetText "Lock";
		_ctrl2 ctrlShow false;
	} else {
		_grp setVariable [QGVAR(locked), true];
		_ctrl ctrlSetText "Unlock";
		_ctrl2 ctrlShow true;
	};
};

GVAR(sqtmgmtblocked) = false;

FUNC(squadmgmtbuttonclicked) = {
	
	if (GVAR(sqtmgmtblocked)) exitWith {};
	private ["_diff", "_grp", "_sidep", "_newgrp", "_count", "_oldgrp", "_disp", "_lbbox", "_lbidx", "_lbname"];
	if (typeName _this != typeName 1) exitWith {};
	_diff = _this - 5000;
	_grp = GVAR(SQMGMT_grps) select _diff;
	_oldgrp = group player;
	disableSerialization;
	// remove unit from group
	_disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
	_lbbox = 2000 + _diff;
	_lbidx = lbCurSel CTRL(_lbbox);
	_lbname = if (_lbidx != -1) then {
		CTRL(_lbbox) lbData _lbidx
	} else {
		""
	};
	_ogrlocked = GV(_oldgrp,GVAR(locked));
	if (isNil "_ogrlocked") then {_ogrlocked = false};
	if (_ogrlocked && {player == leader _oldgrp}) then {
		_oldgrp setVariable [QGVAR(locked), false];
	};
	if (group player == _grp && {_lbname != name player} && {_lbidx != -1} && {player == leader _grp}) exitWith {
		_unittouse = objNull;
		{
			if (name _x == _lbname) exitWith {
				_unittouse = _x;
			};
		} forEach (units _grp);
		if (isNull _unittouse) exitWith {};
		// must be AI version
		if (!isPlayer _unittouse) exitWith {
			if (vehicle _unittouse == _unittouse) then {
				deleteVehicle _unittouse;
			} else {
				moveOut _unittouse;
				_unittouse spawn {
					scriptName "spawn_d_fnc_squadmgmtbuttonclicked_vecwait";
					private "_grp";
					_grp = group _this;
					waitUntil {sleep 0.331;vehicle _this == _this};
					deleteVehicle _this;
				};
			};
			if (dialog) then {
				call FUNC(squadmanagementfill);
			};
		};
		_newgrpp = createGroup side (group player);
		[_unittouse] joinSilent _newgrpp;
		GVAR(sqtmgmtblocked) = true;
		[_grp, _unittouse] spawn {
			scriptName "spawn_d_fnc_squadmgmtbuttonclicked_sqmgmtfill";
			waitUntil {!((_this select 1) in (units (_this select 1)))};
			if (dialog) then {
				call FUNC(squadmanagementfill);
			};
			GVAR(sqtmgmtblocked) = false;
		};
	};
	
	// Leave = new group
	if (group player == _grp) then {
		_sidep = side (group player);
		_newgrp = createGroup _sidep;
		[player] joinSilent _newgrp;
		if (GVAR(with_ai)) then {
			_ai_only = true;
			{
				if (isPlayer _x) exitWith {
					_ai_only = false;
				};
			} forEach (units _grp);
			if (_ai_only) then {
				{
					deleteVehicle _x;
				} forEach (units _grp);
				if (count (units _grp) > 0) then {
					{
						moveOut _x;
						_x spawn {
							scriptName "spawn_d_fnc_squadmgmtbuttonclicked_waitvec2";
							private "_grp";
							_grp = group _this;
							waitUntil {sleep 0.331;vehicle _this == _this};
							deleteVehicle _this;
							deleteGroup _grp;
						};
					} forEach (units _grp)
				};
			};
		};
		if (count (units _grp) == 0) then {
			if (!isNull _grp) then {
				deleteGroup _grp;
			};
		} else {
			[QGVAR(grpswmsg), [leader _grp, name player]] call FUNC(NetCallEventSTO);
		};
		// transfer name of old group to new group ? (setgroup ID) ?
		// edit: not needed, players can't leave groups with just himself in the group
	} else {
		[QGVAR(grpjoin), [_grp, player]] call FUNC(NetCallEventSTO);
		_count = 0;
		{
			if (isPlayer _x) then {
				__INC(_count);
			};
		} forEach (units _grp);
		
		if (_count == 1) then {
			[QGVAR(grpslead), [leader _grp, _grp, player]] call FUNC(NetCallEventSTO);
		};
		
		if (GVAR(with_ai)) then {
			_ai_only = true;
			{
				if (isPlayer _x) exitWith {
					_ai_only = false;
				};
			} forEach (units _oldgrp);
			if (_ai_only) then {
				{
					deleteVehicle _x;
				} forEach (units _oldgrp);
				if (count (units _oldgrp) > 0) then {
					{
						moveOut _x;
						_x spawn {
							scriptName "spawn_d_fnc_squadmgmtbuttonclicked_waitvec3";
							private "_grp";
							_grp = group _this;
							waitUntil {sleep 0.331;vehicle _this == _this};
							deleteVehicle _this;
							deleteGroup _grp;
						};
					} forEach (units _oldgrp)
				};
			};
		};
		if (count (units _oldgrp) == 0&& {!isNull _oldgrp}) then {
			deleteGroup _oldgrp;
		};
		if (!isNull _oldgrp) then {
			[QGVAR(grpswmsg), [leader _oldgrp, name player]] call FUNC(NetCallEventSTO);
		};
		[QGVAR(grpswmsgn), [leader _grp, name player]] call FUNC(NetCallEventSTO);
	};
	GVAR(sqtmgmtblocked) = true;
	
	_oldgrp spawn {
		scriptName "spawn_d_fnc_squadmgmtbuttonclicked_oldgrp";
		waitUntil {!(player in (units _this)) || {isNull _this}};
		if (dialog) then {
			call FUNC(squadmanagementfill);
		};
		GVAR(sqtmgmtblocked) = false;
	};
	
};

// TODO: Invite for squadmgmt

FUNC(squadmgmtlbchanged) = {
	private ["_idc", "_car", "_idx", "_ctrl", "_diff", "_grp", "_disp", "_button", "_lbsel"];
	if (GVAR(sqtmgmtblocked)) exitWith {};
	PARAMS_2(_idc,_car);
	_idx = _car select 1;
	if (_idx == -1) exitWith {};
	_ctrl = _car select 0;
	_diff = _idc - 2000;

	_grp = GVAR(SQMGMT_grps) select _diff;
	disableSerialization;
	_disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
	_button = 3000 + _diff;
	
	if (group player == _grp && {player == leader _grp}) then {
		_lbsel = _ctrl lbText _idx;
		if (name player != _lbsel) then {
			CTRL(_button) ctrlSetText "Remove";
		} else {
			CTRL(_button) ctrlSetText "Leave";
		};
	};
};

FUNC(squadmgmtlblostfocus) = {
	private ["_butidc", "_carray", "_ctrl", "_sel", "_disp", "_buctrl"];
	PARAMS_2(_butidc,_carray);
	_ctrl = _carray select 0;
	_sel = lbCurSel _ctrl;
	if (_sel != -1) then {
		_ctrl lbSetCurSel -1;
	};
	disableSerialization;
	_disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
	_butidc = _butidc + 1000;
	_buctrl = CTRL(_butidc);
	if (ctrlText _buctrl == "Remove") then {
		_buctrl ctrlSetText "Leave";
	};
};

