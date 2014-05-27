// "for Spectating Script";
// "Handles events such as keyboard keypresses";
// "by Kegetys <kegetys [ät] dnainternet.net>";

_type = _this select 0;
_param = _this select 1;

//if ( KEGsRunAbort ) then 
//{
//	diag_log format ["event start: %1 - %2 - %3", KEGs_target, _type, _param];
//};

_cCamera = 55002;
_cTarget = 55003;
_cName = 55004;
KEGs_cLBCameras = 55005;
KEGs_cLBTargets = 55006;
_cCamerasBG = 55007;
_cTargetsBG = 55008;
_cBG1 = 55009;
_cBG2 = 55010;
_cTitle = 55011;
_cHelp = 55012;
_cMap = 55013;
_cMapFull = 55014;
_cMapFullBG = 55015;
_cEventLog = 50016;
_cDebug = 55100;
_UI = [_cCamera, _cTarget, _cName, KEGs_cLBCameras, KEGs_cLBTargets, _cCamerasBG, _cTargetsBG, _cBG1, _cBG2, _cTitle, _cHelp];

//player globalChat format ["event: %1", _this];

switch (_type) do 
{
	// "User clicked map, find nearest unit";
	case "MapClick": 
	{	
		_mapClickPos = _this select 1;
		
		if (KEGs_cameraNames select KEGs_cameraIdx == "Free") then  
		{
			_xx = _mapClickPos select 0;
			_yy = _mapClickPos select 1;
			KEGs_cxpos = _xx;
			KEGs_cypos = _yy;
						
			KEGscam_free setpos [_xx, _yy, (getPosATL KEGscam_free) select 2];
			
			KEGS_camMarker setmarkerposlocal position KEGscam_free;
			KEGS_camMarker setmarkerdirlocal direction KEGscam_free;
				
			if(ctrlVisible _cMapFull) then 
			{
				ctrlShow[_cMapFull, false];
				ctrlShow[_cMapFullBG, false];			
				0.5 fadeSound KEGsSoundVolume;
				ctrlShow[_cMap, true];
			};
		}
		else
		{
			_newCamTarget = (nearestObjects [_mapClickPos, ["CAManBase", "Air", "Car", "Tank"], 200]) select 0;
			//player globalChat format ["new target '%1' - curr target '%2' - ('%3') - ('%4')", _newCamTarget, KEGs_target, vehicle _newCamTarget, deathCam find _newCamTarget];			

			if ( !( isNull _newCamTarget ) && { ( vehicle _newCamTarget == _newCamTarget ) } ) then 
			{
				//player globalChat format ["Crew: '%1' - '%2'", _newCamTarget, crew _newCamTarget];			
				_newCamTarget = (crew _newCamTarget) select 0;
			};
			
			if ( !( isNull _newCamTarget ) && { !((deathCam find _newCamTarget) == -1) } ) then
			{
				//KEGs_tgtIdx = ([deathCam, _newCamTarget] call BIS_fnc_arrayFindDeep) select 0;			
				KEGs_tgtIdx = deathCam find _newCamTarget;
				
				KEGs_target = _newCamTarget;
								
				KEGs_cxpos = getPos KEGs_target select 0;
				KEGs_cypos = getPos KEGs_target select 1;

				KEGscam_free setpos [KEGs_cxpos, KEGs_cypos, (getPosATL KEGscam_free) select 2];
				
				KEGS_camMarker setmarkerposlocal position KEGscam_free;
				KEGS_camMarker setmarkerdirlocal direction KEGscam_free;
				
				// adjust target name bottom left
				[false] spawn PlayerMenuHandler;
				
				//player sideChat format ["new target '%1' - curr target '%2' - ('%3' - '%4')", _newCamTarget, KEGs_target, KEGs_tgtIdx, deathCam select KEGs_tgtIdx];			
				
				if(ctrlVisible _cMapFull) then 
				{
					ctrlShow[_cMapFull, false];
					ctrlShow[_cMapFullBG, false];			
					0.5 fadeSound KEGsSoundVolume;
					ctrlShow[_cMap, true];
				};
			};
		};
	};
	
	case "KeyDown": 
	{		
		_key = _param select 1;
		
		//player globalChat format ["KEY: %1", _param];
		// "WSAD keys: camera movement in dropped mode";
		switch(_key) do 
		{		
			case 32: { 
				// D
				KEGsCamRight = true;
			};	
			case 30: { 
				//A
				KEGsCamLeft = true;
			};
			case 17: { 
				// W
				KEGsCamForward = true;
			};	
			case 31: { 
				// S
				KEGsCamBack = true;
			};
			case 16: { 
				// Q
				KEGsCamUp = true;
			};
			case 44: { 
				// Z
				KEGsCamDown = true;
			};
			
			case 35: { 
				// H
				if (NORRN_noMarkersUpdates) then 
				{
					NORRN_noMarkersUpdates = false;
					titleCut ["\n\n\n\n\n\n\n\n\nMap Marker Updates Enabled","PLAIN", 0.2];
				} else {
					NORRN_noMarkersUpdates = true;
					titleCut ["\n\n\n\n\n\n\n\n\nMap Marker Updates Disabled","PLAIN", 0.2];
				};
			};
			case 56: { 
				//ALT
				KEGs_ALT_PRESS = true;
			};
			case 29: { 
				// CRTL
				KEGs_CTRL_PRESS = true;
			};
		};
	}; 
	
	// "Key up - process keypress";
	case "KeyUp": 
	{
		_key = _param select 1;
		switch(_key) do 
		{
			case 32: {
				// D
				if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
				{
					//Next target
					//KEGs_tgtIdx = (( KEGs_tgtIdx + 1 ) min ( (count deathCam) - 2 ));
					KEGs_tgtIdx = ( KEGs_tgtIdx + 1 );
					if ( KEGs_tgtIdx > ((count deathCam) - 2 ) ) then { KEGs_tgtIdx = 0 };
				
					KEGs_target = deathCam select KEGs_tgtIdx;

					[false] spawn PlayerMenuHandler;
					
					KEGs_cxpos = getPos KEGs_target select 0;
					KEGs_cypos = getPos KEGs_target select 1;
					KEGscam_free setPos [KEGs_cxpos, KEGs_cypos, (getPosATL KEGscam_free) select 2];
				};
				KEGsCamRight = false;				
			};	
			case 30: {
				// A
				if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
				{
					 //Previous target
					//KEGs_tgtIdx = (( KEGs_tgtIdx - 1 ) max 0 );
					KEGs_tgtIdx = ( KEGs_tgtIdx - 1 );
					if ( KEGs_tgtIdx < 0 ) then { KEGs_tgtIdx =  ((count deathCam) - 2 ) };
					
					KEGs_target = deathCam select KEGs_tgtIdx; 
					[false] spawn PlayerMenuHandler;
					
					KEGs_cxpos = getPos KEGs_target select 0;
					KEGs_cypos = getPos KEGs_target select 1;
					KEGscam_free setPos [KEGs_cxpos, KEGs_cypos, (getPosATL KEGscam_free) select 2];
				};
				KEGsCamLeft = false;
			};
			case 17: {
				// W
				KEGsCamForward = false;
			};
			case 31: { 
				// S
				KEGsCamBack = false;
			};
			case 16: { 
				// Q
				KEGsCamUp = false;
			};
			case 44: { 
				// Z
				KEGsCamDown = false;
			};			
			case 46: {
				// "C = Next camera";
				//_debugPlayer sidechat format ["Old KEGs_cameraIdx %1, New KEGs_cameraIdx %2", KEGs_cameraIdx, (KEGs_cameraIdx + 1)];
				KEGs_cameraIdx = KEGs_cameraIdx + 1;
				//KEGs_cameraIdx = KEGs_cameraIdx % 3;
				KEGs_cameraIdx = KEGs_cameraIdx % (count KEGs_cameras);
				["Specta_Events"] call CameraMenuHandler;
				KEGsCamBack = false;
				
				fangle  = 0; // Free camera angle
				fangleY = 15;
			};
			case 20: {
				// "T = Toggle tags";
				if !( KEGs_CTRL_PRESS ) then 
				{
					KEGsTags = !KEGsTags;
					if(!KEGsTags) then {
						["ToggleTags", [false]] call spectate_events;
						lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTags, [1,1,1,0.33]];
					}
					else
					{
						["ToggleTags", [true]] call spectate_events;
						lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTags, [1, 0.5, 0, 1]];
					};
				}
				else
				{
					// Ctrl-T = Toggle Awareness Tags
					KEGsTagsStat = !KEGsTagsStat;
					if(!KEGsTagsStat) then {
						["ToggleTagsStat", [false]] call spectate_events;
						lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTagsStat, [1,1,1,0.33]];
					}
					else
					{
						["ToggleTagsStat", [true]] call spectate_events;
						lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTagsStat, [1, 0.5, 0, 1]];
					};
				};
			};
			
			case 33: {
				// "F = Toggle filter";
				KEGsAIfilter = !KEGsAIfilter;
				KEGsNeedUpdateLB = true;
			};			
			
			case 47: {
				// "V = Toggle viewdistance";
				if ( viewDistance >  KEGsOrgViewDistance ) then 
				{ 
					setViewDistance KEGsOrgViewDistance;					
				}
				else 
				{
					if ( KEGs_ALT_PRESS ) then 
					{
						setViewDistance (( 4 * KEGsOrgViewDistance) max 9000 min 14000);
					}
					else
					{
						setViewDistance KEGsTempViewDistance;
					};
				};
			};
			
			/*
			case 57: {
				// "Space - drop camera or toggle 1stperson/gunner"; _debugPlayer groupchat "Processing SpaceBar Event";
				if(KEGs_cameras select KEGs_cameraIdx == KEGscam_1stperson) then {
					KEGs1stGunner = !KEGs1stGunner;
				} else {
					KEGsDroppedCamera = !KEGsDroppedCamera;
					if(KEGsDroppedCamera) then {
						KEGs_cameraIdx = 0;
						_debugPlayer groupchat "DropCamera Activated";
					};
				};
				["Specta_Events"] spawn CameraMenuHandler;
			};
			*/
	
			// "Direct camera change with number keys";
			case 2: {KEGs_cameraIdx = 0; VM_CurrentCameraView = ""; _debugPlayer globalchat "key 1"; lbSetCurSel[KEGs_cLBCameras, KEGs_cameraIdx]; ctrlSetText[_cCamera, format["Camera: %1", KEGs_cameraNames select KEGs_cameraIdx]]; _debugPlayer sidechat format ["KEGs_cameraNames %1", KEGs_cameraNames];	 ["Specta_Events"] spawn CameraMenuHandler;};				
			case 3: {KEGs_cameraIdx = 1; VM_CurrentCameraView = ""; _debugPlayer globalchat "key 2"; lbSetCurSel[KEGs_cLBCameras, KEGs_cameraIdx]; ctrlSetText[_cCamera, format["Camera: %1", KEGs_cameraNames select KEGs_cameraIdx]];	["Specta_Events"] spawn CameraMenuHandler;};				
			case 4: {KEGs_cameraIdx = 2; VM_CurrentCameraView = ""; _debugPlayer globalchat "key 3"; lbSetCurSel[KEGs_cLBCameras, KEGs_cameraIdx]; ctrlSetText[_cCamera, format["Camera: %1", KEGs_cameraNames select KEGs_cameraIdx]];	["Specta_Events"] spawn CameraMenuHandler;};				
			//case 5: {KEGs_cameraIdx = 3; VM_CurrentCameraView = ""; _debugPlayer globalchat "key 4"; lbSetCurSel[KEGs_cLBCameras, KEGs_cameraIdx]; ctrlSetText[_cCamera, format["Camera: %1", KEGs_cameraNames select KEGs_cameraIdx]];	["Specta_Events"] spawn CameraMenuHandler;};				
			//case 6: {KEGs_cameraIdx = 4; VM_CurrentCameraView = ""; _debugPlayer globalchat "key 5";  lbSetCurSel[KEGs_cLBCameras, KEGs_cameraIdx];  ctrlSetText[_cCamera, format["Camera: %1", KEGs_cameraNames select KEGs_cameraIdx]]; ["Specta_Events"] spawn CameraMenuHandler;};
			
			// "Toggle NVG or map text type";
			case 49: {
				if(ctrlVisible _cMapFull) then 
				{
					KEGsMarkerType = KEGsMarkerType + 1;
					if(KEGsMarkerType > 2) then {KEGsMarkerType=0;};					
				}
				else 
				{
					KEGs_camera_vision = KEGs_camera_vision + 1;
					KEGs_camera_vision = KEGs_camera_vision % 4;
					
					//diag_log format ["SPECT set NV mode [%1]", KEGs_camera_vision]; 
					
					switch (KEGs_camera_vision) do 
					{
						case 0: {
							camusenvg false;
							false SetCamUseTi 0;
						};
						case 1: {
							camusenvg true;
							false SetCamUseTi 0;
						};
						case 2: {
							camusenvg false;
							true SetCamUseTi 0;
						};
						case 3: {
							camusenvg false;
							true SetCamUseTi 1;
						};
					};
				};
			};
			
			case 50: {["ToggleMap",0] call spectate_events;};
			case 15: {["ToggleUI",0] call spectate_events;};
			case 59: {["ToggleHelp",0] call spectate_events;};			
			
			// "Numpad + / -";
			case 78: {if(KEGsMarkerSize < 1.7) then {KEGsMarkerSize = KEGsMarkerSize * 1.15}};
			case 74: {if(KEGsMarkerSize > 0.7) then {KEGsMarkerSize = KEGsMarkerSize * (1/1.15)}};
			
			case 56: { 
				//ALT
				KEGs_ALT_PRESS = false;
			};
			case 29: { 
				// CRTL
				KEGs_CTRL_PRESS = false;
			};
		};
	}; 	
	
	// "Mouse events";
	case "MouseMoving": 
	{	
		//if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
		//{
			_x = _param select 1;
			_y = _param select 2;
			KEGsMouseCoord = [_x, _y];
			[] spawn FreeLookMovementHandler;
		//};
	};
		
	case "MouseButtonDown": 
	{
		//if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
		//{
			_x = _param select 2;
			_y = _param select 3;
			_button = _param select 1;
			KEGsMouseButtons set[_button, true];
		//};
	};
	
	case "MouseButtonUp": 
	{
		//if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
		//{
			_x = _param select 2;
			_y = _param select 3;
			_button = _param select 1;
			KEGsMouseButtons set[_button, false];
			[] spawn FreeLookMovementHandler;
		//};
	};	
	
	case "MouseZChanged": 
	{
	
		//player globalChat format ["CAMERA: [%1] - [%2]", KEGs_cameraNames select KEGs_cameraIdx, KEGs_cameraIdx];
	
		if !(KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
		{
			KEGsMouseScroll = KEGsMouseScroll + (_param select 1);
			[] spawn FreeLookMovementHandler; 
		}
		else
		{
			_camVector = vectordir KEGscam_free;

			_coef = 2;
			if (KEGs_CTRL_PRESS) then {_coef = 50;}; //press left ctrl key to turbo speed
			if (KEGs_ALT_PRESS) then {_coef = 10;}; //press left alt key to increase speed
			
			_dZ = (( _this select 1 ) select 1 ) * _coef;
			_vX = (_camVector select 0) * _dZ;
			_vY = (_camVector select 1) * _dZ;
			_vZ = 0; 

			_camPos = getPosASL KEGscam_free;
			_camPosL_z = (getPosATL KEGscam_free) select 2;
			_camPos = [
				(_camPos select 0) + _vX,
				(_camPos select 1) + _vY,
				(_camPos select 2) + _vZ
			];
			_camPos set [2,(getTerrainHeightASL _camPos) + _camPosL_z];
			KEGscam_free setPosASL _camPos;
		};
	};	

	case "MouseZChangedminimap": {
		KEGsMinimapZoom = ( KEGsMinimapZoom - ((_param select 1)*0.025) ) min 0.75 max 0.01;
		//if(KEGsMinimapZoom > 0.75) then {KEGsMinimapZoom=0.75};
		//if(KEGsMinimapZoom < 0.01) then {KEGsMinimapZoom=0.01};
	};			
		
	case "ToggleCameraMenu": {
		// "hide/unhide camera menu";
		if(ctrlVisible KEGs_cLBCameras) then {
			ctrlShow[KEGs_cLBCameras, false];
			ctrlShow[_cCamerasBG, false];
		} else {
			ctrlShow[KEGs_cLBCameras, true];
			ctrlShow[_cCamerasBG, true];
		};
	};
	
	case "ToggleTargetMenu": {
		// "hide/unhide targets menu";
		if(ctrlVisible KEGs_cLBTargets) then {
			ctrlShow[KEGs_cLBTargets, false];
			ctrlShow[_cTargetsBG, false];
		} else {
			ctrlShow[KEGs_cLBTargets, true];
			ctrlShow[_cTargetsBG, true];
		};
	};
	
	case "ToggleUI": {
		// "hide/unhide UI";
		if(ctrlVisible _cName) then {
			{ctrlShow[_x, false]} foreach _UI;
		} else {
			{ctrlShow[_x, true]} foreach _UI;
			ctrlShow[_cHelp, false];
			ctrlShow[KEGs_cLBTargets, false];
			ctrlShow[_cTargetsBG, false];			
			ctrlShow[KEGs_cLBCameras, false];
			ctrlShow[_cCamerasBG, false];			
		};
	};
		
	case "ToggleHelp": {
		// "hide/unhide Help text";
		if(ctrlVisible _cHelp) then {
			ctrlShow[_cHelp, false];
		} else {
			ctrlShow[_cHelp, true];
		};
	};

	case "ToggleMap": {
		// "hide/unhide Map";
		if(ctrlVisible _cMap and ctrlVisible _cMapFull) then {
			// "Beginning, hide both";
			ctrlShow[_cMap, false];
			ctrlShow[_cMapFull, false];			
			ctrlShow[_cMapFullBG, false];			
		};
		
		if(ctrlVisible _cMap) then {
			ctrlShow[_cMap, false];			
			ctrlShow[_cMapFull, true];
			ctrlShow[_cMapFullBG, true];			
			KEGsMarkerNames = true;
			KEGsSoundVolume = soundVolume;
			0.5 fadeSound 0.2;
		} else {
			KEGsMarkerNames = false;
			if(ctrlVisible _cMapFull) then {
				ctrlShow[_cMapFull, false];
				ctrlShow[_cMapFullBG, false];			
				0.5 fadeSound KEGsSoundVolume;
			} else {
				ctrlShow[_cMap, true];
			};
		};
	};
	
	// "Toggle particlesource tags";	
	case "ToggleTags": 
	{
		//private ["_clearKEGsTagSources"];
		
		//_clearKEGsTagSources = [];
		
		_lifeTime = 0.25;
		_dropPeriod = 0.05;
		//_size = 0.5;
		
		_part = "\a3\data_f\cl_water.p3d";
		//_part = "\A3\data_f\ParticleEffects\Universal\smoke.p3d";
		//if(KEGsClientAddonPresent) then {_part = "\KEGspect\tag.p3d"};
			
		//player globalChat format ["ToggleTags: [%1] - [%2]", _param, _this];
		
		// if current KEGsTarget is player and dies we need to get rid of the Tags, else the client will crash...
/*
		if ( KEGsRunAbort ) then 
		{
			//diag_log format ["Toggle: %1 - %2 - %3", diag_tickTime, (_param select 0), KEGsTags];
			{
				if !( alive (_x select 0)) then 
				{
					diag_log format ["Toggle: detach %1", _x select 1];
					detach (_x select 0);
					detach (_x select 1);
					_clearKEGsTagSources set [(count _clearKEGsTagSources), _x];	
					KEGsTagSources = KEGsTagSources - _clearKEGsTagSources;
				};
			} forEach KEGsTagSources;
		};
*/	
		{
			_u = _x select 0;
			_s = _x select 1;
			
			if ( KEGsTags && { !(isNull _u) } && { (alive _u) } )  then 
			{
			
				//if ( KEGsRunAbort ) then {
				//	diag_log format ["Toggle: %1 - %2 - %3 - %4", KEGs_target, _u, !(isNull _u), ( !(isNull _u) && { (alive _u ) } )];
				//};
				
				//_size = 1.5 min (1.5* (((vehicle _u) distance _cam)/100));
				_size = 5 min (5* (getPosATL (KEGs_cameras select KEGs_cameraIdx) select 2)/300) max 0.2;
				
				_color = [1,1,1,1];
				switch ( side _u ) do
				{
					case east: { _color = [1,0,0,1]; };
					case west: { _color = [0,0,1,1]; };
					case resistance: { _color = [0,1,0,1]; };
					default { _color = [1,1,1,1]; };
				};

				_colorB = [_color select 0, _color select 1, _color select 2, 0];

				_s setParticleParams[_part, "", "billboard", 1, _lifeTime, [0, 0, 2], [0,0,0], 1, 1, 0.784, 0.1, [_size, _size*0.66], [_color, _color, _color, _color, _colorB], [1], 10.0, 0.0, "", "", vehicle _u];
				_s setDropInterval _dropPeriod;
			}		
			else
			//turn off
			{
				if !( isNull _u) then 
				{
					//if ( KEGsRunAbort ) then {
					//	diag_log format ["Toggle OFF: %1 - %2 - %3 - %3", KEGs_target, _u, !(isNull _u), !( (isNull _u) && { !(alive _u) } )];
					//};
					_s setDropInterval 0;
				//}
				//else
				//{
					//diag_log format ["Toggle OFF is Null - detaching: %1 - %2 - %3", KEGs_target, _u, count KEGsTagSources];
					//deleteVehicle _s;
					//detach _s;
					//_clearKEGsTagSources set [(count _clearKEGsTagSources), _x];					
				};
			};
		} foreach KEGsTagSources;

		//KEGsTagSources = KEGsTagSources - _clearKEGsTagSources;
		//if ( KEGsRunAbort ) then {
		//	diag_log format ["Toggle OFF is Null after: %1 - %2 - $3", KEGs_target, count KEGsTagSources, _clearKEGsTagSources];
		//};
		
		//if(KEGsTags) then {lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTags, [1, 0.5, 0, 1]]} 
		//else {lbSetColor[KEGs_cLBCameras, KEGs_cLbToggleTags, [1,1,1,0.33]]};	
		
		//if ( KEGsRunAbort ) then {
		//	diag_log format ["Toggle ready"];
		//};
				
	};
	
	// "Toggle particlesource tags";	
	case "ToggleTagsStat": 
	{
	
	//player globalChat format ["ToggleTagsStat: [%1] - [%2]", _param, _this];
	
		if(_param select 0) then 
		{
			// "turn on";
			{
				_u = _x select 0;
				_s = _x select 1;
				

				[_u, _s] spawn KEGsShowCombatMode;
			/*
				_size = 1.5 min (1.5* (((vehicle _u) distance _cam)/100));
				
				_color = [1,1,1,1];
				if(side _u == east) then {_color = [1,0,0,1]};
				if(side _u == west) then {_color = [0,0,1,1]};
				if(side _u == resistance) then {_color = [0,1,0,1]};
				if(alive _u) then {
					_colorB = [_color select 0, _color select 1, _color select 2, 0];
	
					_s setParticleParams[_part, "", "billboard", 1, _lifeTime, [0, 0, 2], [0,0,0], 1, 1, 0.784, 0.1, [_size, _size*0.66], [_color, _color, _color, _color, _colorB], [1], 10.0, 0.0, "", "", vehicle _u];
					_s setDropInterval _dropPeriod;				
				} else {
					_s setDropInterval 0;				
				};
			*/
			} foreach KEGsTagStatSources;
		}
		else 
		{
			// "turn off";
			{
				_u = _x select 0;	
				_s = _x select 1;	
				if !(isNull _u) then 
				{
					_s setDropInterval 0;
				}
				else
				{
					deleteVehicle _s;
				};
			} foreach KEGsTagStatSources;
		};

		//if ( KEGsRunAbort ) then {
		//	diag_log format ["Toggle status ready"];
		//};
		
	};	

/*	
	// "Add string to event log";
	case "EventLogAdd": {
		_txt = _param select 0;
		_color = _param select 1;
		_i = lbAdd[_cEventLog, _txt];
		lbSetColor[_cEventLog, _i, _color];	
		lbSetCurSel[_cEventLog, _i];
	};
	
	// "Killed eventhandler, add to log";
	case "UnitKilled": {		
		_killed = _param select 0;
		_killer = _param select 1;
		_txt = format["%1 (%2) was killed by %3 (%4) (%5m)", _killed, side _killed, _killer, side _killer, _killed distance _killer];
		["EventLogAdd",[_txt,[1,1,1,1]]] call spectate_events;
	};
*/

/*	
	// "Fired eventhandler, display as marker in map";
	// "Also missile camera is handled here";
	case "UnitFired": 
	{				
		if(KEGsTags and KEGsClientAddonPresent) then {
			// "Bullet path bar";
			_u = _param select 0;
			_w = _param select 1;
			_a = _param select 4;
			_o = (getpos _u) nearestObject _a;
			
			_type = getText(configFile >> "CfgAmmo" >> format["%1", typeOf _o] >> "simulation");
			
			if(_type == "shotBullet") then {
				_bar = "KEGspect_bar_yellow";				
				if(side _u == west) then {_bar = "KEGspect_bar_red"};
				if(side _u == east) then {_bar = "KEGspect_bar_green"};
				
				_bars = [];
				for "_i" from 0 to 300 step 5 do {
					_pos = _o modelToWorld[0,_i+2.5,0];
					_b = _bar createVehicleLocal _pos;
					_b setVectorDir(vectorDir _o);
					_b setVectorUp(vectorUp _o);
					_bars set [(count _bars) , _b]; // _bars = _bars + [_b];
				};		
				_bars spawn {sleep 1.5;{deletevehicle _x} foreach _this};
			};
		};
		if(ctrlVisible _cMapFull) then {
			_u = _param select 0;
			_w = _param select 1;
			_a = _param select 4;
			_o = (getpos _u) nearestObject _a;
			_len = (speed _o)/15;
			KEGs_dir = getdir _o;
			// "Marker for shot effect (stationary circle)";
			_m2 = createMarkerLocal[format["KEGsMarkerFired%1", random 10000], getpos _o];
			_m2 setMarkerColorLocal "ColorYellow";
			_m2 setMarkerSizeLocal[0.45, 0.45];
			_m2 setMarkerTypeLocal "Select";
			
			_type = getText(configFile >> "CfgAmmo" >> format["%1", typeOf _o] >> "simulation");
			_name = getText(configFile >> "CfgWeapons" >> format["%1", _w] >> "displayName");
			
			// "Marker for round itself, for bullet display line, everything else a named marker";
			if(_type == "shotMissile" OR _type == "shotRocket" OR _type == "shotShell" OR _type == "shotTimeBomb" OR _type == "shotPipeBomb" OR _type == "shotMine" OR _type == "shotSmoke") then {
				_m = createMarkerLocal[format["KEGsMarkerFired%1", random 10000], [(getpos _o select 0)+(sin KEGs_dir)*_len, (getpos _o select 1)+(cos KEGs_dir)*_len, 0]];
				_m setMarkerTypeLocal "mil_dot";
				_m setMarkerColorLocal "ColorWhite";
				_m setMarkerSizeLocal[0.25,0.5];
				_m setMarkerTextLocal _name;
				_m2 spawn {sleep(2);deleteMarkerLocal _this};		
				[_m, _o] spawn {
					_m = _this select 0;
					_o = _this select 1;
					while{!isNull _o} do {
						_m setMarkerPosLocal getpos _o;
						_m setMarkerDirLocal getdir _o;
						sleep(1/50);
					};
					_m setMarkerColorLocal "ColorBlack";
					sleep(3);
					deleteMarkerLocal _m;
				};
			} else {
				_m = createMarkerLocal[format["KEGsMarkerFired%1", random 10000], [(getpos _o select 0)+(sin KEGs_dir)*_len, (getpos _o select 1)+(cos KEGs_dir)*_len, 0]];
				_m setMarkerShapeLocal "RECTANGLE";
				_m setMarkerSizeLocal[0.25,_len];
				_m setMarkerDirLocal (getdir _o);
				if(KEGsClientAddonPresent) then {
					_m setMarkerColorLocal "KEGsDarkYellow";
					[_m2, _m] spawn {sleep(1.0);(_this select 1) setMarkerColorLocal "KEGsYellowAlpha";sleep(1);deletemarkerLocal (_this select 1);deletemarkerLocal (_this select 0);};		
				} else {
					_m setMarkerColorLocal "ColorYellow";
					[_m2, _m] spawn {sleep(1.0);(_this select 1) setmarkerbrushLocal "grid";sleep(1);deletemarkerLocal (_this select 1);deletemarkerLocal (_this select 0);};		
				};
			}
		};
		
		// "Missile camera";			
		if(KEGsUseMissileCam and !KEGsDroppedCamera) then 
		{
			_u = _param select 0;
			_w = _param select 1;
			_a = _param select 4;
			_o = (getpos _u) nearestObject _a;
			
			_type = getText(configFile >> "CfgAmmo" >> format["%1", typeOf _o] >> "simulation");
			_name = getText(configFile >> "CfgWeapons" >> format["%1", _w] >> "displayName");
			
			if(_u == vehicle KEGs_target and (_type == "shotMissile" or _type == "shotRocket") and !KEGsMissileCamActive) then 
			{
				KEGsMissileCamActive = true;
				cutText[_name,"PLAIN DOWN", 0.10];
				KEGscam_missile switchCamera "INTERNAL";
				_debugPlayer globalchat "Line 398 KEGscam_missile switchCamera 'INTERNAL';";
				KEGscam_missile cameraEffect["internal", "BACK"];	
				KEGscam_missile camsettarget _o;
				KEGscam_missile camsetrelpos[0,0,0];
				KEGscam_missile camSetFov 0.5;
				KEGscam_missile camCommit 0;
				KEGscam_missile camSetFov 1.25;
				KEGscam_missile camCommit 2;
				_o spawn {
					while{!isNull _this and speed _this > 1} do {
						KEGscam_missile camsettarget _this;
						KEGscam_missile camsetrelpos[0,-0.1,0.20];
						KEGscam_missile camCommit 0;			
						sleep(0.01);			
					};
					sleep(3);
					KEGsMissileCamActive = false;
				};				
			};
		};
	};
*/
				
	default {
		hint "Unknown event";
	};
};

false
