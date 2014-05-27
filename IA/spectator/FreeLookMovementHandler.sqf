//FreeLookMovementHandler = 
//{
	private ["_dX", "_dY"];

	//if ( KEGsRunAbort ) then {
	//	diag_log format ["freelook movement start: %1", KEGs_target];
	//};

	//_debugPlayer=objNull;
	//if ( f_var_debugMode == 1 ) then {
	//	_debugPlayer=player;
	//};
	
	// ----------------------------------------------------------------------------------------------------------------------------------------------------
	// Process mouse movement
	mouseDeltaX = mouseLastX - (KEGsMouseCoord select 0);
	mouseDeltaY = mouseLastY - (KEGsMouseCoord select 1);	
	
	if(!(KEGsMouseButtons select 0) and (KEGsMouseButtons select 1)) then {
		// Right mouse button - Adjust position
		fangle = fangle - (mouseDeltaX*360);
		fangleY=fangleY + (mouseDeltaY*180);
		if(fangleY > 89) then {fangleY = 89};
		if(fangleY < -89) then {fangleY = -89};
//player sideChat format ["Angle: %1 - %2", round fangle, round fangleY];		
	};
	if((KEGsMouseButtons select 0) and !(KEGsMouseButtons select 1)) then {
		// Left mouse button - Adjust distance
		sdistance = sdistance - (mouseDeltaY*10);
		if(sdistance > maxDistance) then {sdistance = maxDistance};
		if(sdistance < -maxDistance) then {sdistance = -maxDistance};		
	};	
	if(KEGsMouseScroll != 0) then {
		// Mouse scroll wheel - Adjust distance
		sdistance = sdistance - (KEGsMouseScroll*0.11);		
		KEGsMouseScroll = KEGsMouseScroll * 0.75;
		if(sdistance > maxDistance) then {sdistance = maxDistance};
		if(sdistance < -maxDistance) then {sdistance = -maxDistance};						
	};
	if((KEGsMouseButtons select 0) and (KEGsMouseButtons select 1)) then {
		// Both mousebuttons - Adjust zoom
		szoom = szoom - (mouseDeltaY*3);		
		if(szoom > minZoom) then {szoom = minZoom};
		if(szoom < maxZoom) then {szoom = maxZoom};

	};
		
	// ----------------------------------------------------------------------------------------------------------------------------------------------------			
	// Get target properties
	if (KEGs_cameraNames select KEGs_cameraIdx == "Free") then 
	{
		if(!(KEGsMouseButtons select 0) and (KEGsMouseButtons select 1)) then 
		{
			_dX = 0;
			_dY = 0;
			
			//player globalChat format ["[%1] - [%2]", mouseDeltaX,(KEGsMouseCoord select 0)];
			
			 if ( mouseDeltaX > 0 ) then {  _dX = mouseDeltaX * -100; };
			 if ( mouseDeltaX < 0 ) then {  _dX = mouseDeltaX * -100; };
			 
			 if ( mouseDeltaY > 0 ) then {  _dY = mouseDeltaY * 50; };
			 if ( mouseDeltaY < 0 ) then {  _dY = mouseDeltaY * 50; };
	
			_dX = _dX max -180 min +180;
			
			KEGscam_free_pitch = (KEGscam_free_pitch + _dY) max -90 min +90;

			KEGscam_free setdir (direction KEGscam_free + _dX);
			[KEGscam_free,KEGscam_free_pitch,0] call bis_fnc_setpitchbank;
		};
		
	};
				
	//VM_CommitDelay;
	mouseLastX = KEGsMouseCoord select 0;
	mouseLastY = KEGsMouseCoord select 1;
//};


