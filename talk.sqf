	while{alive c1} do {
	
		if(behaviour c1 == "SAFE" || behaviour c1 == "CARELESS") then {
	
			
	
			c1 say "radio_eng_1";
			hint "je parle"; sleep 1 ; hint "";
	
		};
	
		_sleep = 5 + random 25;
	
		sleep _sleep;
	
	};