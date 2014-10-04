

_ret = false;
if !(isserver) then {
	_ret = [player, "ACRE_PRC343"] call acre_api_fnc_hasKindOfRadio;
	};
if (_ret) exitwith {systemchat "You already have a 343.";};

player addItem "ACRE_PRC343";