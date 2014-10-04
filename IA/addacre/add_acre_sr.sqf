

_ret = false;
if !(isserver) then {
	_ret = [player, "ACRE_PRC148"] call acre_api_fnc_hasKindOfRadio;
	};
if (_ret) exitwith {systemchat "You already have a 148.";};

player addItem "ACRE_PRC148";