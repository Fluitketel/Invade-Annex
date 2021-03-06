// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds all (enterable) military buildings in a given area.

private ["_pos","_radius","_allbuildings","_buildings","_building","_checkenterable","_ok","_keywords"];
_pos                = _this select 0;
_radius             = _this select 1;
_checkenterable     = if (count _this > 2) then { _this select 2 } else { true }; 

_allbuildings = [];
_buildings = [];

switch (worldName) do {
    case "Stratis";
    case "Altis": {
        _buildings = nearestObjects [_pos, ["Cargo_HQ_base_F","Cargo_House_base_F","Cargo_Tower_base_F"], _radius];
    };
    default {
        _allbuildings = nearestObjects [_pos, ["House"], _radius];
        _keywords = ["mil_","_fort"];

        {
            _ok = false;
            _building = _x;
            
            // Check if it's a military building    
            {
                _result = [(toLower str _building), _x] call CBA_fnc_find;
                if (_result >= 0) exitWith { _ok = true;  };
            }forEach _keywords;
            
            // Check if it's enterable
            if (_ok && _checkenterable) then {
                _ok = [_building] call dep_fnc_isenterable;
            };
            
            // Add it to the array
            if (_ok) then {
                _buildings = _buildings + [_building];
            };
        } forEach _allbuildings;
        _allbuildings = nil;
    };
};

_buildings;