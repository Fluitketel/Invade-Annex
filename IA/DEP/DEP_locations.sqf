// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds all the locations used in DEP.

private ["_locations","_pos_index","_maxbuildingpos","_houses","_validhouses","_valid","_house","_newpos","_location"];

dep_locations = [];
_locations = [];
_pos_index = 0;
_maxbuildingpos = 0;
   
diag_log "Dynamic Enemy Population finding locations...";
_newpos = [1900, 4500, 0];
while {true} do {
    _validhouses = [];
    _valid = true;
    
    if (surfaceIsWater _newpos) then { _valid = false; };
    
    if (_valid) then {
        // Check distance between avoid positions
        {
            if ((_newpos distance _x) < 1500) exitWith { _valid = false; };
        } foreach dep_avoid
    };
    
    if (_valid) then {
        // Check distance between other enemy positions
        {
            if ((_newpos distance (getMarkerPos _x)) < (dep_spacing + (2 * dep_size))) exitWith { _valid = false; };
        } foreach _locations;
    };
    
    if (_valid) then {
        // Check if there are enough enterable houses
        _houses = nearestObjects [_newpos, ["House"], dep_size];
        {	
            _house = _x;
            _i = 0;
            while {count ((_house buildingPos _i)-[0]) > 0} do {_i = _i + 1;};
            _maxbuildingpos = _i - 1;
            if (_maxbuildingpos > 1) then { _validhouses = _validhouses + [_house]; };			
        } foreach _houses;
        if ((count _validhouses) < 1) then {
            _valid = false; 
        };
    };
    
    // If all tests passed create DEP marker
    if (_valid) then {
        _pos_index = _pos_index + 1;
        _name = format ["DEP-%1", _pos_index];
        _m = createMarker [_name, _newpos];
        if (dep_debug) then {           
            _m setMarkerShape "ELLIPSE";
			_m setMarkerSize [dep_size, dep_size];
            _m setMarkerBrush "Solid";
			_m setMarkerType  "Marker";
			_m setMarkerColor "ColorGUER";
        } else {
            _m setMarkerType "Empty";
        };
        _locations = _locations + [_m];
        _location = [];
        _location set [0, [_newpos select 0, _newpos select 1, _newpos select 2]]; // position
        _location set [1, []];      // close units
        _location set [2, false];   // location active
        _location set [3, []];      // enemy groups
        _location set [4, 0];       // time last active
        _location set [5, 0];       // enemy amount
        _location set [6, false];   // location cleared
        dep_locations set [count dep_locations, _location];
    };
    _newpos set [1, (_newpos select 1) + dep_size + (random dep_size)];
    if (_newpos select 1 > 26500) then { 
        _newpos set [1, 4500];
        _newpos set [0, (_newpos select 0) + 200];
    };
    
    if (_newpos select 0 > 29000) exitWith {
        diag_log "end of map";
    };
};
diag_log format ["Dynamic Enemy Population found %1 locations", count dep_locations];
publicVariable "dep_locations";
true;