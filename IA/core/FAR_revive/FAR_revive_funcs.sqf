////////////////////////////////////////////////
// Player Actions
////////////////////////////////////////////////

FAR_Player_Actions =
{
	if (alive player && player isKindOf "Man") then 
	{
		// addAction args: title, filename, (arguments, priority, showWindow, hideOnUse, shortcut, condition, positionInModel, radius, radiusView, showIn3D, available, textDefault, textToolTip)
		player addAction ["<t color=""#C90000"">" + "Medical Revive" + "</t>", "core\FAR_revive\FAR_handleAction.sqf", ["med_action_revive"], 10, true, true, "", "call FAR_Check_Revive_Med"];
		player addAction ["<t color=""#C90000"">" + "Revive" + "</t>", "core\FAR_revive\FAR_handleAction.sqf", ["action_revive"], 10, true, true, "", "call FAR_Check_Revive"];
		player addAction ["<t color=""#C90000"">" + "Drag" + "</t>", "core\FAR_revive\FAR_handleAction.sqf", ["action_drag"], 9, false, true, "", "call FAR_Check_Dragging"];
		//player addAction ["<t color=""#C90000"">" + "Carry" + "</t>","core\FAR_revive\FAR_handleAction.sqf",["action_carry"], 8, true, true, "", "call FAR_Check_Dragging"];
		
	};
};

