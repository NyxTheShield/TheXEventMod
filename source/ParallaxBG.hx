package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

class ParallaxBG extends FlxSpriteGroup
{
    public var onUpdateCallback:Void->Void = null;

    public function InitBG(path:String, targetTime:Float) : FlxSpriteGroup {
        var targetSprite = new FlxSprite().loadGraphic(path);
        targetSprite.antialiasing = true;
        add(targetSprite);

        //Another targetSprite
        targetSprite = new FlxSprite().loadGraphic(path);
        targetSprite.x -= targetSprite.width;
        targetSprite.antialiasing = true;
        add(targetSprite);

        FlxTween.tween(this, {x: targetSprite.width}, targetTime,{
          type: FlxTween.LOOPING,
          onUpdate: function(twn:FlxTween){
              if (onUpdateCallback != null) onUpdateCallback();
          }
        });
        return this;
    }

}
