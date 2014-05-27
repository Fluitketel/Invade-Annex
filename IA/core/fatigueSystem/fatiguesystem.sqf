if (!isDedicated) then 
{
	//fatigueblackout = false;
	needstowalk = false;
	while {true} do 
	{

		waitUntil {getfatigue player > 0.7};

		if (getfatigue player < 0.7) then 
		{
			sleep 0.5;
			needstowalk = false;
			player forcewalk false;
		};

		if ((getfatigue player > 0.9)&&(!needstowalk)) then 
		{
			sleep 0.5;
			needstowalk = true;
			player forcewalk true;
		};

		if (!needstowalk) then 
		{
			sleep 0.5;
			player forcewalk false;
		};

		if ((getfatigue player < 0.8)&&(needstowalk)) then 
		{
			sleep 0.5;
			needstowalk = false;
			player forcewalk false;
		};
		
	sleep 2;
	};
};

