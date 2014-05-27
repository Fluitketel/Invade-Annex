private ["_target", "_killer", "_seagull", "_markers", "_KEGsNextRun", "_name", "_setOriginalSide", "_OriginalSide", "_RatingDelta", "_ehVehicles", "_t", "_disp", "_cCamera", "_cTarget", "_cName", "_cCamerasBG", "_cTargetsBG", "_cMap", "_cMapFull", "_cDebug", "_pos", "_foo", "_nNoDialog", "_lastUpdateMarkers", "_lastUpdateMarkerTypes", "_lastUpdateTags", "_allUnits", "_allVehicles", "_newUnits", "_newVehicles", "_fh", "_kh", "_waitUnits", "_m", "_s", "_rate", "_doMarkerTypes", "_mapFull", "_mappos", "_markedVehicles", "_i", "_u", "_type", "_icon", "_map", "_tt", "_bpos", "_bird"];

//
// Spectating Script for Armed Assault
// by Kegetys <kegetys [ät] dnainternet.net>
//

disableSerialization;

if ( ( count _this ) > 0 ) then { _target = _this select 0; };
//_killer = _this select 1;
//_seagull = _this select 2;

VM_scriptName="specta";

f_var_debugMode = 0;

//StartLoadingScreen ["Initializing Spectator Script..."];
//titleText["","BLACK FADED", 1];
cutText ["Initializing Spectator Script...","BLACK FADED", 0];
//_seagull = "noWait";

// Globals etc.
vm_count = 0; //Debug loop counter
debugX = [];
NORRN_noMarkersUpdates = false; //Added for no marker update - NORRN
spectate_events = compile preprocessFileLineNumbers ("spectator\specta_events.sqf");
//If (isNil "OldNVGMethod") then { OldNVGMethod = false };
//If (isNil "VM_CommitDelay") then { VM_CommitDelay = 0 };
VM_CurrentCameraView = "";
KEG_Spect_Init = false;
//if ( isNil "KEGs_target" ) then { KEGs_target = objNull; } else { diag_log format ["'KEGs_target' already defined: %1", KEGs_target]; };  
//if ( isNil "KEGs_tgtSelLast" ) then {	
KEGs_tgtSelLast = 0; 
//};
KEGsEHlist = [];

//set focus to killer else player
if ( !(isNil "_target") && { ( alive _target ) } ) then 
{
	diag_log format ["Target: %1", _target];
	KEGs_target = _target;
}
else
{
	diag_log format ["No Killer: %1", player];
	if ( (isNil "KEGs_target") || { !(alive KEGs_target) } ) then { KEGs_target = player; };
};

//KEGsRunAbort = false;




KEGsMouseButtons = [false, false];
KEGsMouseScroll = 0;
KEGsMouseCoord = [0.5, 0.5];
KEGsUseNVG = false;
//KEGsMissileCamActive = false;
//KEGsUseMissileCam = false;
KEGsMarkerNames = false; // True = display marker names and arrows
KEGsMarkerType = 1; // 0 = disabled, 1 = names, 2 = types
KEGsTags = false; // Particlesource tags
KEGsTagsStat = false; // Particlesource status tags
KEGsAIfilter = false; // Filter AI units (only players displayed)
KEGsDeadFilter = false; // Filter Unknown Dead units (only Alive players displayed)
KEGsClientAddonPresent = false; // Is client-side addon present?
KEGsMarkerSize = 1.0; // Full map marker size
KEGsMinimapZoom = 0.5; // Minimap zoom
KEGsSelect = 0; // Offset Used to change selected target
KEGsCurrentSelectIdx = 0; // Current Index of the selected target
KEGs1stGunner = false; // Gunner view on 1st person camera?
KEGsDroppedCamera = false; // Free camera dropped (non-targeted with free motion)?
KEGsCamForward = false;
KEGsCamBack = false;
KEGsCamLeft = false;
KEGsCamRight = false;
KEGsCamUp = false;
KEGsCamDown = false;
KEGsNeedUpdateLB = false;
mouseDeltaX = 0;
mouseDeltaY = 0;
sdistance = 5; // camera distance
fangle  = 0; // Free camera angle
fangleY = 15;
KEGs_flybydst = 35; // Distance of flyby camera (adjusted based on target speed)
szoom = 0.976;
_markers = []; // Map markers showing positions of all units
KEGsTagSources = []; // Particle sources for tags
KEGsTagStatSources = []; // Particle sources for status tags
KEGs_lastTgt = 0;
KEGs_dir = 0;
if ( isNil "KEGs_nameCache" ) then { KEGs_nameCache = [] }; // Used to store valid names since name command cannot be trusted
//_name = "Unknown";
CheckNewUnitsReady = true;
RefreshListReady = true;

KEGsOrgViewDistance = viewDistance;
KEGsTempViewDistance = (2 * KEGsOrgViewDistance) min 10000 max 4000;

VM_SpectatorCamerasEnabled = False;

KEGs_camera_vision = 0;
KEGscam_free_pitch = 0;

KEGs_ALT_PRESS = false;
KEGs_CTRL_PRESS = false;

maxDistance = 50;	// Maximum distance for camera
maxZoom = 0.05;		// Maximum zoom level
minZoom = 2;

// Unit sides shown - Show all if sides not set
if(isNil "KEGsShownSides") then {
	KEGsShownSides = [west, east, resistance, civilian];
};

// In an effort to compensate for Renegades (players with ratings of less than -2000) we will add this Renegage fix
//Renegade Fix add function _setOriginalSide - ViperMaul 
VM_CheckOriginalSide =  
{
	private ["_unit", "_OriginalSide", "_RatingDelta"];

	_unit = _this;
	
	_OriginalSide = _unit getVariable ["KEG_OriginalSide",  sideLogic];	
	
	if ( _OriginalSide == sideLogic ) then
	{
		_RatingDelta = abs(Rating _unit);
		_unit addRating _RatingDelta; 
		_unit setVariable ["KEG_OriginalSide",(side _unit)];
		_unit addRating -(_RatingDelta);
	};
	_OriginalSide = _unit getVariable ["KEG_OriginalSide", civilian];
	
	_OriginalSide
};


