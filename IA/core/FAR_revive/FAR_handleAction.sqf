private ["_params", "_action"];

// Parameters passed by the action
_params = _this select 3;
_action = _params select 0;

////////////////////////////////////////////////
// Handle actions
////////////////////////////////////////////////

if (_action == "full_revive") then 
{
    [player] spawn dR_full_heal;
	TotalFullRevives = TotalFullRevives + 1;publicVariable "TotalFullRevives";
};

if (_action == "med_action_revive") then //--- Medic Revive
{
	[cursorTarget] spawn FAR_HandleRevive_Med;
	TotalMedicalRevives = TotalMedicalRevives + 1;publicVariable "TotalMedicalRevives";
};

if (_action == "action_revive") then //--- None medic revive
{
	[cursorTarget,player] spawn FAR_HandleRevive;
	TotalNormalRevives = TotalNormalRevives + 1;publicVariable "TotalNormalRevives";
};

 if (_action == "action_call") then //--- Call for Help
{
	execVM "core\FAR_revive\call.sqf";
};
 if (_action == "action_suicide") then //--- whimp out
{
	closeDialog 0;
	player setcaptive false; //--- bl1p this may need moving below the next line ???
	player setDamage 1;
	//FAR_PlayerSide = side player;
	player setVariable ["FAR_isUnconscious", 0, true];
	TotalSuicides = TotalSuicides + 1;publicVariable "TotalSuicides";
	if (DEBUG) then
	{
		diag_log format ["====== TotalSuicides = %1 ============",TotalSuicides];
	};
};

if (_action == "action_drag") then //--- drag him
{
	[cursorTarget] spawn FAR_Drag;
	TotalDrags = TotalDrags + 1;publicVariable "TotalDrags";
};

if (_action == "action_release") then //--- drop him
{
	[] spawn FAR_Release;
};
if (_action == "action_carry") then //--- carry him
{
	[] spawn FAR_Carry;
};

