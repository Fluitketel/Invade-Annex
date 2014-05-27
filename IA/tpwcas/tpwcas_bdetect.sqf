// -------------------------------------------------------------------------------------------
// bDetect | bullet detection framework
// -------------------------------------------------------------------------------------------
// Version: 4.1
// Date: 14/12/2012
// Author: Fabrizio_T, Ollem (MP code)
// Additional code: TPW
// File Name: bdetect.sqf
// License: GNU/GPL
// -------------------------------------------------------------------------------------------
// BEGINNING OF FRAMEWORK CODE
// -------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------
// Constants
// -------------------------------------------------------------------------------------------

bdetect_name 		= "bDetect | ArmA 3 Bullet Detection Framework";
bdetect_name_short 	= "bDetect_a3";
bdetect_version 	= "1.0";

// -------------------------------------------------------------------------------------------
// Global variables
// -------------------------------------------------------------------------------------------

// You should set these variables elsewhere, don't edit them here since they're default.
// See bottom of this file for framework initialization example.
if(isNil "bdetect_enable") then { bdetect_enable = true; }; 													// (Boolean, Default true) Toggle to Enable / Disable bdetect altogether.
if(isNil "bdetect_startup_hint") then { bdetect_startup_hint = true; }; 										// (Boolean, Default true) Toggle to Enable / Disable bDetect startup Hint.
if(isNil "bdetect_debug_enable") then { bdetect_debug_enable = false; }; 										// (Boolean, Default false) Toggle to Enable / Disable debug messages.
if(isNil "bdetect_debug_chat") then { bdetect_debug_chat = false; }; 											// (Boolean, Default false) Show debug messages also in globalChat.
if(isNil "bdetect_debug_levels") then { bdetect_debug_levels = [0,1,2,3,4,5,6,7,8,9]; }; 						// (Array, Default [0,1,2,3,4,5,6,7,8,9]) Filter debug messages by included levels.
if(isNil "bdetect_callback") then { bdetect_callback = "bdetect_fnc_callback"; }; 								// (String, Default "bdetect_fnc_callback") Name for your own callback function
if(isNil "bdetect_callback_mode") then { bdetect_callback_mode = "spawn"; }; 									// (String, Default "spawn") Allowed values: "call" or "spawn"
if(isNil "bdetect_fps_adaptation") then { bdetect_fps_adaptation = true; }; 									// (Boolean, Default true) Whether bDetect should try to keep over "bdetect_fps_min" FPS while degrading quality of detection
if(isNil "bdetect_fps_min") then { bdetect_fps_min = 20; }; 													// (Number, Default 15) The minimum FPS you wish to keep
if(isNil "bdetect_fps_calc_each_x_frames") then { bdetect_fps_calc_each_x_frames = 20; }; 						// (Number, Default 16) FPS check is done each "bdetect_fps_min" frames. 1 means each frame.
if(isNil "bdetect_eh_assign_cycle_wait") then { bdetect_eh_assign_cycle_wait = 10; }; 							// (Seconds, Default 10). Wait duration foreach cyclic execution of bdetect_fnc_eh_loop()
if(isNil "bdetect_bullet_min_delay") then { bdetect_bullet_min_delay = 0.1; }; 									// (Seconds, Default 0.1) Minimum time between 2 consecutive shots fired by an unit for the last bullet to be tracked. Very low values may cause lag.
if(isNil "bdetect_bullet_max_delay") then { bdetect_bullet_max_delay = 2; }; 									// (Seconds, Default 2)
if(isNil "bdetect_bullet_initial_min_speed") then { bdetect_bullet_initial_min_speed = 360 * 3.6; }; 			// (Meters/Second, Default 360 x 3.6 to convert to km/hr) Bullets slower than this are ignored.
if(isNil "bdetect_bullet_max_proximity") then { bdetect_bullet_max_proximity = 8; }; 							// (Meters, Default 10) Maximum proximity to unit for triggering detection
if(isNil "bdetect_bullet_min_distance") then { bdetect_bullet_min_distance = 20; }; 							// (Meters, Default 25) Bullets having travelled less than this distance are ignored
if(isNil "bdetect_bullet_max_distance") then { bdetect_bullet_max_distance = 1250; }; 							// (Meters, Default 500) Bullets havin travelled more than distance are ignored
if(isNil "bdetect_bullet_max_lifespan") then { bdetect_bullet_max_lifespan = 1.5; }; 							// (Seconds, Default 1.0) Bullets living more than these seconds are ignored
if(isNil "bdetect_projectile_max_lifespan") then { bdetect_projectile_max_lifespan = 5; };					// (Seconds, Default 4.5) Projectiles living more than these seconds are ignored
if(isNil "bdetect_bullet_max_height") then { bdetect_bullet_max_height = 8; }; 									// (Meters, Default 8)  Bullets going higher than this -and- diverging from ground are ignored
if(isNil "bdetect_bullet_skip_mags") then { bdetect_bullet_skip_mags = []; }; 									// (Array) Skip these bullet types altogether. Example: ["30rnd_9x19_MP5", "30rnd_9x19_MP5SD", "15Rnd_9x19_M9"]
//if(isNil "bdetect_mp_enable") then { bdetect_mp_enable = false; }; 												// (Boolean, Default true) Toggle to Enable / Disable MP experimental support
if(isNil "bdetect_mp_per_frame_emulation") then { bdetect_mp_per_frame_emulation = true; }; 					// (Boolean, Default false) Toggle to Enable / Disable experimental server per-frame-execution emulation
if(isNil "bdetect_mp_per_frame_emulation_frame_d") then { bdetect_mp_per_frame_emulation_frame_d = 0.015; };  	// (Seconds, Default 0.02) Experimental server per-frame-execution emulation timeout
if(isNil "bdetect_units_kindof") then { bdetect_units_kindof = ["CaManBase","StaticWeapon","Car_f","Tank_f","Air"]; }; 										// CfgVehicles classes being subject to suppression effects, example: ["CaManBase","StaticWeapon","Car_f","Tank_f","Air"]

