/*

	AUTHOR: aeroson - tweaked by Rarek
	NAME: player_markers.sqf
	VERSION: 1.2

	DESCRIPTION:
	a script to mark players on map without polluting global variable namespace
	it doees also remove all unused markers, instead of leaving them at [0,0]
	lets BTC mark unconscious players, shows Norrin's revive unconscious units

*/

if (isDedicated) exitWith {};
//_Leaders = ["B_Soldier_SL_F", "B_Soldier_TL_F"];
//_iamLeader = ({typeOf player == _x} count _Leaders) > 0;
//if !(_iamLeader) exitwith {player globalchat "leaving markers script";};

private ["_marker","_unitNumber","_show","_injured","_text"];

while {true} do {
	sleep 0.1;

	_unitNumber = 0;
	{
		_show = false;
		_injured = false;

		if(side _x == playerSide) then {
			if((crew vehicle _x) select 0 == _x) then {
				_show = true;
			};
			if(!alive _x || damage _x > 0.3) then {
				_injured = true;
			};
			
		};

		if(_show) then {
			_unitNumber = _unitNumber + 1;
			_marker = format["um%1",_unitNumber];
			if(getMarkerType _marker == "") then {
				createMarkerLocal [_marker, getPos vehicle _x];
			} else {
				_marker setMarkerPosLocal getPosATL vehicle _x;
			};
			_marker setMarkerDirLocal getDir vehicle _x;

			if(_injured) then {
				_marker setMarkerColorLocal "ColorRed";
				_marker setMarkerTypeLocal "mil_dot";
				_marker setMarkerSizeLocal [0.8,0.8];
			} else {
				_marker setMarkerColorLocal "ColorBlue";
				_marker setMarkerTypeLocal "mil_triangle";
				if(_x == player) then {
					_marker setMarkerSizeLocal [0.7,1];
				} else {
					_marker setMarkerSizeLocal [0.5,0.7];
				};
			};

			_text = name _x;
			_veh = vehicle _x;
			if (_veh != _x) then
			{
				_crew = crew _veh;
				if ((count _crew) > 1) then
				{
					_crewLoopCount = (count _crew) - 1;
					for "_i" from 1 to _crewLoopCount do
					{
						_text = format["%1, %2", _text, name (_crew select _i)];
					};
				};
				_text = format["%1 [%2]", _text, getText(configFile>>"CfgVehicles">>typeOf _veh>>"DisplayName")];
			};
			_marker setMarkerTextLocal _text;
			_marker setMarkerSizeLocal [0.5,0.5];

		};
	} forEach playableUnits;

	_unitNumber = _unitNumber + 1;
	_marker = format["um%1",_unitNumber];

	while {(getMarkerType _marker) != ""} do {
		deleteMarkerLocal _marker;
		_unitNumber = _unitNumber + 1;
		_marker = format["um%1",_unitNumber];
	};

};