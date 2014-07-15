//Only display vehicles for that players side, if true Opfor can only spawn Opfor vehicles and so on.
VVS_SideOnly = true;

//Only set to true if you are making pre-made vehicle lists with VVS_x (i.e VVS_Car)
VVS_Premade_List = false;

//If you are going to use Pre-set VVS Vehicles it is recommended to set this to true as it will not run through the config saving CPU resources on initialization, otherwise leave as default.
VVS_Premade_List = false;

/*
	Pre-set VVS Vehicles
	This is similar to VAS's functionality, using these variables will only make those vehicles available.
	Leave them the way they are if you want to auto-fetch the entire vehicle config and list every vehicle.
	
	Example:
	VVS_Car = ["C_Offroad_01_F","C_Quadbike_01_F"];
	VVS_Air = ["B_Heli_Light_01_armed_F"];
*/

VVS_Car = [];
VVS_Air = [];
VVS_Ship = [];
VVS_Armored = [];
VVS_Submarine = [];
VVS_Autonomous = [];
VVS_Support = [];

/*
	Vehicle restriction
	Again, similar to VAS's functionality. If you want to restrict a specific vehicle you can do it or
	you can restrict an entire vehicle set by using its base class.
	
	Example:
	VVS_Car = ["Quadbike_01_base_F"]; //Completely removes all quadbikes for all sides
	VVS_Air = ["B_Heli_Light_01_armed_F"]; //Removes the Pawnee
*/

VVS_R_Car = ["B_G_Offroad_01_F","B_G_Offroad_01_armed_F","B_G_Van_01_transport_F"];
VVS_R_Air = ["B_Plane_CAS_01_F"];
VVS_R_Ship = [];
VVS_R_Armored = ["B_MBT_01_arty_F","B_MBT_01_mlrs_F"];
VVS_R_Submarine = [];
VVS_R_Autonomous = [];
VVS_R_Support = ["B_G_Van_01_fuel_F","B_APC_Tracked_01_CRV_F"];