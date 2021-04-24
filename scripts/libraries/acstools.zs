/*
 * Copyright (c) 2019-2020 Talon1024
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/
// Miscellaneous ACS tools

class ACSTools
{
	// Find the number of the last message in a series of messages in the string table.
	// Examples/expected results for various inputs:
	// prefix: DARRENMESSAGE
	// start: 1
	// return value: 101
	//
	// prefix: PRISONERMESSAGE
	// start: 1
	// return value: 21
	//
	// prefix: MARINEAFTERDOUGLESCONV
	// start: 1
	// return value: 55
	//
	static int LastMessageFor(String prefix, int start)
	{
		// Concatenating an empty string with a number is an easy way of converting it to a string
		String suffix = start < 10 ? "0" .. start : "" .. start;
		String lookup = prefix .. suffix;
		String entry = StringTable.Localize(lookup, false);
		int current = start;
		while (entry != lookup)
		{
			current++;
			suffix = current < 10 ? "0" .. current : "" .. current;
			lookup = prefix .. suffix;
			entry = StringTable.Localize(lookup, false);
		}
		return current - 1;
	}

	// For the first thing with a matching TID, get the integer value for the given argument
	static int GetArgument(int tid, int arg)
	{
		if(arg >= 0 && arg <= 4)
		{
			ActorIterator it = Level.CreateActorIterator(tid);
			Actor thething = it.Next();
			if (thething != null)
			{
				return thething.Args[arg];
			}
		}
		return -1;
	}

	// For every thing with a matching TID, set the integer value for the given argument
	static play void SetArgument(int tid, int arg, int value)
	{
		if (arg < 0 || arg > 4) return;
		ActorIterator it = Level.CreateActorIterator(tid);
		Actor thething = it.Next();
		while (thething != null)
		{
			thething.Args[arg] = value;
			thething = it.Next();
		}
	}

	static clearscope int GetTextureWidth(string TextureName)
	{
		TextureID tex = TexMan.CheckForTexture(TextureName, TexMan.Type_Any);
		if (!tex)
		{
			return 0;
		}
		int width, height;
		[width, height] = TexMan.GetSize(tex);
		return width;
	}

	static clearscope int GetTextureHeight(string TextureName)
	{
		TextureID tex = TexMan.CheckForTexture(TextureName, TexMan.Type_Any);
		if (!tex)
		{
			return 0;
		}
		int width, height;
		[width, height] = TexMan.GetSize(tex);
		return height;
	}

	static play void HasAltDeaths(Actor activator)
	{
		ActorFinderTracer aft = new("ActorFinderTracer");
		aft.Source = activator;
		Vector3 Origin = activator.Pos;
		Origin.Z += activator.Height / 2;
		if (activator is "PlayerPawn")
		{
			Origin.Z = activator.Pos.Z + PlayerPawn(activator).ViewHeight;
		}
		Console.Printf("Origin: %.3f %.3f %.3f", Origin);
		// Actor.Spawn("TraceVisual", Origin, NO_REPLACE);
		float Pitch = activator.Pitch;
		float Angle = activator.Angle;
		Vector3 Direction = ZScriptTools.GetTraceDirection(Angle, Pitch);
		Console.Printf("Direction: %.3f %.3f %.3f", direction);
		aft.Trace(Origin, Level.PointInSector(Origin.XY), Direction, 1024, TRACE_HitSky);
		if (aft.found())
		{
			Console.Printf("========== %s ==========", aft.Results.HitActor.GetClassName());
			State frontDeath = aft.Results.HitActor.FindState("Death.Front");
			State backDeath = aft.Results.HitActor.FindState("Death.Back");
			Console.Printf("Without exact: frontDeath %s, backDeath %s", frontDeath ? "true" : "false", backDeath ? "true" : "false");
			frontDeath = aft.Results.HitActor.FindState("Death.Front", true);
			backDeath = aft.Results.HitActor.FindState("Death.Back", true);
			Console.Printf("With exact: frontDeath %s, backDeath %s", frontDeath ? "true" : "false", backDeath ? "true" : "false");
		}
		/*
		// Visualize trace
		for (vector3 i = Origin; (aft.Results.HitPos - i) dot Direction >= 0; i += Direction * 4)
		{
			Actor.Spawn("TraceVisual", i, NO_REPLACE);
		}
		Actor.Spawn("TraceVisual", aft.Results.HitPos, NO_REPLACE);
		*/
		Console.Printf("Hit position: %.3f %.3f %.3f", aft.Results.HitPos);
	}

	static bool FindInventoryClass(Actor mo, String classname, bool descendants = true)
	{
		if (mo && mo.FindInventory(classname, descendants)) { return true; }

		return false;
	}

	// Gets the entry ID for the properly declined word form, given a number
	// and a "base" entry ID. If no declined entry exists in the language 
	// table, the "base" entry ID is returned.
	//
	// For example:
	// In languages with only singular/plural forms, the plural form of KRAUTSKILLER02 would be KRAUTSKILLER02P
	// In Czech, it would be KRAUTSKILLER02A or KRAUTSKILLER02B
	// But if there is no declined form of KRAUTSKILLER02, it returns KRAUTSKILLER02.
	// s:ScriptCall("ACSTools", "GetDeclinedForm", "entry", xxx)
	static String GetDeclinedForm(String entry, int count) {
		String form = ""; // Singular (default)
		if (language.Left(2) ~== "cs") // Czech
		{
			if (count > 4)
			{
				form = "B";
			}
			else if (count > 1)
			{
				form = "A";
			}
		}
		else if (language.Left(2) ~== "pl") // Polish
		{
			if (count > 4)
			{
				form = "B";
			}
			else if (count > 1)
			{
				form = "A";
			}
		}
		else if (language ~== "ru") // Russian
		{
			int numend = count % 100;
			// See https://en.wikipedia.org/wiki/Russian_declension#Declension_of_cardinal_numerals
			if (numend >= 5 && numend <= 20) // only last two digits matter in all of this
			{
				// Genitive plural
				form = "P";
			}
			else
			{
				numend = count % 10;
				if (numend == 1)
				{
					// Nominative singular
					form = "A";
				}
				else if (numend == 2 || numend == 3 || numend == 4)
				{
					// Genitive singular
					form = "B";
				}
				else
				{
					// Genitive plural
					form = "P";
				}
			}
		}
		else if (count != 1)
		{
			// Languages that only have singular/plural forms
			form = "P"; // Plural
		}
		String key = entry .. form;
		// Check if the declined form exists
		String text = StringTable.Localize(key, false);
		if (text != key && text != " ")
		{
			// Declined form exists because the entry was found
			return text;
		}
		// Declined form was not found, so return the entry in singular form
		text = StringTable.Localize(entry, false);
		if (text != entry)
		{
			return text;
		}
		// Entry was not found, return a blank string.
		return "";
	}

	static bool ShouldUseWideObjectivesBox()
	{
		WideObjectivesDataHandler dataHandler = WideObjectivesDataHandler(StaticEventHandler.Find("WideObjectivesDataHandler"));
		return dataHandler.shouldUseWideObjectivesBox();
	}

	static play void DamageSectorWrapper(int tag, int damage) // for destructible 3d floors --N00b
	{
		SectorTagIterator sectors = level.CreateSectorTagIterator(tag);
		int sector_id = sectors.next(); //damage only the first sector
		Destructible.DamageSector(level.sectors[sector_id], null, damage, "None", SECPART_3D, (0, 0, 0), false);
	}

	static bool IsAtMaxHealth(Actor activator)
	{
		return activator.Health == activator.GetMaxHealth(true);
	}

	static bool IsNoClipping(Actor activator)
	{
		if (activator)
		{
			if (activator.player) { return (activator.player.cheats & (CF_NOCLIP | CF_NOCLIP2)); }
			else { return activator.bNoClip; }
		}

		return false;
	}

	// Check if the player is wearing a disguise and is currently hidden
	// If a player is wearing a disguise and is undetected, returns true
	// If a player has been seen or is carrying a weapon not allowed by the current disguise, returns false
	ui static bool IsHidden(Actor mo)
	{
		if (mo && mo.player)
		{
			let disguise = DisguiseToken(mo.FindInventory("DisguiseToken", true));

			if (
				disguise &&
				disguise.notarget &&
				mo.player.cheats & CF_NOTARGET
			) { return true; }
		}

		return false;
	}

	// ZScript implementation of similar funtionality to V_BreakLines.  Hard-coded to use SmallFont
	//  Some logic taken from https://github.com/coelckers/gzdoom/blob/master/src/common/fonts/v_text.cpp
	ui static String BreakString(String input, int maxwidth)
	{
		if (!input.length()) { return ""; }

		input = StringTable.Localize(input, false);

		int c, linestart, lastspace, colorindex;
		String output, currentcolor, lastcolor;
		bool lastWasSpace = false;

		int count = input.CodePointCount();

		for (int i = 0; i < count; i++)
		{
			c = input.GetNextCodePoint(i);

			if (c == 0x1C)
			{
				c = input.GetNextCodePoint(++i);

				if (c == 0x5B) // [
				{
					int namestart = i;
					int length;
					while (c && c != 0x5D) // ]
					{
						c = input.GetNextCodePoint(++i);

						length++;
					}

					if (i < count) { length++; }

					lastcolor = currentcolor; // Remember the previous color in case the string gets cut before this point
					currentcolor = input.Mid(namestart, length);
				}
				else
				{
					lastcolor = currentcolor;
					currentcolor = String.Format("%c", c);
				}

				colorindex = i; // Remember the index of the color so that we can revert to the old color if the last space precededes the color change

				continue;
			}

			if (ZScriptTools.IsWhiteSpace(c))
			{
				if (!lastWasSpace)
				{
					lastspace = i;
					lastWasSpace = true;
				}
			}
			else
			{
				lastWasSpace = false;
			}

			String line = input.Mid(linestart, i - linestart + 1);

			if (SmallFont.StringWidth(line) > maxwidth)
			{
				if (colorindex > lastspace) { currentcolor = lastcolor; } // Make sure the color change didn't happen after the last known space
				output = String.Format("%s%s%c\c%s", output, input.Mid(linestart, lastspace - linestart + 1), c == 0x0A ? 0 : 0x0A, currentcolor);

				linestart = lastspace + 1;
				lastspace = linestart;
			}
		}

		if (linestart < count)
		{
			output = String.Format("%s%s", output, input.Mid(linestart));
		}

		return output;
	}
}

class ActorFinderTracer : LineTracer
{
	Actor Source;
	class<Actor> typeRestriction;
	bool exactType;
	private bool find;

	bool isSuitableActor(Actor toExamine)
	{
		bool typeGood = true;
		if (typeRestriction)
		{
			if (exactType)
			{
				typeGood = toExamine.GetClass() == typeRestriction;
			}
			else
			{
				typeGood = toExamine is typeRestriction;
			}
		}
		return typeGood && toExamine != Source && toExamine is "Base" && toExamine.bSolid && toExamine.bShootable;
	}

	bool found()
	{
		return find;
	}

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling || Results.HitType == TRACE_HasHitSky)
		{
			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			if (Results.HitLine.sidedef[1] && Results.Tier == TIER_Middle)
			{
				return TRACE_Skip;
			}
			else
			{
				return TRACE_Stop;
			}
		}
		else if (Results.HitType == TRACE_HitActor)
		{
			if (isSuitableActor(Results.HitActor))
			{
				find = true;
				return TRACE_Stop;
			}
			else
			{
				return TRACE_Skip;
			}
		}
		return TRACE_Skip;
	}
}