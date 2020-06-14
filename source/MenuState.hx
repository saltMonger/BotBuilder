package;

import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;


// FlxState is like a scene in other game engines
// Only one state is active at a time, just like a Unity scene or whatever

class MenuState extends FlxState
{

	var playButton:FlxButton;

	override public function create()
	{
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.screenCenter();
		add(playButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function clickPlay()
	{
		FlxG.switchState(new PlayState());
	}
}
