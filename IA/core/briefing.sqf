waitUntil {!isNull player && player == player};
if(player diarySubjectExists "Server rules")exitwith{};

player createDiarySubject ["Mission Specific","Revive"];
player createDiarySubject ["Server rules","General Rules"];
player createDiarySubject ["Bannable","Bannable Offenses"];
player createDiarySubject ["Dedicated Rejects","Information"];

player createDiaryRecord 
	["Mission Specific",
		[
			"Revive", 
				"
				WIP</br>
				"
		]
	];

player createDiaryRecord 
	["Server rules",
		[
			"General Rules", 
				"
				You will not be kicked, but banned.<br/><br/>

				1. NO Cheating.<br/>
				2. NO Team killing.<br/>
				3. Listen to admins.<br/>
				4. Follow your Squad Leader.<br/>
				5. Abusing vehicle will Not be tolerated.<br/>
				"
		]
	];
	

player createDiaryRecord 
	["Bannable",
		[
			"Bannable Offenses", 
				"
				Consider this your one and only warning.<br/><br/>
				
				1. Hacking<br/>
				2. Cheating<br/>
				3. Being kicked 3 or more times.<br/>
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