state("PROA34-Win64-Shipping")
{
	float TotalCentiseconds : 0x42C4EA0, 0x30, 0xE8, 0x258, 0x10B8, 0x260;
	//the timer, starts at milliseconds, stored as 4byte and is slightly off displayed timer
}

startup
{
vars.menuTime = 0;
}

start
{
	if (current.TotalCentiseconds >= 1
	&& current.TotalCentiseconds <= 100)
		{
		return true;
		}
}

gameTime
{
if (current.TotalCentiseconds != 0) {
	print("a" + current.TotalCentiseconds);
	return TimeSpan.FromSeconds(current.TotalCentiseconds / 100f);
	}
else if (old.TotalCentiseconds == 0 ) {
	print("c" + vars.menuTime);
	return TimeSpan.FromSeconds(vars.menuTime / 100f);
	}
else if (current.TotalCentiseconds == 0 ) {
	print("b" + old.TotalCentiseconds);
	vars.menuTime = old.TotalCentiseconds;
	return TimeSpan.FromSeconds(vars.menuTime / 100f);
} else { 
	print ("d" + current.TotalCentiseconds);
	return TimeSpan.FromSeconds(current.TotalCentiseconds / 100f); 
	//if something goes wrong
	}
}

isLoading
{
	return true;
}