////////////////////////////////////////////////
// Handle Death
////////////////////////////////////////////////
FAR_HandleDamage_EH =
{
    private ["_unit", "_killer", "_amountOfDamage", "_isUnconscious", "_maxrevives", "_uncon"];
	
    _unit = _this select 0;
    _amountOfDamage = _this select 2;
    _killer = _this select 3;
    _isUnconscious = _unit getVariable "FAR_isUnconscious";
    _maxrevives = 5;
    
    if (alive _unit && {_amountOfDamage >= 1} && {_isUnconscious == 0}) then
    {
        _uncon = false;
        if (_unit getVariable "revives" < _maxrevives) then { _uncon = true; };
        if (_uncon && ((random 1) <= 0.1) && _unit getVariable "revives" >= _maxrevives) then { _uncon = false; };
        
        // Fluit: Only go uncon if revive times not exceeded
        if (_uncon) then {
            //sleep 2;
            _unit setDamage 0;//--- bl1p alter to make uncon damaged make uncon unit bloody (doesnt always work well)
            _unit allowDamage false;
            [_unit, _killer] spawn FAR_Player_Unconscious;
            _amountOfDamage = 0;
        } else {
			// Death message if friendly fire
			if (FAR_EnableDeathMessages && {!isNil "_killer"} && {isPlayer _killer} && {_killer != _unit}) then
			{
				FAR_deathMessage = [_unit, _killer];
				publicVariable "FAR_deathMessage";
				["FAR_deathMessage", [_unit, _killer]] call FAR_public_EH;
				Totalfriendlyfire = Totalfriendlyfire + 1;publicvariable "Totalfriendlyfire";
			};
            _amountOfDamage = 1;
        };
    };
    _amountOfDamage
};
////////////////////////////////////////////////
// DR handle healing
////////////////////////////////////////////////
//dr_handle_healing =
//{
//	_this spawn {
//		diag_log "inside dr_handle_healing";
//		private ["_unit", "_healer", "_medic", "_damage"];
//		_unit = _this select 0;
//		_healer = _this select 1;
//		_medic = _this select 2;
//		_damage = 0.4;
//		
//		if (_medic) then {
//			// Medic has beter healing
//			_damage = 0.2;
//		};
//		
//		if (damage _unit > _damage) then {
//			_unit setDamage _damage;
//			diag_log format ["unit %1 is healed by %2 to damage %3", _unit, _healer, _damage];
//			systemchat format ["unit %1 is healed by %2 to damage %3", _unit, _healer, _damage];
//		};
//	   // AISFinishHeal [_unit, _healer, _medic];
//	   //true;
//   };
//};
////////////////////////////////////////////////
// Make Player Unconscious
////////////////////////////////////////////////
FAR_Player_Unconscious =
{
	private["_unit", "_killer","_playerpos"];
	_unit = _this select 0;
	_killer = _this select 1;
	
    
	
	// Death message if friendly fire
	if (FAR_EnableDeathMessages && {!isNil "_killer"} && {isPlayer _killer} && {_killer != _unit}) then
	{
		FAR_deathMessage = [_unit, _killer];
		publicVariable "FAR_deathMessage";
		["FAR_deathMessage", [_unit, _killer]] call FAR_public_EH;
		Totalfriendlyfire = Totalfriendlyfire + 1;publicvariable "Totalfriendlyfire";
	};
	// Death message none friendly fire
	if (FAR_EnableDeathMessages) then //--- param in the revive init
	{
		FAR_deathMessage_bl1p = [_unit, _killer];
		publicVariable "FAR_deathMessage_bl1p";
		["FAR_deathMessage_bl1p", [_unit, _killer]] call FAR_public_EH;
	};
	
	
	if (isPlayer _unit) then
	{
		titleText ["", "BLACK FADED"];
		execVM "core\FAR_revive\scream.sqf";
	};
	
	
	// Eject unit if inside vehicle
    if (vehicle _unit != _unit) then 
    {
		sleep 3;
        _playerpos = getPos _unit; // Fluit get unit position
        unAssignVehicle _unit;
        _unit action ["eject", vehicle _unit];
        
        sleep 1;
        _unit setPos [_playerpos select 0, _playerpos select 1, 0]; // Fluit set unit position but on ground
    };
	
	_unit setDamage 0;
    _unit setVelocity [0,0,0];
    _unit allowDamage false;
    _unit playMoveNow "AinjPpneMstpSnonWrflDnon_rolltoback"; //--- bl1p added playMoveNow to try to combat the problem of players not staying on back
	sleep 1;
	
	
    //WaitUntil {animationstate _unit == "AinjPpneMstpSnonWrflDnon"}; //find animation state of on back payer
	//diag_log format ["animationstate = %1",_state];
	
	if (isPlayer _unit) then
	{
		titleText ["", "BLACK IN", 1];	
		createDialog "bl1p_dialog";
		//--- bl1p disable players ability to use chat and escape while unconsious and place a suicide button
		noesckey = (findDisplay 2000) displayAddEventHandler ["KeyDown", "true"]; 
	};
	//--- bl1p stop acre when uncon
		if (acre_enabled) then 
		{
			_ret = [true] call acre_api_fnc_setSpectator;
		};
	
	//	if (taskForce_enabled) then 
	//	{
	//	[player, true] call TFAR_fnc_forceSpectator;
	//	};
		
	_unit switchMove "AinjPpneMstpSnonWrflDnon";
	_unit enableSimulation false;
	_unit setVariable ["FAR_isUnconscious", 1, true];
	
	// place marker on unconsious player
	if (FAR_EnableDeathMessages) then //--- param in the revive init
	{
		FAR_Marker_bl1p = [_unit, _killer];
		publicVariable "FAR_Marker_bl1p";
		["FAR_Marker_bl1p", [_unit, _killer]] call FAR_public_EH;
	};
	
	_unit setCaptive true;
	
	
	
	// Call this code only on players
	if (isPlayer _unit) then 

		{
			// Bleedout timer calculations                          
			// example 2 revives: 480 - ((2/10) * 480) = 480 - (0.2 * 480) = 480 - 96  = 384 seconds
			// example 4 revives: 480 - ((4/10) * 480) = 480 - (0.4 * 480) = 480 - 192 = 288 seconds
			_unitrevives = 0;
			if !(isNil { _unit getVariable "revives" } ) then { _unitrevives = _unit getVariable "revives"; };
			_bleedOut = FAR_BleedOut - ((_unitrevives / 10) * FAR_BleedOut);
			_bleedOut = round (_bleedOut + ((random 60) - 30)); // randomize it!
			if (_bleedOut < 20) then { _bleedOut = 20; };
			_bleedOut = time + _bleedOut;
			
			while { !isNull _unit && {alive _unit} && {_unit getVariable "FAR_isUnconscious" == 1} && {(FAR_BleedOut <= 0 || time < _bleedOut)} } do
			{
				hintSilent format["Bleedout in %1 seconds\n\n%2", round (_bleedOut - time)];
				//_time = (round (_bleedOut - time)); // Fluit: doesn't do anything?
				sleep 0.5;
			};
			
			// Player bled out
			if (FAR_BleedOut > 0 && {time >= _bleedOut}) then
			{
				
				//--- bl1p was here re enable all
				closeDialog 0;
				(findDisplay 2000) displayRemoveEventHandler ["KeyDown", noesckey];
				disableUserInput false;
				_unit setCaptive false;
				_unit setDamage 1;
				_unit setVariable ["FAR_isUnconscious", 0, true];
				_unit setVariable ["FAR_isDragged", 0, true];
				
			}
			else
			{
				// Player got revived
				sleep 6;
				
				// Clear the "medic nearby" hint
				hintSilent "";
				
				//--- bl1p was here re enable all
				//--- if alive added if cti maybe remove if not ?
				if (alive _unit) then 
					{ 
				closeDialog 0;	
				(findDisplay 2000) displayRemoveEventHandler ["KeyDown", noesckey]; //--- bl1p remove button and enable keypresses
					};
				//--- bl1p stop acre when uncon
					if (acre_enabled) then 
					{
						_ret = [false] call acre_api_fnc_setSpectator;
					};
					
				//--- bl1p stop taskforce when uncon
				//	if (taskForce_enabled) then 
				//	{
				//	[player, false] call TFAR_fnc_forceSpectator;
				//	};
					
				disableUserInput false;
				_unit enableSimulation true;
				_unit allowDamage true;
				_unit setDamage 0.5;
				_unit setCaptive false;
				_unit playMove "amovppnemstpsraswrfldnon";
				_unit playMove "";
			};
		};
};
////////////////////////////////////////////////
// Revive Player can fail
////////////////////////////////////////////////
FAR_HandleRevive =
{
	private ["_target","_targetRevives"];
	_target = _this select 0;
	_healer = _this select 1;
	_chance = random 10;
	_maxrevives = 5;

	// Fluit: Get number of revives from target
	if (isNil { _target getVariable "revives" } ) then { _target setVariable ["revives", 0]; };
	_targetRevives = _target getVariable "revives";
	
	diag_log format ["==Revive== Player: %1 times revived: %2 out of %3", _target, _targetRevives, _maxrevives];
	
	if ((alive _target) && (_chance >= 8) && (_targetRevives < _maxrevives)) then
	{
		player playMove "AinvPknlMstpSlayWrflDnon_medic";
		// add score goes here
		
		_target setVariable ["FAR_isUnconscious", 0, true];
		_target setVariable ["FAR_isDragged", 0, true];
		_healer removeItem "firstAidKit";

		// Fluit: Add revive to counter
		_target setVariable ["revives", (_targetRevives + 1), true];

		sleep 5;
		//if (_targetRevives >= 3) then {systemchat "It looks like he is going to die soon";};
	};
		if ((alive _target) && (_chance < 8)) then
	{
		player playMove "AinvPknlMstpSlayWrflDnon_medic";
		_healer removeItem "firstAidKit";
		sleep 5;
		_healer groupChat "Failed";
	};
};

