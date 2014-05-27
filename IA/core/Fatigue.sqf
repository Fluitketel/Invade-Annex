//--- reduce fatigue every 5 sec

if (isServer) exitwith {};
while {True} do 
{
 if (getfatigue player > 0.5) then {
	player setfatigue (getfatigue player - 0.1);
	};
	sleep 5;
};