/*
INCREASE UNIT SKILLS
- called from main loop
- aiming shake, aiming accuracy and courage increase by 10%
*/

tpwcas_fnc_incskill = 
{
	private ["_unit","_originalaccuracy","_originalshake","_originalcourage","_currentaccuracy","_currentshake","_currentcourage","_newaccuracy","_newshake","_newcourage","_inc"];
	
	_unit = _this select 0;
	
	if (  isNil {_unit getVariable "tpwcas_originalaccuracy"} ) then 
	{
	    _unit setVariable ["tpwcas_originalaccuracy", _unit skill "aimingAccuracy"];        
	    _unit setVariable ["tpwcas_originalshake", _unit skill "aimingShake"];      
	    _unit setVariable ["tpwcas_originalcourage", _unit skill "courage"]; 
	};
	
	_originalaccuracy = _unit getVariable "tpwcas_originalaccuracy";        
	_originalshake = _unit getVariable "tpwcas_originalshake";      
	_originalcourage = _unit getVariable "tpwcas_originalcourage"; 
	
	_currentaccuracy = _unit skill "aimingAccuracy"; 
	_currentshake = _unit skill "aimingShake"; 
	_currentcourage = _unit skill "courage"; 
	
	_inc = 0.10; //10% increment
	
	if (_currentaccuracy < _originalaccuracy) then 
	{
		//INCREMENT SKILLS
		_newaccuracy = _currentaccuracy + (_originalaccuracy * _inc);
		_newshake = _currentshake + (_originalshake * _inc); 
		_newcourage = _currentcourage + (_originalcourage * _inc); 	
		
		_unit setSkill ["aimingAccuracy",_newaccuracy];         
		_unit setSkill ["aimingShake",_newshake];        
		_unit setSkill ["courage",_newcourage];  
		
		//diag_log format [">>> Unit [%1] - Acc: [%2] - Shake: [%3] - Courage: [%4]", _unit, _newaccuracy, _newshake, _newcourage];
	}
	else
	{
		//RESET SKILLS
		_unit setSkill ["aimingAccuracy",_originalaccuracy];         
		_unit setSkill ["aimingShake",_originalshake];        
		_unit setSkill ["courage",_originalcourage];
		
		_unit setVariable ["tpwcas_skillreset", 0];
		
		//diag_log format ["=== Unit [%1] - Acc: [%2] - Shake: [%3] - Courage: [%4] - time: [%5]", _unit, _originalaccuracy, _originalshake, _originalcourage, time];
	};
};