private ["_houses", "_pos", "_size", "_house", "_maxbuildingpos"];
_pos = _this select 0;
_size = _this select 1;

_validhouses = [];
_houses = nearestObjects [_pos, ["House"], _size];
{	
    _house = _x;
    _i = 0;
    while {count ((_house buildingPos _i)-[0]) > 0} do {
        _i = _i + 1;
    };
    _maxbuildingpos = _i - 1;
    if (_maxbuildingpos > 0) then { 
        _validhouses = _validhouses + [_house]; 
    };			
} foreach _houses;
_validhouses;