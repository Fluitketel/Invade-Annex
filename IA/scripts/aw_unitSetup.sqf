_unit = _this select 0;

if(isNull _unit) exitWith {};

//--- clear all cargo all vehicles
_unit execVM "scripts\ClearCargo.sqf";

//--- Mowhawk
if(typeOf _unit == "I_Heli_Transport_02_F") then 
	{
		[_unit] execVM "scripts\aw_sling\aw_sling_setupUnit.sqf";
	};
//--- Med truck
if(typeOf _unit == "B_Truck_01_medical_F") then 
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


//--- Trucks
if (typeOf _unit == "B_Truck_01_ammo_F") then 
	{
		      _unit addAction ["<t color='#40ff00'>Ammo Box</t>", "VAS\open.sqf",[], 0, false, false, "", "vehicle _this == _this && _target distance _this < 10"];
	};
	
//--- Ammo box taskforce radio
if (typeOf _unit == "B_supplyCrate_F") then 
	{
		_unit addItemCargoGlobal ["tf_rf7800str", 100];
		_unit addItemCargoGlobal ["tf_anprc152", 100];
		_unit addBackpackCargoGlobal ["tf_rt1523g",50];
	};