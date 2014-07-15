if (isServer || isDedicated || !hasInterFace) exitwith {diag_log "I was kicked from the Init_Client.sqf";};

// JIP Check (This code should be placed first line of init.sqf file)
	if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};
 
 // Wait until player is initialized
	if (!isDedicated) then
		{
			waitUntil {!isNull player && isPlayer player};
			sidePlayer = side player;
		};

	diag_log "==============I am in the Init_client.sqf==============";
	
	if(DEBUG) then
			{
				diag_log "I am in the Init_client.sqf";
			};
	

	// move map to player pos disabled by larrow
	h = [] spawn 
	{
		disableSerialization;
		while {true} do {
			waitUntil { visibleMap };
			_display = uiNamespace getVariable "RSCDiary";
			_ctrl = _display displayCtrl 1202;
			_ctrl ctrlEnable false;
			_ctrl ctrlsettextcolor [0,0,0,0];
			_ctrl ctrlSetTooltip "";
			_ctrl ctrlCommit 0;
			waitUntil { !visibleMap };
		};
	};  
	
	//--- bl1p remove shift click
	if (!DEBUG) then 
	{
		onMapSingleClick "_shift";
	};
	
	// vehicle crew display
	[player] execVM "scripts\crew\crew.sqf";

	// restrictions
	_null = [] execVM "core\Restrictions\restrictions.sqf";
	
	if(DEBUG) then
		{
			_null=[] execVM "core\admin_uid.sqf";
		};
		
		
	// Allow to Jump set the key in the .sqf defualt is f - 2x's
	execVM "misc\jump.sqf";
	
	//--- BL1P player nametags and other restrictions
	execVM "core\nametag.sqf";
	execVM "core\Restrictions\naughtyThermal.sqf";
	execVM "core\Restrictions\drivercheck.sqf";
	
	
	if (isNil 'currentAO') then {currentAO = "Nothing"};
	waitUntil {sleep 0.5; currentAO != "Nothing"};
	
	if (isNil 'radioTowerAlive') then {radioTowerAlive = false};
	if (radioTowerAlive) then
	{
		"radioMarker" setMarkerPosLocal (getPos radioTower);
		"radioMarker" setMarkerTextLocal (markerText "radioMarker");
		"radioMarker" SetMarkerAlpha 0;
	} else {
		"radioMarker" setMarkerPosLocal [0,0,0];
		"radioMarker" SetMarkerAlpha 0;
	};
	
	if (isNil 'priorityTargetUp') then {priorityTargetUp = false};
	if (ConvoyAlive) then
	{
		_pos = getmarkerpos "priorityMarker";
		if (DEBUG) then {diag_log format ["_pos = %1",_pos];};
		"priorityMarker" setMarkerPosLocal _pos;
		"priorityCircle" setMarkerPosLocal _pos;
		//--- bl1p
		"priorityCircle" SetMarkerAlpha 0;
		"priorityMarker" SetMarkerAlpha 0;
	} else {
		"priorityMarker" setMarkerPosLocal [0,0,0];
		"priorityCircle" setMarkerPosLocal [0,0,0];
		//--- bl1p
		"priorityCircle" SetMarkerAlpha 0;
		"priorityMarker" SetMarkerAlpha 0;
	};
	if (isNil 'currentAOUp') then {currentAOUp = false};
	if (currentAOUp) then
	{
		{
			_x setMarkerPosLocal (getMarkerPos currentAO);
			"aoCircle" SetMarkerAlpha 0;
		} forEach ["aoCircle","aoMarker"];
		"aoMarker" setMarkerTextLocal format["Take %1",currentAO];
		//--- bl1p
		"aoCircle" SetMarkerAlpha 0;
	} else {
		{
			_x setMarkerPosLocal [0,0,0];
		} forEach ["aoCircle","aoMarker"];
		//-- bl1p
		"aoCircle" SetMarkerAlpha 0;
		"aoMarker" SetMarkerAlpha 0;
	};
	
	if (isNil 'RunninngDefenceAO') then {RunninngDefenceAO = false};
	if (RunninngDefenceAO) then
	{
		{
			_x setMarkerPosLocal (getMarkerPos currentAO);
		} forEach ["aoCircle_2","aoMarker_2"];
		"aoMarker_2" setMarkerTextLocal format["Defend %1",currentAO];
	} else {
		{
			_x setMarkerPosLocal [0,0,0];
		} forEach ["aoCircle_2","aoMarker_2"];
		//-- bl1p
		"aoCircle_2" SetMarkerAlpha 0;
		"aoMarker_2" SetMarkerAlpha 0;
	};
	
/*	
	//bl1p uav action
	_type = typeOf player;
	if (_type == "B_Soldier_SL_F" || _type == "B_Soldier_TL_F" || _type == "B_officer_F") then 
		{
			_uavAction = player addAction
			[
				"<t color='#FFCF11'>Activate Personal UAV</t>",
				"scripts\uavView.sqf",
				[
					currentAO
				],
				0,
				false,
				true
			];
		};
*/
	
_spawnBuildings = nearestObjects [(getMarkerPos "respawn_west"), ["building"], 1000];

	{
		_x allowDamage false;
		_x enableSimulation false;
	} forEach _spawnBuildings;

/*
while {true} do
{
	
	waitUntil {sleep 0.5; !alive player};
	waitUntil {sleep 0.5; alive player};
	//bl1p uav action
	_type = typeOf player;
	if (_type == "B_Soldier_SL_F" || _type == "B_Soldier_TL_F" || _type == "B_officer_F") then 
		{
			_uavAction = player addAction
			[
				"<t color='#FFCF11'>Activate Personal UAV</t>",
				"scripts\uavView.sqf",
				[
					currentAO
				],
				0,
				false,
				true
			];
		};
sleep 1;
};
*/

CTI_Init_Client = true;