deathCam = [];
//_ehVehicles = []; // Used to keep track of added eventhandlers

/*
KEGsAllUnits = [];

// Create trigger for retrieving all vehicles
_t = createTrigger["EmptyDetector", (player modelToWorld [0,0,0]) ];
_t setTriggerType "NONE";
_t setTriggerStatements ["this", "KEGsAllUnits = thislist", ""];
_t setTriggerArea[50000, 50000, 0, false];
_t setTriggerActivation["ANY", "PRESENT", false];

// Wait until trigger assigns the array
waitUntil{count KEGsAllUnits > 0};
*/

//if(typeName _seagull != "string") then {
//	sleep 1;
	//titleCut ["","BLACK IN", 2];
	//titleText["","BLACK IN", 1];	
//} else {
//	titleText["","BLACK IN", 0];	
//};

// Create dialog & assign keyboard handler
createDialog "KEGsRscSpectate";
_disp = (findDisplay 55001);
_disp displaySetEventHandler["KeyDown", "[""KeyDown"",_this] call spectate_events"];
_disp displaySetEventHandler["KeyUp", "[""KeyUp"",_this] call spectate_events"];

// hide menus by default
["ToggleCameraMenu",0] call spectate_events;
["ToggleTargetMenu",0] call spectate_events;
["ToggleHelp",0] call spectate_events;
["ToggleMap",1] call spectate_events;

// IDC's from rsc
_cCamera = 55002;
_cTarget = 55003;
_cName = 55004;
KEGs_cLBCameras = 55005;
KEGs_cLBTargets = 55006;
_cCamerasBG = 55007;
_cTargetsBG = 55008;
_cMap = 55013;
_cMapFull = 55014;
_cDebug = 55100;
KEGs_nearest = objNull;

// Create cameras
//if (isnil "KEGs_Camera") then {
//	createcenter sidelogic;
//	_logicGrp = creategroup sidelogic;
//	_logicASL = _logicGrp createunit ["Logic",position player,[],0,"none"];
//	KEGs_Camera = _logicASL;
//};

//_logic = KEGs_Camera;


_pos = [(KEGs_target modelToWorld [0,0,0] select 0)-1+random 2, (KEGs_target modelToWorld [0,0,0] select 1)-1+random 2, 2];
KEGscam_chase = "camera" camCreate _pos;
KEGscam_target = "camera" camCreate _pos; // "Dummy" target camera for smooth transitions
KEGscam_lockon = "camera" camCreate _pos;
//KEGscam_free = "camera" camCreate [(_pos select 0),(_pos select 1),15];;
KEGscam_free = "camera" camCreate (KEGs_target modelToWorld [30,30,25]);
[KEGscam_free,-70,0] call bis_fnc_setpitchbank;

//KEGscam_target switchCamera "INTERNAL";
//KEGscam_target cameraEffect["INTERNAL", "BACK"];
//KEGscam_target camsettarget KEGs_target;
//KEGscam_target camsetrelpos[0,-0.1,0.20]

//--- Create Cam Marker
KEGS_camMarker = createMarkerLocal ["KEGS_camMarker", getPos KEGscam_free];
KEGS_camMarker setMarkerTypeLocal "mil_start";
KEGS_camMarker setMarkerColorLocal "colorpink";
KEGS_camMarker setMarkerSizeLocal [.75,.75];

//KEGscam_flyby = "camera" camCreate _pos;
//KEGscam_topdown = "camera" camCreate _pos;
//KEGscam_1stperson = "camera" camCreate _pos; // Dummy camera
//KEGscam_missile = "camera" camCreate _pos; // Missile camera
KEGscam_fullmap = "camera" camCreate _pos; // Full map view camera
//KEGs_cameras = [KEGscam_lockon, KEGscam_chase, KEGscam_flyby, KEGscam_topdown, KEGscam_1stperson];
//KEGs_cameras = [KEGscam_chase, KEGscam_lockon, KEGscam_free, KEGscam_target];
//KEGs_cameras = [KEGscam_chase, KEGscam_lockon, KEGscam_free];
KEGs_cameras = [KEGscam_lockon, KEGscam_free, KEGscam_chase];
//KEGs_cameraNames = ["Free", "Chase", "Flyby", "Top-down", "1st person"];
//KEGs_cameraNames = ["Chase", "Lock-on", "Free", "1st person"];
//KEGs_cameraNames = ["Chase", "Lock-on", "Free"];
KEGs_cameraNames = ["Lock-on", "Free", "Chase"];

//KEGs_dummy = "Land_HelipadEmpty_F" createVehicleLocal [0,0,0]; // Dummy object for distance command

// Add cameras to listbox
lbClear KEGs_cLBCameras;
{lbAdd[KEGs_cLBCameras, _x]} forEach KEGs_cameraNames;

// Add separator & toggles
KEGs_cLbSeparator = lbAdd[KEGs_cLBCameras, "---"];
lbSetColor[KEGs_cLBCameras, KEGs_cLbSeparator, [0.5, 0.5, 0.5, 0.5]];
//KEGs_cLbMissileCam = lbAdd[KEGs_cLBCameras, "Missile camera"];
//KEGs_cLbToggleNVG = lbAdd[KEGs_cLBCameras, "Night vision"];
KEGs_cLbToggleTags = lbAdd[KEGs_cLBCameras, "Unit tags"];
KEGs_cLbToggleTagsStat = lbAdd[KEGs_cLBCameras, "Combat status tags"];
KEGs_cLbToggleAiFilter = lbAdd[KEGs_cLBCameras, "Filter AI"];
KEGs_cLbToggleDeadFilter = lbAdd[KEGs_cLBCameras, "Filter Unknown/Dead"];

KEGs_tgtIdx = 0;
KEGs_cameraIdx = 0;
showCinemaBorder false;
lbClear KEGs_cLBTargets;
onMapSingleClick "[""MapClick"",_pos] call spectate_events";

//["EventLogAdd",["Initialize",[1,1,1,1]]] call spectate_events;

