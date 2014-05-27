	
//////////////////////////////////////////	
//ANGLE OF SUN - ADAPTED FROM CARLGUSTAFFA
//////////////////////////////////////////

private ["_lat","_day","_hour"];

while {true} do 
{
	_lat = -1 * getnumber(configfile >> "cfgworlds" >> worldname >> "latitude");
	_day = 360 * (datetonumber date);
	_hour = (daytime / 24) * 360;
	tpwcas_los_sunangle = round (((12 * cos(_day) - 78) * cos(_lat) * cos(_hour)) - (24 * sin(_lat) * cos(_day)));
	
	// reduce impact of day time and night time
	switch ( true ) do 
			{
				case ( tpwcas_los_sunangle > 10 ): 
				{  
					tpwcas_los_sunangle = 10;
				};
				
				case ( tpwcas_los_sunangle < -10 ): 
				{  
					tpwcas_los_sunangle = -10;
				};
			};

	sleep 300; 
};
