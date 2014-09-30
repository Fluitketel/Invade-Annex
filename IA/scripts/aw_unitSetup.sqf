_unit = _this select 0;

if(isNull _unit) exitWith {};


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

//--- Trucks
if (typeOf _unit == "B_Truck_01_ammo_F") then 
	{
		//_unit addAction ["<t color='#40ff00'>Ammo Box</t>", "VAS\open.sqf",[], 0, false, false, "", "vehicle _this == _this && _target distance _this < 10"];
		_unit addAction ["<t color='#FF0000'>ADD ACRE SHORTRANGE</t>", "addacre\add_acre_lr.sqf",[], 0, false, true, "", "vehicle _this == _this && _target distance _this < 10"];  
		_unit addAction ["<t color='#FF0000'>ADD ACRE LONGRANGE</t>", "addacre\add_acre_sr.sqf",[], 0, false, true, "", "vehicle _this == _this && _target distance _this < 10"];
	};
