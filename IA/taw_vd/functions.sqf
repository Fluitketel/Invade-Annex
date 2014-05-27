fnc_vd_foot_onsliderchange =
{
	private["_dialog","_text","_value"];
	disableSerialization;
	
	_dialog = findDisplay 2900;
	_text = _dialog displayCtrl 2902;
	_value = _this select 0;
	
	tawvd_foot = round(_value);
	_text ctrlSetText format["%1", round(_value)];
	[] call fnc_vd_changed;
};
	
fnc_vd_car_onsliderchange =
{
	private["_dialog","_text","_value"];
	disableSerialization;
	
	_dialog = findDisplay 2900;
	_text = _dialog displayCtrl 2912;
	_value = _this select 0;
	
	tawvd_car = round(_value);
	_text ctrlSetText format["%1", round(_value)];
	[] call fnc_vd_changed;
};

fnc_vd_air_onsliderchange =
{
	private["_dialog","_text","_value"];
	disableSerialization;
	
	_dialog = findDisplay 2900;
	_text = _dialog displayCtrl 2922;
	_value = _this select 0;
	
	tawvd_air = round(_value);
	_text ctrlSetText format["%1", round(_value)];
	[] call fnc_vd_changed;
};

fnc_terrainchange =
{
	private["_type"];
	_type = _this select 0;
	
	switch (_type) do
	{
		case "none":
		{
			setTerrainGrid 50;
		};
		
		case "low":
		{
			setTerrainGrid 30;
		};
		
		case "norm":
		{
			setTerrainGrid 12.5;
		};
		
		case "high":
		{
			setTerrainGrid 3.125;
		};
	};
};

fnc_vd_changed =
{
	private["_type"];
	
	if((vehicle player) isKindOf "Man" && viewdistance != tawvd_foot) then
	{
		setViewDistance tawvd_foot;
	};
		
	if((vehicle player) isKindOf "LandVehicle" || (vehicle player) isKindOf "Ship" && viewdistance != tawvd_car) then
	{
		setViewDistance tawvd_car;
	};
		
	if((vehicle player) isKindOf "Air" && viewdistance != tawvd_air) then
	{
		setViewDistance tawvd_air;
	};
};