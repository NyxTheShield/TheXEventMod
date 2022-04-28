package;


import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxTileFrames;
import flixel.addons.tile.FlxTilemapExt;
import openfl.Assets;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;


using StringTools;

class Curtain extends FlxSpriteGroup
{
    var curtainSprite:FlxSprite = new FlxSprite();

    public function new()
    {
      super();
      curtainSprite = curtainSprite.makeGraphic(FlxG.width, FlxG.height);
      this.add(curtainSprite);
      curtainSprite.alpha = 0;
      this.scrollFactor.set();
    }

    var currentTween:FlxTween;

    function CancelCurrentTween(){
        if (currentTween != null) currentTween.cancel();
    }

    public function FadeIn(time:Float, ?callbackFunc:Void->Void=null): Void {
        CancelCurrentTween();
        currentTween = FlxTween.tween(curtainSprite, {alpha:1}, time,
          {onComplete:
            function(twn:FlxTween){
              if (callbackFunc != null) callbackFunc();
            }
          }
        );
    }

    public function FadeOut(time:Float, ?callbackFunc:Void->Void=null): Void {
        CancelCurrentTween();
        currentTween = FlxTween.tween(curtainSprite, {alpha:0}, time,
          {onComplete:
            function(twn:FlxTween){
              if (callbackFunc != null) callbackFunc();
            }
          }
        );
    }

    //Fades in and back
    public function Transition(time:Float, holdTime:Float, ?callback:Void->Void=null): Void {
        CancelCurrentTween();
        FadeIn(time, function(){FadeIn(time, function(){FadeOut(time, callback);}  );});
    }

    //Full brightness into fadeout
    public function Flash(time:Float, holdTime:Float, ?callback:Void->Void=null): Void {
        CancelCurrentTween();
        curtainSprite.alpha = 1;
        FadeIn(time, function(){FadeOut(time, callback);});
    }

    public function SetColor( ?col:FlxColor = FlxColor.WHITE ) : Void {
        this.curtainSprite.color = col;
    }
}
