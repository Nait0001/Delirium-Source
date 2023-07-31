package;

// import sys.FileSystem;
// import sys.FileSystem;
import lime.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
// import sys.FileSystem;

using StringTools;

class DialogueStuff extends FlxSpriteGroup {

	var curLetter:Int = -1;
	private var allLetters:Array<String> = [];
	private static var del:String = '::';
	private static var widthBox:Int = 265;
	private var groupCharacter:FlxSpriteGroup;
	private var textDialogue:FlxText;
	public var dialogueSpr:Array<Dynamic>;
	public var counterDialoge:Int = 0;
	private var boxDialogue:FlxSprite;
	// var sprDialogue:DialogueSpr = null;
	// Syouko::angry::teste bacana brava grrrr::0.05::50
	override public function new(text:String, ?color:FlxColor = FlxColor.WHITE, ?velocity:Float = 0.05, ?fontScale:Int = 50, ?x:Float = 0, ?y:Float = 0) {
		super(x,y);

		trace(allLetters);
		
		var colorFuck = FlxColor.BLUE;

		groupCharacter = new FlxSpriteGroup();
		add(groupCharacter);

		dialogueSpr = groupCharacter.members;

		// boxDialogue.loadGraphic()

		boxDialogue = new FlxSprite();
		// boxDialogue.makeGraphic(FlxG.width,widthBox,colorFuck);
		// boxDialogue
		boxDialogue.loadGraphic(Paths.image('dialogue/boxDialogue'));
		// boxDialogue.setGraphicSize(Std.int(boxDialogue.width),widthBox);
		boxDialogue.scrollFactor.set();
		add(boxDialogue);


		textDialogue = new FlxText(boxDialogue.x + 40, boxDialogue.y + 20, FlxG.width - 40, text);
		textDialogue.setFormat("Hello Sunday", fontScale, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textDialogue.scrollFactor.set();
		textDialogue.text = '';
		add(textDialogue);

		positionOrigins();
		changeDialogue(text,velocity,fontScale);
	}

	public function positionOrigins(tween:Bool = false) {
		boxDialogue.y = (FlxG.height - boxDialogue.height);
		textDialogue.setPosition(boxDialogue.x + 40, boxDialogue.y + 20);
		textDialogue.frameWidth = FlxG.width - 40;
	}

	public function aligamentDialogue(aligament:String) {
		switch(aligament.toLowerCase().trim()){
			case 'left':
				textDialogue.alignment = LEFT;
			case 'center':
				textDialogue.alignment = CENTER;
			case 'right':
				textDialogue.alignment = RIGHT;
		}
	}

	public function getLimiter():String {
		return del;
	}

	private var letterTimer:FlxTimer = null;
	public var characterName:String = 'Pablo';
	public function changeDialogue(text:String,?velocity:Float = 0.05,?fontScale:Int = 50) {
		if (text == null) text = 'TEXT ERROR';
		if (letterTimer != null) letterTimer.cancel();
		for (i in 0...allLetters.length) allLetters.remove(allLetters[i]);
		curLetter = -1;
		counterDialoge += 1;

		textDialogue.size = fontScale;
		textDialogue.updateHitbox();

		var velText = text.split(del)[3];
		if (velText != null) velocity = Std.parseFloat(velText);

		var sclText = text.split(del)[4];
		if (sclText != null) fontScale = Std.parseInt(sclText);


		characterName = text.split(del)[0];
		allLetters = text.split(del)[2].split('');

		// soundDetec(characterName);

		if (characterName != 'null'){
			textDialogue.text = '$characterName: ';		
		} else
		textDialogue.text = '';


		// trace(textDialogue.text);
		if (text.split(del)[2] != 'null') letterTimer = new FlxTimer().start(velocity,addLetter,allLetters.length);
	}

	// public var characterNameArray:Array<String> = [];
	private var dialogueSound:String = 'soundDialogue';
	private var dialogueSoundVolume:Float = 1;
	public function addCharacter(?name:String = null,?reactionSpr:String = 'normal',?x:Float = 0, ?y:Float = 0) {
		name = name.toLowerCase();
		if (name != 'null' || name != null || name != '[empty]'){
			// syouko/normal
			// characterNameArray.push(name);
			var sprDialogue:DialogueSpr = new DialogueSpr('$name/$reactionSpr',x,y);
			sprDialogue.y += (textDialogue.y - sprDialogue.height);
			sprDialogue.alpha = 0;
			FlxTween.tween(sprDialogue, {alpha: 1}, 0.5);
			// boxDialogue.y - 20
			groupCharacter.add(sprDialogue);

			sprDialogue.screenCenter(X);
		}
	}

	public function alphaCharacter(?timeTwe:Float = 1){
		var alphaTwen:Float = 1;
		if (groupCharacter.alpha >= 0.1)
			alphaTwen = 0;

		// trace("alphaTwen" + alphaTwen);

		FlxTween.tween(groupCharacter, {alpha: alphaTwen}, timeTwe);

	}

	private function soundDetec(chr:String) {
		switch(chr.toLowerCase().trim()){
			case 'syouko':
				dialogueSound = 'girl';
				dialogueSoundVolume = 1;
			default :
				dialogueSound = 'soundDialogue';
				dialogueSoundVolume = 0.1;
		}
	}

	private function addLetter(t:FlxTimer) {
		if (curLetter > allLetters.length) letterTimer.cancel();

		curLetter += 1;
		textDialogue.text += allLetters[curLetter];

		FlxG.sound.play(Paths.sound('dialogue/$dialogueSound'), 0.1);
	}

	// public function selectedChr(id:Int):DialogueSpr {
		
	// 	// return Std.is(groupCharacter.members[id], DialogueSpr);
		
	// 	// Std.isOfType(groupCharacter.members[id], DialogueSpr);

	// }
	// some tweenStuff
	public function tweenChr(id:Int, things:Dynamic, ?time:Float = 0.5, ease:Dynamic) {
		FlxTween.tween(groupCharacter.members[id], things, time, ease);
	}
}

class DialogueSpr extends FlxSprite {

