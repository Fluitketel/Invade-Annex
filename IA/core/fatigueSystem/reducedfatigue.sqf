_debug = false;	// set to true for debug hint with players fatigue

while {true} do 
{
	player setfatigue (getfatigue player - 0.02);
	if (_debug) then {systemchat format ["Fatigue: %1",getfatigue player];};
	sleep 2;
};