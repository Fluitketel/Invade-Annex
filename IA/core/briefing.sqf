waitUntil {!isNull player && player == player};
if(player diarySubjectExists "Server rules")exitwith{};

player createDiarySubject ["Mission Specific","Revive"];
player createDiarySubject ["Dedicated Rejects","Information"];

player createDiaryRecord 
	["Mission Specific",
		[
			"Revive", 
				"
				Revive System:<br/><br/>
				Medics using a medkit will always be able to revive unconscious players.<br/><br/>
				Other classes can attempt to revive with a first aid kit but have only a 20% chance of success and it will remove a FAK each try.<br/><br/>
				In addition the bleedout timer decreases for each time you've been critically wounded and after a certain amount of revives there becomes a slim chance of dying outright.<br/><br/> 
				On the medical trucks and Nurse Gladys in the field hospital at base is a 'Heal' option that resets this.<br/><br/>
				"
		]
	];


	
player createDiaryRecord 
	["Dedicated Rejects",
		[
			"Information", 
				"
				Feel free to join us on TeamSpeak 3 at<br/>
				Voice.dedicatedrejects.com<br/><br/>
				Or on our web site at<br/>
				www.dedicatedrejects.com<br/>
				"
		]
	];