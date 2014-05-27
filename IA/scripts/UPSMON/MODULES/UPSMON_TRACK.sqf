// track unit ======================================================================================

private ["_trackername","_destname","_npc","_grpid","_grpidx","_track","_trackername","_markerobj","_markertype","_trackername","_markercolor","_trackername","_destname","_wpos","_index"];


_trackername = "";
_destname = "";

While {true} do
{
	{
	
	 _npc = _x;
	 _grpid = _npc getvariable "UPSMON_grpid";
	 _grpidx = format["%1",_grpid];
	 _ucthis = _npc getvariable "UPSMON_Ucthis";
	 _grpmission = _npc getvariable "UPSMON_Grpstatus";
	 _colorstatus = (_npc getvariable "UPSMON_Grpstatus") select 1;
	 
	 _track = 	if (("TRACK" in _UCthis) || (UPSMON_Debug>0)) then {"TRACK"} else {"NOTRACK"};
	 
	if (_track=="TRACK") then {
		_track = "TRACK";
		_trackername=format["trk_%1",_grpidx];
		
			if (getMarkerColor _trackername == "") then 
		{
			_markerobj = createMarker[_trackername,[0,0]];
		};
		_markerobj setMarkerShape "ICON";
		_markertype = "mil_dot";
		
		_trackername setMarkerType _markertype;
		_markercolor = switch (side _npc) do {
			case west: {"ColorGreen"};
			case east: {"ColorRed"};
			case resistance: {"ColorBlue"};
			default {"ColorBlack"};
		};
		_trackername setMarkerColor _markercolor;
		_trackername setMarkerText format["%1",_grpidx];
		
		_destname=format["dest_%1",_grpidx];
		if (getMarkerColor _destname == "") then 
		{
			_markerobj = createMarker[_destname,[0,0]];
		};
		
		_markerobj setMarkerShape "ICON";
		_markertype = "mil_objective";
		
		_markercolor = switch (_colorstatus) do {
			case "GREEN": {"ColorGreen"};
			case "RED": {"ColorRed"};
			case "BLUE": {"ColorBlue"};
			case "YELLOW": {"ColorYellow"};
			case "ORANGE": {"ColorOrange"};
			case "WHITE": {"ColorWhite"};
			default {"ColorBlack"};
		};
		
		_destname setMarkerType _markertype;
		_destname setMarkerColor _markercolor;
		_destname setMarkerText format["%1 in %2",_grpidx,_grpmission];
		_destname setMarkerSize [.5,.5];
		
		_index = currentWaypoint (group _npc);
		_wPos = waypointPosition [group _npc, _index];
		If (alive _npc) then
		{
			_destname setmarkerpos _wPos;
			_trackername setmarkerpos getpos _npc;
		};
	};
	} foreach UPSMON_NPCs;
	
	sleep 4;
};