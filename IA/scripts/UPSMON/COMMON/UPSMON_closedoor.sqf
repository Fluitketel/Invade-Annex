
private ["_bld"];
_bld = _this select 0;
sleep 35;

	for "_i" from 0 to 5 do 
	{
		// if (this animationPhase (format ["door_%1_rot",_i]) < 0.1) exitwith {}; 
		// _x animate ["door_" + str _i + "_rot",0]
		[_bld, "door_" + str _i + "_rot", "Door_Handle_" + str _i + "_rot_1", "Door_Handle_" + str _i + "_rot_2"] execVM "\A3\Structures_F\scripts\Door_close.sqf";
	};
