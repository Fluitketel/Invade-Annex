//////////////////////////////////////////////////////////////////
//
// TPWCAS v4.5 Script startup script
//
// Usage: [<tpwcas_mode>] execVM "tpwcas\tpwcas_script_init.sqf";
//
// E.g.: [2] execVM "tpwcas\tpwcas_script_init.sqf";
//
//////////////////////////////////////////////////////////////////

// HEADLESS CLIENT CHECK
tpwcas_isHC = ( !(hasInterface) && !(isDedicated) );

if !(isNil "tpwcas_mode") then // tpwcas_mode set by logic module or by global pubvar
{
	diag_log format ["%1 pre-init defined twpcas mode: 'tpwcas_mode = %2'", time, tpwcas_mode];
};

if ( (isNil "tpwcas_mode") && (count _this) == 1 ) then 
{
	tpwcas_mode = _this select 0;
};

// Force 'tpwcas_mode = 1' for SinglePlayer Mode 
if ( (isServer) && !(isMultiPlayer) ) then 
{
	tpwcas_mode = 1;
};

diag_log format ["%1 twpcas mode init check: tpwcas_mode = %2 - Server: [%3] - MP: [%4] - tpwcas_isHC: [%5] - isNil tpwcas_mode: [%6]", time, tpwcas_mode, isServer, isMultiPlayer, tpwcas_isHC, isNil "tpwcas_mode"];

// Multi Player Client Mode (tpwcas_mode 0, 2, or 3)
if ( !(isServer) && !(tpwcas_isHC) && isMultiPlayer) then 
{	
	if ( isNil "tpwcas_mode" ) then 
	{
		diag_log format ["%1 waiting for twpcas client mode variable set by server", time];
		0 = [] spawn // set parameter to close tpwcas if no server variable received within 4 minutes
			{ 
				sleep 240;
				if (isNil "tpwcas_mode") then 
				{
					tpwcas_mode = 0;
				}; 	
			};
		waitUntil { sleep 3;!(isNil "tpwcas_mode") };
		diag_log format ["%1 twpcas client mode set to tpwcas_mode: [%2]", time, tpwcas_mode];
	};

	if ( tpwcas_mode == 2 ) then // set by global pub var
	{
		diag_log format ["%1 enabled tpwcas client mode: tpwcas_mode = %2", time, tpwcas_mode];
	}
	else //unknown value or value = 3 - disable tpwcas
	{
		diag_log format ["%1 disable tpwcas client mode: detected value for tpwcas_mode = %2", time, tpwcas_mode];
		tpwcas_mode = 0;
	};
};

// Multi Player Server or HC Mode (tpwcas_mode 2 or 3)
if ( ( ( isServer || tpwcas_isHC ) ) && ( isMultiPlayer )) then 
{  
	diag_log format ["%1 tpwcas_mode = %2 - Server: [%3] - MP: [%4] - config: [%5] - isNil: [%6]", time, tpwcas_mode, isServer, isMultiPlayer, getnumber(configfile>> "tpwcas_key_setting"  >> "tpwcas_mode"), isNil "tpwcas_mode"];
		
	if ( isNil "tpwcas_mode" ) then // default value if not provided
	{
		tpwcas_mode = 3;	
	};
	
	if ( !((tpwcas_mode == 2) || (tpwcas_mode == 3) || (tpwcas_mode == 0) || (tpwcas_mode == 5)) ) then 
	{
		diag_log format ["%1 forcing tpwcas to value [3]: determined tpwcas_mode value: [%2]", time, tpwcas_mode];
		tpwcas_mode = 3; 
	}; 
	
	if ( tpwcas_mode == 5 ) then // => DEPRECATED
	{
		tpwcas_mode = 0;
		diag_log format ["%1 disabled tpwcas by userconfig file: tpwcas_mode = %2", time, tpwcas_mode];
	};
};

if ( !(tpwcas_mode == 0) ) then  
{
	nul = [] execvm "tpwcas\tpwcas_init.sqf";
};