////////////////////////////////////////////////
// Medical Revive Player Never fails
////////////////////////////////////////////////
FAR_HandleRevive_Med =
{
	private ["_target","_targetRevives"];
	_target = _this select 0;
	_maxrevives = 5;

	// Fluit: Get number of revives from target
	if (isNil { _target getVariable "revives" } ) then { _target setVariable ["revives", 0]; };
	_targetRevives = _target getVariable "revives";
	
	diag_log format ["==Revive== Player: %1 times revived: %2 out of %3", _target, _targetRevives, _maxrevives];

	if (alive _target && (_targetRevives < _maxrevives)) then
	{
		player playMove "AinvPknlMstpSlayWrflDnon_medic";
		
		//addscroe goes here
		
		_target setVariable ["FAR_isUnconscious", 0, true];
		_target setVariable ["FAR_isDragged", 0, true];

		// Fluit: Add revive to counter
		_target setVariable ["revives", (_targetRevives + 1), true];
		
		sleep 6;
		//if (_targetRevives >= 3) then {systemchat format ["%1 wont survive another injury",name _target];};
	};
};
////////////////////////////////////////////////
// DR FUll HEAL by Fluit
////////////////////////////////////////////////
dR_full_heal =
{
	private ["_target", "_damage", "_time", "_stages", "_revives"];
	_target = _this select 0; 					// unit that needs to be healed
	
	_damage = damage _target; 					// damage the unit has taken
	_revives = _target getVariable "revives";	// number of times the unit has been revived
	_time = 10.8;									// time of each healing stage
	_stages = floor(_damage * 10);				// number of healing stages
	
	if (_stages < 1) then { 
		_stages = 1;
	};
	
	if ((_damage > 0) || (_revives > 0)) then {
		_target allowDamage false;
		_target playMoveNow "AinjPpneMstpSnonWrflDnon_rolltoback";
		sleep 6;
		systemChat "Hold still while healing...";
		_target enableSimulation false;
		for "_x" from 1 to _stages do {
			if (damage _target >= 0.1) then {
				playSound "dumdidum";
				sleep _time;
				_target setDamage (damage _target - 0.1);
				//playsound3d ["A3\Sounds_f\characters\human-sfx\08_hum_inside_head1.wss",_target, true, getpos _target, 0.5, 1, 0];
				systemChat format ["Healing %1 percent done..", floor((100 / _stages) * _x)];
			};			
		};
		if (_revives > 0) then {
			_target setVariable ["revives", 0, true]; // Reset the revive counter
			playSound "dumdidum";
			sleep _time;
			systemChat "Your old war wounds have been healed!";
		};
		_target setDamage 0; // Set the damage to 0 just to be sure.
		_target setVariable ["revives", 0, true]; // Reset the revive counter
		systemChat "Successfully healed!";
		_target enableSimulation true;
		_target playMove "amovpknlmstpsraswrfldnon";
		_target allowDamage true;
	} else {
		sleep 1;
		systemChat "You are already healthy!";
	};
};

