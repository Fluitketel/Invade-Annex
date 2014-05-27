/*
BDETECT CALLBACK TO ADD TO EACH UNIT'S LOCAL BULLET COUNT AND SUPPRESSION STATUS 
- called/spawned from bDetect
- increments a unit's enemy and total bullet count
- assigns supression status based on these bullet counts
- minimal calculation, to keep it fast
*/

tpwcas_fnc_supstate =  
{ 
	private [ "_unit","_data","_shooter","_shooterside","_bulletcount","_enemybulletcount", "_bullet", "_bpos", "_pos", "_time"]; 

	_unit = _this select 0; // suppressed unit 
	_shooter = _this select 1; // shooter of suppressing bullet	
	_type = _this select 6; // 0 is bullet; 1 is projectile
	
	if ( _type == 0 ) then 
	{
		_shooterside = side _shooter; //side of shooter 
		_bulletcount = _unit getVariable ["tpwcas_bulletcount", 0]; //total bullet count 
		_enemybulletcount = _unit getVariable ["tpwcas_enemybulletcount", 0]; //enemy bullet count 
		_bulletcount = _bulletcount + 1; 
		_unit setVariable ["tpwcas_skillregain", time + 2 + random 3];        
		_unit setVariable ["tpwcas_stanceregain", time + 8 + random 5];   
		_unit setVariable ["tpwcas_bulletcount", _bulletcount]; 
		_unit setVariable ["tpwcas_supstate",1]; 
		_unit setVariable ["tpwcas_shooter",_shooter]; 
		_unit setVariable ["tpwcas_process",1]; 

		if ( _shooterside getFriend ( side _unit ) < 0.6 ) then  
		{ 
			_enemybulletcount = _enemybulletcount + (random 2); 
			_unit setVariable ["tpwcas_enemybulletcount", _enemybulletcount]; 
			
			if (tpwcas_reveal > 0) then 
			{
				// If ASR_AI is running reveal is automatically handled dynamically by ASR_AI
				_kv = _unit knowsAbout _shooter;
				if ( _kv < 1.6 ) then
				{
					_revealVal = (1.9 + (100 / (_unit distance _shooter) ));
					if ( _revealVal > tpwcas_reveal ) then { _revealVal = tpwcas_reveal };
					_unit reveal [_shooter, _revealVal]; 
				};
			};
		}; 

		if ((_enemybulletcount > 0) && (_enemybulletcount < tpwcas_st)) then  
		{ 
			_unit setVariable ["tpwcas_supstate",2]; 
		}; 

		if (_enemybulletcount >= tpwcas_st) then  
		{ 
			_unit setVariable ["tpwcas_supstate",3]; 
		};
	}
	else // projectile or grenade
	{
		_bulletcount = _unit getVariable ["tpwcas_bulletcount", 0]; //total bullet count 
		_enemybulletcount = _unit getVariable ["tpwcas_enemybulletcount", 0]; //enemy bullet count 
		_bulletcount = _bulletcount + 10; 
		_enemybulletcount = _enemybulletcount + 10; 
		_unit setVariable ["tpwcas_skillregain", time + 2 + random 3];        
		_unit setVariable ["tpwcas_stanceregain", time + 8 + random 5];   
		_unit setVariable ["tpwcas_bulletcount", _bulletcount]; 
		_unit setVariable ["tpwcas_shooter",_shooter]; 
		_unit setVariable ["tpwcas_process",1]; 
		_unit setVariable ["tpwcas_enemybulletcount", _enemybulletcount]; 
		_unit setVariable ["tpwcas_supstate",3]; 
	};
	
	if( bdetect_debug_enable ) then 
	{
		_msg = format["'tpwcas_fnc_supstate': unit [%1] - Status: [%2] - (bullet count: [%3] - [%4])", _unit, _unit getVariable ["tpwcas_supstate",-1], _bulletcount, _enemybulletcount];
		[ _msg, 9 ] call bdetect_fnc_debug;
	};
};  