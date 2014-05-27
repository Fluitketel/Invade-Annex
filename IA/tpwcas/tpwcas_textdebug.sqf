/*
FLOATING TEXT BASED DEBUG
- Spawned per unit from main loop:
- Displays appropriate coloured floating debug text depending on unit's suppression state
- Hides text for unsuppressed or injured units
*/

tpwcas_fnc_textdebug =
	{
	private ["_unit","_rate","_display","_control","_pos2d","_sup","_disp","_text","_tsize","_tcolour"];
	_unit = _this select 0;
	_rate = _this select 1;
	disableserialization;

	if (isnil "BIS_fnc_3dCredits_n") then {BIS_fnc_3dCredits_n = 2733;};
	BIS_fnc_3dCredits_n cutrsc ["rscDynamicText","plain"];
	BIS_fnc_3dCredits_n = BIS_fnc_3dCredits_n + 1;
	_display = uinamespace getvariable "BIS_dynamicText";
	_control = _display displayctrl 9999;
	while {true} do 
		{
		_pos2d = worldtoscreen getposatl _unit;
		if (count _pos2D > 0) then 
			{
			_sup = _unit getvariable "tpwcas_supstate";
			_disp = _unit getvariable "tpwcas_enemybulletcount";
			//_disp = (round ((_unit skill "courage") * 100))/100;
			_tsize = 0.5 - ((player distance _unit) / 500) max 0.2;
			_tcolour = "#ffffffff";
			switch ( true ) do
				{
				case (lifestate _unit != "ALIVE"): {_disp = ""};
				case (fleeing _unit): {_tcolour ="#000000"};
				case (_sup == 0): {_tcolour ="#77ffffff"}; 
				case (_sup == 1): {_tcolour ="#7700ff00"};
				case (_sup == 2): {_tcolour ="#77ffff00"};
				case (_sup == 3): {_tcolour ="#77ff0000"};
				};
			_control ctrlsetposition [(_pos2d select 0) -0.5,(_pos2d select 1)];
			_text = format ["<t color ='%3' shadow ='0' size='%2'>%1</t>",_disp,_tsize,_tcolour];
			_control ctrlsetstructuredtext parsetext _text;
			_control ctrlsetfade 255;
			_control ctrlcommit 0;
			};
		sleep (1 / _rate);
		};
	};
