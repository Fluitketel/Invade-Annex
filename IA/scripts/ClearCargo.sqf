if(isNull _this) exitWith {};
if (alive _this) then {
	clearBackpackCargoGlobal _this;
	clearMagazineCargoGlobal _this;
	clearWeaponCargoGlobal _this;
	clearItemCargoGlobal _this;
};