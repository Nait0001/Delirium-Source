package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class FreeplayAlphabet extends FlxSpriteGroup {
	public var targetY:Int = 0;
	public var distancePerItem:FlxPoint = new FlxPoint(700, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

	public var isMenuItem:Bool = false;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var doorSunday:FlxSprite;
	// public var colorDoor(default, set):FlxColor = FlxColor.WHITE;
	public function new(x:Float, y:Float, ?coloru:FlxColor = FlxColor.WHITE, ?text:String = "") {
		super(x,y);
		// colorDoor = coloru;
		doorSunday = new FlxSprite(0,0).loadGraphic(Paths.image('door'));
		var bladoorSunday = new FlxSprite(0,0).makeGraphic(Std.int(doorSunday.width),Std.int(doorSunday.height),FlxColor.BLACK);

		// set_colorDoor()
		var textSundayText:FlxText = new FlxText(0,0,0,text);
		textSundayText.setFormat("Hello Sunday", 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textSundayText.setPosition(
			(doorSunday.width - textSundayText.width)/2,
			-100
		);

		add(bladoorSunday);
		add(doorSunday);
		add(textSundayText);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			if(changeX)
				x = FlxMath.lerp(x, (targetY * 1.3 * distancePerItem.x) + startPosition.x, lerpVal);
			if(changeY)
				y = FlxMath.lerp(y, (targetY * distancePerItem.y) + startPosition.y, lerpVal);
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if(changeX)
				x = (targetY * 1.3 * distancePerItem.x) + startPosition.x;
			if(changeY)
				y = (targetY * distancePerItem.y) + startPosition.y;
		}
	}

	// function set_colorDoor(value:FlxColor):FlxColor {
	// 	doorSunday.color = value;
	// 	return value;
	// }
}