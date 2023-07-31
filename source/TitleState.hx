package;

import openfl.filters.GlowFilter;
import flixel.addons.effects.FlxTrail;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.addons.display.FlxBackdrop;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED 
			Paths.pushGlobalMods(); 
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized) {
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
			MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
			MusicBeatState.switchState(new ChartingState());
		#else
			if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new FlashingState());
			} else {
				#if desktop
				if (!DiscordClient.isInitialized)
				{
					DiscordClient.initialize();
					Application.current.onExit.add (function (exitCode) {
						DiscordClient.shutdown();
					});
				}
				#end

				if (initialized)
					startIntro();
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						startIntro();
					});
				}
			}
		#end
	}

	var logoBl:FlxSprite;
	var logoPosCat:FlxSprite;
	var logoBlDeli:FlxSprite;
	var sclPosCat:Float = 1.2;
	function startIntro()
	{
		if (!initialized) {
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(69);
		persistentUpdate = true;

		var bgSolidBackdrop:FlxSprite = new FlxSprite();
		bgSolidBackdrop.makeGraphic(FlxG.width,FlxG.height,0xFFf9aced);
		// bgSolidBackdrop.repeatAxes = X;
		add(bgSolidBackdrop);

		
		var clound:FlxBackdrop = new FlxBackdrop(Paths.image('bgTitle/nuvem'),X,10);
		clound.velocity.x = 20;
		clound.y = (FlxG.height/2)+100;
		add(clound);


		logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.7));
		logoBl.updateHitbox();
		logoBl.screenCenter();




		logoBl.visible = false;
		add(logoBl);

		var animFrames:Array<FlxFrame> = [];

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		var poscatLogo:String = 'PoscatSTUDIOS_LOGO';

		if (FlxG.random.bool(10)) poscatLogo += '_KISS';
		logoPosCat = new FlxSprite().loadGraphic(Paths.image(poscatLogo));
		logoPosCat.antialiasing = ClientPrefs.globalAntialiasing;
		logoPosCat.setGraphicSize(Std.int(ngSpr.width * sclPosCat));
		logoPosCat.updateHitbox();
		logoPosCat.screenCenter();
		add(logoPosCat);
		logoPosCat.visible = false;

		logoBlDeli = new FlxSprite();
		logoBlDeli.loadGraphic(Paths.image('delirium'));
		logoBlDeli.screenCenter();
		logoBlDeli.updateHitbox();
		add(logoBlDeli);
		logoBlDeli.visible = false;



		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
			
				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			// var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			var money:FlxText = new FlxText(0,0,0,textArray[i]);
			money.setFormat("Hello Sunday", 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
			FlxTween.shake(money, 0.02, 0.1);

		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			// var coolText:Alphabet = new Alphabet(0, 0, text, true);
			var coolText:FlxText = new FlxText(0,0,0,text);
			coolText.setFormat("Hello Sunday", 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
			FlxTween.shake(coolText, 0.02, 0.1);

		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	// override function beatHit()
	// {
	// 	super.beatHit();

	// 	if(!closedState) {
	// 		sickBeats++;
	// 		switch (sickBeats)
	// 		{
	// 			case 17:
	// 				skipIntro();
	// 		}
	// 	}
	// }

	var zoomTween:FlxTween = null;
	// var cutPart:Bool = false;
	override function stepHit() {
		super.stepHit();

		if(!closedState) {
			sickBeats++;
			switch (sickBeats){
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					visibleAwesome(logoBl);
				case 4:
					visibleAwesome(logoBl);
				case 10:
					createCoolText(["PosCat Studios"]);
				case 12:
					addMoreText('Pres');

					// zoomTween = FlxTween.tween(logoPosCat.scale, 
					// 	{x: sclPosCat + 0.3, y: sclPosCat + 0.3}, 
					// 2);
					// logoPosCat.visible = true;
				case 15:
					deleteCoolText();
					createCoolText(["PosCat Studios"]);
					addMoreText('Present');
					// zoomTween.cancel();


					// FlxTween.tween(glow, {alpha: 0}, 0.5);
				case 20:
					deleteCoolText();
					visibleAwesome(logoPosCat);

					sclPosCat += 0.3;

					logoPosCat.setGraphicSize(Std.int(ngSpr.width * sclPosCat));
					logoPosCat.updateHitbox();
					logoPosCat.screenCenter();
				case 25:
					sclPosCat += 0.3;
					logoPosCat.setGraphicSize(Std.int(ngSpr.width * sclPosCat));
					logoPosCat.updateHitbox();
					logoPosCat.screenCenter();
					visibleAwesome(logoPosCat,false);
				case 30:
					visibleAwesome(logoPosCat);
				case 33:
					// CreditsState.posCatStudioCredits[0]
					addMoreText(CreditsState.posCatStudioCredits[0][0]);
				case 35:
					addMoreText(CreditsState.posCatStudioCredits[1][0]);
				case 38:
					addMoreText(CreditsState.posCatStudioCredits[2][0]);
					addMoreText(CreditsState.posCatStudioCredits[3][0]);
				case 40:
					addMoreText(CreditsState.posCatStudioCredits[4][0]);
					addMoreText(CreditsState.posCatStudioCredits[5][0]);
				case 44:
					deleteCoolText();
					// provavel mostre os icones
				case 50:
					deleteCoolText();
					createCoolText(["Psych Engine by"], 15);
				case 53:
					addMoreText('Shadow Mario', 15);
				case 55:
					addMoreText('RiverOaken', 15);
					addMoreText('shubs', 15);
				case 60:
					deleteCoolText();
					createCoolText(["For FNF Jam Mod"], 15);
				case 65:
					deleteCoolText();
				case 70:
					createCoolText(['Not associated', 'with'], -40);
				case 73:
					addMoreText('newgrounds', -40);
					visibleAwesome(ngSpr);
				case 75:
					visibleAwesome(ngSpr);
					visibleAwesome(logoBlDeli);
					deleteCoolText();
					logoBlDeli.alpha = 0;
					logoBlDeli.alpha += 0.5;
					sclPosCat = 1;
					// createCoolText(['Delir']);
				case 78:
					visibleAwesome(logoBlDeli,false);
					// deleteCoolText();	
					sclPosCat += 0.5;
					logoPosCat.setGraphicSize(Std.int(ngSpr.width * sclPosCat));
					logoPosCat.updateHitbox();
					logoPosCat.screenCenter();
					logoBlDeli.alpha += 0.5;
					// createCoolText(['Delirium']);
				case 80:
					skipIntro();
			}

		}
	}



	private function visibleAwesome(spr:FlxSprite, visible = true) {
		if(visible) spr.visible = !spr.visible;
		FlxTween.shake(spr, 0.02, 0.1);
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		// FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		if (!skippedIntro)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new MainMenuState());
		}
	}
}
