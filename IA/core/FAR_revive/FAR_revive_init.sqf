//
// Farooq's Revive 1.4d
// Alterd by BL1P
//

//------------------------------------------//
// Parameters - Feel free to edit these
//------------------------------------------//

// Seconds until unconscious unit bleeds out and dies. Set to 0 to disable. can use a variable to create a paramater for the amount of bleedout.
if (IsServer || IsDedicated) exitwith {diag_log "I was Kicked from the FAR_revive_Init.sqf"};

//FAR_BleedOut = 300; // 5 min	
FAR_BleedOut = 480; // 8 min	

// Enable teamkill notifications
FAR_EnableDeathMessages = true;

/*
	0 = Only medics can revive
	1 = All units can revive //--- this is used in Alterd by bl1p version
	2 = Same as 1 but a medikit is required to revive
*/
FAR_ReviveMode = 1;

//------------------------------------------//

call compile preprocessFile "core\FAR_revive\FAR_revive_funcs.sqf";

#define SCRIPT_VERSION "2.3a"


FAR_isDragging 		   = false;
FAR_isDragging_EH 	   = [];
FAR_deathMessage 		   = [];
FAR_deathMessage_bl1p 	   = []; //--- bl1p adding a global message player is uncon
FAR_Marker_bl1p		   = []; //--- bl1p uncon marker

//FAR_Carry_bl1p = [];
//FAR_Carry_bl1p2 = [];

FAR_Debugging = false;
run = [];

//--- exit if you are the server continue if you are not the server
if (isDedicated) exitWith {};


////////////////////////////////////////////////
// Player Initialization
////////////////////////////////////////////////
[] spawn
{
    waitUntil { !isNull player };

	// Public event handlers
	"FAR_isDragging_EH" addPublicVariableEventHandler FAR_public_EH;
	"FAR_deathMessage" addPublicVariableEventHandler FAR_public_EH;
	"FAR_deathMessage_bl1p" addPublicVariableEventHandler FAR_public_EH;
	"FAR_Marker_bl1p" addPublicVariableEventHandler FAR_public_EH;
	
	//"FAR_Carry_bl1p" addPublicVariableEventHandler FAR_public_EH;
	//"FAR_Carry_bl1p2" addPublicVariableEventHandler FAR_public_EH;
	
	
	
	[] spawn FAR_Player_Init;
	
	//hintSilent format["Farooq's Revived revive %1 is initialized.", SCRIPT_VERSION];

	// Event Handlers
	player addEventHandler 
	[
		"Respawn", 
		{ 
			[] spawn FAR_Player_Init;
		}
	];
};

// Drag & Carry animation fix
[] spawn
{
	while {true} do
	{
		if (animationState player == "acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon" || animationState player == "helper_switchtocarryrfl" || animationState player == "AcinPknlMstpSrasWrflDnon") then
		{
			if (FAR_isDragging) then
			{
				player switchMove "AcinPknlMstpSrasWrflDnon";
			}
			else
			{
				player switchMove "amovpknlmstpsraswrfldnon";
			};
		};
			
		sleep 3;
	}
};

FAR_Player_Init =
{
	// Cache player's side
	FAR_PlayerSide = side player;

	// Clear event handler before adding it
	player removeAllEventHandlers "HandleDamage";
	player addEventHandler ["HandleDamage", FAR_HandleDamage_EH];
	//player removeAllEventHandlers "HandleHeal";
	//player addEventHandler ["HandleHeal", dr_handle_healing];
	//player addMPEventHandler ['MPkilled', {(_this select 0) execVM 'core\FAR_revive\removeBody.sqf'}];
	

	player setVariable ["FAR_isUnconscious", 0, true];
	player setVariable ["FAR_isDragged", 0, true];
	player setCaptive false;//--- bl1p was here
	FAR_isDragging = false;
	closeDialog 0;
	
	[] spawn FAR_Player_Actions;
};
