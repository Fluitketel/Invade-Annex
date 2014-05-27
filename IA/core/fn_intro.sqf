
private ["_hellstorm"];



sleep 2;
_intro = [];
__hellstorm = [format["Welcome to <t color='#ff3b14'>Dedicated Rejects</t> %1,<br/><br/>
		Please note that this mission is still <t color='#ff3b14'>under development</t>. If you happen to find any bugs on the server, please submit a bug report on the website (Suggestions).<br/>
		www.dedicatedrejects.com<br/>
		Contact us on <t color='#ff3b14'>Teamspeak </t>IP:-Voice.dedicatedrejects.com.</br></br>
		Please take note that you should not shoot in base and you should not <t color='#ff3b14'>TEAMKILL</t> <br/><br/>
		For further information please read the rules on our website: www.dedicatedrejects.com<br/><br/>
		<br/><br/>", name player]];
		


switch (playerSide) do {
	case west: {
		{
			_intro = _intro + [(parseText _x)];
		} forEach __hellstorm;
		__hellstorm = _intro;
		"Welcome To Dedicated Rejects" hintC __hellstorm;
	};

};