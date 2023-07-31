package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

class FreeplaySubState extends MusicBeatSubstate {
	public static var vocals:FlxSound = null;

	public function new() {
		super();
	
		
		var textDialogue:FlxText = new FlxText(0, 0, 0, "AAAAAAAAAAAAAAAAAA");
		textDialogue.setFormat("Hello Sunday", 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(textDialogue);
		textDialogue.screenCenter();
		// var text:Alphabet = new Alphabet(0,0,'aAASDDJFJD');
		// text.screenCenter();
		// add(text);
	}	

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}
}