////////////////////////////////////////////////
// Drag Injured Player
////////////////////////////////////////////////
FAR_Drag =
{
	private ["_target", "_id"];
	
	FAR_isDragging = true;
	_target = _this select 0;
	_target attachTo [player, [0, 1.1, 0.092]];
	_target setDir 180;
	_target setVariable ["FAR_isDragged", 1, true];
	player playMoveNow "AcinPknlMstpSrasWrflDnon";
	// Rotation fix
	FAR_isDragging_EH = _target;
	publicVariable "FAR_isDragging_EH";
	
	// Add release action and save its id so it can be removed
	_id = player addAction ["<t color=""#C90000"">" + "Release" + "</t>", "core\FAR_revive\FAR_handleAction.sqf", ["action_release"], 10, true, true, "", "true"];
	
	hint parsetext "Toggle Combat Speed if you can't move<br/>Default 'C'";
	
	// Wait until release action is used
	waitUntil 
	{ 
		!alive player || player getVariable "FAR_isUnconscious" == 1 || !alive _target || _target getVariable "FAR_isUnconscious" == 0 || !FAR_isDragging || _target getVariable "FAR_isDragged" == 0 
	};

	// Handle release action
	FAR_isDragging = false;
	
	if (!isNull _target && alive _target) then
	{
		_target switchMove "AinjPpneMstpSnonWrflDnon";
		_target setVariable ["FAR_isDragged", 0, true];
		detach _target;
	};
	
	player removeAction _id;
};

