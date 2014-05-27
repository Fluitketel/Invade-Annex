_unit = _this select 0;

if(isNull _unit) exitWith {};

//--- Mowhawk
if(_unit isKindOf "I_Heli_Transport_02_F") then 
	{
		[_unit] execVM "scripts\aw_sling\aw_sling_setupUnit.sqf";
	};
//--- Med truck
if(_unit isKindOf "B_Truck_01_medical_F") then 
	{
		_unit addAction ["<t color='#FFCF11'>Heal...</t>", "core\FAR_revive\FAR_handleAction.sqf",["full_revive"], 0, false, false, "", "vehicle _this == _this && _target distance _this < 10
		"];
	};
//--- Mohawk skin dR
if((_unit isKindOf "I_Heli_Transport_02_F")) then
	{
		_unit setObjectTexture [0,"core\Signs\heli_transport_02_1_ion_co_DR_small.paa"];
		_unit setObjectTexture [1,"#(argb,8,8,3)color(0,0,0,1)"];
		_unit setObjectTexture [2,"#(argb,8,8,3)color(0,0,0,1)"];
	}; 

//--- boats
if((_unit isKindOf "Ship") OR (_unit isKindOf "Wheeled_APC_F")) then {[_unit] execVM "scripts\aw_boatPush\aw_boatPush_setupUnit.sqf"};

//--- hunters
if (_unit isKindOf "B_MRAP_01_F") then 
	{
		clearitemcargo _unit; 
		clearWeaponCargoGlobal _unit; 
		clearMagazineCargoGlobal _unit;
		
		// fill crate with our junk
		_unit addWeaponCargoGlobal ["arifle_MX_GL_F",1];
		_unit addItemCargoGlobal ["FirstAidKit", 25];
		_unit addMagazineCargoGlobal ["30Rnd_556x45_Stanag", 100];
		_unit addMagazineCargoGlobal ["200Rnd_65x39_cased_Box_Tracer", 20];
		_unit addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 150];
		_unit addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
		_unit addMagazineCargoGlobal ["HandGrenade", 40];
		_unit addMagazineCargoGlobal ["SmokeShell", 40];
		_unit addMagazineCargoGlobal ["SmokeShellGreen", 40];
		_unit addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 40];
		_unit addMagazineCargoGlobal ["NLAW_F", 2];
		_unit addMagazineCargoGlobal ["Titan_AT", 2];
		_unit addMagazineCargoGlobal ["Titan_AA", 2];	
	};
//--- Trucks
if ((_unit isKindOf "B_Truck_01_covered_F") || (_unit isKindOf "B_Truck_01_transport_F") || (_unit isKindOf "B_Truck_01_ammo_F") || (_unit isKindOf "B_Truck_01_Repair_F")) then 
	{
		clearitemcargo _unit; 
		clearWeaponCargoGlobal _unit; 
		clearMagazineCargoGlobal _unit;
		
		// fill crate with our junk
		_unit addWeaponCargoGlobal ["arifle_MX_GL_F",5];
		_unit addItemCargoGlobal ["FirstAidKit", 50];
		_unit addMagazineCargoGlobal ["30Rnd_556x45_Stanag", 100];
		_unit addMagazineCargoGlobal ["200Rnd_65x39_cased_Box_Tracer", 20];
		_unit addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 150];
		_unit addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 8];
		_unit addMagazineCargoGlobal ["HandGrenade", 40];
		_unit addMagazineCargoGlobal ["SmokeShell", 40];
		_unit addMagazineCargoGlobal ["SmokeShellGreen", 40];
		_unit addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 80];
		_unit addMagazineCargoGlobal ["NLAW_F", 12];
		_unit addMagazineCargoGlobal ["Titan_AT", 12];
		_unit addMagazineCargoGlobal ["Titan_AA", 12];	
	};