	public var reactionSpr:String = 'normal';
	public var characterSpr:String = 'syouko';
	override public function new(loadSpr:String,?x:Float = 0,?y:Float = 0){
		super(x,y);

		characterSpr = loadSpr.toLowerCase().split('/')[0];
		reactionSpr = loadSpr.split('/')[1];
		// loadGraphic(Paths.image('dialogue/$loadSpr'));
		changeCharacter(reactionSpr);
		FlxG.log.add("LOCAL: " + loadSpr);
		// tweenJump();
	}

	private var bumpJump:FlxTween = null;
	public function tweenJump(?yPos:Float = 30, ?time:Float = 0.3) {
		this.y += yPos;
		if (bumpJump != null) bumpJump.cancel();
		bumpJump = FlxTween.tween(this, {y: this.y - yPos}, time,{
			onComplete: function(tween:FlxTween){
				bumpJump = null;
			}
		});
	}

	public function changeCharacter(name:String) {
		if (name != 'null'){
			// reactionSpr = name.split('::')[1];
			reactionSpr = name;
			loadGraphic(Paths.image('dialogue/$characterSpr/$name'));
			setGraphicSize(Std.int(width * 0.45));
			updateHitbox();
			FlxG.log.add("LOCAL2: " + '$characterSpr/$reactionSpr');

			tweenJump();
		}
	}
}

class DialogueReader {
	public var nameText:String = '';
	private var vanillaTxt:String = '';
	public var textDialogueArray:Array<String> = [];
	public function new(name:String, ?lauguage:String = 'english') {
		// readDirectory(Paths.);
		// FileSystem
		nameText = name;
		vanillaTxt = Assets.getText('assets/dialogue/$lauguage/$name.txt');
		textDialogueArray = vanillaTxt.split('\n');

		trace(textDialogueArray[0]);
	}
}