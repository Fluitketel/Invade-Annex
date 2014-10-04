//Script by Sa-Matra edit by bl1p
//--- bl1p notes players can board as back passengers then take control of the vehicle as driver maybe pilot also
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the drivercheck.sqf I am not a true client";};

true spawn {
_layer = 85125; 
    //List of pilot classes, crewman classes, affected aircraft classes and affected vehicle classes
    _pilots = 
	[
	"B_Pilot_F"
	];
	
	_pilotsChopper = 
	[
	"B_Helipilot_F",
	"B_helicrew_F"
	];
	
    _crewmen = 
	[
	"B_soldier_repair_F",
	"B_crew_F",
	"B_officer_F",
	"DR_DPM_officer",
	"DR_URBAN_officer",
	"DR_DPM_soldier_repair",
	"DR_URBAN_soldier_repair"
	];
	
    _aircraft = 
	[
	"B_Heli_Light_01_F",
	"I_Heli_Transport_02_F",
	"O_Heli_Light_02_F",
	"O_Heli_Attack_02_black_F",
	"B_Heli_Light_01_armed_F",
	"O_Heli_Attack_02_F",
	"I_Plane_Fighter_03_AA_F",
	"I_Plane_Fighter_03_CAS_F"
	];
	
	_aircraftLVL1 = 
	[
	"B_Heli_Attack_01_F",
	"B_Plane_CAS_01_F"
	];
	
    _armor = 
	[
	"B_MBT_01_cannon_F",
	"B_MBT_01_TUSK_F",
	"B_APC_Tracked_01_rcws_F",
	"B_APC_Tracked_01_CRV_F",
	"B_APC_Tracked_01_AA_F",
	"B_APC_Wheeled_01_cannon_F",
	"O_APC_Tracked_02_AA_F",
	"O_MBT_02_cannon_F"
	];

    //Wait until player is fully loaded
    waitUntil {player == player};

    //Check if player is pilot, chopper pilot or crewman, you can add more classes into arrays	
	_iampilotChop = ({typeOf player == _x} count _pilotsChopper) > 0;
    _iampilot = ({typeOf player == _x} count _pilots) > 0;
    _iamcrewman = ({typeOf player == _x} count _crewmen) > 0;

    //Never ending cycle
    while{true} do 
	{
        //--- COPILOT KICK
        //If player is inside vehicle and not on foot
		waituntil {vehicle player != player};
        if(vehicle player != player) then 
		{
            _veh = vehicle player;
           
			//Pilot check on mohawk and armed little bird
			if (typeOf _veh == "I_Heli_Transport_02_F" || typeOf _veh == "B_Heli_Light_01_armed_F") then 
			{
             //_friend = player getVariable "friend";
			    _forbidden = [driver _veh];
                if (player in _forbidden && !(_iampilotChop)) then 
			   {
					systemChat format ["Sorry Pilots only",name player];
                    player action ["getOut", _veh];
					_veh engineon false;
					sleep 1;
			   };
			};
			
			//Mortar check
			if (typeOf _veh == "O_Mortar_01_F") then 
			{
                //_friend = player getVariable "friend";
			    _forbidden = [gunner _veh];
                if (player in _forbidden) then 
			   {
					_veh setVehicleAmmo 0;
					systemChat format ["Sorry %1 Mortar is Damaged",name player];
                    player action ["getOut", _veh];
					sleep 1;
			   };
            };
			
			
			//-- friend and pilot check on CHOPPER
			if (typeOf _veh == "B_Heli_Attack_01_F") then 
			{
               //_friend = player getVariable "friend";
			    _forbidden = [driver _veh] + [gunner _veh];
                if (player in _forbidden && !(_iampilotChop)) then 
			   {
					systemChat format ["Sorry %1 Only LvL 1 Chopper Pilots in the vehicle",name player];
                    player action ["getOut", _veh];
					_veh engineon false;
					sleep 1;
			   };
            };
			
			 
			
            //Check if vehicle is armor and player is not crewman
            if 
			(
				typeOf _veh == "B_MBT_01_cannon_F" || 
				typeOf _veh == "B_MBT_01_TUSK_F" || 
				typeOf _veh == "B_APC_Tracked_01_rcws_F" ||
				typeOf _veh == "B_APC_Tracked_01_CRV_F" ||
				typeOf _veh == "B_APC_Tracked_01_AA_F" ||
				typeOf _veh == "B_APC_Wheeled_01_cannon_F" ||
				typeOf _veh == "B_APC_Wheeled_01_cannon_F"
			) then 
			{
               // _friend = player getVariable "friend";
				_forbidden = [commander _veh] + [gunner _veh] + [driver _veh];
				//_forbidden = [commander _veh] + [gunner _veh] + [driver _veh] + [crew _veh];
                if (player in _forbidden && !(_iamcrewman)) then  
				{
                    systemChat format ["Sorry %1 Only LvL 1 Crew in the vehicle",name player];
                    player action ["getOut", _veh];
					_veh engineon false;
					sleep 1;
			    };
            };
			
			///tick tock for enemy vehicle
			if (typeOf _veh == "O_APC_Tracked_02_cannon_F" || typeOf _veh == "O_APC_Tracked_02_AA_F" || typeOf _veh == "O_MBT_02_cannon_F" || typeOf _veh == "O_APC_Wheeled_02_rcws_F" || typeOf _veh == "I_APC_Wheeled_03_cannon_F" || typeOf _veh == "I_APC_tracked_03_cannon_F" || typeOf _veh == "I_MBT_03_cannon_F") then 
			{
                // _friend = player getVariable "friend";
                _forbidden = [commander _veh] + [gunner _veh] + [driver _veh] + [crew _veh];
                if (player in _forbidden) then  
				{
					
					_ticktock = 10;
					while {_ticktock > 0} do
					{
						_veh lock true;
						_veh setFuel 0;
						_layer cuttext [format ["TICK... %1",_ticktock],"PLAIN"];
						playsound3d ["A3\Sounds_f\sfx\Beep_Target.wss",_veh, true, getpos _veh, 1, 1, 0];
						sleep 1;
						_ticktock = _ticktock -1;
						if (_ticktock < 3) then 
						{
							player action ["getOut", _veh];
							//_veh engineon false;
						};
					};
					sleep 1;
					_veh setdamage 1;
			    };
            };
        };
		sleep 1;
    };
};