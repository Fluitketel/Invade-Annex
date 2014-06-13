hmg_camp = {
	private ["_pos", "_newpos", "_dir", "_campgroup", "_campgun1group", "_campgun2group", "_prop", "_bagspos"];
	_pos = _this select 0; // Camp position
	_dir = _this select 1; // Camp direction
	
	_flatPos = _pos isFlatEmpty [13, 0, 0.2, 10, 0, false];
	if (count _flatPos == 0) exitWith {
		// Return false if the camp fails to create
		false;
	};
		
	_campgroup 		= createGroup east;
	_campgun1group 	= createGroup east;
	_campgun2group 	= createGroup east;
	_campgroup 		setFormDir _dir;
	_campgun1group 	setFormDir _dir;
	_campgun2group 	setFormDir _dir + 180;
	_campgroup 		call CampCleanup;
	_campgun1group 	call CampCleanup;
	_campgun2group 	call CampCleanup;
	
	_prop = "Land_BagBunker_Tower_F" createVehicle _pos;
	_prop call CampCleanup;
	_prop setDir _dir;
	
	_newpos = [_pos, 9, (_dir - 15)] call BIS_fnc_relPos;
	_prop = (["Flag_CSAT_F","Land_TTowerSmall_1_F","Land_TTowerSmall_2_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
	_prop call CampCleanup;
	
	_bagspos = [_pos, 6, (_dir + 90)] call BIS_fnc_relPos;
	_numberofbags = 5;
	_bagsdir = _dir;
	for "_c" from 1 to _numberofbags do
	{
		_temppos = [_bagspos, 6, _bagsdir] call BIS_fnc_relPos;
		_prop = "Land_BagFence_Long_F" createVehicle _temppos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _bagsdir;
		_bagsdir = _bagsdir + (200 / _numberofbags);
	};
	sleep 0.5;
	
	_gun1 = "O_HMG_01_high_F" createVehicle _bagspos;
	waitUntil {alive _gun1};
	_gun1 call CampCleanup;
	_gun1 setDir _dir;
	_newpos = [_bagspos, 1, (_dir + 180)] call BIS_fnc_relPos;
	_gunner1 = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	waitUntil {alive _gunner1};
	_gunner1 assignAsGunner _gun1;
	_gunner1 moveInGunner _gun1;
	_gunner1 setDir _dir;
	
	_newpos = [_bagspos, 5, _dir + 90] call BIS_fnc_relPos;
	_soldier = _campgun1group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	
	_bagspos = [_pos, 6, (_dir - 90)] call BIS_fnc_relPos;
	_numberofbags = 5;
	_bagsdir = _dir + 180;
	for "_c" from 1 to _numberofbags do
	{
		_temppos = [_bagspos, 6, _bagsdir] call BIS_fnc_relPos;
		_prop = "Land_BagFence_Long_F" createVehicle _temppos;
		waitUntil {alive _prop};
		_prop call CampCleanup;
		_prop setDir _bagsdir;
		_bagsdir = _bagsdir + (200 / _numberofbags);
	};
	sleep 1;
	
	_gun2 = "O_HMG_01_high_F" createVehicle _bagspos;
	waitUntil {alive _gun2};
	_gun2 call CampCleanup;
	_gun2 setDir _dir + 180;
	_newpos = [_bagspos, 1, (_dir + 180)] call BIS_fnc_relPos;
	_gunner2 = _campgun2group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	waitUntil {alive _gunner2};
	_gunner2 assignAsGunner _gun2;
	_gunner2 moveInGunner _gun2;
	_gunner2 setDir _dir + 180;
	
	_newpos = [_bagspos, 5, _dir - 90] call BIS_fnc_relPos;
	_soldier = _campgun2group createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	
	_soldier = _campgroup createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
	doStop _soldier;
	_newpos = _pos; _newpos set [2, 1];
	_soldier = _campgroup createUnit ["O_Soldier_F", _newpos, [], 0, "NONE"];
	doStop _soldier;
	true;
};