/*
// Check for client side addon
_foo = "KEGsAddon10" createVehicleLocal[-1000,-1000,0];
//_foo = "KEGspect_bar_yellow" createVehicleLocal[-1000,-1000,0];
if(!isNull _foo) then {
	deletevehicle _foo;
	KEGsClientAddonPresent = true;	
};
*/

// Spawn thread to display help reminder after a few seconds
[] spawn {sleep(3);if(dialog) then {cutText["\n\n\n\n\nPress F1 for help","PLAIN DOWN", 0.75]}};

KEGs_camSelLast = 0;
//KEGs_tgtSelLast = 0; // Moved up
mouseLastX = 0.5;
mouseLastY = 0.5;
_nNoDialog = 0;
lastCheckNewUnits = -100;
_lastUpdateMarkers = -100;
_lastUpdateMarkerTypes = -100;
_lastUpdateTags = -100;
KEGs_lastAutoUpdateLB = time;
KEGsCamPos = [0,0,0];
KEGs_cxpos = 0;
KEGs_cypos = 0;
KEGs_czpos = 0;
KEGs_cspeedx = 0;
KEGs_cspeedy = 0;
KEGs_tbase = 0.1;
KEGs_hi = 2;



// Initialize the arrays and the listboxes.
CheckNewUnits = {

			//diag_log format ["CheckNewUnits start: %1", KEGs_target];

			private["_vm_CheckNewUnitsNumber"];
			CheckNewUnitsReady = false;
			RefreshListReady = false;
			_vm_CheckNewUnitsNumber = vm_count;
			_allUnits = allUnits;
			//_allVehicles = Vehicles;
			
			// Avoid game logic
	
			_newUnits = _allUnits - deathCam;	
			/*
			if (count _allVehicles > 0) then {
				// Add event handlers to new vehicles
				_ehVehicles = _allVehicles;
				{
					// Add fired eventhandler for map indication
					_nn = _x getVariable "KEGsEHfired";
					if (isNil "_nn") then {
						_fh = _x addeventhandler["fired", {["UnitFired",_this] call spectate_events}];
						_x setVariable["KEGsEHfired", _fh];
					};
				} foreach _allVehicles;
			};			
			*/
			if(count _newUnits > 0) then 
			{
				_waitUnits = [];
				{
					if ( _x getVariable ["KEG_SPECT", false] ) then
					{
						// If variable not found, set it, thus unit is tagged for next update cycle
						// This way, (re)spawned units have some time to fully initialize. Name arma.rpt Error fix.
						_x setVariable ["KEG_SPECT", true];
						_waitUnits set [(count _waitUnits ),_x]; // _waitUnits = _waitUnits + [_x];
					};
					
					// In an effort to compensate for Renegades (players with ratings of less than -2000) we will add this Renegage fix
					//Renegade Fix - ViperMaul
					_x call VM_CheckOriginalSide;
					
				} forEach _newUnits;
				
				_newUnits = _newUnits - _waitUnits;			

				// Add new units to end of list
				deathCam = deathCam + _newUnits;
				
				// Request listbox update
				KEGsNeedUpdateLB = true;
				
				// Create markers
				{
					//if ( isNil "_markers" ) then { _markers = [] };
					
					// Create marker
					_m = createMarkerLocal[format["KEGsMarker%1", count _markers], (player modelToWorld [0,0,0]) ];
					_m setMarkerTypeLocal "mil_dot";			
					_m setMarkerSizeLocal[0.4, 0.4];
					_markers set [(count _markers),_m]; // _markers = _markers + [_m];
					
					_OriginalSide = _x call VM_CheckOriginalSide;  
					
					// Set marker color
					if(_OriginalSide == west) then {_m setMarkerColorLocal "ColorBlue";};
					if(_OriginalSide == east) then {_m setMarkerColorLocal "ColorRed";};
					if(_OriginalSide == resistance) then {_m setMarkerColorLocal "ColorGreen";};
					if(_OriginalSide == civilian) then {_m setMarkerColorLocal "ColorWhite";};			
					
					// Create particle source
					_s = "#particlesource" createVehicleLocal (_x modelToWorld [0,0,1]);
	////				_s = "#particlesource" createVehicleLocal [(random 15),(random 15),1];
	////				_s attachTo [_x, [0,0,2]];
					
					KEGsTagSources set [(count KEGsTagSources) , [_x, _s]]; //KEGsTagSources = KEGsTagSources + [[_x, _s]];	
					
					//if (isPlayer _x ) then { diag_log format ["KEGsEH: %1", count KEGsTagSources] }; 
					
					// create awareness status tag info
					if !(isPlayer _x) then 
					{
						_s = "#particlesource" createVehicleLocal getPos vehicle _x;
						KEGsTagStatSources set [(count KEGsTagStatSources) , [_x, _s]]; //KEGsTagSources = KEGsTagSources + [[_x, _s]];
					//}
					//else
					//{
						//_KEGs_EH_Indx = _x addEventHandler ["Killed", "deleteVehicle _s; diag_log format ['KEGsEH A: %1', count KEGsTagSources]; KEGsTagSources = KEGsTagSources - [_x, _s]; diag_log format ['KEGsEH B: %1', count KEGsTagSources];" ];
					//	_KEGs_EH_Indx = _x addEventHandler ["Killed", format ["deleteVehicle %1; KEGsTagSources = KEGsTagSources - [%2, %1];", _s, _x] ];
					//	KEGsEHlist set [(count KEGsEHlist), [_x, _KEGs_EH_Indx]];
					//	diag_log format ["KEGsEHlist: %1", KEGsEHlist];	
					};
					
				} forEach _newUnits;

				// If tags are on, turn them off and back again to include new units
//				if(KEGsTags) then {
//					["ToggleTags",[false, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
//					["ToggleTags",[true, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
//				};					
			};
			
			RefreshListReady = true;
			CheckNewUnitsReady = true;	
			lastCheckNewUnits = time;
		  };  // End of Spawn CheckNewUnits
		  

		
