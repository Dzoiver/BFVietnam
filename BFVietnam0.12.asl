
state("BfVietnam") 
{
	byte enemyScore : "BfVietnam.exe", 0x965748, 0xA4;
	byte allyScore : "BfVietnam.exe", 0x965748, 0xE8;
	float missionTimer : "BfVietnam.exe", 0x9A21AC, 0x48, 0x4, 0xBC, 0x78, 0x1EC; // Actual Mission time. Resets to 0 when it's finished
}	
startup 
{
	vars.total = 0.0f; // Total time from all missions
	vars.lastTimer = 0.0f; // End value of current mission
	vars.added = false; // Checks if mission time was added to the total time
	vars.maxIGT = 0.0f;
	vars.replayMissionDifference = 0.0f;
	settings.Add("RefreshRate_60", true, "Refresh rate 60 (Turn off if you have troubles with perfomance)");
}
isLoading
{
	return true; // We use gametime
}

gameTime
{
	if (current.missionTimer == 0 && vars.added == false) // Adds mission time to the total time when loading next mission
	{
		vars.total += vars.lastTimer;
		vars.maxIGT = 0.0f; // reset max so it won't define it like reset
		vars.added = true; // Extra flag for not adding infinite amount of current mission to the total time
	}
	if (current.missionTimer > vars.maxIGT) // Finding Max IGT
	{
		vars.maxIGT = current.missionTimer;
	}
	if (current.missionTimer < vars.maxIGT && vars.added == true)
	{
		vars.replayMissionDifference += vars.maxIGT;
		vars.maxIGT = 0.0f;
	}
	return TimeSpan.FromSeconds(vars.total + current.missionTimer + vars.replayMissionDifference);
}

split // Split either when we win or lose (because of some losing strats)
{
	if (old.enemyScore > 0 && current.enemyScore == 0) 
	{
		vars.added = false;
		vars.lastTimer = current.missionTimer; // Remember current misison time before the split
		return true;
	}
	if (old.allyScore > 0 && current.allyScore == 0)
	{
		vars.added = false;
		vars.lastTimer = current.missionTimer;
		return true;
	}
}
start
{
	if (old.enemyScore == 0 && current.enemyScore != 0 && settings.StartEnabled) // Start when enemy score value defined
	{
		vars.total = 0.0f;
		vars.lastTimer = 0.0f;
		vars.added = false; // Checks if mission time was added to the total time
		vars.maxIGT = 0.0f;
		vars.replayMissionDifference = 0.0f;
		return true;
	}
	
}
init 
{
	if (!settings["RefreshRate_60"])
	{
		refreshRate = 30;
	}
}