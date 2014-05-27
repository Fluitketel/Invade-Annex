AW_fnc_establishingShot = {
	/*
		Author: Thomas Ryan
			Tweaked by Rarek [AW]
		
		Description:
		Play a fake UAV observational sequence which serves as an establishing shot.
		
		Parameters:
			_this select 0: OBJECT or ARRAY - Target position/object
			_this select 1: STRING - Text to display
			_this select 2 (Optional): NUMBER - Altitude (in meters)
			_this select 3 (Optional): NUMBER - Radius of the circular movement (in meters)
			_this select 4 (Optional): NUMBER - Viewing angle (in degrees)
			_this select 5 (Optional): NUMBER - Direction of camera movement (0: anti-clockwise, 1: clockwise, default: random)
			_this select 6 (Optional): ARRAY -	Objects/positions/groups to display icons over
								Syntax: [[icon, color, target, size X, size Y, angle, text, shadow]]
	*/
	enableSaving [false, false];

	BIS_missionStarted = nil;

	private ["_tgt", "_txt", "_alt", "_rad", "_ang", "_dir"];
	_tgt = [_this, 0, objNull, [objNull, []]] call BIS_fnc_param;
	_txt = [_this, 1, "", [""]] call BIS_fnc_param;
	_alt = [_this, 2, 500, [500]] call BIS_fnc_param;
	_rad = [_this, 3, 200, [200]] call BIS_fnc_param;
	_ang = [_this, 4, random 360, [0]] call BIS_fnc_param;
	_dir = [_this, 5, round random 1, [0]] call BIS_fnc_param;

	BIS_fnc_establishingShot_icons = [_this, 6, [], [[]]] call BIS_fnc_param;

	//0 fadeSound 0;
	titleCut ["", "BLACK FADED", 10e10];

	// Create fake UAV
	if (isNil "BIS_fnc_establishingShot_fakeUAV") then {
		BIS_fnc_establishingShot_fakeUAV = "Camera" camCreate [10,10,10];
	};

	BIS_fnc_establishingShot_fakeUAV cameraEffect ["INTERNAL", "BACK"];

	cameraEffectEnableHUD true;

	private ["_pos", "_coords"];
	_pos = if (typeName _tgt == typeName objNull) then {position _tgt} else {_tgt};
	_coords = [_pos, _rad, _ang] call BIS_fnc_relPos;
	_coords set [2, _alt];

	BIS_fnc_establishingShot_fakeUAV camPrepareTarget _tgt;
	BIS_fnc_establishingShot_fakeUAV camPreparePos _coords;
	BIS_fnc_establishingShot_fakeUAV camPrepareFOV 0.700;
	BIS_fnc_establishingShot_fakeUAV camCommitPrepared 0;

	// Timeout the preload after 3 seconds
	BIS_fnc_establishingShot_fakeUAV camPreload 3;

	// Apply post-process effects
	private ["_ppColor"];
	_ppColor = ppEffectCreate ["colorCorrections", 1999];
	_ppColor ppEffectEnable true;
	_ppColor ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [0.8, 0.8, 0.8, 0.65], [1, 1, 1, 1.0]];
	_ppColor ppEffectCommit 0;

	private ["_ppGrain"];
	_ppGrain = ppEffectCreate ["filmGrain", 2012];
	_ppGrain ppEffectEnable true;
	_ppGrain ppEffectAdjust [0.1, 1, 1, 0, 1];
	_ppGrain ppEffectCommit 0;

	// Disable stuff after simulation starts
	[] spawn {
		waitUntil {time > 0};
		showCinemaBorder false;
		enableEnvironment false;
	};

	// Compile SITREP text
	private ["_month", "_day", "_hour", "_minute"];
	_month = str (date select 1);
	_day = str (date select 2);
	_hour = str (date select 3);
	_minute = str (date select 4);

	if (date select 1 < 10) then {_month = format ["0%1", str (date select 1)]};
	if (date select 2 < 10) then {_day = format ["0%1", str (date select 2)]};
	if (date select 3 < 10) then {_hour = format ["0%1", str (date select 3)]};
	if (date select 4 < 10) then {_minute = format ["0%1", str (date select 4)]};

	private ["_time", "_date"];
	_time = format ["%1%2", _hour, _minute];
	_date = format ["%1/%2/%3", _day, _month, str (date select 0)];

	private ["_SITREP"];
	_SITREP = format ["<t align = 'left' shadow = '1'>PERSONAL UAV V1.71||%1|%2 %3 HOURS||Ahoy World 2013</t>", _txt, _date, _time];
	
	//removed 'toUpper _txt' from _SITREP

	disableSerialization;

	waitUntil {!(isNull ([] call BIS_fnc_displayMission))};

	// Compile key
	private ["_key"];
	_key = format ["BIS_%1.%2_establishingShot", missionName, worldName];

	private ["_dispMis"];
	_dispMis = [] call BIS_fnc_displayMission;
	
	// Allow skipping
	/*
		if (_this select 1 == 57) then {
			0 fadeSound 1;
			playSound 'click';
			
			activateKey '%1';
			BIS_fnc_establishingShot_skip = true;
			
			true
		};
		
		if (_this select 1 == 79) then {
			false setCamUseTi 0;
			true
		};
	*/
		
	private ["_skipEH"];
	_skipEH = _dispMis displayAddEventHandler [
		"KeyDown",
		format [
			"
				switch (_this select 1) do
				{
					case 57:
					{
						0 fadeSound 1;
						playSound 'click';
						
						activateKey '%1';
						BIS_fnc_establishingShot_skip = true;
						
						true
					};
					
					case 79:
					{
						false setCamUseTi 0;
						playSound 'click';
						true
					};
					
					case 80:
					{
						true setCamUseTi 0;
						playSound 'click';
						true
					};
					
					case 81:
					{
						true setCamUseTi 1;
						playSound 'click';
						true
					};
					
					case 75:
					{
						true setCamUseTi 2;
						playSound 'click';
						true
					};
					
					case 76:
					{
						true setCamUseTi 3;
						playSound 'click';
						true
					};
					
					case 77:
					{
						true setCamUseTi 4;
						playSound 'click';
						true
					};
					
					case 71:
					{
						true setCamUseTi 5;
						playSound 'click';
						true
					};
					
					case 72:
					{
						true setCamUseTi 6;
						playSound 'click';
						true
					};
					
					case 73:
					{
						true setCamUseTi 7;
						playSound 'click';
						true
					};
				};
			",
			_key
		]
	];

	// Create vignette & tiles
	("BIS_layerEstShot" call BIS_fnc_rscLayer) cutRsc ["RscEstablishingShot", "PLAIN"];
	
	// Remove effects if video options opened
	optionsMenuOpened = {
		disableSerialization;
		{(_x call BIS_fnc_rscLayer) cutText ["", "PLAIN"]} forEach ["BIS_layerEstShot", "BIS_layerStatic", "BIS_layerInterlacing"];
	};

	// Add them back if closed
	optionsMenuClosed = {
		disableSerialization;
		("BIS_layerEstShot" call BIS_fnc_rscLayer) cutRsc ["RscEstablishingShot", "PLAIN"];
	};

	waitUntil {!(isNull (uiNamespace getVariable "RscEstablishingShot"))};

	// Wait for the camera to load
	waitUntil {camPreloaded BIS_fnc_establishingShot_fakeUAV || !(isNil "BIS_fnc_establishingShot_skip")};
	
	private ["_musicEH", "_drawEH"];

	if (isNil "BIS_fnc_establishingShot_skip") then {
		// Play ambience on repeat
		0 fadeMusic 0;
		2 fadeMusic 1;
		playMusic ["RadioAmbient1", random 60];
		_musicEH = addMusicEventHandler ["MusicStop", {playMusic "RadioAmbient1"}];
		
		// Move camera in a circle
		[_pos, _alt, _rad, _ang, _dir] spawn {
			scriptName "BIS_fnc_establishingShot: camera control";
			
			private ["_pos", "_alt", "_rad", "_ang", "_dir"];
			_pos = _this select 0;
			_alt = _this select 1;
			_rad = _this select 2;
			_ang = _this select 3;
			_dir = _this select 4;
			
			while {isNil "BIS_missionStarted"} do 
			{
				_ang = _ang - 0.5;
				
				private ["_coords"];
				_coords = [_pos, _rad, if (_dir == 0) then {_ang} else {_ang * -1}] call BIS_fnc_relPos;
				_coords set [2, _alt];
				
				BIS_fnc_establishingShot_fakeUAV camPreparePos _coords;
				BIS_fnc_establishingShot_fakeUAV camCommitPrepared 0.5;
				
				waitUntil {camCommitted BIS_fnc_establishingShot_fakeUAV || !(isNil "BIS_missionStarted")};
				
				BIS_fnc_establishingShot_fakeUAV camPreparePos _coords;
				BIS_fnc_establishingShot_fakeUAV camCommitPrepared 0;
				//sleep 0.5;
			};
		};
		
		sleep 1;
		
		if (isNil "BIS_fnc_establishingShot_skip") then {
			// Static fade-in
			("BIS_layerStatic" call BIS_fnc_rscLayer) cutRsc ["RscStatic", "PLAIN"];
			waitUntil {!(isNull (uiNamespace getVariable "RscStatic_display")) || !(isNil "BIS_fnc_establishingShot_skip")};
			waitUntil {isNull (uiNamespace getVariable "RscStatic_display")  || !(isNil "BIS_fnc_establishingShot_skip")};
			
			if (isNil "BIS_fnc_establishingShot_skip") then {
				// Show interlacing
				("BIS_layerInterlacing" call BIS_fnc_rscLayer) cutRsc ["RscInterlacing", "PLAIN"];
				
				// Show screen
				titleCut ["", "PLAIN"];
				
				// Add interlacing to optionsMenuClosed
				optionsMenuClosed = {
					("BIS_layerEstShot" call BIS_fnc_rscLayer) cutRsc ["RscEstablishingShot", "PLAIN"];
					("BIS_layerInterlacing" call BIS_fnc_rscLayer) cutRsc ["RscInterlacing", "PLAIN"];
				};
				
				// Show icons
				if (count BIS_fnc_establishingShot_icons > 0) then {
					_drawEH = addMissionEventHandler [
						"Draw3D",
						{
							{
								private ["_icon", "_color", "_target", "_sizeX", "_sizeY", "_angle", "_text", "_shadow"];
								_icon = [_x, 0, "", [""]] call BIS_fnc_param;
								_color = [_x, 1, [], [[]]] call BIS_fnc_param;
								_target = [_x, 2, [], [[], objNull, grpNull]] call BIS_fnc_param;
								_sizeX = [_x, 3, 1, [1]] call BIS_fnc_param;
								_sizeY = [_x, 4, 1, [1]] call BIS_fnc_param;
								_angle = [_x, 5, random 360, [0]] call BIS_fnc_param;
								_text = [_x, 6, "", [""]] call BIS_fnc_param;
								_shadow = [_x, 7, 0, [0]] call BIS_fnc_param;
								
								// Determine condition and position
								private ["_condition", "_position"];
								_condition = true;
								_position = _target;
								
								switch (typeName _target) do {
									// Object
									case typeName objNull: {
										_condition = alive _target;
										_position = getPosATL _target;
									};
									
									// Group
									case typeName grpNull: {
										_condition = {alive _x} count units _target > 0;
										_position = getPosATL leader _target;
									};
								};
								
								// Draw icon
								if (_condition) then {
									drawIcon3D [_icon, _color, _position, _sizeX, _sizeY, _angle, _text, _shadow];
								};
							} forEach BIS_fnc_establishingShot_icons;
						}
					];
				};
				
				// Spawn instructions separately to allow for no delay in skipping
				_key spawn {
					scriptName "BIS_fnc_establishingShot: instructions control";
					
					disableSerialization;
					
					private ["_key"];
					_key = _this;
					
					if (!(isKeyActive _key) && isNil "BIS_fnc_establishingShot_skip") then {
						// Display instructions
						private ["_layerTitlecard"];
						_layerTitlecard = "BIS_layerTitlecard" call BIS_fnc_rscLayer;
						_layerTitlecard cutRsc ["RscDynamicText", "PLAIN"];
						
						private ["_dispText", "_ctrlText"];
						_dispText = uiNamespace getVariable "BIS_dynamicText";
						_ctrlText = _dispText displayCtrl 9999;
						
						_ctrlText ctrlSetPosition [
							0 * safeZoneW + safeZoneX,
							0.8 * safeZoneH + safeZoneY,
							safeZoneW,
							safeZoneH
						];
						
						// Determine appropriate key highlight
						private ["_keyColor"];
						_keyColor = format [
							"<t color = '%1'>",
							(["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet) call BIS_fnc_colorRGBtoHTML
						];
						
						private ["_skipText"];
						_skipText = format [
							"%1PRESS %2[SPACE]%3 TO ADVANCE%4",	// Todo: localize
							"<t size = '0.75'>",
							_keyColor,
							"</t>",
							"</t>"
						];
						
						_ctrlText ctrlSetStructuredText parseText _skipText;
						_ctrlText ctrlSetFade 1;
						_ctrlText ctrlCommit 0;
						
						_ctrlText ctrlSetFade 0;
						_ctrlText ctrlCommit 1;
						
						// Wait for video to finish
						waitUntil {{!(isNil _x)} count ["BIS_fnc_establishingShot_skip", "BIS_fnc_establishingShot_UAVDone"] > 0};
						
						// Remove instructions
						_ctrlText ctrlSetFade 1;
						_ctrlText ctrlCommit 0;
					};
				};
				
				sleep 1;
				
				if (isNil "BIS_fnc_establishingShot_skip") then {
					((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlSetPosition [
						(((safeZoneW / safeZoneH) min 1.2) / 40) + safeZoneX,
						((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25) + safeZoneY,
						safeZoneW,
						safeZoneH
					];
					
					((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlCommit 0;
					
					// Split text to individual characters
					private ["_SITREPArray"];
					_SITREPArray = toArray _SITREP;
					{_SITREPArray set [_forEachIndex, toString [_x]]} forEach _SITREPArray;
					
					private ["_scrollIn"];
					_scrollIn = _SITREPArray spawn {
						disableSerialization;
						
						private ["_SITREPArray"];
						_SITREPArray = _this;
						
						private ["_SITREPCompile"];
						_SITREPCompile = "";
						
						// Make text scroll in
						for "_i" from 0 to (count _SITREPArray - 1) do {
							private ["_character", "_delay"];
							_character = _SITREPArray select _i;
							_delay = if (_character == "|") then {_character = "<br/>"; 1} else {0.01};
							
							_SITREPCompile = _SITREPCompile + _character;
							
							if (!(isNull (uiNamespace getVariable "RscEstablishingShot"))) then {
								((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlSetStructuredText parseText (_SITREPCompile + "_");
								((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlCommit 0;
							};
							
							sleep _delay;
						};
						
						if (!(isNull (uiNamespace getVariable "RscEstablishingShot"))) then {
							((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlSetStructuredText parseText _SITREPCompile;
						};
						
						sleep 8;
					};
					
					waitUntil {!(isNil "BIS_fnc_establishingShot_skip")};
					
					if (isNil "BIS_fnc_establishingShot_skip") then {
						// Register the UAV finished
						BIS_fnc_establishingShot_UAVDone = true;
					};
				};
			};
		};
	};

	waitUntil {{!(isNil _x)} count ["BIS_fnc_establishingShot_skip", "BIS_fnc_establishingShot_UAVDone"] > 0};

	// Remove skipping eventhandler
	_dispMis displayRemoveEventHandler ["KeyDown", _skipEH];

	// Static fade-out
	("BIS_layerStatic" call BIS_fnc_rscLayer) cutRsc ["RscStatic", "PLAIN"];
	waitUntil {!(isNull (uiNamespace getVariable "RscStatic_display"))};
	waitUntil {isNull (uiNamespace getVariable "RscStatic_display")};

	// Remove HUD
	optionsMenuOpened = nil;
	optionsMenuClosed = nil;

	if (!(isNil "_drawEH")) then {
		removeMissionEventHandler ["Draw3D", _drawEH];
	};

	if (!(isNull (uiNamespace getVariable "RscEstablishingShot"))) then {
		((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlSetFade 1;
		((uiNamespace getVariable "RscEstablishingShot") displayCtrl 2500) ctrlCommit 0;
	};

	{
		private ["_layer"];
		_layer = _x call BIS_fnc_rscLayer;
		_layer cutText ["", "PLAIN"];
	} forEach ["BIS_layerEstShot", "BIS_layerStatic", "BIS_layerInterlacing"];

	// Stop ambience
	if (!(isNil "_musicEH")) then {
		0 fadeMusic 0;
		removeMusicEventHandler ["MusicStop", _musicEH];
	};

	titleCut ["", "BLACK FADED", 10e10];

	sleep 1;

	enableSaving [true, true];

	BIS_fnc_establishingShot_fakeUAV cameraEffect ["TERMINATE", "BACK"];

	ppEffectDestroy _ppColor;
	ppEffectDestroy _ppGrain;

	3 fadeSound 1;
	enableEnvironment true;
	titleCut ["", "BLACK IN", 3];

	// Clear existing global variables
	BIS_fnc_establishingShot_icons = nil;
	BIS_fnc_establishingShot_skip = nil;
	BIS_fnc_establishingShot_UAVDone = nil;

	// Start mission
	BIS_missionStarted = true;

	true
};

if (radioTowerAlive) exitWith
{
	hint parseText format 
	[
		"<t align='center' size='2.0'>UAV Status</t><br/>
		<t align='center' size='1.5' color='#b60000'>UNAVAILABLE</t><br/>
		______________<br/>
		Before you can use your Personal UAV, we have to destroy the enemy radio tower in %1.<br/>
		<br/>
		Once the radio tower has been destroyed (using explosive satchels or the like), all Personal UAVs will be clear for use. Get that tower down.",
		currentAO
	];
};

if (!currentAOUp) exitWith {hint "UAV link down please wait....";};

private["_obj","_id","_currentTarget","_colorWest","_markerArray","_playerName","_size","_unitType","_icon"];
_obj = _this select 0;
_id = _this select 2;
_currentTarget = (_this select 3) select 0;

_colorWest = WEST call BIS_fnc_sideColor;
_colorWest set [3, 0.5];

_markerArray = [
	["a3\ui_f\data\map\groupIcons\selector_selectedFriendly_ca.paa", [255,255,255,0.5], player, 2, 2, 0, "", 0]
];

{
	if (alive _x && side _x == WEST) then
	{
		_playerName = name _x;
		_size = 0.5;
		_unitType = typeOf _x;
		_icon = "a3\ui_f\data\map\markers\nato\b_inf.paa";
		
		if (rank _x == "SERGEANT") then {
			_size = 1;
		};
		
		switch (_unitType) do
		{
			case "B_medic_F":
			{
				_icon = "a3\ui_f\data\map\markers\nato\b_med.paa";
			};
			
			case "B_soldier_repair_F":
			{
				_icon = "a3\ui_f\data\map\markers\nato\b_maint.paa";
			};
		};
		
		_markerArray = _markerArray + [[_icon, [255,255,255,0.5], _x, _size, _size, 0, _playerName, 1]];
	};
} forEach allUnits;

[
	markerPos currentAO,
	format ["OPERATOR: %1|TARGET: %2||Press SPACE to EXIT|Press NUM 1 - 9 to switch viewing modes|", name _obj, currentAO],
	300,
	230,
	random 360,
	1,
	_markerArray
] call AW_fnc_establishingShot;

/* _obj removeAction _id;
usedUAV = true;

hint parseText "<t align='center' size='2.0'>UAV Status</t><br/>
<t align='center' size='1.5' color='#b60000'>UNAVAILABLE</t><br/>
______________<br/>
Your personal UAV is bugging out for around 30 seconds to rearm and refuel. We'll let you know when it's back up.<br/>
<br/>
Remember: because the UAV is so small, transmitting data to your display takes a lot of power. Once you've used it it will need time to rearm and refuel.<br/>
<br/>
Good hunting, soldier."; */