/*
DECREASE UNIT SKILLS
- called from main loop
- aiming shake, aiming accuracy and courage decreased by 2.5% per enemy bullet, or 5% if there are nearby casualties
- these skills won't fall below the value set in twpcas_minskill
*/

tpwcas_fnc_decskill =
{
	private [ "_x","_unit","_originalaccuracy","_originalshake","_originalcourage","_shots","_newaccuracy","_newshake","_newcourage","_nearunits","_cas","_dec"];
	
	_unit = _this select 0;
	
	//ANY FRIENDLY CASUALTIES WITHIN 50m OF UNIT
	_nearunits = nearestObjects [_unit,["CaManBase"],50];
	_cas = 0;
	{
		if ( (side _x == side _unit) && !(lifeState _x == "HEALTHY") ) then
		{
			_cas = _cas + 1;
		};
	} count _nearunits;
		
	if (_cas == 0) then 
	{
		_dec = 0.01; //1% decrease
	}
		else
	{
		_dec = 0.05; //5% decrease
	};
	
	if (  isNil {_unit getVariable "tpwcas_originalaccuracy"} ) then 
	{
	    _unit setVariable ["tpwcas_originalaccuracy", _unit skill "aimingAccuracy"];        
	    _unit setVariable ["tpwcas_originalshake", _unit skill "aimingShake"];      
	    _unit setVariable ["tpwcas_originalcourage", _unit skill "courage"]; 
	};
			 	
	_originalaccuracy = _unit getVariable "tpwcas_originalaccuracy";        
	_originalshake = _unit getVariable "tpwcas_originalshake";      
	_originalcourage = _unit getVariable "tpwcas_originalcourage";       
	_shots = _unit getVariable "tpwcas_enemybulletcount";     

	_newaccuracy = (_originalaccuracy - (( _originalaccuracy * _dec) * _shots )) max (_originalaccuracy * tpwcas_minskill); 
	_newshake = (_originalshake - ((_originalshake * _dec) * _shots )) max (_originalshake * tpwcas_minskill);
	_newcourage = (_originalcourage - ((_originalcourage * _dec * (1 - _originalcourage)) * _shots )) max (_originalcourage * tpwcas_minskill);
	_unit setSkill ["aimingAccuracy",_newaccuracy];         
	_unit setSkill ["aimingShake",_newshake];        
	_unit setSkill ["courage",_newcourage]; 
	
	if (_unit getVariable ["tpwcas_skillreset", 0] == 0) then
	{
		_unit setVariable ["tpwcas_skillreset", 1];
	};
	
	//diag_log format ["<<< Unit [%1] - Acc: [%2] - Shake: [%3] - Courage: [%4] - time: [%5]", _unit, _newaccuracy, _newshake, _newcourage, time];
					
};  