// NEVER edit the variables below, please.
if(isNil "bdetect_fired_bullets") then { bdetect_fired_bullets = []; };
if(isNil "bdetect_fired_bullets_count") then { bdetect_fired_bullets_count = 0; };
if(isNil "bdetect_fired_bullets_count_blufor") then { bdetect_fired_bullets_count_blufor = 0; };
if(isNil "bdetect_fired_bullets_count_redfor") then { bdetect_fired_bullets_count_redfor = 0; };
if(isNil "bdetect_fired_bullets_count_tracked") then { bdetect_fired_bullets_count_tracked = 0; };
if(isNil "bdetect_fired_bullets_count_detected") then { bdetect_fired_bullets_count_detected = 0; };
if(isNil "bdetect_fired_bullets_count_blacklisted") then { bdetect_fired_bullets_count_blacklisted = 0; };
if(isNil "bdetect_fired_projectiles") then { bdetect_fired_projectiles = []; };
if(isNil "bdetect_fired_projectiles_count_tracked") then { bdetect_fired_projectiles_count_tracked = 0; };
if(isNil "bdetect_fired_projectiles_count_detected") then { bdetect_fired_projectiles_count_detected = 0; };
if(isNil "bdetect_fired_projectiles_count_blacklisted") then { bdetect_fired_projectiles_count_blacklisted = 0; };
if(isNil "bdetect_units_count") then { bdetect_units_count = 0; };
if(isNil "bdetect_units_count_killed") then { bdetect_units_count_killed = 0; };
if(isNil "bdetect_players_count_killed") then { bdetect_players_count_killed = 0; };
if(isNil "bdetect_fps") then { bdetect_fps = bdetect_fps_min; };
if(isNil "bdetect_bullet_delay") then { bdetect_bullet_delay = bdetect_bullet_min_delay; };
if(isNil "bdetect_frame_tstamp") then { bdetect_frame_tstamp = 0; };
if(isNil "bdetect_frame_min_duration") then { bdetect_frame_min_duration = 0.015; }; // 60fps

bdetect_projectile_array = [["GrenadeHand", 15, 4.5, 50],["GrenadeBase", 15, 4.5, 1000],["ShellBase", 40, 20, 7000],["RocketBase", 30, 10, 1000],["MissileBase", 20, 8, 2500],["BombCore", 40, 10, 1000]];

// -------------------------------------------------------------------------------------------
// Functions
// -------------------------------------------------------------------------------------------

bdetect_fnc_per_frame_emulation =
{
    private ["_fnc", "_msg"];

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_per_frame_emulation() has started"];
		[ _msg, 8 ] call bdetect_fnc_debug;
	};

    while { true } do {
        call bdetect_fnc_detect;
        sleep bdetect_mp_per_frame_emulation_frame_d;
    };
};

bdetect_fnc_init =
{
    private [ "_msg", "_nul" ];

	if( bdetect_debug_enable ) then {
		_msg = format["%1 v%2 is starting ...", bdetect_name_short, bdetect_version];
		[ _msg, 0 ] call bdetect_fnc_debug;
	};
	// bullet speed converted to kmh
	//bdetect_bullet_initial_min_speed = bdetect_bullet_initial_min_speed * 3.6;

	// Add per-frame execution of time-critical function
	if( isMultiPlayer && { bdetect_mp_per_frame_emulation }  ) then 
	{  // emulated, per-timeout (MP)
		_nul = [] spawn bdetect_fnc_per_frame_emulation;
	} else { // native per-frame (SP)
		//[bdetect_fnc_detect,0] call cba_fnc_addPerFrameHandler; => ARMA3 -> missing in CBA?
		_nul = [] spawn bdetect_fnc_per_frame_emulation;
	};

	// Assign event handlers to any units (even spawned ones)
	bdetect_spawned_loop_handler = [] spawn bdetect_fnc_eh_loop;

	if ( isNil "bdetect_init_done" ) then
	{
		bdetect_init_done = true;

		if ( bdetect_debug_enable ) then 
		{
			_msg = format["%1 v%2 has started", bdetect_name_short, bdetect_version];
			[ _msg, 0 ] call bdetect_fnc_debug;
		};

		if ( bdetect_startup_hint ) then 
		{
			_msg = format["%1 v%2 has started", bdetect_name_short, bdetect_version];
			hintSilent _msg;
		};
	};
};

