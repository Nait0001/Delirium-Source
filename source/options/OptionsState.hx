package options;

import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var bgTweem:FlxSpriteGroup;
	public static var inOTherState:Bool = false;
	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		persistentUpdate = true; 
		inOTherState = false;

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

		var clound:FlxBackdrop = new FlxBackdrop(Paths.image('bgTitle/nuvem'),X,10);
		clound.velocity.x = 20;
		
		bgTweem = new FlxSpriteGroup();
		add(bgTweem);

		bgTweem.add(clound);
		bgTweem.add(grassBackSpr);
		bgTweem.add(grassSpr);

		var fakeParalax:Float = 100;
		grassSpr.velocity.x = -fakeParalax;
		grassBackSpr.velocity.x = -(fakeParalax/2.5);
		clound.velocity.x = -(fakeParalax/3.5);

		
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			// var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			var optionText:FlxText = new FlxText(0,0,0,options[i]);
			optionText.setFormat("Hello Sunday", 80, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.screenCenter(Y);
			optionText.ID = i;
			optionText.x = 20;
			optionText.y += (180 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!inOTherState){
			grpOptions.visible = true;
			
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT) {
				inOTherState = true;
				grpOptions.visible = false;
				openSelectedSubstate(options[curSelected]);
			}
		}
	}
	
	var tweenText:FlxTween = null;
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		grpOptions.forEach(function(spr:FlxText){
			spr.text = spr.text.replace("> ","");
			spr.alpha = 0.7;
			if (curSelected == spr.ID){
				spr.alpha = 1;
				spr.text = '> ' + spr.text;

				tweenText = FlxTween.tween(spr, {x: spr.x + 60}, 0.3,{ease: FlxEase.circOut});
			} else
				tweenText = FlxTween.tween(spr, {x: 20}, 0.3,{ease: FlxEase.circInOut,});
			
		});
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
	}
}