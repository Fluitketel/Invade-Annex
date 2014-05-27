_uid = getPlayerUID player;
_position = run find _uid;

_moaning = ["P0_moan_13_words.wss","P0_moan_14_words.wss","P0_moan_15_words.wss","P0_moan_16_words.wss","P0_moan_17_words.wss","P0_moan_18_words.wss","P0_moan_19_words.wss","P0_moan_20_words.wss"];
_randommoan = _moaning select floor(random(count _moaning));
_moanfile = Format ["a3\sounds_f\characters\human-sfx\Person0\%1", _randommoan]; 
_removecountar = 4;

if (_position == -1) then 
	{ 
		player globalchat "help";
		//playSound "HOTINHERE"
		run = (run - [_uid]) + [_uid]; publicvariable "run";
		sleep 20;
		run = run - [_uid];publicvariable "run";
	}
 else
	{
		player globalchat "Button abuse detected... Primary Weapon Removed";
	};

