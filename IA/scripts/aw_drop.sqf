//--- bl1p edited a little created by AW

private ["_heli", "_reloadtime"];

		// lets set some local variables
	_heli = _this select 0;
    _chuteType = "B_Parachute_02_F";	//parachute for blufor, for opfor and greenfor replace the 'B' with 'O' or 'G' respectively
    _crateType =  "B_supplyCrate_F";	//ammocrate class for blufor, feel free to change to whichever box you desire
    _smokeType =  "SmokeShellPurple";  //smoke shell color you want to use
    _lightType =  "Chemlight_blue";  //chemlightcolor you want used
    _reloadtime = 1200;  // time before next ammo drop is available to use
    _minheight = 70;  // the height you have to be before you can actually drop the crate
    _HQ = [West,"HQ"];  // do not touch this!
    _toLow = format
    	[
    	"<t align='center'><t size='2.2' color='#ed3b00'>TO LOW</t><br/><t size='1.2' color='#9ef680'>You need to be above</t><br/><t size='1.5' color='#ed3b00'>%1 meters</t><br/><t size='1.2' color='#9ef680'>in order to drop an ammo crate.</t></t>",
    		_minheight
    	];  //text to display when not high enough to drop

	if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};

	// Wait until player is initialized
	if (!isDedicated) then
	{
		waitUntil {!isNull player && isPlayer player};
	};
	// meat and potatoes
	if ( !(isNil "AW_ammoDrop") ) exitWith {hint "Ammo drop is not currently available"};
	
	if ((getPos player) select 2 < _minheight) exitWith {hint parseText _toLow};
	
	if ((getPos player) select 2 > _minheight) then
		{
			AW_ammoDrop = false;
			publicVariable "AW_ammoDrop";

			_chute = createVehicle [_chuteType, [100, 100, 200], [], 0, 'FLY'];
			_chute setPos [getPosASL _heli select 0, getPosASL _heli select 1, (getPosASL _heli select 2) - 50];
			_crate = createVehicle [_crateType, position _chute, [], 0, 'NONE'];
			_crate attachTo [_chute, [0, 0, -1.3]];
			_crate allowdamage false;
			_light = createVehicle [_lightType, position _chute, [], 0, 'NONE'];
			_light attachTo [_chute, [0, 0, 0]];

			// clear crate - leaves medkits in place. add clearItemCargoGlobal _crate; to remove medkits
			clearWeaponCargoGlobal _crate;
			clearMagazineCargoGlobal _crate;

			// fill crate with our junk
			_crate addWeaponCargoGlobal ["arifle_MX_GL_F",5];
			_crate addItemCargoGlobal ["FirstAidKit", 50];
			_crate addMagazineCargoGlobal ["30Rnd_556x45_Stanag", 100];
			_crate addMagazineCargoGlobal ["200Rnd_65x39_cased_Box_Tracer", 20];
			_crate addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 150];
			_crate addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 8];
			_crate addMagazineCargoGlobal ["HandGrenade", 40];
			_crate addMagazineCargoGlobal ["SmokeShell", 40];
			_crate addMagazineCargoGlobal ["SmokeShellGreen", 40];
			_crate addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 40];
			_crate addMagazineCargoGlobal ["NLAW_F", 12];
			_crate addMagazineCargoGlobal ["Titan_AT", 12];
			_crate addMagazineCargoGlobal ["Titan_AA", 12];

			// lets people know stuff happened
			//_HQ sideChat "ammo crate has been dropped.";
			hint format ["ammo crate dropped, Next one will be ready in: %1 seconds",_reloadtime];
			waitUntil {position _crate select 2 < 1 || isNull _chute};
			detach _crate;
			_crate setPos [position _crate select 0, position _crate select 1, 0];
			_smoke = _smokeType createVehicle [getPos _crate select 0, getPos _crate select 1,5];

			// let ground forces know they can resupply
			//_HQ sideChat "Be advised: ammo crate has touched down!";
			sleep 3;
			//_HQ sideChat "I say again, ammo crate has touched down!";

			// time to reload a new ammo crate
			sleep _reloadtime;

			// we are back in action
			vehicle player vehicleChat "Ammo drop available...";
			AW_ammoDrop = nil;
			publicVariable "AW_ammoDrop";
		};
