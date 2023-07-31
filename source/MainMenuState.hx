package;

import openfl.filters.ShaderFilter;
import openfl.filters.ColorMatrixFilter;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import openfl.display.BlendMode;
import shader.ShaderInvert;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.addons.effects.FlxTrail;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxSpriteGroup;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		// #if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var debugKeys:Array<FlxKey>;
	var logoBl:FlxSprite;

	public static var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var bgTweem:FlxSpriteGroup;
	private var tweenSeparation:Float = (FlxG.height/2)+100;
	var versionText:FlxSpriteGroup;
	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		

		// FlxG.camera.flash(FlxColor.WHITE, 4);
		var musicTime = 17.377960*1000;

		if (FlxG.sound.music.time <= musicTime){
			FlxG.sound.music.time = musicTime;
		}

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		// FlxG.sound.music.fadeTween(0.7, 1);
		FlxG.sound.music.fadeIn(0.5,FlxG.sound.music.volume,1);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.camera.fade(FlxColor.BLACK, 4, true);
		persistentUpdate = persistentDraw = true;

		var grassBack:FlxBackdrop = new FlxBackdrop();
		grassBack.makeGraphic(FlxG.width,FlxG.height,0xFFffff94);
		add(grassBack);

		var bgSolidBackdrop:FlxBackdrop = new FlxBackdrop();
		bgSolidBackdrop.makeGraphic(FlxG.width,FlxG.height,0xFFf9aced);
		bgSolidBackdrop.repeatAxes = X;
		add(bgSolidBackdrop);

		// var grassSpr:FlxSprite = new FlxSprite();
		var grassSpr:FlxBackdrop = new FlxBackdrop();
		grassSpr.repeatAxes = X;

		// var grassBackSpr:FlxSprite = new FlxSprite();
		var grassBackSpr:FlxBackdrop = new FlxBackdrop();
		grassBackSpr.repeatAxes = X;

		grassSpr.frames = Paths.getSparrowAtlas('bgTitle/grass');
		grassSpr.animation.addByPrefix('idle', 'graas idle', 3);
		grassSpr.animation.play('idle');
		grassSpr.updateHitbox();
		grassSpr.y = FlxG.height - grassSpr.height;


		grassBackSpr.frames = Paths.getSparrowAtlas('bgTitle/gramalaranja');
		grassBackSpr.animation.addByPrefix('idle_orage', 'graas_orage idle', 3);
		grassBackSpr.animation.play('idle_orage');
		grassBackSpr.updateHitbox();
		grassBackSpr.y = FlxG.height - grassBackSpr.height;
		var chair:FlxSprite = new FlxSprite(1050,350).loadGraphic(Paths.image('bgTitle/chair'));

		var clound:FlxBackdrop = new FlxBackdrop(Paths.image('bgTitle/nuvem'),X,10);
		clound.velocity.x = 20;
		
		bgTweem = new FlxSpriteGroup();
		add(bgTweem);

		logoBl = new FlxSprite();
		logoBl.loadGraphic(Paths.image('delirium'));
		logoBl.screenCenter();
		logoBl.updateHitbox();

		bgTweem.add(clound);
		bgTweem.add(grassBackSpr);
		bgTweem.add(chair);
		bgTweem.add(grassSpr);


		// FlxTween.tween(grassSpr, {x: -50}, 1, {type: PINGPONG, ease: FlxEase.smoothStepInOut});



		// FlxG.camera.setFilters([new ColorMatrixFilter(matrix___)]);
		
		// logoBl.shader = new BitmapFilterShader(new ColorMatrixFilter(matrix___));
		// logoBl.color.getInverted()

		// spr.blend = BlendMode.INVERT;

		// var trail:FlxTrail = new FlxTrail(logoBl,null,10,4,0.2,0.05);
		var angulo:Float = 3;

		logoBl.angle = -angulo;
		FlxTween.tween(logoBl, {angle: angulo*2},1.5, {ease: FlxEase.smoothStepInOut, type: PINGPONG});
		// add(trail);
		add(logoBl);
		// logoBl.shader = swagShader.shader;

		bgTweem.y = tweenSeparation;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, FlxG.width, FlxG.height/1.5);
		add(camFollow);
		add(camFollowPos);		

		menuItems = new FlxSpriteGroup();
		add(menuItems);

		for (i in 0...bgTweem.members.length){
			bgTweem.members[i].scrollFactor.x = (i/10)*3.5;
		}

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		// logoBl.shader = new ShaderInvert();

		versionText = new FlxSpriteGroup();
		add(versionText);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Delirium v" + '1.0', 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.add(versionShit);
		versionText.alpha = 0;

		versionText.scrollFactor.set();

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		FlxG.camera.follow(camFollowPos,null,1);

		super.create();
	}

	function addButton(?logo:Bool = false) {
		menuItems.clear();
		// menuItems.kill();
		for (i in 0...optionShit.length){
			// var realNameText:String = optionShit[i].replace("_", " ");
			// var text:FlxText = new FlxText(0,0,0,realNameText,30);

			var text:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('bgTitle/button/' + optionShit[i]));
			text.screenCenter(X);
			text.x -= 200;
			text.x += i*300;
			text.x += 30;

			text.ID = i;
			menuItems.add(text);
			text.y = FlxG.height + 100;

			text.setGraphicSize(Std.int(text.width * 0.35));
			text.updateHitbox();
			var logoFuck:Float = logoBl.height;
			if (logo) logoFuck += 100;

			FlxTween.tween(text, {y: ((logoBl.y + logoFuck) - 50)}, 0.4+((i*2)/10), {ease: FlxEase.backOut});
			// menuItems.add(menuItem);
			changeItem();
		}
		FlxTween.tween(versionText, {alpha: 1}, 0.5);
	}


	override function beatHit()
	{
		super.beatHit();
	
		if (curBeat % 2 == 0 && bumpLogo){
			var scl:Float = 0.9;
			logoBl.setGraphicSize(Std.int(logoBl.width * scl),Std.int(logoBl.height * scl));
			FlxTween.tween(logoBl.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.elasticOut});
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	private var addButtonBool:Bool = false;
	private var bumpLogo:Bool = true;

	override function update(elapsed:Float)
	{
		// if (FlxG.sound.music.volume < 0.8){
		// 	FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		// 	if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		// }


		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if (logoBl != null && bumpLogo)	{
			logoBl.updateHitbox();
			logoBl.screenCenter();

			if (addButtonBool){
				logoBl.y -= 100;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (controls.BACK && !FreeplaySubState.exitFreeplay && selectedSomethin)
		{	
			camFollow.x = 0;
			new FlxTimer().start(0.5,function(t:FlxTimer){
				addButton(FreeplaySubState.exitFreeplay);
				FreeplaySubState.exitFreeplay = false;
				selectedSomethin = false;
			});
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				if(addButtonBool) FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				if(addButtonBool) FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (!FreeplaySubState.exitFreeplay)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.1);
					trace(addButtonBool);
					if (!addButtonBool){
						addButton();
						for (i in 0...bgTweem.members.length) FlxTween.tween(bgTweem.members[i], {y: bgTweem.members[i].y + (-tweenSeparation)}, 1.2+((i+1)/10), {ease: FlxEase.circInOut});
						
						FlxTween.tween(logoBl,{y: FlxG.height}, 1.5, {ease: FlxEase.backIn});
						// logoBl.y -= 100;
						bumpLogo = false;
						FlxTween.tween(logoBl, {y: logoBl.y -100}, 0.5, {ease: FlxEase.backOut, onComplete: function(a:FlxTween){bumpLogo = true;}});
						addButtonBool = true;
					} else {
						var timeFlick:Float = 1.5;
						var yThing:Float = camFollow.y;
						var xThing:Float = (camFollow.x+1)*1000;
						if (optionShit[curSelected] != 'freeplay'){
							
							if (optionShit[curSelected] == 'credits'){
								xThing = camFollow.x;
								yThing += 4000;
							} else 
							FlxG.camera.fade(FlxColor.BLACK, 1.2, false, null, true);
						} else timeFlick = 0.3;
						
						FlxTween.tween(camFollow, {x: xThing, y: yThing}, timeFlick, {ease: FlxEase.quartIn, onComplete: function(t:FlxTween){	
							if (optionShit[curSelected] == 'freeplay'){			
								new FlxTimer().start(0.3,function(n:FlxTimer) {
									openSubState(new FreeplaySubState());
								});							
							}
						}});
						if (optionShit[curSelected] == 'donate')
						{
							CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
						}
						else
						{
							FlxTween.tween(versionText, {alpha: 0}, 0.5);
							selectedSomethin = true;

							menuItems.forEach(function(spr:FlxSprite)
							{
								if (curSelected != spr.ID)
								{
									FlxTween.tween(spr, {alpha: 0}, 0.4, {
										ease: FlxEase.quadOut,
										onComplete: function(twn:FlxTween)
										{
											spr.kill();
										}
									});
								}
								else
								{
									FlxFlicker.flicker(spr, timeFlick, 0.06, false, false, function(flick:FlxFlicker)
									{
										var daChoice:String = optionShit[curSelected];

										switch (daChoice)
										{
											case 'story_mode':

											// PlayState.storyDifficulty = curDifficulty;
											var songArray:Array<String> = ["Syouko","Shame","Pride"];
											PlayState.storyPlaylist = songArray;
											PlayState.isStoryMode = true;

											PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
											PlayState.campaignScore = 0;
											PlayState.campaignMisses = 0;
											// LoadingState.loadAndSwitchState(new PlayState(), true);
											DialogueState.debugMode = false;
											LoadingState.loadAndSwitchState(new DialogueState(), true);
											DialogueState.curChapter = 1;
					

											//curChapter
											FreeplaySubState.destroyFreeplayVocals();
											case 'freeplay':

											case 'awards':
												MusicBeatState.switchState(new DialogueState());
											case 'credits':
												FlxTransitionableState.skipNextTransIn = true;
												FlxTransitionableState.skipNextTransOut = true;
												MusicBeatState.switchState(new CreditsState());
											case 'options':
												LoadingState.loadAndSwitchState(new options.OptionsState());
										}
									});
								}
							});
						}
					}
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new editors.MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		// trace(menuItems.length);
		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;


		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr != null){
				var localArchive:String = optionShit[spr.ID];
				// spr.color = FlxColor.WHITE;
				// spr.color.saturation = 0;
				// spr.blend = BlendMode.NORMAL;
				// camFollow.setPosition(
				// 		spr.getGraphicMidpoint().x, 
				// 		spr.getGraphicMidpoint().y);

				if (spr.ID == curSelected) {
					camFollow.x = (spr.ID*15)-30;
					// spr.colorTransform.greenOffset = 5;
					// spr.color.saturation = 1;
					// spr.blend = BlendMode.ADD;
					FlxTween.shake(spr, 0.01, 0.1);
					localArchive += '_invert';
				}

				spr.loadGraphic(Paths.image('bgTitle/button/' + localArchive));
			}
		});
	}
}