RefreshPlayerList = compile preprocessFileLineNumbers "spectator\RefreshPlayerList.sqf";
FreeLookMovementHandler = compile preprocessFileLineNumbers "spectator\FreeLookMovementHandler.sqf";
CameraMenuHandler = compile preprocessFileLineNumbers "spectator\CameraMenuHandler.sqf";
PlayerMenuHandler = compile preprocessFileLineNumbers "spectator\PlayerMenuHandler.sqf";
KEGsShowCombatMode = compile preprocessFileLineNumbers "spectator\specta_combatmode.sqf";

KEGs_fnc_camMove = 
{
	_dX = _this select 0;
	_dY = _this select 1;
	_dZ = _this select 2;
	
	//--- Nelson's solution for key lag
	_coef = 0.1;
	_zCoef = 0.1;
	if (KEGs_CTRL_PRESS && { (_dZ == 0) } ) then {_coef = 10; _zCoef = 3; }; //press left ctrl key for turbo speed
	if (KEGs_ALT_PRESS) then {_coef = 2.5;  _zCoef = 0.5; }; //press left alt key to increase speed


	_pos = getPosASL KEGscam_free;
	_dir = (direction KEGscam_free) + _dX * 90;
	_camPos = [
		(_pos select 0) + ((sin _dir) * _coef * _dY),
		(_pos select 1) + ((cos _dir) * _coef * _dY),
		(_pos select 2) + _dZ * _zCoef * (abs(((getPosATL KEGscam_free) select 2) + 0.001379)/5) 
	];
	
	//_debugPlayer globalChat format ["%1", ( (abs (getPosATL KEGscam_free select 2)/50))];
	
	_camPos set [2,(_camPos select 2) max ((getTerrainHeightASL _camPos) + 1)];
	KEGscam_free setPosASL _camPos;
};

