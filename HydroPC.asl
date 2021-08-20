state("HydroPC")
{
	bool loading: 0x16880C8;
	byte level: 0x1687E6C;
	uint checkpoint: 0x1681910;
	
	bool cutscene: 0x166A234;
	bool cutscene2: 0x1682B68;
	bool cutsceneSkip: 0x1599EBC;
	
	byte bossElectro: 0x1687308;
}

startup
{
	settings.Add("noloads", true, "Enable Load Removal");
	settings.Add("crash", true, "Pause game timer if game crashes", "noloads");
	settings.Add("cutscenes", true, "Cutscenes pause game timer", "noloads");
	settings.Add("skipcutscenes", false, "Unpause when cutscene can be skipped", "cutscenes");
}

init
{
	if (settings["noloads"] && settings["crash"])
		timer.IsGameTimePaused=false;
		
	current.bossPhase = 0;
}

exit
{
	if (settings["noloads"] && settings["crash"])
		timer.IsGameTimePaused=true;
}

start
{
	return current.level == 0 && !current.cutscene2 && old.cutscene2;
}

isLoading
{
	//Pause game timer during cutscenes
	if (settings["cutscenes"] && current.cutscene)
	{
		if (settings["skipcutscenes"])
			return !current.cutsceneSkip;
		else
			return current.cutscene;
	}
	//Pause game timer during loading screens
	else if(current.loading)
	{
		current.bossPhase = 0;
		
		if (settings["noloads"])
			return true;
		else
			return false;
	}
	else
		return false;
}

split
{
	//Split when boss phase counter reaches 3, but only if in boss room
	if(current.level == 2 && current.checkpoint == 3344481171)
		return old.bossPhase == 2 && current.bossPhase == 3;
	//Else split when reaching Act Complete screen, but only for the first 2 acts
	return current.level > old.level && current.level < 3;
}

update
{
	//Debug
	//if(current.level != old.level) print("level: "+old.level+">"+current.level);
	//if(current.checkpoint != old.checkpoint) print("checkpoint: "+old.checkpoint+">"+current.checkpoint);
	//if(current.cutscene != old.cutscene) print("cutscene: "+current.cutscene);
	//if(current.cutscene2 != old.cutscene2) print("cutscene2: "+current.cutscene2);
	
	//Update boss phase counter, but only if in boss room
	if(current.level == 2 && current.checkpoint == 3344481171)
	{
		//Reset to initial phase if boss hasn't been stunned yet
		if(current.bossElectro < old.bossElectro)
			current.bossPhase = 0;
		//Increment boss phase counter when cutscene starts
		else if(current.cutscene && !old.cutscene)
		{
			//Wraps around from 3 to 0 in the event that the counter doesn't get reset somehow
			current.bossPhase = (current.bossPhase+1)%4;
			//print("bossPhase: "+old.bossPhase+">"+current.bossPhase);
		}
	}
}