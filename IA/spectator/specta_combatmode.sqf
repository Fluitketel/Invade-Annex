
	private ["_color","_shape","_Type","_timer","_life","_position","_weight","_vol","_rub","_size","_PS","_unit"];
	
	_unit = _this select 0;
	_PS = _this select 1;

	//_shape = "\a3\data_f\cl_water.p3d";
	_shape = "\A3\data_f\ParticleEffects\Universal\smoke.p3d";
	
	_timer = 0.01;
	_life = 2.5;
	_position = [0, 0, 1.5];
	_weight = 7.5;
	_vol = 10;
	_rub = 0;
	_size = [0.4];

	//_PS = "#particlesource" createVehicleLocal getpos vehicle _unit;

	_PS setParticleCircle [0, [0, 0, 0]];
	_PS setParticleRandom [0, [0, 0, 0], [0, 0, 0], 0, 0, [0, 0, 0, 0], 0, 0];
	_PS setDropInterval 0.01;


	while {KEGsTagsStat && { alive _unit} } do {

		_color = switch (behaviour _unit) do {
			case 'CARELESS': {[[0,0,1,1]]};
			case 'SAFE': {[[0,1,0,1]]};
			case 'AWARE': {[[1,1,0,1]]};
			case 'COMBAT': {[[1,0,0,1]]};
			case 'STEALTH': {[[0,1,1,1]]};
		};

		_PS setParticleParams [

			[_shape, 8, 2, 0], "",
			 "billboard",
			 _timer,
			 _life,
			 _position,
			 [0, 0, 0], 0,
			 _weight,
			 _vol,
			 _rub,
			 _size,
			 _color,
			 [1],
			 0,
			 0,
			 "",
			 "",
			 vehicle _unit

		];

		sleep 0.03;
		if (!alive _unit) then { deleteVehicle _PS};
	};

