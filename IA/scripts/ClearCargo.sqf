if(isNull _this) exitWith {};

if (alive _this) then 
{
	//--- Trucks
	if (typeOf _this == "DR_Truck_02_ammo_F") then 
	{
		//diag_log "I AM A DR_Truck_02_ammo_F";
		while {alive _this} do
		{
			clearMagazineCargoGlobal _this;
			clearItemCargoGlobal _this;
			
			_this addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 250];
			_this addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag_Tracer", 250];
			_this addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag", 100];
			_this addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 100];
			_this addMagazineCargoGlobal ["200Rnd_65x39_cased_Box", 150];
			_this addMagazineCargoGlobal ["200Rnd_65x39_cased_Box_Tracer", 150];
			_this addMagazineCargoGlobal ["20Rnd_762x51_Mag", 100];
			_this addMagazineCargoGlobal ["30Rnd_45ACP_Mag_SMG_01", 50];
			_this addMagazineCargoGlobal ["30Rnd_45ACP_Mag_SMG_01_tracer_green", 50];
			_this addMagazineCargoGlobal ["30Rnd_9x21_Mag", 50];
			_this addMagazineCargoGlobal ["11Rnd_45ACP_Mag", 50];
			_this addMagazineCargoGlobal ["16Rnd_9x21_Mag", 50];
			_this addMagazineCargoGlobal ["HandGrenade", 50];
			_this addMagazineCargoGlobal ["MiniGrenade", 50];
			_this addMagazineCargoGlobal ["3Rnd_HE_Grenade_shell", 150];
			_this addMagazineCargoGlobal ["3Rnd_UGL_FlareWhite_F", 150];
			_this addMagazineCargoGlobal ["SmokeShell", 150];
			_this addMagazineCargoGlobal ["SmokeShellGreen", 50];
			_this addMagazineCargoGlobal ["SmokeShellRed", 50];
			_this addMagazineCargoGlobal ["SmokeShellBlue", 50];
			_this addMagazineCargoGlobal ["Titan_AA", 50];
			_this addMagazineCargoGlobal ["Titan_AT", 50];
			_this addMagazineCargoGlobal ["NLAW_F", 75];
			_this addMagazineCargoGlobal ["APERSBoundingMine_Range_Mag", 20];
			_this addMagazineCargoGlobal ["APERSMine_Range_Mag", 20];
			_this addMagazineCargoGlobal ["APERSTripMine_Wire_Mag", 20];
			_this addMagazineCargoGlobal ["ATMine_Range_Mag", 20];
			_this addMagazineCargoGlobal ["ClaymoreDirectionalMine_Remote_Mag", 20];
			_this addMagazineCargoGlobal ["SLAMDirectionalMine_Wire_Mag", 20];
			_this addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 20];
			_this addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 10];

			_this addItemCargoGlobal ["FirstAidKit",200];
			_this addItemCargoGlobal ["Medikit" ,5];
			sleep 21600;
		};
	};
	
	
	clearBackpackCargoGlobal _this;
	clearMagazineCargoGlobal _this;
	clearWeaponCargoGlobal _this;
	clearItemCargoGlobal _this;

};