// Keep searching units for newly spawned ones and assign fired EH to them
bdetect_fnc_eh_loop =
{
	private [ "_x", "_msg"];
	
	// iteratively add EH to all units spawned at runtime
	if ( tpwcas_mode == 3 ) then // (dedicated) server no clients - check only player detection
	{	
		if( bdetect_debug_enable ) then {
			_msg = format["'bdetect_fnc_eh_loop' starting EventHandler loop for playableUnits ..."];
			[ _msg, 0 ] call bdetect_fnc_debug;
		};

		while { true } do // iteratively add EH to all units spawned at runtime
		{
			{ [_x] call bdetect_fnc_eh_add; } count playableUnits;	// Loop players only

			sleep bdetect_eh_assign_cycle_wait;
		};
	}
	else
	{		
		if( bdetect_debug_enable ) then {
			_msg = format["'bdetect_fnc_eh_loop' starting EventHandler loop for allUnits ..."];
			[ _msg, 0 ] call bdetect_fnc_debug;
		};

		while { true } do // iteratively add EH to all units spawned at runtime
		{
			{ [_x] call bdetect_fnc_eh_add; } count allUnits;	// Loop onto all units

			sleep bdetect_eh_assign_cycle_wait;
		};
	};
};

bdetect_fnc_eh_add =
{
    private ["_unit", "_reset", "_vehicle", "_e", "_msg"];

    _unit = _this select 0;

	// Add Killed EH
	if ( isNil { _unit getVariable "bdetect_killed_eh" } ) then
	{
		if ( isServer && { isMultiPlayer } && { (isPlayer _unit) } ) then 
		{
			_e = _unit addMPEventHandler ["mpkilled", bdetect_fnc_killed];
			_unit setVariable ["bdetect_killed_eh", _e, true];
		}
		else 
		{
			_e = _unit addEventHandler ["Killed", bdetect_fnc_killed];
			_unit setVariable ["bdetect_killed_eh", _e];
		};

		bdetect_units_count = bdetect_units_count + 1;

		if ( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_eh_add() - unit=%1, KILLED EH assigned", _unit];
			[ _msg, 3 ] call bdetect_fnc_debug;
		};
	};

	// Add Fired EH
	if ( isNil { _unit getVariable "bdetect_fired_eh" } ) then
	{
		_e = _unit addEventHandler ["Fired", bdetect_fnc_fired];
		_unit setVariable ["bdetect_fired_eh", _e];

		if ( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_eh_add() - unit=%1, FIRED EH assigned", _unit];
			[ _msg, 3 ] call bdetect_fnc_debug;
		};
	};

    // handling vehicles
	_vehicle = assignedVehicle _unit;

	if ( !(isNull _vehicle) ) then
	{
		// Reset EH after player respawn
		if ( (tpwcas_mode == 2)
			&& { !(isNil {_vehicle getVariable "bdetect_fired_eh" }) }
			&& { !((_vehicle getVariable ["bdetect_fired_eh_owner", 0]) == (owner _vehicle)) }
			) then
		{
			if ( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_eh_add() - vehicle=[%1], EH owner changed - reassign FIRED + KILLED EH - new owner: [%2]", _vehicle, (owner _vehicle)];
				[ _msg, 3 ] call bdetect_fnc_debug;
			};

			_e = _vehicle getVariable "bdetect_fired_eh";
			_vehicle removeEventHandler ["fired", _e];
			_vehicle setVariable ["bdetect_fired_eh", nil];

			if ( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_eh_add() - vehicle=%1, FIRED EH unassigned", _vehicle];
				[ _msg, 3 ] call bdetect_fnc_debug;
			};
		};

		// Add vehicle Fired EH
		if ( isNil { _vehicle getVariable "bdetect_fired_eh" } ) then
		{
			_e = _vehicle addEventHandler ["Fired", bdetect_fnc_fired];
			_vehicle setVariable ["bdetect_fired_eh", _e];

			if ( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_eh_add() - vehicle=%1, FIRED EH assigned", _vehicle];
				[ _msg, 3 ] call bdetect_fnc_debug;
			};

			if ( tpwcas_mode == 2 ) then {
				_vehicle setVariable ["bdetect_fired_eh_owner", owner _vehicle];
			};
		};

		// Add vehicle Killed EH
		if ( isNil { _vehicle getVariable "bdetect_killed_eh" } ) then
		{
			if ( isServer && { isMultiPlayer } ) then {
				_e = _vehicle addMPEventHandler ["mpkilled", bdetect_fnc_killed];
				_vehicle setVariable ["bdetect_killed_eh", _e, true];
			} else {
				_e = _vehicle addEventHandler ["Killed", bdetect_fnc_killed];
				_vehicle setVariable ["bdetect_killed_eh", _e];
			};

			if ( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_eh_add() - vehicle=%1, KILLED EH assigned", _vehicle];
				[ _msg, 3 ] call bdetect_fnc_debug;
			};
		};
    };
};

