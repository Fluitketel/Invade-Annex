//////////////////////////////////////////////
//        dR_N_Friends.sqf					
//        by Fluit n BL1P		
//   adapted from a script by TG Unk				
//     execVM "dR_N_Friends.sqf";	
//////////////////////////////////////////////

private ["_dRFriends","_IamAdRFriend", "_isAdmin", "_welcome", "_welcomeadmin"];
_IamAdRFriend = false;
_isAdmin = false;
_welcome = [
			"Welcome back %1",
			"Hello %1!",
			"What's up %1!",
			"Hey its %1!",
			"Wotcha %1",
			"Ay-up %1",
			"Welcome home Lord %1",
			" %1! Thou hast returneth",
			"Delighted to see you %1",
			"Golly gosh...! if it isnt %1",
			"My word %1 is that a gun in your pants or are you pleased to be back?",
			"%1 Today try to remember G is not for Gear !!",
			"Accessing Bank details for %1",
			"player %1 Connected dangerous weapons removed",
			"Its a bird ! ... Its a plane !... NO its %1",
			"OMG! Yay! its %1",
			"Ladies and Gentlemen.... I present to you... %1",
			"%1..  %1..  %1.. hip.. hip.. hooorah",
			"Jolly hockey sticks its %1",
			"Well slap me in the face with a wet kipper... if it isnt %1",
			"Shhhh %1s back",
			"%1 connected ..... accessing password details .... password taken from %1",
			"The people await your orders %1."
			];
_welcomeadmin = [
			"Welcome back %1",
			"Hello %1!",
			"What's up %1!",
			"Hey its %1!",
			"Wotcha %1",
			"Ay-up %1",
			"Welcome home Lord %1",
			"%1! Thou hast returneth",
			"Delighted to see you %1",
			"Golly gosh...! if it isnt %1",
			"My word %1 is that a gun in your pants or are you pleased to be back?",
			"%1 Today try to remember G is not for Gear !!",
			"Accessing Bank details for %1",
			"player %1 Connected dangerous weapons removed",
			"Its a bird ! ... Its a plane !... NO its %1",
			"OMG! Yay! its %1",
			"Ladies and Gentlemen.... I present to you... %1",
			"%1..  %1..  %1.. hip.. hip.. hooorah",
			"Jolly hockey sticks its %1",
			"Well slap me in the face with a wet kipper... if it isnt %1",
			"Shhhh %1s back",
			"%1 connected ..... accessing password details .... password taken from %1",
			"The people await your orders %1."
			];			

systemchat "dRnF is running on this Server.";

if (isServer) exitWith 
{
	//_dRFriends = loadfile "\BL1P\dRFriends.ini";
	//dRFriendsArray = [_dRFriends, ","] call CBA_fnc_split;
	dRFriendsArray = call compile preprocessFile "\dRnF\dRFriends.sqf";
	publicVariable "dRFriendsArray";
};

		
if (isNil ("dRFriendsArray")) then 
	{
		waitUntil {!isNil("dRFriendsArray")};
	};
	sleep 1;
	
//diag_log format ["=dRFriendsArray= = %1",dRFriendsArray];

{
	if ( (getPlayerUID player) == (_x select 0)) then {
		// Player UID is in friend list => he is our friend
		_IamAdRFriend = true;

		if ( (_x select 1) == 1) then {
			// Player is an admin
			_isAdmin = true;
		};
	};
} forEach dRFriendsArray;
	
//diag_log format ["==_IamAdRFriend== = %1",_IamAdRFriend];

player setVariable["friend", _IamAdRFriend, true];
player setVariable["admin", _isAdmin, true];
_playerType = typeOf player;

if ((_playerType == "B_officer_F") && !(_isAdmin)) then {failMission "END6";}; //--- bl1p sent back to lobby
if ((_playerType == "B_Pilot_F" || _playerType == "B_Helipilot_F" || _playerType == "B_helicrew_F" || _playerType == "B_soldier_repair_F") && !(_IamAdRFriend)) then {failMission "END7";}; //--- bl1p sent back to lobby

if (_IamAdRFriend) then {
	if (_isAdmin) then {
		systemChat format [_welcomeadmin call BIS_fnc_selectRandom, name player];
		systemChat format ["Level Two Access Granted to %1", name player];
	} else {
		systemChat format [_welcome call BIS_fnc_selectRandom, name player];
		systemChat format ["Level One Access Granted to %1", name player];
	};
} else {
		systemChat format ["Hello %1 you are not a dR registerd Friend or Member",name player];
		systemChat "Contact info is in the map info... or on a Sign in base";
		systemChat "Enjoy your stay";
};