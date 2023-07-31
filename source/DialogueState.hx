package;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import DialogueStuff.DialogueReader;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;

using StringTools;

class DialogueState extends MusicBeatState {

	var dialogue:DialogueStuff;
	var pressButton:Bool = false;
	var talkDialogue:Array<String> = [
		'Syouko::angry::teste bacana brava grrrr',
		'Syouko::happy::teste feliz eba eba ebaaaaa',
		// '[Time::1]',
		'Syouko::sad::teste triste',
		'Syouko::scared::teste medo buuuuu',
		'Syouko::superHappy::teste super feliz ebaaa',
	];
	var limiterDialog:String;
	var curDiallogue:Int = -1;
	public static var curChapter:Int = 0;
	public static var textDialogue:String = 'girlText';
	public static var debugMode:Bool = false;
	var dialogArray:Array<String> = ['girlText','shameText','prideText','guiltyText'];
	// var boxDialogue:FlxSprite;
	// var groupCharacter:FlxSprite;

	var phoneSound:FlxSound;
	override function create() {
		super.create();

		FlxG.sound.music.stop();

		FlxG.log.add('dialogChose: ' + dialogArray[curChapter-1]);

		textDialogue = dialogArray[curChapter-1];

		talkDialogue = new DialogueReader(textDialogue).textDialogueArray;
		dialogue = new DialogueStuff('null::null::null::');
		limiterDialog = dialogue.getLimiter();
		add(dialogue);
		dialogue.alpha = 0;
		pressButton = true;
	
		new FlxTimer().start(0.8,chapterIntro);
		cacheDowload(textDialogue);
	}	
	var stopNextDialogue:Bool = false;
	override function update(elapsed:Float) {
		super.update(elapsed);


		if (!pressButton){
			if (controls.BACK)
			{
				pressButton = true;
				// FlxG.sound.playMusic(Paths.music('freakyMenu'));
				// MusicBeatState.switchState(new MainMenuState());
				onFinishDialogue();
			}

			else if(FlxG.keys.justPressed.SEVEN){
				debugMode = !debugMode;
				trace('debugMode: ' + debugMode);
			}
			
			else if(controls.ACCEPT){
				if (curDiallogue >= talkDialogue.length-1)
					onFinishDialogue();
				else setDialog(1,true);
			}
		}
	}


	function onFinishDialogue() {
		// FlxG.sound.playMusic(Paths.music('freakyMenu'));
		FlxG.sound.play(Paths.sound('cancelMenu'));
		if (debugMode)
			MusicBeatState.switchState(new MainMenuState());
		else{
			PlayState.isStoryMode = true;
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			LoadingState.loadAndSwitchState(new PlayState(), true);


			curChapter ++;
			textDialogue = dialogArray[curChapter-1];
		}
	}

	function setDialog(?times:Int = 1,?playSound:Bool = false) {
		if (!stopNextDialogue){
			curDiallogue += times;

			if (!talkDialogue[curDiallogue].contains('[') && !talkDialogue[curDiallogue].contains(']')){
				dialogue.changeDialogue(talkDialogue[curDiallogue]);
				if (dialogue.dialogueSpr[0] != null)
					dialogue.dialogueSpr[0].changeCharacter(talkDialogue[curDiallogue].split(limiterDialog)[1]);
				if(playSound) FlxG.sound.play(Paths.sound('dialogue/next'), 0.5);	
			} else {
				var removeBar:String = talkDialogue[curDiallogue].replace("[","").replace("]","").toLowerCase().trim();
				// trace(removeBar);
				eventsDialogue(removeBar.split(limiterDialog)[0],Std.parseFloat(removeBar.split(limiterDialog)[1]));
				// FlxG.log.add(removeBar);
			}
		}
	}

	function eventsDialogue(dialogueNow:String,?event1:Float = 0) {
		var setDialogue:Bool = true;
		switch(dialogueNow){
			case 'empty':
				dialogue.members[1].visible = true;
				dialogue.members[1].alpha = 0;
				dialogue.aligamentDialogue('center');
			case 'drum':
				phoneSound.loadEmbedded(Paths.sound('dialogue/drum'));
				phoneSound.play(false);
				phoneSound.volume = 0;
				phoneSound.fadeOut(1,1);
				FlxG.sound.music.fadeOut(0.5,0);
			case 'music':
				var volumeMusic:Float = 0;
				if (FlxG.sound.music.volume < 1.0)
					volumeMusic = 1;
				else
					volumeMusic = 0;

				trace(volumeMusic);
				FlxG.sound.music.fadeOut(event1,volumeMusic);
			case 'pause':
				stopNextDialogue = true;
				setDialogue = false;
				dialogue.changeDialogue("null::null::...::" + (event1/3));
				new FlxTimer().start(event1,function(t:FlxTimer){
					stopNextDialogue = false;
					setDialog();
				});
			case 'add_syouko':
				phoneSound.stop();
				dialogue.aligamentDialogue('left');
				FlxTween.tween(dialogue.members[1], {alpha: 1}, 0.5);
				dialogue.addCharacter('syouko','angry');
				FlxG.sound.playMusic(Paths.music('dialogue/girl'));
				FlxG.sound.music.volume = 0;
				FlxG.sound.music.fadeIn(2,1);
			case 'syouko_alpha' :
				dialogue.alphaCharacter(event1);
			case 'phone':
				phoneSound.loadEmbedded(Paths.sound('dialogue/phone'), true);
				phoneSound.play(false);
				phoneSound.fadeIn(1,phoneSound.volume,event1);
			case 'interrupt':
				setDialogue = false;
				new FlxTimer().start(event1,function(t:FlxTimer){
					setDialog();
				});
			case 'time_skip':
				setDialogue = false;
				FlxG.camera.fade(FlxColor.BLACK,event1,true,function(){
					new FlxTimer().start(0.8,function(t:FlxTimer){
						FlxG.camera.fade(FlxColor.BLACK,1,false);
						// setDialog();
					});
				},true);
			case 'silence':
				visibleUI(false,true,event1);
				stopNextDialogue = true;
				FlxG.sound.music.fadeOut(event1,0,function(t:FlxTween){
					new FlxTimer().start(event1,function(t:FlxTimer){
						stopNextDialogue = false;
						setDialog();
						visibleUI(true,true,event1);
						FlxG.sound.music.fadeOut(event1,1);
					});
				});
			// case 'back':
				// FlxG.camera.fade(FlxColor.BLACK,)
		}
		if (setDialogue) setDialog();
	}

