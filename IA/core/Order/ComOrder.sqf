if (isServer) exitwith {diag_log "I was kicked from the ComOrder.sqf";};

private = ["_castypes","_landtypes"];

_unit = _this select 0;
_castypes = [];
_landtypes = [];
_playerType = typeOf player;

OrderCas = false; publicvariable "OrderCas";
OrderLand = false; publicvariable "OrderLand";

if (_playertype != "") exitwith {};

_unit addAction ["<t color='#FFCF11'>Heal...</t>", "core\FAR_revive\FAR_handleAction.sqf",["full_revive"], 0, false, false, "", "vehicle _this == _this && _target distance _this < 10