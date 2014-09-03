//--- increase rate of fuel used when engine on
// nul=[this,0.005] execvm "Fuel_Consumption.sqf"; 
// calc (1 / rate * sleep / 60 = minutes of fuel) Default rate of 0.01 = 16min

private ["_unit", "_rate", "_Mraps", "_Armoured", "_LightAir", "_AttackAir", "_TransTruck", "_SuportTruck", "_FuelTruck"];

//FuelDebug = true;
FuelDebug = false;

_unit = _this select 0;
_rate = _this select 1;

_Mraps = ["B_MRAP_01_F","B_MRAP_01_gmg_F","B_MRAP_01_hmg_F"];
_Armoured = ["B_MBT_01_TUSK_F","B_APC_Wheeled_01_cannon_F","B_APC_Tracked_01_rcws_F","B_APC_Tracked_01_CRV_F","B_APC_Tracked_01_AA_F","B_MBT_01_cannon_F","B_MBT_01_arty_F","B_MBT_01_mlrs_F"];
_LightAir = ["B_Heli_Light_01_F","B_Heli_Light_01_armed_F"];
_TransAir = ["B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","I_Heli_Transport_02_F"];
_AttackAir = ["B_Heli_Attack_01_F","B_Plane_CAS_01_F"];
_TransTruck = ["B_Truck_01_transport_F","B_Truck_01_covered_F","B_Truck_01_mover_F","B_Truck_01_box_F"];
_SuportTruck = ["B_Truck_01_ammo_F","B_Truck_01_medical_F","B_Truck_01_Repair_F"];
_FuelTruck = ["B_Truck_01_fuel_F"];


//--- Mraps
if (({typeOf _unit == _x} count _Mraps) > 0 ) then {_rate = _rate / 2;if (FuelDebug) then {systemchat format ["I am an Mrap %1",_rate];};};

//--- armoured
if (({typeOf _unit == _x} count _Armoured) > 0 ) then {_rate = _rate / 4;if (FuelDebug) then {systemchat format ["I am an Armoured %1",_rate];};};

//--- Light Aircraft
if (({typeOf _unit == _x} count _LightAir) > 0 ) then {_rate = _rate / 6;if (FuelDebug) then {systemchat format ["I am an Light Air %1",_rate];};};
	
//--- Large Transport AirCraft
if (({typeOf _unit == _x} count _TransAir) > 0 ) then {_rate = _rate / 8;if (FuelDebug) then {systemchat format ["I am an Trans Air %1",_rate];};};
	
//--- Attack AirCraft
if (({typeOf _unit == _x} count _AttackAir) > 0 ) then {_rate = _rate / 6.5;if (FuelDebug) then {systemchat format ["I am an Attack Air %1",_rate];};};

//--- Trans truck
if (({typeOf _unit == _x} count _TransTruck) > 0 ) then {_rate = _rate / 4;if (FuelDebug) then {systemchat format ["I am an Trans Truck %1",_rate];};};

//--- support trucks
if (({typeOf _unit == _x} count _SuportTruck) > 0 ) then {_rate = _rate / 4;if (FuelDebug) then {systemchat format ["I am an Suport Truck %1",_rate];};};
	
//--- fuel truck
if (({typeOf _unit == _x} count _FuelTruck) > 0 ) then {_rate = _rate / 6;if (FuelDebug) then {systemchat format ["I am an Fuel Truck %1",_rate];};};

//--- loop for fuel reduction
while {(alive _unit) and (fuel _unit > 0)} do 
{ 
	waituntil {isengineon _unit}; //--- stop loop until engine on
	if (isengineon _unit) then 
		{
			_unit setFuel ( Fuel _unit - _rate);
			if (FuelDebug) then {systemchat format ["Time = %1",(Fuel _unit) / _rate * 10 / 60];};
		};
		sleep 10;
		if (FuelDebug) then {systemchat "LOOP";};
};