// Killed EH payload
bdetect_fnc_killed =
{
	private ["_unit", "_killer", "_e", "_msg"];

	_unit = _this select 0;
	_killer = _this select 1;

	// Reset Fired EH after respawn
	if ( !(isNil {_unit getVariable "bdetect_fired_eh"} ) )  then
	{
		_e = _unit getVariable "bdetect_fired_eh";
		_unit removeEventHandler ["fired", _e];
		_unit setVariable ["bdetect_fired_eh", nil];

		if ( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_killed() -  KILLED EH - unit [%1] killed by [%2] - FIRED EH unassigned", _unit, _killer];
			[ _msg, 3 ] call bdetect_fnc_debug;
		};

		bdetect_units_count_killed = bdetect_units_count_killed + 1;
		if ( isPlayer _unit ) then {
			bdetect_players_count_killed = bdetect_players_count_killed + 1;
		};
	};
};

// Fired EH payload
bdetect_fnc_fired =
{
 	private ["_unit", "_weapon", "_muzzle", "_magazine", "_bullet", "_speed", "_msg", "_time", "_dt", "_result"];

	if( bdetect_enable ) then
	{
		_unit = _this select 0;
		_weapon = _this select 1;
		_muzzle = _this select 2;
		_mode = _this select 3;
		_ammo = _this select 4;
		_magazine = _this select 5;
		_bullet = _this select 6;
		_speed = speed _bullet;
		_time = time; //diag_tickTime
		_dt = _time - ( _unit getVariable ["bdetect_fired_time", 0] );

		bdetect_fired_bullets_count = bdetect_fired_bullets_count + 1;

		if ( ( ( side _unit ) getFriend WEST ) < 0.6 ) then
		{
			bdetect_fired_bullets_count_redfor = bdetect_fired_bullets_count_redfor + 1;
		}
		else 
		{
			bdetect_fired_bullets_count_blufor = bdetect_fired_bullets_count_blufor + 1;			
		};

		if (   (_dt > bdetect_bullet_delay)
			&& { !( _magazine in bdetect_bullet_skip_mags) }
			&& { (_speed > bdetect_bullet_initial_min_speed) }
			) then
		{

			_unit setVariable ["bdetect_fired_time", _time];

			// Append info to bullets array
			[ _bullet, _unit, _time ] call bdetect_fnc_bullet_add;

			bdetect_fired_bullets_count_tracked = bdetect_fired_bullets_count_tracked + 1;

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_fired() - Tracking: bullet=%1, shooter=%2, speed=%3, type=%4, _dt=%5", _bullet, _unit, _speed, typeOf _bullet, _dt ];
				[ _msg, 2 ] call bdetect_fnc_debug;
			};
		}
		else
		{
			_result = [_bullet] call bdetect_fnc_find_other_ammo;

			if ( _result select 0 ) then
			{
				_unit setVariable ["bdetect_fired_time", _time];

				// Append info to bullets array
				[ _bullet, _unit, _time ] call bdetect_fnc_projectile_add;

				bdetect_fired_projectiles_count_tracked = bdetect_fired_projectiles_count_tracked + 1;

				if( bdetect_debug_enable ) then {
					_msg = format["bdetect_fnc_fired() - Tracking: projectile=%1, shooter=%2, speed=%3, type=%4, _dt=%5, class=%6", _bullet, _unit, _speed, typeOf _bullet, _dt, _result select 1 ];
					[ _msg, 2 ] call bdetect_fnc_debug;
				};
			}
			else
			{
				if ( (bdetect_debug_enable) && { (_dt > bdetect_bullet_delay) } ) then {
					_msg = format["bdetect_fnc_fired() - Skipping: projectile=%1, shooter=%2, speed=%3 [min:%8], type=%4, _dt=%5 [min:%6 max:%7]", _bullet, _unit, _speed, typeOf _bullet, _dt, bdetect_bullet_min_delay, bdetect_bullet_max_delay, bdetect_bullet_initial_min_speed];
					[ _msg, 2 ] call bdetect_fnc_debug;
				};
			};
		};
	};
};

// check other for other ammo like grenades, rockets, shells
bdetect_fnc_find_other_ammo =
{
    private ["_projectile","_result", "_nr"];

    _projectile = _this select 0;
	_nr = -1;
    _result = [false, "", -1];

	//diag_log format ["bdetect_fnc_find_other_ammo: [%1] - [%2]", _projectile, typeOf _projectile];

    {
		_nr = _nr + 1;
        if (_projectile isKindOf _x) exitWith {_result = [true, _x, _nr]};
	} count ["GrenadeHand", "GrenadeBase", "RocketBase", "MissileBase"];
    //} forEach ["GrenadeHandTimedWest", "GrenadeBase", "RocketBase", "ShellBase", "MissileBase", "BombCore"];
    _result
};

// Time-critical detection function, to be executed per-frame
bdetect_fnc_detect =
{
	private ["_tot", "_msg"];

	if( bdetect_enable ) then
	{
		private ["_t", "_dt"];

		_t = time; //diag_tickTime
		_dt = _t - bdetect_frame_tstamp;

		if( _dt >= bdetect_frame_min_duration ) then
		{
			bdetect_frame_tstamp = _t;

			if( bdetect_debug_enable && { (diag_frameno % 32 == 0) } ) then {
				_msg = format["bdetect_fnc_detect() - Frame: duration=%1 (min=%2), FPS=%3", _dt , bdetect_frame_min_duration, diag_fps ];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};

			if( bdetect_fps_adaptation && { (diag_frameno % bdetect_fps_calc_each_x_frames == 0) } ) then {
				call bdetect_fnc_diag_min_fps;
			};

			_tot = count bdetect_fired_bullets;

			if ( _tot > 0 ) then
			{
				[ _tot, _t ] call bdetect_fnc_detect_bullet_sub;
			};

			_tot = count bdetect_fired_projectiles;

			if ( _tot > 0 ) then
			{
				[ _tot, _t ] call bdetect_fnc_detect_projectile_sub;
			};
		};

		bdetect_fired_bullets = bdetect_fired_bullets - [-1];
		bdetect_fired_projectiles = bdetect_fired_projectiles - [-1];
	};
};