	function visibleUI(visibleUI:Bool = true,?fade:Bool = false,?timeTween:Float = 0.5) {
		for (spr in dialogue.members){
			if (!fade) spr.visible = visibleUI;
			else {
				// spr.alpha = !visibleUI ? 0 : 1;
				FlxTween.tween(spr, {alpha: !visibleUI ? 0 : 1},timeTween);
			}
		}
	}

	function cacheDowload(mname:String) {
		phoneSound = new FlxSound();
		phoneSound.volume = 0;
		add(phoneSound);

		switch(mname){
			case 'girlText':
				phoneSound.loadEmbedded(Paths.sound('dialogue/drum'), true);
				// FlxG.sound.list.add(phoneSound);
			case 'girlText' | 'shameText' | 'prideText' | 'guiltyText':
				phoneSound.loadEmbedded(Paths.sound('dialogue/phone'), true);
		}


	}

	function chapterIntro(number:FlxTimer){
		// var chapterNum:FlxSprite = new FlxSprite();
		var groupChapter:FlxSpriteGroup = new FlxSpriteGroup();
		add(groupChapter);

		var textDown:String = 'testFuck';
		var colorBase:FlxColor = FlxColor.WHITE;
		var timeTweenFuck:Float = 2;
		
		var chapterText:FlxText = new FlxText();
		chapterText.setFormat(Paths.font("hello-sunday.otf"), 150, colorBase, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		chapterText.text = 'Chapter $curChapter';
		chapterText.scale.x = chapterText.scale.y = 0.5;
		chapterText.alpha = 0;
		chapterText.screenCenter();
		groupChapter.add(chapterText);

		var barBackDown:FlxSprite = new FlxSprite();
		barBackDown.makeGraphic(Std.int(chapterText.width + 50),3,colorBase);
		barBackDown.scale.x = barBackDown.scale.y = 0;
		groupChapter.add(barBackDown);


		FlxTween.tween(chapterText, {alpha: 1},(timeTweenFuck-0.5)/timeTweenFuck);
		FlxTween.tween(chapterText.scale, {x: 1, y: 1}, timeTweenFuck-1,{
			onUpdate: function(up:FlxTween) {
				chapterText.screenCenter();
				barBackDown.x = (chapterText.x - 20);
				barBackDown.y = (chapterText.y + chapterText.height) + 10;
			},
			onComplete: function(up:FlxTween) {
				FlxTween.tween(barBackDown.scale, {x: 1, y: 1}, (timeTweenFuck-1.0), {
					onComplete: function(up:FlxTween) {
						FlxTween.tween(groupChapter, {y: groupChapter.y - 50},timeTweenFuck-1.5);
						switch(curChapter){
							case 1:
								textDown = 'Syouko';
							case 2:
								textDown = 'Laith';
							case 3:
								textDown = 'Pride';
							case 4:
								textDown = 'Guilt';
						}

						var chapterDescText:FlxText = new FlxText();
						chapterDescText.setFormat(Paths.font("hello-sunday.otf"), 100, colorBase, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						chapterDescText.text = textDown;
						chapterDescText.y = barBackDown.y - (50/2);
						chapterDescText.scale.x = 0.7;
						chapterDescText.screenCenter(X);
						add(chapterDescText);
						chapterDescText.alpha = 0;

						FlxTween.tween(chapterDescText, {alpha: 1},timeTweenFuck-1);
						FlxTween.tween(chapterDescText.scale, {x: 1},timeTweenFuck-1.5);

						new FlxTimer().start((timeTweenFuck-1)+1.5,function(up:FlxTimer){
							FlxTween.tween(chapterDescText, {alpha: 0},1);
							FlxTween.tween(groupChapter, {alpha: 0},1,{
								onComplete: function(s:FlxTween){
									groupChapter.kill();
									remove(chapterDescText);
								}
							});
							if (talkDialogue[0].toLowerCase().trim() == '[empty]'){
								dialogue.members[1].visible = false;
							};
							FlxTween.tween(dialogue, {alpha: 1}, 1.5,{
								onComplete: function(up:FlxTween) {
									pressButton = false;
									setDialog();
								}
							});
						});
					}
				});
			}
		});
	}
}