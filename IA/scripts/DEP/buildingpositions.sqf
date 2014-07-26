// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file finds spawn positions in a building.
private ["_building", "_positions", "_i"];
_building = _this;
_positions = [];
_i = 1;
while {_i > 0} do {
   _next = _building buildingPos _i;
   if (((_next select 0) == 0) && ((_next select 1) == 0) && ((_next select 2) == 0)) then {
      _i = 0;
   } else {
      _positions set [(count _positions), _next];
      _i = _i + 1;
   };
};
_positions;