FAR_Release =
{
	// Switch back to default animation
	player playMove "amovpknlmstpsraswrfldnon";

	FAR_isDragging = false;
};
////////////////////////////////////////////////
//Carry Injured Player
////////////////////////////////////////////////

////////////////////////////////////////////////
// Event handler for public variables
////////////////////////////////////////////////
FAR_public_EH =
{
	if(count _this < 2) exitWith {hint "exiting with less than 2";};
	
	_EH  = _this select 0;
	_target = _this select 1;

	// FAR_isDragging
	if (_EH == "FAR_isDragging_EH") then
	{
		_target setDir 180;
	};
	
	// FAR_deathMessage
	if (_EH == "FAR_deathMessage") then
	{
		_killed = _target select 0;
		_killer = _target select 1;

		if (isPlayer _killed && isPlayer _killer) then
		{
			systemChat format["%1 was injured by %2", name _killed, name _killer];
		};
	};
	// FAR_deathMessage_bl1p
	if (_EH == "FAR_deathMessage_bl1p") then
	{
		_killed = _target select 0;
		_killer = _target select 1;
		systemChat format["%1 is Incapacitated", name _killed];
	};
	
	// FAR_deathMessage_bl1p
	if (_EH == "FAR_Marker_bl1p") then
	{
	
	
			
			_killed = _target select 0;
			_killer = _target select 1;
			
			_side = side player; 
			
		if (_side == FAR_PlayerSide) then 
			{
				
				_pos = getpos _killed;
				_marker = createmarkerlocal [format ["FA_%1", _pos], _pos];
				
				format ["FA_%1", _pos] setmarkertypelocal "mil_box";
				format ["FA_%1", _pos] setMarkerTextlocal format ["<%1", name _killed];
				format ["FA_%1", _pos] setmarkerColorlocal "ColorGreen";
				format ["FA_%1", _pos] setMarkerSizelocal [0.3, 0.3];
				[_pos,_killed] spawn
				{
					_pos  = _this select 0;
					_killed = _this select 1;
					while {(!(isNull _killed) && (format ["%1", _killed getVariable "FAR_isUnconscious"] == "1"))} do
					{
						format ["FA_%1", _pos] setMarkerPoslocal getpos _killed;
						sleep 1;
					};
					
					deleteMarker format ["FA_%1", _pos];
				};
			};
	};
	
};

////////////////////////////////////////////////
// Revive Action Check
////////////////////////////////////////////////
FAR_Check_Revive = 
{
	private ["_target", "_isTargetUnconscious", "_isDragged"];

	_return = false;
	
	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	_target = cursorTarget;

	// Make sure player is alive and target is an injured unit
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	// Make sure target is unconscious and player is NOT a medic //--- bl1p
	if (_isTargetUnconscious == 1 && _isDragged == 0 && (_isMedic == 0) ) then
	{
		_return = true;

		// [ReviveMode] Check if player has a first aid
		if ( FAR_ReviveMode == 1 && !("FirstAidKit" in (items player)) ) then
		{
			_return = false;
		};
	};
	if (_isTargetUnconscious == 1 && _isDragged == 0 && (_isMedic == 1) ) then 
	{
		// [ReviveMode] Check if player doesnt have medkit but has a firstaidkit and is medic then do normal revive
		if ( FAR_ReviveMode == 1 && !("Medikit" in (items player)) && (_isMedic == 1) && ("FirstAidKit" in (items player))  ) then
		{
			_return = true;
		};
	};
	_return
};
////////////////////////////////////////////////
// Medic Revive Action Check
////////////////////////////////////////////////
FAR_Check_Revive_Med = 
{
	private ["_target", "_isTargetUnconscious", "_isDragged"];

	_return = false;
	
	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	_target = cursorTarget;

	// Make sure player is alive and target is an injured unit
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	// Make sure target is unconscious and player is a medic 
	if (_isTargetUnconscious == 1 && _isDragged == 0 && (_isMedic == 1) ) then
	{
		_return = true;
		
		// [ReviveMode] Check if player is medic
		if ( FAR_ReviveMode > 0 && (_isMedic < 1) ) then
		{
			_return = false;
		};
		// [ReviveMode] Check if player has a Medikit
		if ( FAR_ReviveMode == 1 && !("Medikit" in (items player)) ) then
		{
			_return = false;
		};
	};
	
	_return
};