// Subroutine executed within bdetect_fnc_detect()
bdetect_fnc_detect_bullet_sub =
{
	private ["_tot", "_t", "_n", "_bullet", "_data", "_shooter", "_pos", "_time", "_blacklist", "_update_blacklist", "_bpos", "_dist", "_units", "_x", "_data", "_nul"];

	_tot = _this select 0;
	_t = _this select 1;

	for "_n" from 0 to _tot - 1 step 2 do
	{
		_bullet = bdetect_fired_bullets select _n;
		_data = bdetect_fired_bullets select (_n + 1);
		_shooter = _data select 0;
		_pos = _data select 1;
		_time = _data select 2;
		_blacklist = _data select 3;
		_update_blacklist = false;

		if( !( isNull _bullet ) ) then
		{
			_bpos = getPosATL _bullet;
			_dist = _bpos distance _pos;

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_detect_bullet_sub() - Flying: bullet=%1, lifespan=%2, distance=%3, speed=%4, position=%5", _bullet, _t - _time, round _dist, round (speed _bullet / 3.6), _bpos];
				[ _msg, 4 ] call bdetect_fnc_debug;
			};
		}
		else
		{
			_dist = 0;
			_bpos = [0,0,0];
		};

		if( isNull _bullet
		|| { !(alive _bullet) }
		|| { _t - _time > bdetect_bullet_max_lifespan }
		|| { _dist > bdetect_bullet_max_distance }
		|| { speed _bullet < bdetect_bullet_initial_min_speed } // funny rebounds handling
		|| { ( ( _bpos select 2) > bdetect_bullet_max_height && { (( vectorDir _bullet ) select 2) > 0.2 } ) }
		) then {
			[ _bullet ] call bdetect_fnc_bullet_tag_remove;
		}
		else
		{
			if( _dist > bdetect_bullet_min_distance	) then
			{
				_units = _bpos nearEntities [ bdetect_units_kindof, bdetect_bullet_max_proximity];

				{
					if( _x != _shooter ) then
					{
						if( !(_x in _blacklist) && { (local _x) } && { (vehicle _x == _x) }  && { ((lifeState _x == "HEALTHY") || (lifeState _x == "INJURED")) } ) then
						{
							_blacklist set [ count _blacklist, _x];
							_update_blacklist = true;

							bdetect_fired_bullets_count_detected = bdetect_fired_bullets_count_detected + 1;

							// compile callback name into function
							bdetect_callback_compiled = call compile format["%1", bdetect_callback];

							/* MP - BEGIN */
							if( bdetect_callback_mode == "spawn" ) then {
									_nul = [ _x, _shooter, _bullet, _bpos, _pos, _time, 0 ] spawn bdetect_callback_compiled;
							} else {
									[ _x, _shooter, _bullet, _bpos, _pos, _time, 0 ] call bdetect_callback_compiled;
							};
							/* MP - END */

							if( bdetect_debug_enable ) then {
								_msg = format["bdetect_fnc_detect_bullet_sub() - *** CLOSE BULLET ***: unit=%1, shooter=%2, bullet=%3, proximity=%4, data=%5", _x, _shooter, _bullet, round (_x distance _bpos), _data];
								[ _msg, 9 ] call bdetect_fnc_debug;
							};
						}
						else
						{
							bdetect_fired_bullets_count_blacklisted = bdetect_fired_bullets_count_blacklisted + 1;

							if( bdetect_debug_enable ) then {
								_msg = format["bdetect_fnc_detect_bullet_sub() - blacklisted: unit=%1, shooter=%2, bullet=%3 - [%4] [%5] [%6] [%7]", _x, _shooter, _bullet, !(_x in _blacklist), (local _x), (vehicle _x == _x),lifeState _x];
								[ _msg, 5 ] call bdetect_fnc_debug;
							};
						};
					};

				} count _units;

				if(_update_blacklist) then {
					bdetect_fired_bullets set[ _n + 1, [_shooter, _pos, _time, _blacklist] ]; // Update blacklist
				};
			};
		};
	};
};

