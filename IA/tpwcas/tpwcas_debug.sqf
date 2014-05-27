/*
DEBUG BALL HANDLER
Every 1 sec:
- Displays appropriate coloured debug ball depending on unit's suppression state
- Hides balls for unsuppressed or injured units
- Removes balls from dead units (!)
- Places markers on map indicating unit status
*/

tpwcas_fnc_debug = 
{
	private ["_cas_ball", "_los_ball", "_marker", "_level", "_x", "_ball_level"];
	
	while { true } do
	{
		{ // forEach start
			if ( local _x ) then //Only process debug info for local AI
			{				
				if( isNil { _x getVariable "tpwcas_debug_ball" } ) then
				{
					// tpwcas debug ball
					//_cas_ball = createVehicle ["Sign_sphere25cm_EP1", [(random 15),(random 15),1], [], 0, "NONE"]; //ARMA3
					_cas_ball = createVehicle ["Sign_Sphere25cm_F", [(random 15),(random 15),1], [], 0, "NONE"];					
					_x setVariable ["tpwcas_ball_state", 0];
					_x setVariable ["tpwcas_debug_ball", _cas_ball ];
					// tpwlos debug ball
					//_los_ball = createVehicle ["Sign_sphere25cm_EP1", [(random 15),(random 15),1], [], 0, "NONE"]; //ARMA3
					_los_ball = createVehicle ["Sign_Sphere25cm_F", [(random 15),(random 15),1], [], 0, "NONE"];
					_x setVariable ["tpwlos_ball_state", 0];
					_x setVariable ["tpwlos_debug_ball", _los_ball ];
					sleep 0.05;
					
					diag_log format ["%1 Frame:%2 'tpwcas_fnc_debug()' - Added debug ball for %3", time, diag_frameno, _x];
				};

				if( !( isNull _x ) && (alive _x) ) then // better to double check for unit being alive ...
				{
					// tpw cas debug ball
					_cas_ball = _x getVariable "tpwcas_debug_ball";
					_level = _x  getVariable ["tpwcas_supstate", 0];
					_ball_level = _x getVariable ["tpwcas_ball_state", 0];
					
					if !( _level == _ball_level ) then 
					{
						switch ( true ) do
						{
							case ( fleeing _x ): 
							{  
								if ( ( tpwcas_mode == 1 ) || ( tpwcas_mode == 2 ) ) then // sp or client-server setup
								{
									[_x, _cas_ball, 1] spawn tpwcas_fnc_client_debug;  // black
									if ( tpwcas_mode == 2 ) then 
									{ 
										[[_x, _cas_ball, 1],"tpwcas_fnc_client_debug",true,false] spawn BIS_fnc_MP;
									};
								};
								
								detach _cas_ball;
								_cas_ball attachTo [_x,[0,0,4]]; 
							};
							
							case ( _level == 0 ): 
							{  
								detach _cas_ball;
								_cas_ball setPosATL [(random 15),(random 15),1];
							};
							
							case ( _level == 1 ): 
							{  
								if ( ( tpwcas_mode == 1 ) || ( tpwcas_mode == 2 ) ) then // sp or client-server setup
								{
									[_x, _cas_ball, 2] spawn tpwcas_fnc_client_debug;  // green
									if ( tpwcas_mode == 2 ) then 
									{
										[[_x, _cas_ball, 2],"tpwcas_fnc_client_debug",true,false] spawn BIS_fnc_MP;
									};
								};
								detach _cas_ball;
								_cas_ball attachTo [_x,[0,0,3]]; 
							};
							
							case ( _level == 2): 
							{ 
								if ( ( tpwcas_mode == 1 ) || ( tpwcas_mode == 2 ) ) then // sp or client-server setup
								{						
									[_x, _cas_ball, 3] spawn tpwcas_fnc_client_debug; //yellow
									if ( tpwcas_mode == 2 ) then 
									{
										[[_x, _cas_ball, 3],"tpwcas_fnc_client_debug",true,false] spawn BIS_fnc_MP;
									};
								};
								detach _cas_ball;
								_cas_ball attachTo [_x,[0,0,2]]; 
							};
							
							case ( _level == 3 ): 
							{  
								if ( ( tpwcas_mode == 1 ) || ( tpwcas_mode == 2 ) ) then // sp or client-server setup
								{						
									[_x, _cas_ball, 4] spawn tpwcas_fnc_client_debug; //red  
									if ( tpwcas_mode == 2 ) then 
									{
										[[_x, _cas_ball, 4],"tpwcas_fnc_client_debug",true,false] spawn BIS_fnc_MP;
									};
								};
								detach _cas_ball;
								_cas_ball attachTo [_x,[0,0,1.2]]; 
							};
						};
							
						_x setVariable ["tpwcas_ball_state", _level];
						
						if ( tpwcas_mode == 2 ) then 
						{
							_msg = format["'tpwcas_fnc_debug' tpwcas debug ball - unit [%1] - new value: [%2]", _x, _level];
							[ _msg, 9 ] call bdetect_fnc_debug;
						};
					};
					
					// tpw los debug ball
					_los_ball = _x getVariable "tpwlos_debug_ball";
					_level = _x  getVariable ["tpwcas_los_visstate", 0];
					_ball_level = _x getVariable ["tpwlos_ball_state", 0];
				
					if !( _level == _ball_level ) then 
					{
						switch ( true ) do
						{
							case ( _level == 0 ): 
							{  
								detach _los_ball;
								_los_ball setPosATL [(random 15),(random 15),1];
							};
							
							case ( _level == 1 ): 
							{
								if ( ( tpwcas_mode == 1 ) || ( tpwcas_mode == 2 ) ) then // sp or client-server setup
								{						
									[_x, _los_ball, 5] spawn tpwcas_fnc_client_debug; // blue
									if ( tpwcas_mode == 2 ) then 
									{
										[[_x, _los_ball, 5],"tpwcas_fnc_client_debug",true,false] spawn BIS_fnc_MP;
									};
								};						
								detach _los_ball;
								_los_ball attachTo [_x,[0,0,2.3]]; 
							};
						};
						
						_x setVariable ["tpwlos_ball_state", _level];
						_x setvariable ["tpwlos_debugnexttime", diag_ticktime + 3];
						
						if ( tpwcas_mode == 2 ) then 
						{
							_msg = format["'tpwcas_fnc_debug' tpwlos debug ball - unit [%1] - new value: [%2]", _x, _level];
							[ _msg, 9 ] call bdetect_fnc_debug;
						};
					};

					// Unit may be out range in mean time - reset ball state to force check next loop in order to hide or re-attach
					if ( ( _level == 1 ) && ( diag_ticktime >= ( _x getVariable ["tpwlos_debugnexttime", diag_ticktime + 1]) ) ) then
					{
						_x setVariable ["tpwcas_los_visstate", 0];
					};
				};
				
				//if !((lifestate _x == "HEALTHY") || (lifestate _x == "INJURED")) then
				if (lifeState _x == "DEAD") then
				{
					// hide tpwcas ball
					_cas_ball = _x getVariable "tpwcas_debug_ball";	 
					detach _cas_ball;
					_cas_ball setPosATL [(random 15),(random 15),1];
					
					// hide tpwlos ball			
					_los_ball = _x getVariable "tpwlos_debug_ball";
					detach _los_ball;
					_los_ball setPosATL [(random 15),(random 15),1];
				};
			};
		} count allUnits;
		
		// Remove debug balls for dead ai
		{ // forEach start
			
			//Only process debug info for local AI
			if (local _x) then 
			{
				// tpwcas
				if( !( isNil { _x getVariable "tpwcas_debug_ball" } ) ) then 
				{
					detach ( _x getVariable "tpwcas_debug_ball" );
					deleteVehicle ( _x getVariable "tpwcas_debug_ball" );
					_x setVariable ["tpwcas_debug_ball", nil];
				};
				
				// tpwlos
				if( !( isNil { _x getVariable "tpwlos_debug_ball" } ) ) then 
				{
					detach ( _x getVariable "tpwcas_debug_ball" );
					deleteVehicle ( _x getVariable "tpwlos_debug_ball" ); 
					_x setVariable ["tpwlos_debug_ball", nil];
				};
			};
			
		} count allDead;

		sleep 1;
	};
};
