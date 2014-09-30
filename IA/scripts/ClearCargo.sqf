if(isNull _this) exitWith {};

if (alive _this) then {
	//--- Trucks
	if ((typeOf _this == "DR_Truck_01_ammo_F") || (typeOf _this == "DR_Truck_02_ammo_F")) exitwith {};
	clearBackpackCargoGlobal _this;
	clearMagazineCargoGlobal _this;
	clearWeaponCargoGlobal _this;
	clearItemCargoGlobal _this;
};