// Subroutine executed within bdetect_fnc_detect()
bdetect_fnc_detect_projectile_sub =
{
	private ["_tot", "_t", "_n", "_nr", "_projectile", "_projectile_type", "_data", "_shooter", "_pos", "_time", "_blacklist", "_update_blacklist", "_bpos", "_dist", "_units", "_x", "_data", "_nul", "_projectile_max_proximity", "_projectile_max_lifespan", "_projectile_max_distance"];

	_tot = _this select 0;
	_t = _this select 1;

	for "_n" from 0 to _tot - 1 step 2 do
	{
		_projectile = bdetect_fired_projectiles select _n;
		_data = bdetect_fired_projectiles select (_n + 1);
		_shooter = _data select 0;
		_pos = _data select 1;
		_time = _data select 2;
		_blacklist = _data select 3;
		_update_blacklist = false;

		_projectile_max_lifespan = 0;
		_projectile_max_distance = 0;

		if( !( isNull _projectile ) ) then
		{
			_bpos = getPosATL _projectile;
			_dist = _bpos distance _pos;

			_nr = [_projectile] call bdetect_fnc_find_other_ammo;
			_projectile_array = bdetect_projectile_array select (_nr select 2);

			_projectile_type = _projectile_array select 0;
			_projectile_max_proximity = _projectile_array select 1;
			_projectile_max_lifespan = _projectile_array select 2;
			_projectile_max_distance = _projectile_array select 3;

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_detect_projectile_sub() - Flying: bullet=%1, lifespan=%2, distance=%3, speed=%4, position=%5", _projectile, _t - _time, round _dist, round (speed _projectile / 3.6), _bpos];
				[ _msg, 4 ] call bdetect_fnc_debug;
			};
		}
		else
		{
			_dist = 0;
			_bpos = [0,0,0];
			_projectile_max_lifespan = 0;
			_projectile_max_distance = 1;
		};

		if( isNull _projectile
			|| { !(alive _projectile) }
			|| { _t - _time > _projectile_max_lifespan }
			|| { _dist > _projectile_max_distance }
		) then 
		{
			[ _projectile ] call bdetect_fnc_projectile_tag_remove;
		}
		else
		{
			//if( _dist > bdetect_bullet_min_distance ) then
			//{

				_units = _bpos nearEntities [ ["CaManBase"] , _projectile_max_proximity];

				{
					if( _x != _shooter ) then {

						if( !(_x in _blacklist)  ) then {

							if( (local _x) && { (vehicle _x == _x) } && { ((lifeState _x == "HEALTHY") || (lifeState _x == "INJURED")) } ) then 
							{
								_blacklist set [ count _blacklist, _x];
								_update_blacklist = true;

								bdetect_fired_projectiles_count_detected = bdetect_fired_projectiles_count_detected + 1;

								// compile callback name into function
								bdetect_callback_compiled = call compile format["%1", bdetect_callback];

								/* MP - BEGIN */
								if( bdetect_callback_mode == "spawn" ) then {
										_nul = [ _x, _shooter, _projectile, _bpos, _pos, _time, 1 ] spawn bdetect_callback_compiled;
								} else {
										[ _x, _shooter, _projectile, _bpos, _pos, _time, 1 ] call bdetect_callback_compiled;
								};
								/* MP - END */

								if( bdetect_debug_enable ) then {
									_msg = format["bdetect_fnc_detect_projectile_sub() - *** CLOSE BULLET ***: unit=%1, bullet=%2, shooter=%3, proximity=%4, data=%5", _x, _projectile, _shooter, round (_x distance _bpos), _data];
									[ _msg, 9 ] call bdetect_fnc_debug;
								};
							};
						}
						else
						{
							bdetect_fired_projectiles_count_blacklisted = bdetect_fired_projectiles_count_blacklisted + 1;

							if( bdetect_debug_enable ) then {
								_msg = format["bdetect_fnc_detect_projectile_sub() - blacklisted: unit=%1, shooter=%2, bullet=%3", _x, _shooter, _projectile];
								[ _msg, 5 ] call bdetect_fnc_debug;
							};
						};
					};

				} count _units;

				if(_update_blacklist) then {
					bdetect_fired_projectiles set[ _n + 1, [_shooter, _pos, _time, _blacklist] ]; // Update blacklist
				};
		};
	};
};

// Adapt frequency of some bullet checking depending on minimum FPS
bdetect_fnc_diag_min_fps =
{
	private ["_fps", "_msg"];

	_fps = diag_fps;

	if( _fps < bdetect_fps_min * 1.1) then
	{
		if( bdetect_bullet_delay  < bdetect_bullet_max_delay ) then {

			bdetect_bullet_delay = ( ( bdetect_bullet_delay + 0.2) min bdetect_bullet_max_delay );

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_diag_min_fps() - FPS = %1, bdetect_bullet_delay = %2", _fps, bdetect_bullet_delay];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};
		};
	}
	else
	{
		if( bdetect_bullet_delay > bdetect_bullet_min_delay ) then {

			bdetect_bullet_delay = (bdetect_bullet_delay - 0.1) max bdetect_bullet_min_delay;

			if( bdetect_debug_enable ) then {
				_msg = format["bdetect_fnc_diag_min_fps() - FPS = %1, bdetect_bullet_delay = %2", _fps, bdetect_bullet_delay];
				[ _msg, 1 ] call bdetect_fnc_debug;
			};
		};
	};

	bdetect_fps = _fps;
};

// Add a bullet to bdetect_fired_bullets
bdetect_fnc_bullet_add =
{
	private ["_bullet", "_shooter", "_pos", "_time",  "_msg", "_n"];

	_bullet = _this select 0; 	// bullet object
	_shooter = _this select 1;	// shooter
	_pos = getPosATL _shooter;	// bullet start position
	_time = _this select 2;		// bullet shoot time

	_n = count bdetect_fired_bullets;
	bdetect_fired_bullets set [ _n,  _bullet  ];
	bdetect_fired_bullets set [ _n + 1, [ _shooter, _pos, _time, [] ] ];

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_bullet_add() - Bullet=%1, shooter=%2, bullets(%3)= %4", _bullet, _shooter, _n / 2, bdetect_fired_bullets];
		[ _msg, 1] call bdetect_fnc_debug;
	};
};

