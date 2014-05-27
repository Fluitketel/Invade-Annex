UPSMON_Clones = {
private ["_Ucthis","_mincopies","_maxcopies","_copies","_grpcnt","_unittype","_grp","_lead","_initstr","_members","_newunit"];

_Ucthis = _this select 0;
_mincopies = _this select 1;
_maxcopies = _this select 2;

_npc = _Ucthis select 0;
_members = units _npc;
_grpcnt = count units _npc;
_speedmode = (_npc getvariable "UPSMON_Origin") select 1;
_orgMode = (_npc getvariable "UPSMON_Origin") select 0;
	If (UPSMON_Debug > 0) then {diag_log format ["%1 copy",_npc];};
	_copies=_mincopies+random (_maxcopies-_mincopies);
	
	// create the clones
		for "_grpcnt" from 1 to _copies do 
		{
			// copy groups
			if (isNil ("UPSMON_grpindex")) then {UPSMON_grpindex = 0}; 
			UPSMON_grpindex = UPSMON_grpindex+1;
			// copy group leader
			_unittype = typeof _npc;
			// make the clones civilians
			// use random Civilian models for single unit groups
			if ((_unittype=="Civilian") && (count _members==1)) then {_rnd=1+round(random 20); if (_rnd>1) then {_unittype=format["Civilian%1",_rnd]}};
			
			// any init strings?
			_initstr = ["INIT:","",_UCthis] call UPSMON_getArg;

			_grp=createGroup side _npc;
			_lead = _grp createUnit [_unittype, getpos _npc, [], 0, "form"];
			_lead setVehicleVarName format["l%1",UPSMON_grpindex];
			call compile format["l%1=_lead",UPSMON_grpindex];
			_lead setBehaviour _orgMode;
			_lead setSpeedmode _orgSpeed;
			_lead setSkill skill _npc;
			If (_initstr != "") then {
			if (isMultiplayer) then 
			{
				[[netid _lead, _initstr], "UPSMON_fnc_setVehicleInit", true, true] spawn BIS_fnc_MP;
			} else 
			{
				_unitstr = "_lead";
				_index=[_initstr,"this",_unitstr] call UPSMON_Replace;
				call compile format ["%1",_index];
			};};
			
			[_lead] join _grp;
			_grp selectLeader _lead;
			// copy team members (skip the leader)
			_i=0;
			{
				_i=_i+1;
				if (_i>1) then {
					_newunit = _grp createUnit [typeof _x, getpos _x, [],0,"form"];
					_newunit setBehaviour _orgMode;
					_newunit setSpeedMode _orgSpeed;
					_newunit setSkill skill _x;
					If (_initstr != "") then {
					if (isMultiplayer) then 
					{
						[[netid _newunit, _initstr], "UPSMON_fnc_setVehicleInit", true, true] spawn BIS_fnc_MP;
					} else 
					{
						_unitstr = "_newunit";
						_index=[_initstr,"this",_unitstr] call UPSMON_Replace;
						call compile format ["%1",_index];
					};};
					[_newunit] join _grp;
				};
			} foreach _members;
			_Ucthis set [0,_lead];
			nul= _Ucthis spawn UPSMON;
			//sleep .05;
		};	
		sleep .05;
};