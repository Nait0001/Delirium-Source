package shader;

import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;

class FilteredSprite extends FlxSprite {
    private var filter:BitmapFilter;

    public function new(bitmapData:BitmapData) {
        super();
        this.makeGraphic(bitmapData.width, bitmapData.height, 0x00000000);
        this.pixels.copyPixels(bitmapData, bitmapData.rect, new openfl.geom.Point(0, 0));
    }

    public function applyFilter(filter:BitmapFilter):Void {
        this.filter = filter;
        this.dirty = true;
    }

    // override public function draw():Void {
    //     if (this.filter != null) {
    //         this.pixels.applyFilter(this.pixels, this.pixels.rect, new openfl.geom.Point(0, 0), this.filter);
    //         this.filter = null;
    //         this.dirty = true;
    //     }
    //     super.draw();
    // }
}