// Add a projectile to bdetect_fired_projectiles
bdetect_fnc_projectile_add =
{
	private ["_projectile", "_shooter", "_pos", "_time",  "_msg", "_n"];

	_projectile = _this select 0; 	// projectile object
	_shooter = _this select 1;	// shooter
	_pos = getPosATL _shooter;	// projectile start position
	_time = _this select 2;		// projectile shoot time

	_n = count bdetect_fired_projectiles;
	bdetect_fired_projectiles set [ _n,  _projectile  ];
	bdetect_fired_projectiles set [ _n + 1, [ _shooter, _pos, _time, [] ] ];

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_protectile_add() - Protectile=%1, shooter=%2, protectiles(%3)= %4", _projectile, _shooter, _n / 2, bdetect_fired_projectiles];
		[ _msg, 1] call bdetect_fnc_debug;
	};
};

// Tag a bullet to be removed from bdetect_fired_bullets
bdetect_fnc_bullet_tag_remove =
{
	private ["_bullet", "_n", "_msg" ];

	_bullet = _this select 0;
	_n = bdetect_fired_bullets find _bullet;

	if( _n != -1 ) then
	{
		bdetect_fired_bullets set[ _n, -1 ];
		bdetect_fired_bullets set[ _n + 1, -1 ];

		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_bullet_tag_remove() - tagging null/expired bullet to be removed"];
			[ _msg, 4 ] call bdetect_fnc_debug;
		};
	};
};

// Tag a projectile to be removed from bdetect_fired_projectiles
bdetect_fnc_projectile_tag_remove =
{
	private ["_projectile", "_n", "_msg" ];

	_projectile = _this select 0;
	_n = bdetect_fired_projectiles find _projectile;

	if( _n != -1 ) then
	{
		bdetect_fired_projectiles set[ _n, -1 ];
		bdetect_fired_projectiles set[ _n + 1, -1 ];

		if( bdetect_debug_enable ) then {
			_msg = format["bdetect_fnc_projectile_tag_remove() - tagging null/expired projectile to be removed"];
			[ _msg, 4 ] call bdetect_fnc_debug;
		};
	};
};

// Prototype for callback function to be executed within bdetect_fnc_detect
bdetect_fnc_callback =
{
	private [ "_unit", "_shooter", "_bullet", "_bpos", "_pos", "_time", "_proximity", "_msg" ];

	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	_bullet = _this select 2;	// bullet object
	_bpos = _this select 3;	// bullet position
	_pos = _data select 4;	// starting position of bullet
	_time = _data select 5; // starting time of bullet
	_proximity = _bpos distance _unit;	// distance between _bullet and _unit

	if( bdetect_debug_enable ) then {
		_msg = format["bdetect_fnc_callback() - unit=%1, bullet=%2, shooter=%3, proximity=%4, data=%5", _unit, _bullet, _shooter, _proximity, _data];
		[ _msg, 9 ] call bdetect_fnc_debug;
	};
};

// function to display and log stuff (into .rpt file) level zero is intended only for builtin messages
bdetect_fnc_debug =
{
	private [ "_msg", "_level"];

	/*
	DEBUG LEVELS:
	From 0-9 are reserved.

	0 = Startup / unclassified messages
	1 = Frames / FPS related messages
	2 = "bdetect_fired_bullets" related messages
	3 = EH related messages
	...
	5 = Unit blacklist messages
	...
	8 = MP related messages
	9 = Unit detection related messages
	*/

	_level = _this select 1;

	if( bdetect_debug_enable && ( _level in bdetect_debug_levels ) ) then
	{
		_msg = _this select 0;
		diag_log format["%1 [%2 v%3] Frame:%4 L%5: %6", time, bdetect_name_short, bdetect_version, diag_frameno, _level, _msg ];

		if( bdetect_debug_chat ) then {
			player globalChat format["%1 - %2", time, _msg ];
		};
	};
};

tpwcas_fnc_benchmark =
{
	private ["_cnt"];

	if(isNil "bdetect_stats_max_bullets") then { bdetect_stats_max_bullets = 0; };
	if(isNil "bdetect_stats_min_fps") then { bdetect_stats_min_fps = 999; };
	if(isNil "bdetect_fired_bullets") then { bdetect_fired_bullets = []; };

	_nul = [] spawn
	{
		tpwcas_benchmark = true;
		
		while { tpwcas_benchmark } do
		{
			_cnt = count ( bdetect_fired_bullets ) / 2;
			if( _cnt > bdetect_stats_max_bullets ) then { bdetect_stats_max_bullets = _cnt; };

			if( diag_fps < bdetect_stats_min_fps ) then { bdetect_stats_min_fps = diag_fps };
			hintSilent format["TIME: %1\nFPS: %2 (min: %3)\nBULLETS: %4 (max: %5)\nS.DELAY: %6 (Min FPS: %7)\nFIRED: %8 (BLUE:%9 RED:%10)\nTRACKED: %11\nDETECTED: %12\nBLACKLISTED: %13\nUNITS: %14\nKILLED: %15",
			time,
			diag_fps,
			bdetect_stats_min_fps,
			_cnt,
			bdetect_stats_max_bullets,
			bdetect_bullet_delay,
			bdetect_fps_min,
			bdetect_fired_bullets_count,
			bdetect_fired_bullets_count_blufor,
			bdetect_fired_bullets_count_redfor,
			bdetect_fired_bullets_count_tracked + bdetect_fired_projectiles_count_tracked,
			bdetect_fired_bullets_count_detected + bdetect_fired_projectiles_count_detected,
			bdetect_fired_bullets_count_blacklisted + bdetect_fired_projectiles_count_blacklisted,
			bdetect_units_count,
			bdetect_units_count_killed];

			sleep 1;
		};
	};
};