KEGs_fnc_MovementCameraLoop = 
	{

		private ["_bb", "_foo", "_l", "_w", "_name", "_targetSpeed", "_KEGs_targetPos", "_checkTarget", "_hstr", "_d", "_z", "_cMapFull", "_camMove", "_comSpeed", "_coef", "_zCoef", "_camPos", "_dX", "_dY", "_dZ", "_dir", "_pos"  ];
		_cMapFull = 55014;
		vm_MovementCameraLoop_count = 0;

		KEGsNextRun = true;
		
		While { VM_SpectatorCamerasEnabled  } do 
		{

//if (KEGsNextRun) then {
//	diag_log format ["next movement loop start: %1", KEGs_target];
	//KEGsRunAbort = false; 
//};
			
			KEGsNextRun = true;
		
			//while { !( (isPlayer KEGs_target) || { (alive KEGs_target) } ) && { KEGsNextRun } } do  
			while { ( ( !(isPlayer KEGs_target) || ((isPlayer KEGs_target) && { (alive KEGs_target) } )) && { KEGsNextRun } ) } do  
			{
			
		//	if ( KEGsRunAbort ) then 
		//	{
		//		diag_log format ["next movement loop new target: %1", KEGs_target];
				//KEGsRunAbort = true; 
		//	};
				//_KEGs_targetAtStart = KEGs_target;
		//diag_log format ["1 - KEGs_targetAtStart = '%1' KEGs_target = '%2'", _KEGs_targetAtStart, KEGs_target];
				
				//_checkTarget = true;

				//while { ( alive KEGs_target ) && _checkTarget } do
				//{
					// Get target properties
					_bb = boundingBoxReal vehicle KEGs_target;					
					_targetSpeed = speed vehicle KEGs_target;
					_name = name KEGs_target;
					//_KEGs_targetPos = getPosATL KEGs_target;
				//	_checkTarget = false;
				//};
				
				//if ( isNil "_KEGs_targetPos" ) then 
				//{
				//	KEGs_target = player;
				//	_bb = boundingBox vehicle KEGs_target;
				//	_targetSpeed = speed vehicle KEGs_target;
				//	_KEGs_targetPos = getPosATL KEGs_target;
					
				//};
				
			//	_foo = ((_bb select 1) select 2) - ((_bb select 0) select 2); // Height
			//	_l = ((_bb select 1) select 1) - ((_bb select 0) select 1); // Length
			//	_w = ((_bb select 1) select 0) - ((_bb select 0) select 0); // Width

				_foo = 2;
				_l = 2;
				_w = 2;
	
				//player sideChat format ["BB: %1 - %2 - %3 - %4", round _foo, round _l, round _w, _bb];
	
	
				_hstr = 0.15;		
				KEGs_hi = abs ((_foo*_hstr)+(KEGs_hi*(1-_hstr)));
							
				// Free camera, user rotates camera around target
				_d = (-(_l*(0.3 max sdistance)));
				_z = sin(fangleY)*(_l*(0.3 max sdistance));
				KEGscam_lockon camSetRelPos[(sin(fangle)*_d)*cos(fangleY), (cos(fangle)*_d)*cos(fangleY), _z];
				KEGscam_lockon camCommit 0;
				
				if (KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
				{				
					if(KEGsCamForward) then 
					{
						[0,1,0] call KEGs_fnc_camMove;
						KEGsCamForward = false;
					};
					if(KEGsCamBack) then 
					{
						[0,-1,0] call KEGs_fnc_camMove;
						KEGsCamBack = false;
					};
					if(KEGsCamLeft) then 
					{
						[-1,1,0] call KEGs_fnc_camMove;
						KEGsCamLeft = false;
					};
					if(KEGsCamRight) then 
					{
						[1,1,0] call KEGs_fnc_camMove;
						KEGsCamRight = false;
					};
					if(KEGsCamUp) then 
					{
						//_debugPlayer globalChat format ["UP"];
						[0,0,1] call KEGs_fnc_camMove;
						KEGsCamUp = false;
					};
					if(KEGsCamDown) then 
					{
						//_debugPlayer globalChat format ["DOWN"];
						[0,0,-1] call KEGs_fnc_camMove;
						KEGsCamDown = false;
					};

					KEGS_camMarker setMarkerPosLocal position KEGscam_free;
					KEGS_camMarker setMarkerDirLocal direction KEGscam_free;
					//KEGS_camMarker setmarkerposlocal position KEGscam_free;
					//KEGS_camMarker setmarkerdirlocal direction KEGscam_free;
				};

	//diag_log format ["2 - KEGs_targetAtStart = '%1' KEGs_target = '%2'", _KEGs_targetAtStart, KEGs_target];			
				// Set targets for all cameras
	//			KEGs_cxpos = _KEGs_targetPos select 0;
	//			KEGs_cypos = _KEGs_targetPos select 1;
	//			KEGs_czpos = (_KEGs_targetPos select 2) + 1.5;
				
				KEGs_cxpos = (vehicle KEGs_target modelToWorld [0,0,0]) select 0;
				KEGs_cypos = (vehicle KEGs_target modelToWorld [0,0,0]) select 1;
				KEGs_czpos = (vehicle KEGs_target modelToWorld [0,0,0]) select 2;
				
	//diag_log format ["3 - KEGs_targetAtStart = '%1' KEGs_target = '%2'", _KEGs_targetAtStart, KEGs_target];		
				//_comSpeed = 1.0 - ((speed vehicle KEGs_target)/70);	
				_comSpeed = 1.0 - (_targetSpeed/70);	
				if(_comSpeed < 0.0) then {_comSpeed = 0.0;};
	//diag_log format ["4 - KEGs_targetAtStart = '%1' KEGs_target = '%2'", _KEGs_targetAtStart, KEGs_target];		
				if((vehicle KEGs_target) distance KEGscam_chase > 850) then {_comSpeed = 0}; // Jump immediately to distant target
				if((vehicle KEGs_target) distance KEGscam_chase > 850) then {_comSpeed = 0}; // Jump immediately to distant target
				if((vehicle KEGs_target) distance KEGscam_lockon > 850) then {_comSpeed = 0}; // Jump immediately to distant target
				
				KEGscam_target camSetPos[KEGs_cxpos, KEGs_cypos, KEGs_czpos+(KEGs_hi*0.7)];
				//_KEGs_dir = direction vehicle KEGs_target;			
				//KEGscam_target setDir _KEGs_dir;
				
				KEGscam_chase camSetTarget KEGscam_target;				
				KEGscam_lockon camSetTarget KEGscam_target; //[KEGs_cxpos, KEGs_cypos, KEGs_czpos+(KEGs_hi*0.6)];	
				
				//KEGscam_free camSetTarget[KEGs_cxpos, KEGs_cypos, KEGs_czpos+(KEGs_hi*0.6)];
				
		//		KEGscam_flyby camSetTarget KEGscam_target;	
		//		KEGscam_topdown camSetTarget[KEGs_cxpos, KEGs_cypos, KEGs_czpos+(KEGs_hi*0.6)];	
				{_x camSetFov szoom} foreach KEGs_cameras;		
			
				// Static camera, follows unit from behind
				if (isnil "KEGs_dir") then {KEGs_dir = 0}; 
				//KEGs_dir = direction vehicle KEGs_target;
				KEGs_dir = direction KEGs_target;
				KEGscam_chase camSetRelPos[sin(KEGs_dir)*(-(_l*sdistance)), cos(KEGs_dir)*(-(_l*sdistance)), 0.6*abs sdistance];
		/*		
				// Flyby camera, no user control except zoom
				if(_KEGs_target distance KEGscam_flyby > (KEGs_flybydst*1.1)) then {
					KEGs_flybydst = 20+(speed vehicle _KEGs_target);
					KEGscam_flyby camSetRelPos[sin(KEGs_dir)*KEGs_flybydst, cos(KEGs_dir)*KEGs_flybydst, 1+((random KEGs_hi)*1.5)];
					KEGscam_flyby camCommit 0;	
					KEGscam_target camCommit 0;	
				};
		
				// Top-down camera
				KEGscam_topdown camSetRelPos[0.0, -0.01, 2+((0 max sdistance)*15)];
				KEGscam_topdown camCommit 0;	
		*/	

				// Commit static and flyby cameras
				
				KEGscam_chase camCommit _comSpeed/2;
				KEGscam_target camCommit _comSpeed/3;
				//KEGscam_flyby camCommit _comSpeed;
				
				//sleep 0.04;
				
				KEGsNextRun = false;
			};
			
			//player target got killed		
			if  ( ( (isNull KEGS_target) || { !(alive KEGs_target) } ) && KEGsNextRun ) then 
			{
				private ["_newCheckUnits", "_foundPlayer"];
				
				//KEGsRunAbort = true; 
				
				// if current KEGsTarget is player and dies we need to get rid of the Tags, else the client will crash...
				{deletevehicle (_x select 1)} foreach KEGsTagSources;
				KEGsTagSources = [];
				
				diag_log format ["Player killed: %1 - %2  - ('%3')", diag_frameno, _name, KEGs_target];
				
	//			KEGsTags = false;
	//			KEGsTagsStat = false;
	//			["ToggleTags",[false]] call spectate_events;
	//			["ToggleTagsStat",[false]] call spectate_events;
				
				//sleep 0.3;
				//_newCheckUnits = allUnits - deathCam;
				_foundPlayer = false; 
				while { !_foundPlayer } do 
				{	
					sleep 0.08;				
					{
						if ( ( (name _x) == _name ) && ( alive _x ) ) then 
						{
							KEGs_target = _x;
							_foundPlayer = true; 
							diag_log format ["found killed player: %1 - %2", diag_frameno, _x];
						};
						//if ( ( (name _x) == _name ) && !( alive _x ) ) then 
						//{
							//diag_log format ["killed player not alive yet: %1 - %2 - ('%3')", diag_frameno, KEGs_target, _x];
						//};						
					} forEach allUnits;					
				};
				
				// recreate Tags again
				{
					_s = "#particlesource" createVehicleLocal (_x modelToWorld [0,0,1]);
					//_s = "#particlesource" createVehicleLocal [(random 15),(random 15),1];
					//_s attachTo [_x, [0,0,2]];
					KEGsTagSources set [(count KEGsTagSources) , [_x, _s]]; 
				} forEach allUnits;
				
				//sleep 1;
				//KEGs_target = deathCam select ((count deathCam) -1);
				
				//diag_log format ["Player killed: %1 - %2 - ('%3')", diag_frameno, KEGs_target, name KEGs_target];
	//KEGs_tgtSelLast = 0;
	[] call RefreshPlayerList;
				
				//If tags are on, turn them off and back again to adjust for killed player
				//NOTE: might be needed also for killed AI -> would need killed eventhandler to execute this code
				//if(KEGsTags) then 
				//{
				//	["ToggleTags",[false, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
				//	["ToggleTags",[true, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
				//};
			};
		};
	};		
// end MovementCameraLoop
	
call 
	{
		
			lastCheckNewUnits = time;
			
//			player setVariable ['BIS_IS_inAgony',false];
			
//			"dynamicBlur" ppEffectAdjust [0];
//			"dynamicBlur" ppEffectCommit 0.0;
//			"dynamicBlur" ppEffectEnable false;
			
			// Avoid game logics
			_allUnits = allUnits;
			//_allVehicles = Vehicles;
			_newUnits = _allUnits - deathCam;	
	
	/*	
			if (count _allVehicles > 0) then {
				// Add event handlers to new vehicles
				_ehVehicles = _allVehicles;
				{
					// Add fired eventhandler for map indication
					_nn = _x getVariable "KEGsEHfired";
					if (isNil "_nn") then {
						_fh = _x addeventhandler["fired", {["UnitFired",_this] call spectate_events}];
						_x setVariable["KEGsEHfired", _fh];
					};
				} foreach _allVehicles;
			};
	*/		
			if(count _newUnits > 0) then 
			{
				_waitUnits = [];
				{
					//if ((format["%1", _x getVariable "KEG_SPECT"]) != "true") then
					if !( _x getVariable ["KEG_SPECT", false] ) then 
					{
						// If variable not found, set it, thus unit is tagged for next update cycle
						// This way, (re)spawned units have some time to fully initialize. Name arma.rpt Error fix.
						_x setVariable ["KEG_SPECT", true];
						_waitUnits set [(count _waitUnits ),_x];
					};
					
					// In an effort to compensate for Renegades (players with ratings of less than -2000) we will add this Renegage fix
					//Renegade Fix - ViperMaul
					_x call VM_CheckOriginalSide;
					
				} forEach _newUnits;
				// _newUnits = _newUnits - _waitUnits;	// this line is not needed for the initialization  -ViperMaul
				
				// Add new units to end of list
				deathCam = deathCam + _newUnits;
				
				// Request listbox update
				KEGsNeedUpdateLB = true;
				
				// Create markers
				{ 
					// Crete marker
					_m = createMarkerLocal[format["KEGsMarker%1", count _markers], (player modelToWorld [0,0,0]) ];
					_m setMarkerTypeLocal "mil_dot";			
					_m setMarkerSizeLocal[0.4, 0.4];
					_markers set [(count _markers),_m];
					
					_OriginalSide = _x call VM_CheckOriginalSide;  
					
					// Set marker color
					if(_OriginalSide == west) then {_m setMarkerColorLocal "ColorBlue";};
					if(_OriginalSide == east) then {_m setMarkerColorLocal "ColorRed";};
					if(_OriginalSide == resistance) then {_m setMarkerColorLocal "ColorGreen";};
					if(_OriginalSide == civilian) then {_m setMarkerColorLocal "ColorWhite";};			
					
					// Create particle source
					//_s = "#particlesource" createvehiclelocal (_x modelToWorld [0,0,0]);
					//KEGsTagSources set [(count KEGsTagSources) , [_x, _s]]; //KEGsTagSources = KEGsTagSources + [[_x, _s]];
					
					_s = "#particlesource" createVehicleLocal (_x modelToWorld [0,0,1]);
					//_s = "#particlesource" createVehicleLocal [(random 15),(random 15),1];
					//_s attachTo [_x, [0,0,2]];
					
					KEGsTagSources set [(count KEGsTagSources) , [_x, _s]]; 
					
					
					// create awareness status tag info
					if !(isPlayer _x) then 
					{
						_s = "#particlesource" createVehicleLocal getpos vehicle _x;
						KEGsTagStatSources set [(count KEGsTagStatSources) , [_x, _s]]; //KEGsTagSources = KEGsTagSources + [[_x, _s]];
					//}
					//else
					//{
						//_KEGs_EH_Indx = _x addEventHandler ["Killed", { deleteVehicle _s; KEGsTagSources = KEGsTagSources - [_x, _s] } ];
						//_KEGs_EH_Indx = _x addEventHandler ["Killed", "deleteVehicle _s; diag_log format ['KEGsEH A: %1', count KEGsTagSources]; KEGsTagSources = KEGsTagSources - [_x, _s]; diag_log format ['KEGsEH B: %1', count KEGsTagSources];" ];
					//	_KEGs_EH_Indx = _x addEventHandler ["Killed", format ["deleteVehicle %1; KEGsTagSources = KEGsTagSources - [%2, %1];", _s, _x] ];
					//	KEGsEHlist set [(count KEGsEHlist), [_x, _KEGs_EH_Indx]];
					//	diag_log format ["KEGsEHlist: %1", KEGsEHlist];						
					};								
					
					// If tags are on, turn them off and back again to include new units
					//if(KEGsTags) then 
					//{
					//	["ToggleTags",[false, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
					//	["ToggleTags",[true, (KEGs_cameras select KEGs_cameraIdx)]] call spectate_events;
					//};					
				} forEach _newUnits;						
			};
			
			[] call RefreshPlayerList;
			["Init"] call CameraMenuHandler;
			[true] call PlayerMenuHandler;
			
			if(count deathCam > 0 and !KEG_Spect_Init) then 
			{ 
				KEG_Spect_Init = true; 
				VM_SpectatorCamerasEnabled = true; 
			};
			
			//_KEGs_target = deathCam select KEGs_tgtIdx;  // reset camera to the new or current player target
		   //(KEGs_cameras select KEGs_cameraIdx) cameraEffect["internal", "BACK"];
		   
		   //VM_CurrentCameraView = cameraView;
		   
			//diag_log format ["specta start: %1", KEGs_target];

		   [] spawn KEGs_fnc_MovementCameraLoop; 
		
	};

EndLoadingScreen;		

		
		
while{ dialog } do {


	// If ((player getVariable "BIS_IS_inAgony") == true) then { player setVariable ['BIS_IS_inAgony',false]; };
//	player setVariable ['BIS_IS_inAgony',false];
//	"dynamicBlur" ppEffectAdjust [0];
//	"dynamicBlur" ppEffectCommit 0.0;
//	"dynamicBlur" ppEffectEnable false;
	
	

		// Request listbox update every 20 seconds to update dead units or jip player names (
		if(time - KEGs_lastAutoUpdateLB > 20 && (RefreshListReady) && (CheckNewUnitsReady)) then 
		{
			KEGs_lastAutoUpdateLB = time;
			KEGsNeedUpdateLB = true;
		};	
	
		if(KEGsNeedUpdateLB && RefreshListReady && (CheckNewUnitsReady)) then 
		{
			[] spawn RefreshPlayerList;
		};
	
		// Check for new units every 20 seconds
		if((time - lastCheckNewUnits > 20)  && (CheckNewUnitsReady) ) then 
		{
			lastCheckNewUnits = time;
			RefreshListReady = false;
			[] spawn CheckNewUnits;
		}; 
		// End of If statement for Checking New Units
		
			
			//ctrlSetText[_cDebug, format["%1", count _markers]];			
			
			// Update tag particlesources
			//if(time - _lastUpdateTags > (1/5)) then 
			if(time - _lastUpdateTags > 1) then 
			{
				_lastUpdateTags = time;
				//if(KEGsTags) then 
				//{
					["ToggleTags", [KEGsTags]] call spectate_events;
				//};
				
			};
			
			// Update markers 10fps
			_rate = 10; // modified from 15 - norrin/ViperMaul
			if(count _markers > 100) then {_rate = 5}; // Update large number of markers less often // modified from 7.5 - norrin/ViperMaul
			if(count _markers > 200) then {_rate = 0.5}; // Update large number of markers less often // added - norrin/ViperMaul
			
			if(time - _lastUpdateMarkers > (1/_rate)) then 
			{
				_lastUpdateMarkers = time;
			
				if (!NORRN_noMarkersUpdates) then //added check to remove marker updates - norrin
				{
					// setMarkerTypeLocal is very slow, call it only once per second
					_doMarkerTypes = false;
					if(time - _lastUpdateMarkerTypes > 1) then 
					{
						_lastUpdateMarkerTypes = time;
						_doMarkerTypes = true; // Allow update marker types
					};
					
					if(ctrlVisible _cMapFull) then 
					{
						// Position camera in the middle of full map, for sound and
						// smoother marker motion (distant objects appear less smooth)
						_mapFull = _disp displayctrl _cMapFull;
						_mappos = _mapFull posScreenToWorld[0.5, 0.5];
						KEGscam_fullmap camSetTarget _mappos;
						KEGscam_fullmap camSetRelPos [0, -1, 150];
						KEGscam_fullmap camCommit 0;
					};
					
					_markedVehicles = []; // Keep track of vehicles with markers to avoid multiple markers for one vehicle
					for "_i" from 0 to ((count _markers)-1) do 
					{
						_m = _markers select _i;
						_u = (deathCam select _i);
						_m setMarkerPosLocal ((vehicle _u modelToWorld [0,0,0]));
						
						_OriginalSide = _u getVariable ["KEG_OriginalSide", side _u]; 
						if(!((_OriginalSide) in KEGsShownSides)) then 
						{
							// We arent' supposed to show this side unit - hide marker
							if(_doMarkerTypes) then {_m setMarkerTypeLocal "empty"};
						}
						else 
						{ 				
							if(KEGsMarkerNames or KEGsMinimapZoom < 0.15) then 
							{
								// Set full screen map marker types - Also zoomed minimap
								if(ctrlVisible _cMapFull) then 
								{
									switch(KEGsMarkerType) do 
									{
										case 0: {	// No text
											_m setMarkerTextLocal "";
										};
										case 1: {	// Names
											if(alive (vehicle _u)) then {
												if(name (vehicle _u) != "Error: no unit") then {_m setMarkerTextLocal name ( _u)};
											};
										};
										case 2: {	// Types
											_m setMarkerTextLocal getText (configFile >> "CfgVehicles" >> format["%1", typeOf (vehicle _u)] >> "DisplayName");
										};
									};
								} 
								else 
								{
									// Minimap with detailed icons but no text
									_m setMarkerTextLocal "";
								};
								
								//if(KEGsClientAddonPresent) then 
								//{
									// With client side addon use better icons
								//	_type = getText(configFile >> "CfgVehicles" >> format["%1", typeOf (vehicle _u)] >> "simulation");
								//	_icon = "mil_arrow";
								//	switch(_type) do {
								//		case "tank": {_icon = "KEGsTank"};
								//		case "car": {_icon = "KEGsCar"};
								//		case "soldier": {_icon = "KEGsMan"};
								//		case "ship": {_icon = "KEGsShip"};
								//		case "airplane": {_icon = "KEGsPlane"};
								//		case "helicopter": {_icon = "KEGsHelicopter"};
								//		case "motorcycle": {_icon = "KEGsMotorcycle"};
								//		case "parachute": {_icon = "KEGsParachute"};
								//	};
								//	if(_doMarkerTypes) then {_m setMarkerTypeLocal _icon};
								//	_m setMarkerSizeLocal[0.42*KEGsMarkerSize, 0.42*KEGsMarkerSize];
								//}
								//else 
								//{
									// No client side addon - basic markers
									if(_doMarkerTypes) then {_m setMarkerTypeLocal "mil_arrow"};
									
									if(_u == vehicle _u) then 
									{
										_m setMarkerSizeLocal[0.33*KEGsMarkerSize, 0.27*KEGsMarkerSize];
									}
									else 
									{
										_m setMarkerSizeLocal[0.42*KEGsMarkerSize, 0.42*KEGsMarkerSize];
									};						
								//};
								
								_m setMarkerDirLocal (getdir (vehicle _u));
							} 
							else 
							{
								_m setMarkerTextLocal "";
								if(_doMarkerTypes) then 
								{
									_m setMarkerTypeLocal "mil_dot";
								};
								_m setMarkerSizeLocal[0.4,0.4];
							};		
						};
						
						if(not alive _u) then 
						{
							if(KEGsClientAddonPresent) then 
							{
								// Switch to darker color, cant use side since the unit is already dead
								if(getMarkerColor _m == "ColorBlue") then {_m setMarkerColorLocal "KEGsDarkBlue"};
								if(getMarkerColor _m == "ColorRed") then {_m setMarkerColorLocal "KEGsDarkRed"};
								if(getMarkerColor _m == "ColorGreen") then {_m setMarkerColorLocal "KEGsDarkGreen"};
								if(getMarkerColor _m == "ColorWhite") then {_m setMarkerColorLocal "KEGsGrey"};								
							} else {
								_m setMarkerColorLocal "ColorBlack"
							};
						};
						
						if(vehicle _u in _markedVehicles) then 
						{
							// This vehicle was already marked, hide marker
							_m setMarkerTypeLocal "Empty";
						} else {
							_markedVehicles set [(count _markedVehicles) , vehicle _u];  // _markedVehicles = _markedVehicles + [vehicle _u];
						};
					};	
				};
			// END OF added check to remove marker updates - norrin
				
				// Follow target with small map			
				_map = _disp displayctrl _cMap;
				ctrlMapAnimClear _map;
				if (KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
				{
					// Center on dropped camera position
					//_map ctrlMapAnimAdd[0.3, KEGsMinimapZoom, [KEGs_cxpos, KEGs_cypos,0]];
					_map ctrlMapAnimAdd[0.3, KEGsMinimapZoom, [getPos KEGscam_free  select 0, getPos KEGscam_free  select 1,0]];
					
				} else {
					// Center on target
					_map ctrlMapAnimAdd[0.3, KEGsMinimapZoom, visiblePosition KEGs_target];
				};
				ctrlMapAnimCommit _map;					

				// Check if target changed and center main map
				if(KEGs_tgtIdx != KEGs_lastTgt) then 
				{
					//diag_log format ["specta update map: %1 - %2 - %3", KEGs_target, KEGs_tgtIdx, KEGs_lastTgt];
			
					_map = _disp displayctrl _cMapFull;
					ctrlMapAnimClear _map;
					_map ctrlMapAnimAdd [0.2, 1.0, visiblePosition (deathcam select KEGs_tgtIdx)];
					ctrlMapAnimCommit _map;			
				};
			};
			

			

		KEGs_lastTgt = KEGs_tgtIdx;	 //capture the last target index for the player in focus	

		// Wait a moment. 125fps ought to be enough for everyone :-)
		_tt = time;
		sleep(1/125);
		KEGs_tbase = time-_tt;
		
		vm_count = vm_count + 1;
};

StartLoadingScreen ["EXITING SPECTATOR MODE..."];

VM_SpectatorCamerasEnabled = False;
// Dialog closed with esc key
titleText["","BLACK IN", 0.5];

// Destroy cameras, markers, particlesources, etc.
camDestroy KEGscam_target;
//camDestroy KEGscam_missile;
camDestroy KEGscam_fullmap;
//deletevehicle KEGscam_target;
//deletevehicle KEGscam_missile;
//deletevehicle KEGscam_fullmap;
{camDestroy _x} foreach KEGs_cameras;
{deletemarkerlocal _x} foreach _markers;	 
//deletevehicle _t;
//deletevehicle KEGs_dummy;
// camUseNVG false;
KEGsTags = false;
onMapSingleClick "";
{deletevehicle (_x select 1)} foreach KEGsTagSources;
KEGsTagSources = [];
{deletevehicle (_x select 1)} foreach KEGsTagStatSources;
KEGsTagStatSources = [];
{ (_x select 0) removeEventHandler ["killed", (_x select 1)] } forEach KEGsEHlist;
KEGsEHlist = [];
setViewDistance KEGsOrgViewDistance;
deletemarkerlocal KEGS_camMarker;

/*
// Remove eventhandlers TODO: does this work properly?
{
	_fh = _x getVariable "KEGsEHfired";
	//_kh = _x getVariable "KEGsEHkilled";
	if (! isnil "_fh") then {if(typeName _fh == "SCALAR") then {_x removeEventHandler["fired", _fh]}};
	//if(typeName _kh == "SCALAR") then {_x removeEventHandler["killed", _kh]};
} foreach _ehVehicles;
*/

// Create a butterfly for player to fly with
/*
_bpos = [(((vehicle KEGs_target)modelToWorld [0,0,0])  select 0)-5+random 10, (((vehicle KEGs_target) modelToWorld [0,0,0])  select 1)-5+random 10, 1];
// _bird = "ButterFlySpectator"createVehicle _bpos; //custom ButterFly for improved flight.
_bird = "ButterFly"createVehicle _bpos;
_bird setvelocity[0,0,5];
_bird setpos _bpos;
_bird switchCamera "INTERNAL";

_bird cameraEffect["terminate","FRONT"];
_bird camCommand "manual on";

camUseNVG false; setAperture -1; //  Reset NVGs

KEGsBird = _bird;
onMapSingleClick "KEGsBird setpos [_pos select 0, _pos select 1, 2];KEGsBird setvelocity[0,0,5];";

cutText["\n\n\n\n\nLand on ground to return to spectating\nClick at map to jump to location","PLAIN DOWN", 0.75];

// Wait until landed, delete bird & restart script
waitUntil{(_bird modelToWorld [0,0,0]) select 2 < 0.05 and speed _bird < 1};
onMapSingleClick "";*/


/*
if !( f_var_debugMode == 1 ) then {
	titleText["","BLACK OUT", 0.5];
	sleep(1);
};
*/

EndLoadingScreen;	

player switchCamera "INTERNAL";
player cameraEffect["terminate","FRONT"];

//if !(isnil "_bird") then {deletevehicle _bird};

//sleep 2;

//if (mcc_missionmaker == (name player)) exitWith {}; 


//if !( f_var_debugMode == 1 ) then {
//	[_player, _killer, "noWait"] execVM ("spectator\specta.sqf");
//};

