/*
CLIENT DEBUG BALL HANDLER
Called by BIS_fnc_MP remote Event Handler
- Displays appropriate coloured debug ball depending on unit's suppression state
*/

tpwcas_fnc_debug_smoke = 
{
	private ["_colorCode", "_coverPosition", "_color"];

	//diag_log format ["tpwcas_fnc_debug_smoke: %1 - %2 - [%3]", _this select 0, _this select 1, count _this];
	
	if !(count _this == 2 ) exitWith { diag_log format ["tpwcas_fnc_debug_smoke: not enough parameters: %1", _this] };
	
	_color 			= _this select 0;
	_coverPosition 	= _this select 1;
	
	_msg = format["tpwcas_fnc_debug_smoke: %1 - %2", _this select 0, _this select 1];
	[ _msg, 9 ] call bdetect_fnc_debug;
	
	_colorCode =
		switch ( _color ) do
		{
			case "red": 	{ [1, 0, 0, 0.5] };
			case "blue":	{ [0, 0, 1, 0.5] };
			case "green": 	{ [0, 1, 0, 0.5] };
			case "cyan": 	{ [0, 1, 1, 0.5] };
			case "yellow":	{ [1, 1, 0, 0.5] };
			case "orange":	{ [1, 0.5, 0.5, 0.5] };
			default			{ [1, 1, 1, 0.5] };
		};	
	
	drop ['\a3\data_f\cl_basic.p3d', '', 'Billboard', 1, 20, _coverPosition, [0, 0, 0], 0, 1.274, 0.5, 0, [5],[_colorCode], [0, 1], 0, 0, '', '', ''];
};

tpwcas_fnc_client_debug = 
{
	private ["_unit", "_ball", "_color"];

	_unit = _this select 0;
	_ball = _this select 1;
	_color = _this select 2;

	_msg = format["'suppressDebug' event for unit [%1] - value [%2] - ball [%3]", _unit, _color, _ball];
	[ _msg, 9 ] call bdetect_fnc_debug;
	
	switch ( _color ) do
	{
		case 0: 
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.99,0.99,0.99,0.7,ca)"];  // white
		};
		case 1: 
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.0,0.0,0.0,0.9,ca)"];  // black
		};
		case 2:
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.1,0.9,0.1,0.7,ca)"];  // green
		};
		case 3: 
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.9,0.9,0.1,0.7,ca)"]; //yellow
		};
		case 4:
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.9,0.1,0.1,0.7,ca)"]; //red  
		};
		case 5: //tpw los debug
		{
			_ball setObjectTexture [0,"#(argb,8,8,3)color(0.2,0.2,0.9,0.5,ca)"]; // blue
		};
	};
};
