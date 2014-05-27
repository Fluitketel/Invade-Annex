private ["_Source", "_debugPlayer", "_cName", "_cCamera", "_idx", "_found", "_role", "_name", "_ccName", "_disp", "_mode"];

//if ( KEGsRunAbort ) then {
//	diag_log format ["playermenuhandler start: %1", KEGs_target];
//};

//_Source = _this select 0;
//_mode = _this select 1;
//_debugPlayer=objNull;

//if ( f_var_debugMode == 1 ) then {
//	_debugPlayer=player;
//};

_cName = 55004;
_cCamera = 55002;
_name = ""; 

//if ( _mode == 0 ) then 
if ( _this select 0 ) then 
{
	/****************************************   PLAYER MENU HANDLING ***************************************************/

	if(lbCurSel KEGs_cLBTargets > lbSize KEGs_cLBTargets) then 
	{
		lbSetCurSel[KEGs_cLBTargets, lbSize KEGs_cLBTargets];	// Selection outside listbox size
		//_debugPlayer globalchat "Selection outside listbox size - reset select";
	};

	// CHECK FOR NEW PLAYER TARGET 
	if ( KEGs_tgtSelLast != lbCurSel KEGs_cLBTargets ) then 
	{
		//KEGsDroppedCamera = false;
		KEGs_tgtIdx = lbValue[KEGs_cLBTargets, (lbCurSel KEGs_cLBTargets)]; // Get the new target
		KEGs_lastTgt = KEGs_tgtIdx;	//immediately capture the last target index
		KEGs_tgtSelLast = lbCurSel KEGs_cLBTargets; //immediately capture the last selected target index
		//_debugPlayer globalchat "Get the new player target (updated KEGs_tgtIdx)";
		
		// Check limits
		if(KEGs_tgtIdx >= count deathCam) then {KEGs_tgtIdx = (count deathCam)-1;};
		if(KEGs_tgtIdx < 0) then {KEGs_tgtIdx = 0};	
						
		//_debugplayer globalchat format ["*Changing Camera to %1", (KEGs_cameras select KEGs_cameraIdx) ];
		KEGs_target = deathCam select KEGs_tgtIdx;  // reset camera to the new or current player target


		KEGs_cxpos = getPos KEGs_target select 0;
		KEGs_cypos = getPos KEGs_target select 1;

		// move free cam to same position
		KEGscam_free setpos [KEGs_cxpos, KEGs_cypos, (getPosATL KEGscam_free) select 2];
	};
	
	if( lbValue[KEGs_cLBTargets, (lbCurSel KEGs_cLBTargets)] != KEGs_tgtIdx) then 
	{
		//possible bug in A2 somewhere in this code - ViperMaul
		// Find listbox element with matching value
		for "_idx" from 0 to (lbSize KEGs_cLBTargets) do 
		{
			if(lbValue[KEGs_cLBTargets, (lbCurSel KEGs_cLBTargets)] == KEGs_tgtIdx) then 
			{
				lbSetCurSel[KEGs_cLBTargets, _idx];
				//_found = true;
			};
		};
	};
	
};		
	
// Set UI texts
_role = "";

// _name = "Unknown";
if(alive KEGs_target) then 
{
	_name = name KEGs_target;
	
	if(_name == "Error: no unit") then { _name = "Unknown" };
	
	if(vehicle KEGs_target != KEGs_target) then 
	{
		if(KEGs_target == driver vehicle KEGs_target) then {_role = "(Driver)"};
		if(KEGs_target == gunner vehicle KEGs_target) then {_role = "(Gunner)"};
		if(KEGs_target == commander vehicle KEGs_target) then {_role = "(Commander)"};
	};		
}
else
{
	_Idx_KEGS_Target = deathCam find KEGs_target;
	if (lbValue [KEGs_cLBTargets, (lbCurSel KEGs_cLBTargets)] != KEGs_tgtIdx) then 
	{
		// Find listbox element with matching value
		for "_idx" from 0 to (lbSize KEGs_cLBTargets) do 
		{
			if(lbValue[KEGs_cLBTargets, (lbCurSel KEGs_cLBTargets)] == KEGs_tgtIdx) then 
			{
				_name = KEGs_nameCache select _idx;
				//_found = true;
			};
		};
	};
};

ctrlSetText[_cName, format["Focus: %1 %2", _name, _role]];	

//KEGs_lastTgt = KEGs_tgtIdx;		//capture the last target index for the player in focus
