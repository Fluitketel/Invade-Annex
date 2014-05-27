/*
MAIN LOOP
Every 1 sec:
- Assigns initial variables to each unit if they are not yet assigned
- Checks suppression state of unit and applies appropriate stance and skill changes
*/

tpwcas_fnc_main_loop = 
{
	private ["_unitCheck","_stanceregain","_skillregain","_unit","_x", "_anim", "_upos", "_umov", "_dthstr", "_posstr", "_acePosstr", "_movstr", "_chatString", "_shooter", "_lineIntersect","_coverregain","_cover","_stance","_GetNeckPos","_inBuilding","_isBuilding"];	
	
	if( bdetect_debug_enable ) then {
        _msg = format["%1 Started 'tpwcas_fnc_main_loop' - mode: [%2]", time, tpwcas_mode];
        [ _msg, 8 ] call bdetect_fnc_debug;
	};
	
	while {true} do    
	{
		{ //forEach start
		
			_unit = _x;		
		
			// If the tpwcas_ignoreUnit variable set on the unit is true, then the unit will be skipped/ignored.						
			if !( _unit getVariable ["tpwcas_ignoreUnit", false] ) then 
			{			
				if ( tpwcas_mode == 3 ) then // multiplayer (dedicated) server no client setup
				{
					_unitCheck = ( !(isPlayer _unit) && { (local _unit) } );
				}
				else // singleplayer or (hosted/dedicated) server with clients enabled or headless client
				{
					_unitCheck = (local _unit);
				};
			
				if ( (_unitCheck) && { (vehicle _unit == _unit) } && { !(lifeState _unit == "DEAD") } && { !(side _unit == civilian) } ) then
				{
					_stanceregain = _unit getVariable ["tpwcas_stanceregain", -1];
				
					if (tpwcas_canflee == 0) then 
					{
						_unit allowFleeing 0;
					};
				
					//-------------------------------------------------------------------------------------------------------------
					//SET INITIAL PARAMETERS FOR EACH UNIT   
					if (_stanceregain == -1 ) then
					{ 
						//SET ASR AI SKILLS IF ASR AI IS RUNNNING
						if (!isNil "asr_ai3_sysaiskill_fnc_setUnitSkill") then 
						{
							[_unit] call asr_ai3_sysaiskill_fnc_setUnitSkill;
						};
						
						_unit setVariable ["tpwcas_originalaccuracy", _unit skill "aimingAccuracy"];      
						_unit setVariable ["tpwcas_originalshake",  _unit skill "aimingShake"];     
						_unit setVariable ["tpwcas_originalcourage", _unit skill "courage"];      
						_unit setVariable ["tpwcas_general", _unit skill "general"];     
						_unit setVariable ["tpwcas_stanceregain", time];
						//_unit setVariable ["tpwcas_orgbehaviour", behaviour _unit];
						_unit setVariable ["tpwcas_stance", "auto"];
					};    
		
					//-------------------------------------------------------------------------------------------------------------
					//RESET UNIT SETTINGS IF UNSUPPRESSED   
					if ( time >= _stanceregain  ) then        
					{ 
						//if ( !( _unit getVariable "tpwcas_stance" == "auto") || !(_unit getVariable ["tpwcas_supstate",0] == 0) ) then 
						if ( !(_unit getVariable ["tpwcas_supstate",0] == 0) ) then 
						{						
							//Reset behaviour - after bullet detection behaviour should at least be aware							
							if ( ( _unit getVariable ["tpwcas_supstate", 0] == 3 ) && { !(isPlayer (leader _unit)) } ) then 
							{
								_unit setBehaviour "COMBAT";
							}
							else
							{
								_unit setBehaviour "AWARE";
							};
														
							_unit setVariable ["tpwcas_supstate",0];  
							_unit setVariable ["tpwcas_bulletcount",0];     
							_unit setVariable ["tpwcas_enemybulletcount",0]; 
							_unit setVariable ["tpwcas_stanceregain", time + 9 + random 5]; 

							//RESET UNIT STANCE
							if ( (_unit getVariable ["tpwcas_stance", -1]) in ["Middle","Down"]) then 
							{
								if (_unit getVariable ["tpwcas_inbuilding", false] ) then
								{
									_unit setUnitPos "UP";
									_unit setVariable ["tpwcas_stance", "Up"];
								}
								else
								{
									_unit setUnitPos "auto"; 
									_unit setVariable ["tpwcas_stance", "auto"];
								};
								
								// workaround to bypass AI getting stuck in lowering/raising weapon mode
								// often occurs when moving from setUnitPos "Middle" to setUnitPos "Auto" again   // Solved???
							//	if ( _unit getVariable ["tpwcas_stance", "Auto"] == "Middle" ) then 
							//	{
									//_unit playMoveNow "AmovPercMevaSrasWrflDf_AmovPknlMstpSrasWrflDnon";	
							//		_unit playMoveNow "";
									//_unit setUnitPos "auto"; 									
							//	};
								
								//_unit setVariable ["tpwcas_stance", "auto"];
							};
		
							//if ( _cover > 0 ) then
							if ( (tpwcas_getcover == 1) && { ((_unit getVariable ["tpwcas_cover", 0]) > 0 ) } ) then 
							{
								_unit setVariable ["tpwcas_cover", 0];
								//avoid run for cover loop effect
								_unit setVariable ["tpwcas_coverregain", time + (( random 20) + 20)]; 
							};
						};
						
						_skillregain = _unit getVariable ["tpwcas_skillregain", -1]; 
						//RESET UNIT SKILLS IF UNSUPPRESSED  
						if ( (time >= _skillregain) && { ( tpwcas_skillsup == 1 ) } && { (_unit getVariable ["tpwcas_skillreset", 1] == 1) } ) then 
						{						 
							[_unit] call tpwcas_fnc_incskill;
						};
					};   

					//-------------------------------------------------------------------------------------------------------------
					if ( _unit getVariable ["tpwcas_process", 0] == 1 ) then 
					{
						if !(isPlayer _unit) then 
						{
							//UNIT CHANGES FOR DIFFERENT SUPPRESSION 
							switch ( _unit getVariable "tpwcas_supstate" ) do  
							{  							
								//------------------------------------------------------------------------------------------------------
								case 1: //IF ANY BULLETS NEAR UNIT  
								{
									//CROUCH IF STANDING 
									if ( stance _unit == "STAND" ) then
									{
										_unitPos = eyePos _unit;
										_inBuilding = ((lineIntersectsWith [_unitPos, [(_unitPos select 0), (_unitPos select 1), (_unitPos select 2 ) + 5]] ) select 0);
										if ( !( isNil "_inBuilding" ) && { _inBuilding isKindOf "Building" } ) then 
										{
											_unit setVariable ["tpwcas_inbuilding", true];
										};
										_unit setUnitPos "Middle"; 
										_unit setVariable ["tpwcas_stance", "Middle"];	
									};	

									if ( ( behaviour _unit == "SAFE" ) && { !(isPlayer (leader _unit)) } ) then 									
									{ 
										// after bullet detection behaviour should at least be aware
										//_unit setVariable ["tpwcas_orgbehaviour", "AWARE"];
										_unit setBehaviour "AWARE";
									};										
								};  
								  
								//------------------------------------------------------------------------------------------------------
								case 2: //IF ENEMY BULLETS NEAR UNIT  
								{ 
									//CROUCH IF NOT PRONE
									if !( stance _unit == "PRONE" ) then
									{ 
										//_cover = _unit getVariable ["tpwcas_cover", 0];
										_coverregain = _unit getVariable ["tpwcas_coverregain", time];
										_isBuilding = false;
										
										if ( stance _unit == "STAND" ) then
										{
											_unitPos = eyePos _unit;
											_inBuilding = ((lineIntersectsWith [_unitPos, [(_unitPos select 0), (_unitPos select 1), (_unitPos select 2 ) + 5]] ) select 0);
											if ( !( isNil "_inBuilding" ) && { _inBuilding isKindOf "Building" } ) then 
											{
												_unit setVariable ["tpwcas_inbuilding", true];
												_isBuilding = true;
												
												if (tpwcas_debug > 0) then 
												{	
													if (tpwcas_debug == 2) then 
													{
														diag_log format ["unit %1 (%2) is in building", name _unit, _unit];
													};
													[['orange', _unitPos],"tpwcas_fnc_debug_smoke",true,false] spawn BIS_fnc_MP;
													if (hasInterface) then {
														['orange', _unitPos] spawn tpwcas_fnc_debug_smoke;
													};
												};
											};
										};
										
										if ( 
												( time >= _coverregain) && 
												{ ( tpwcas_getcover == 1 ) } && 
												{ ( (_unit getVariable ["tpwcas_cover", 0]) == 0 ) } && 
												{ ( diag_fps > tpwcas_getcover_minfps ) } &&
												{ !(isPlayer (leader _unit)) } &&
												{ !(_isBuilding) }
											) then 
										{
											[_unit, 2] spawn tpwcas_fnc_find_cover;
										};

										_unit setUnitPos "Middle"; 
										_unit setVariable ["tpwcas_stance", "Middle"];
									};										
										
									if ( ( (behaviour _unit) in ["SAFE", "AWARE"] ) && { !(isPlayer (leader _unit)) } ) then 
									{ 
										// after bullet detection behaviour should at least be aware
										//_unit setVariable ["tpwcas_orgbehaviour", "AWARE"];
										_unit setBehaviour "COMBAT";
									};
									
									//SKILL MODIFICATION 
									if (tpwcas_skillsup == 1) then 
									{ 
										[_unit] call tpwcas_fnc_decskill;
									};

									_shooter = _unit getVariable "tpwcas_shooter";
									_unit doWatch _shooter;
								};  
								  
								//------------------------------------------------------------------------------------------------------
								case 3: //IF UNIT IS SUPPRESSED BY MULTIPLE ENEMY BULLETS   
								{ 
									if !( stance _unit == "PRONE" ) then
									{ 
										_coverregain = _unit getVariable ["tpwcas_coverregain", time];
										_isBuilding = false;
										
										if ( stance _unit == "STAND" ) then
										{
											_unitPos = eyePos _unit;
											_inBuilding = ((lineIntersectsWith [_unitPos, [(_unitPos select 0), (_unitPos select 1), (_unitPos select 2 ) + 5]] ) select 0);
											if ( !( isNil "_inBuilding" ) && { _inBuilding isKindOf "Building" } ) then 
											{
												_unit setVariable ["tpwcas_inbuilding", true];
												_isBuilding = true;
												
												if (tpwcas_debug > 0) then 
												{	
													if (tpwcas_debug == 2) then 
													{
														diag_log format ["unit %1 (%2) is in building", name _unit, _unit];
													};
													[['orange', _unitPos],"tpwcas_fnc_debug_smoke",true,false] spawn BIS_fnc_MP;
													if (hasInterface) then {
														['orange', _unitPos] spawn tpwcas_fnc_debug_smoke;
													};
												};
											};
										};										

										if ( 
												( time >= _coverregain) && 
												{ ( tpwcas_getcover == 1 ) } && 
												{ ( (_unit getVariable ["tpwcas_cover", 0]) == 0 ) } && 
												{ ( diag_fps > tpwcas_getcover_minfps ) } &&
												{ !(isPlayer (leader _unit)) } &&
												{ !(_isBuilding) }
											) then 
										{
											[_unit, 2] spawn tpwcas_fnc_find_cover;
										};

										//GO PRONE 
										_unit setUnitPos "Down"; 
										_unit setVariable ["tpwcas_stance", "Down"];					
										_unit forceSpeed -1;
									};
									
									if ( ( (behaviour _unit) in ["SAFE", "AWARE", "COMBAT"] ) && { !(isPlayer (leader _unit)) } ) then 
									{ 
										_unit setBehaviour "STEALTH";
									};

									//SKILL MODIFICATION 
									if (tpwcas_skillsup == 1) then 
									{
										[_unit] call tpwcas_fnc_decskill;
									};
									
									_shooter = _unit getVariable "tpwcas_shooter";							
									_unit doWatch _shooter;
								}; 
							};
						}
						else
						{						
							//------------------------------------------------------------------------------------------------------
							//PLAYER VISUAL CHANGES FOR DIFFERENT SUPPRESSION 
							
							switch ( _unit getVariable "tpwcas_supstate" ) do  
							{
								case 2: //IF ENEMY BULLETS NEAR PLAYER  
								{
									//PLAYER CAMERA SHAKE  
									if (tpwcas_playershake == 1) then    
									{    
										addCamShake [0.5, 2 + (random 2), 2]; 
									};							
								};
							
								case 3: //IF PLAYER IS SUPPRESSED BY MULTIPLE ENEMY BULLETS   
								{
									//PLAYER CAMERA SHAKE AND FX 
									if (tpwcas_playershake == 1) then  
									{ 
										addCamShake [0.75 , 3 + (random 3), 3];
									}; 
									
									//PLAYER VISUAL FX
									if (tpwcas_playervis == 1) then  
									{     
										[] spawn tpwcas_fnc_visuals;   
									}; 
								};
							};
							
							if( bdetect_debug_enable ) then {
								_msg = format["'tpwcas_fnc_main_loop' Player CamShake suppression - level [%1]", (_unit getVariable "tpwcas_supstate")];
								[ _msg, 8 ] call bdetect_fnc_debug;
							};
							
						};
						//------------------------------------------------------------------------------------------------------
						
						//processed so reset value
						_unit setVariable ["tpwcas_process", 0];
					};
				}
				else
				{
					//if civilian
					if ( (side _x == civilian) && { (vehicle _x == _x) } && { !(lifeState _x == "DEAD") } && { !(isPlayer _x) } ) then				
					{
						_unit  = _x;  

						_stanceregain = _unit getVariable ["tpwcas_stanceregain", -1];
							  
						//SET INITIAL PARAMETERS FOR EACH UNIT   
						if (_stanceregain == -1 ) then        
						{ 
							_unit setVariable ["tpwcas_originalcourage", _unit skill "courage"];      
							_unit setVariable ["tpwcas_stanceregain", time];      
							_unit setVariable ["tpwcas_stance", "auto"];
						};    
						 
						//RESET UNIT SETTINGS IF UNSUPPRESSED   
						if ( time >= _stanceregain) then        
						{ 
							_unit setVariable ["tpwcas_supstate",0];  
							_unit setVariable ["tpwcas_bulletcount",0];
							_unit setVariable ["tpwcas_enemybulletcount",0]; 
							
							_unit setSkill ["courage",_unit getVariable ["tpwcas_originalcourage",0.5]];
							
							_unit setVariable ["tpwcas_stanceregain", time + 5]; 					
							
							_stance = _unit getVariable ["tpwcas_stance", -1];						
							
							if ( (_stance in ["Middle","Down"]) && { !(unitPos _unit == "Auto") } ) then 
							{
								_unit setUnitPos "Auto"; 
								_unit setVariable ["tpwcas_stance", "Auto"];
							};
						};
						
						//_cover = _unit getVariable ["tpwcas_cover", 0];
						
						if ( ((_unit getVariable ["tpwcas_cover", 0]) == 0) && { ((_unit getVariable "tpwcas_supstate") > 0 ) } ) then 
						{
							//run for it: civilians will run in random directions due to shooting
							[_unit] spawn tpwcas_fnc_run_for_it;
						};
					};
				};
			};
		} forEach allUnits; 
			
		//sleep 1.2;
		sleep 1;
	};   
};  
