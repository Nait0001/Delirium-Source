package;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import openfl.geom.Rectangle;
import flixel.group.FlxSpriteGroup;

class HealthSystem extends FlxSpriteGroup {
    public var healthNum(default, set):Int = 6;
    private var fullBar:FlxSprite;
    private var cutFuck:FlxRect = null;
    private var cutRect:Float = 0;
    public function new(?x:Float,?y:Float) {
        super(x,y);

        var scl:Float = 0.6;


        
        // var blackBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('lifeFull'));
        // blackBar.setGraphicSize(Std.int(blackBar.width * scl));
        // blackBar.updateHitbox();
        // blackBar.color = FlxColor.WHITE;
        // add(blackBar);
        

        fullBar = new FlxSprite().loadGraphic(Paths.image('lifeFull'));
        fullBar.setGraphicSize(Std.int(fullBar.width * scl));
        fullBar.updateHitbox();
        add(fullBar);

        var emptyBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('life'));
        emptyBar.setGraphicSize(Std.int(emptyBar.width * scl));
        emptyBar.updateHitbox();
        add(emptyBar);

        cutRect = (fullBar.width*1.7);
        // setGraphicSize(Std.int(width * 0.95));
        // updateHitbox();
        // screenCenter();
        // updateHitbox();

        // (265)/
        cutFuck = new FlxRect(0, 0, cutRect, fullBar.height+120);
        healthNum = 6;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    var healhTween:FlxTween = null;
    function set_healthNum(Value:Int):Int 
    {
        var limitCut:Int = 6;
    
        if (Value > limitCut) Value = limitCut;
        else if(Value < 0) Value = 0;
                
    
        var MATH_ABS_VALUE:Float = Math.abs(Value-limitCut);
        var cutThing:Float = 0;
        cutThing = cutRect;
        trace(cutThing);
        if (Value != limitCut){
            cutThing -= (MATH_ABS_VALUE)*(cutRect/limitCut);
            cutThing /= 1.15;
            if (Value == 5) cutThing += 20;
        }

        // cutFuck.width = cutThing;
        // fullBar.clipRect = cutFuck;
        if (healhTween != null){
            healhTween.cancel();
        }

        healhTween = FlxTween.tween(cutFuck,{width: cutThing},0.2,{
            ease: FlxEase.circInOut,
            onUpdate: function(update:FlxTween){
                fullBar.clipRect = cutFuck;
            },
            onComplete: function(end:FlxTween){
                healhTween = null;
            }
        });
        
        
        return Value;
    }
}