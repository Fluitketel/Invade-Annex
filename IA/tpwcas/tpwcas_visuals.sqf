/*
BLUR PLAYER VISION WHEN SUPPRESSED 
- Called from the main loop
- Creates radial blur and gamma darkening to simulate tunnel vision
- Is flagged so only one instance can run at a time
*/
  
tpwcas_fnc_visuals =    
{
	private ["_x","_blur","_tint","_ppmod","_ppmodifier"];
	
	if ( ( player getVariable ["tpwcas_supvis", 0] == 0 ) ) then    
	{  
		player setVariable ["tpwcas_supvis",1];
		
		_tint = ppEffectCreate ["Colorcorrections", 1552];   
		_tint ppEffectEnable true;   
		_blur = ppEffectCreate ["RadialBlur", 1551];   
		_blur ppEffectEnable true;   
		_ppmodifier = 0.001; 
		 
		{ 
			_ppmod = _ppmodifier * _x; 
			_blur ppEffectAdjust [_ppmod,_ppmod,0.1,0.1];  
			_blur ppEffectCommit 0;  
			_tint ppEffectAdjust[1, 1, (-5 * _ppmod), [0,0,0,0], [0,0,0,0.8], [0,0,0,0.8]]; 
			_tint ppEffectCommit 0;  
			sleep 0.1;      
		} count [1,2,3,4]; 
		 
		sleep 2;   

		{ 
			_ppmod = _ppmodifier * _x; 
			_blur ppEffectAdjust [_ppmod,_ppmod,0.1,0.1];  
			_blur ppEffectCommit 0;  
			_tint ppEffectAdjust[1, 1, (-5 * _ppmod), [0,0,0,0], [0,0,0,0.8], [0,0,0,0.8]]; 
			_tint ppEffectCommit 0;  
			sleep 0.1;      
		} count [4,3,2,1];  
		 
		ppEffectDestroy _blur;   
		ppEffectDestroy _tint;

		player setVariable ["tpwcas_supvis",0];
	};
};