////////////////////////////////////////////////
// Suicide Action Check
////////////////////////////////////////////////
FAR_Check_call =
{
	_return = false;
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	
	if (alive player && _isPlayerUnconscious == 1) then 
	{
		_return = true;
	};
	
	_return
};

////////////////////////////////////////////////
// Dragging Action Check
////////////////////////////////////////////////
FAR_Check_Dragging =
{
	private ["_target", "_isPlayerUnconscious", "_isDragged"];
	
	_return = false;
	_target = cursorTarget;
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";

	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return;
	};
	
	// Target of the action
	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	if(_isTargetUnconscious == 1 && _isDragged == 0) then
	{
		_return = true;
	};
		
	_return
};

////////////////////////////////////////////////
// Show Nearby Friendly Medics
////////////////////////////////////////////////
FAR_IsFriendlyMedic =
{
	private ["_unit"];
	
	_return = false;
	_unit = _this;
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf _unit >> "attendant");
				
	if ( alive _unit && {(isPlayer _unit || FAR_Debugging)} && {side _unit == FAR_PlayerSide} && {_unit getVariable "FAR_isUnconscious" == 0} && {(_isMedic == 1 || FAR_ReviveMode > 0)} ) then
	{
		_return = true;
	};
	
	_return
};

FAR_CheckFriendlies =
{
	private ["_unit", "_units", "_medics", "_hintMsg"];
	
	_units = nearestObjects [getpos player, ["Man", "Car", "Air", "Ship"], 800];
	_medics = [];
	_dist = 800;
	_hintMsg = "";
	
	// Find nearby friendly medics
	if (count _units > 1) then
	{
		{
			if (_x isKindOf "Car" || _x isKindOf "Air" || _x isKindOf "Ship") then
			{
				if (alive _x && count (crew _x) > 0) then
				{
					{
						if (_x call FAR_IsFriendlyMedic) then
						{
							_medics = _medics + [_x];
							
							if (true) exitWith {};
						};
					} forEach crew _x;
				};
			} 
			else 
			{
				if (_x call FAR_IsFriendlyMedic) then
				{
					_medics = _medics + [_x];
				};
			};
			
		} forEach _units;
	};
	
	// Sort medics by distance
	if (count _medics > 0) then
	{
		{
			if (player distance _x < _dist) then
			{
				_unit = _x;
				_dist = player distance _x;
			};
		
		} forEach _medics;
		
		if (!isNull _unit) then
		{
			_unitName	= name _unit;
			_distance	= floor (player distance _unit);
			//_hintMsg = format["Nearby Medic:\n%1 is %2m away.", _unitName, _distance]; //--- Commented out to remove medics near by hint
		};
	} 
	else 
	{
	//	_hintMsg = "No medic nearby."; //--- Commented out to remove the medics nearby hint
	};
	
	_hintMsg
};

/////////////////////////////
//         todo            //
/////////////////////////////
//
//--- add carry animations and function and action
//
//--- implement acre shutdown compatability
//
//--- find a better solution to call for help playsound3d
//
//--- place marker on unconsious players
//
//--- Chance medic can fail 1% chance
//
//--- chance player wakes up 5% chance
//
//--- CPR to increase the life timer
