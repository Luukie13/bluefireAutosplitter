state("PROA34-Win64-Shipping")
{
	float TotalCentiseconds : 0x42C4EA0, 0x30, 0xE8, 0x258, 0x10B8, 0x260;
	//the timer, starts at milliseconds, stored as 4byte and is slightly off displayed timer
}

startup
{
	vars.Log = (Action<object>)((output) => print("[Blue Fire] " + output));
	vars.MenuTime = 0f;
}

init
{
	vars.CancelSource = new CancellationTokenSource();
	vars.ScanThread = new Thread(() =>
	{
		vars.Log("Starting scan thread.");

		var gWorld = IntPtr.Zero;
		var gWorldTrg = new SigScanTarget(10, "80 7C 24 ?? 00 ?? ?? 48 8B 3D ???????? 48")
		{ OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr) };

		var scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);
		var token = vars.CancelSource.Token;

		while (!token.IsCancellationRequested)
		{
			if (gWorld == IntPtr.Zero && (gWorld = scanner.Scan(gWorldTrg)) != IntPtr.Zero)
			{
				vars.Data = new MemoryWatcherList
				{
					new MemoryWatcher<float>(new DeepPointer(gWorld, 0x30, 0xE8, 0x258, 0x10B8, 0x260)) { Name = "TotalCentiseconds" }
				};

				vars.Log("Found GWorld at 0x" + gWorld.ToString("X") + ".");
				break;
			}

			Thread.Sleep(2000);
		}

		vars.Log("Exitng scan thread.");
	});

	vars.ScanThread.Start();
}

update
{
	if (vars.ScanThread.IsAlive) return false;

	vars.Data.UpdateAll(game);
	current.Centiseconds = vars.Data["TotalCentiseconds"].Current;
}

start
{
	return old.Centiseconds < 1f && current.Centiseconds >= 1f;
}

gameTime
{
	if (current.Centiseconds > 0)
		return TimeSpan.FromSeconds(current.Centiseconds / 100f);
}

isLoading
{
	return true;
}
