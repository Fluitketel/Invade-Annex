// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file tells a group to garrison in the nearest building.
private ["_house","_group","_pos","_buildpos","_newbuildpos"];
_group  = _this select 0;
_pos    = getPos (leader _group);

_validhouses = [_pos] call dep_fnc_findnearhouses;
if ((count _validhouses) > 0) then {
    _house = _validhouses call BIS_fnc_selectRandom;
    _buildpos = _house call dep_fnc_buildingpositions;
    {
        if (alive _x) then {
            _newbuildpos = _buildpos call BIS_fnc_selectRandom;
            _buildpos = _buildpos - [_newbuildpos];
            _x setPos _newbuildpos;
        };
    } foreach (units _group);
};