UPSMON_randomPos = {
	private["_cx","_cy","_rx","_ry","_cd","_sd","_ad","_tx","_ty","_xout","_yout"];
	_cx=_this select 0; 
	_cy=_this select 1; 
	_rx=_this select 2; 
	_ry=_this select 3; 
	_cd=_this select 4; 
	_sd=_this select 5; 
	_ad=_this select 6; 
	_tx=random (_rx*2)-_rx; 
	_ty=random (_ry*2)-_ry; 
	_xout=if (_ad!=0) then {_cx+ (_cd*_tx - _sd*_ty)} else {_cx+_tx}; 
	_yout=if (_ad!=0) then {_cy+ (_sd*_tx + _cd*_ty)} else {_cy+_ty}; 
	[_xout,_yout]
};

UPSMON_getDirPos = 
{
	private["_a","_b","_from","_to","_return"]; 
	_from = _this select 0; 
	_to = _this select 1; 
	_return = 0; 
	
	_a = ((_to select 0) - (_from select 0)); 
	_b = ((_to select 1) - (_from select 1)); 
	if (_a != 0 || _b != 0) then {_return = _a atan2 _b}; 
	if ( _return < 0 ) then { _return = _return + 360 }; 
	
	_return
};

UPSMON_rotpoint = 
{
	private["_cp","_a","_tx","_ty","_cd","_sd","_cx","_cy","_xout","_yout"];
	_cp=_this select 0; 
	_cx=_cp select 0; 
	_cy=_cp select 1; 
	_a=_this select 1; 
	_cd=cos(_a*-1); 
	_sd=sin(_a*-1); 
	_tx=_this select 2; 
	_ty=_this select 3; 
	_xout=if (_a!=0) then 
	{
		_cx+ (_cd*_tx - _sd*_ty)
	} else 
	{
		_cx+_tx
	}; 
	_yout=if (_a!=0) then {_cy+ (_sd*_tx + _cd*_ty)} else {_cy+_ty}; 
	
	[_xout,_yout,0]
};

UPSMON_stayInside = 
{
	private["_np","_nx","_ny","_cp","_cx","_cy","_rx","_ry","_d","_tp","_tx","_ty","_fx","_fy"];
	_np=_this select 0;	_nx=_np select 0;	_ny=_np select 1;
	_cp=_this select 1;	_cx=_cp select 0;	_cy=_cp select 1;
	_rx=_this select 2;	_ry=_this select 3;	_d=_this select 4;
	_tp = [_cp,_d,(_nx-_cx),(_ny-_cy)] call UPSMON_rotpoint;
	_tx = _tp select 0; _fx=_tx;
	_ty = _tp select 1; _fy=_ty;
	if (_tx<(_cx-_rx)) then {_fx=_cx-_rx};
	if (_tx>(_cx+_rx)) then {_fx=_cx+_rx};
	if (_ty<(_cy-_ry)) then {_fy=_cy-_ry};
	if (_ty>(_cy+_ry)) then {_fy=_cy+_ry};
	if ((_fx!=_tx) || (_fy!=_ty)) then {_np = [_cp,_d*-1,(_fx-_cx),(_fy-_cy)] call UPSMON_rotpoint};
	_np;
};

UPSMON_distancePosSqr = 
{round(((((_this select 0) select 0)-((_this select 1) select 0))^2 + (((_this select 0) select 1)-((_this select 1) select 1))^2)^0.5)};

UPSMON_getArg = 
{

	private["_cmd","_arg","_list","_a","_v"]; 
	_cmd=_this select 0; 
	_arg=_this select 1; 
	_list=_this select 2; 
	_a=-1; 
	{_a=_a+1; _v=format["%1",_list select _a]; 
	if (_v==_cmd) then {_arg=(_list select _a+1)}} foreach _list; 
	
	_arg
};

UPSMON_setArg = 
{
	private["_cmd","_arg","_list","_a","_v"]; 
	_cmd=_this select 0; 
	_arg=_this select 1; 
	_list=_this select 2; 
	_a=-1; 
	{	
		_a=_a+1; 
		_v= format ["%1", _list select _a]; 
		if (_v==_cmd) then 
		{
			_a=_a+1; 
			_list set [_a,_arg];
		};
	} foreach _list; 
_list
};

UPSMON_deleteDead = 
{

	private["_u","_s"];
	_u=_this select 0; 
	_s= _this select 1; 
	_u removeAllEventHandlers "killed"; 
	sleep _s; 
	deletevehicle _u
};

UPSMON_StrToArray = {
	private["_in","_i","_arr","_out"];
	_in=_this select 0;
	_arr = toArray(_in);
	_out=[];
	for "_i" from 0 to (count _arr)-1 do {
		_out=_out+[toString([_arr select _i])];
	};
	_out
};

UPSMON_StrLen = {
	private["_in","_arr","_len"];
	_in=_this select 0;
	_arr=[_in] call UPSMON_StrToArray;
	_len=count (_arr);
	_len
};

UPSMON_StrIndex = {
	private["_hay","_ndl","_lh","_ln","_arr","_tmp","_i","_j","_out"];
	_hay=_this select 0;
	_ndl=_this select 1;
	_out=-1;
	_i=0;
	if (_hay == _ndl) exitWith {0};
	_lh=[_hay] call UPSMON_StrLen;
	_ln=[_ndl] call UPSMON_StrLen;
	if (_lh < _ln) exitWith {-1};
	_arr=[_hay] call UPSMON_StrToArray;
	for "_i" from 0 to (_lh-_ln) do {
		_tmp="";
		for "_j" from _i to (_i+_ln-1) do {
			_tmp=_tmp + (_arr select _j);
		};
		if (_tmp==_ndl) exitWith {_out=_i};
	};
	_out
};

UPSMON_StrInStr = {
	private["_out"];
	_in=_this select 0;
	_out=if (([_this select 0,_this select 1] call UPSMON_StrIndex)==-1) then {false} else {true};
 	_out
};

UPSMON_Replace = {
	private["_str","_old","_new","_out","_tmp","_jm","_la","_lo","_ln","_i"];
	_str=_this select 0;
	_arr=toArray(_str);
	_la=count _arr;
	_old=_this select 1;
	_new=_this select 2;
	_na=[_new] call UPSMON_StrToArray;
	_lo=[_old] call UPSMON_StrLen;
	_ln=[_new] call UPSMON_StrLen;
	_out="";
	for "_i" from 0 to (count _arr)-1 do {
		_tmp="";
		if (_i <= _la-_lo) then {
			for "_j" from _i to (_i+_lo-1) do {
				_tmp=_tmp + toString([_arr select _j]);
			};
		};
		if (_tmp==_old) then {
			_out=_out+_new;
			_i=_i+_lo-1;
		} else {
			_out=_out+toString([_arr select _i]);
		};
	};
	_out
};