tpwcas_fnc_log_benchmark =
{
	private ["_cnt"];

	if(isNil "bdetect_stats_max_bullets") then { bdetect_stats_max_bullets = 0; };
	if(isNil "bdetect_stats_min_fps") then { bdetect_stats_min_fps = 999; };
	if(isNil "bdetect_fired_bullets") then { bdetect_fired_bullets = []; };

	_nul = [] spawn
	{
		tpwcas_log_benchmark = true;
		
		while { tpwcas_log_benchmark } do
		{
			_cnt = count ( bdetect_fired_bullets ) / 2;
			if( _cnt > bdetect_stats_max_bullets ) then { bdetect_stats_max_bullets = _cnt; };

			if( diag_fps < bdetect_stats_min_fps ) then { bdetect_stats_min_fps = diag_fps };
			diag_log text format["TIME: %1;FPS: %2 (min: %3);BULLETS: %4 (max: %5);S.DELAY: %6 (Min FPS: %7);FIRED: %8 (BLUE:%9 RED:%10);TRACKED: %11;DETECTED: %12;BLACKLISTED: %13;UNITS: %14;KILLED: %15;PLAYERKILLED: %16",
			time,
			diag_fps,
			bdetect_stats_min_fps,
			_cnt,
			bdetect_stats_max_bullets,
			bdetect_bullet_delay,
			bdetect_fps_min,
			bdetect_fired_bullets_count,
			bdetect_fired_bullets_count_blufor,
			bdetect_fired_bullets_count_redfor,
			bdetect_fired_bullets_count_tracked + bdetect_fired_projectiles_count_tracked,
			bdetect_fired_bullets_count_detected + bdetect_fired_projectiles_count_detected,
			bdetect_fired_bullets_count_blacklisted + bdetect_fired_projectiles_count_blacklisted,
			bdetect_units_count,
			bdetect_units_count_killed,
			bdetect_players_count_killed];

			sleep 60;
		};
	};
};

// -------------------------------------------------------------------------------------------
// END OF FRAMEWORK CODE
// -------------------------------------------------------------------------------------------
// BELOW: Example for running the framework
// The below commented code is not part of the framework, just an example of how to run it
// -------------------------------------------------------------------------------------------
/*
// Cut & paste the following code into your own sqf. file.
// Place "bdetect.sqf" into your own mission folder.

// First load the framework
call compile preprocessFileLineNumbers "bdetect.sqf";  // CAUTION: comment this line if you wish to execute the framework from -within- bdetect.sqf file

// Set any optional configuration variables whose value should be other than Default (see all the defined variables in bdetect.sqf, function bdetect_fnc_init() ).
// Below some examples.
bdetect_debug_enable = true;		// Example only - Enable debug / logging in .rpt file. Beware, full levels logging may be massive.
bdetect_debug_levels = [0,9];		// Example only - Log only some basic messages (levels 0 and 9). Read comment about levels meanings into "bdetect.sqf, function bdetect_fnc_debug()
bdetect_debug_chat = true;			// Example only - log also into globalChat.

// Now name your own unit callback function (the one that will be triggered when a bullet is detected close to an unit)
bdetect_callback = "my_function";

// Define your own callback function and its contents, named as above. Here's a prototypical function:
my_function = {
	private [ "_unit", "_shooter", "_bullet", "_bpos", "_pos", "_time", "_proximity", "_msg" ];

	_unit = _this select 0;		// unit being under fire
	_shooter = _this select 1;	// shooter
	_bullet = _this select 2;	// bullet object
	_bpos = _this select 3;	// bullet position
	_pos = _this select 4;	// starting position of bullet
	_time = _this select 5; // starting time of bullet
	_proximity = _bpos distance _unit;	// distance between _bullet and _unit

	_msg = format["my_function() - [%1] close to bullet %2 fired by %3, proximity=%4m, data=%5", _unit, _bullet, _shooter, _proximity, _data];
	[ _msg, 9 ] call bdetect_fnc_debug;
};

// Now initialize framework
sleep 5; // wait some seconds if you want to load other scripts
call bdetect_fnc_init;

// Wait for framework to be fully loaded
waitUntil { !(isNil "bdetect_init_done") };

// You are done. Optional: care to activate display of some runtime stats ?
sleep 5;	// wait some more seconds for CPU load to normalize
call bdetect_fnc_benchmark;

// All done, place your other fancy stuff below ...
*/