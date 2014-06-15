//init.sqf:   [] execvm "crew.sqf";
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the crew.sqf I am not a true client";};
   
Private ["_name","_vehicle","_vehname","_weapname","_weap","_target","_picture","_vehtarget","_azimuth","_wepdir","_hudnames","_ui"];   
	   
disableSerialization;
  while {true} do  {

   	 1000 cutRsc ["HudNames","PLAIN"];
   	 _ui = uiNameSpace getVariable "HudNames";
 	 _HudNames = _ui displayCtrl 99999;

    
 
	   
    if(player != vehicle player) then
    {
        _name = "";
        _vehicle = assignedVehicle player;
        _vehname= getText (configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "DisplayName");
        _weapname = getarray (configFile >> "CfgVehicles" >> typeOf (vehicle player) >> "Turrets" >> "MainTurret" >> "weapons"); 
		//_weapnameCom = getarray (configFile >> "CfgVehicles" >> typeOf (vehicle player)>> "Turrets" >> "MainTurret" >> "Turrets" >> "CommanderOptics" >> "weapons");
        _weap = _weapname select 0;
		//_weapCom = _weapnameCom select 0;
		//diag_log format ["_weap = %1  and _weapCom = %2",_weap,_weapCom];
        _name = format ["<t size='1.25' color='#FFCC00' shadow='1'>%1</t><br/>", _vehname];


					
        {
           if((driver _vehicle == _x) || (gunner _vehicle == _x) || (commander _vehicle == _x)) then
            {  
				if(driver _vehicle == _x) then
					{
						//_name = format ["<t size='0.85' color='#FFFFFF' shadow='1'>%1 %2</t> <img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa'/><br/>", _name, (name _x)];
						_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t><br/>", _name, (name _x)];
					};
				if(commander _vehicle == _x) then
					{
						// --- blip note below doesnt work needs looking at along with the two lines commented out above
						
						//_wepdirCom =  (vehicle player) weaponDirection _weapCom;
						//_AzimuthCom = round  (((_wepdirCom select 0) ) atan2 ((_wepdirCom select 1) ) + 360) % 360;
						//_name = format ["<t size='0.85' color='#FFFFFF' shadow='1'>%1 %2</t> <img size='0.7' color='#CCFF66' shadow='1' //image='a3\ui_f\data\IGUI\Cfg\Actions\getincommander_ca.paa'/><br/> <t size='0.85' color='#FFFFFF'>Heading :<t/> <t size='0.85' color='#ff0000'>%3</t><br/>", //_name, (name _x), _AzimuthCom];//--- bl1p edit removed the target
						_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getincommander_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t><br/>", _name, (name _x)];
					};
				if(gunner _vehicle == _x) then
					{
						/*_wepdir =  (vehicle player) weaponDirection _weap;
						_Azimuth = round  (((_wepdir select 0) ) atan2 ((_wepdir select 1) ) + 360) % 360;
						_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t> <t size='0.80' color='#FFFFFF'>Heading:<t/> <t size='0.80' color='#ff0000'>%3</t><br/>", _name, (name _x), _Azimuth];*///--- bl1p edit removed the target
						_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t><br/>", _name, (name _x)];
					};
            }
            else
            {
				// Fluit: Check if unit is second gunner
				if (_vehicle turretUnit [2]	== _x) then {
					_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t><br/>", _name, (name _x)];
				} else {
					_name = format ["%1<img size='0.8' color='#CCFF66' shadow='1' image='a3\ui_f\data\IGUI\Cfg\Actions\getincargo_ca.paa'/> <t size='0.85' color='#FFFFFF' shadow='1'>%2</t><br/>", _name, (name _x)];
				};
            };  
              
        } forEach crew _vehicle;

      	_HudNames ctrlSetStructuredText parseText _name;
      	_HudNames ctrlCommit 0;
       	
       
    	};
    sleep 1;
  };  
  