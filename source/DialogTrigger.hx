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

class DialogTrigger extends InteractableObject
{
    public var stringsSequence:Array<String>;
    public var colorSequence:Array<FlxColor>;
    public var timingSequence:Array<Float>;
    public var interactSprite:FlxText;

    public var fadeTween:FlxTween;
    public var justEnteredCollision:Bool = false;
    public var alertOffset = 35;

    public function new(x:Float=0, y:Float=0){
        super(x,y);
        SetInteractText();
    }

    public function SetInteractText(newText:String = "!", newWidth:Int=300, fontSize:Int = 24) : Void {
        interactSprite = new FlxText(0, 0, newWidth, newText, fontSize);
        interactSprite.bold = true;
        interactSprite.alignment = "center";
        interactSprite.borderColor = FlxColor.BLACK;
        interactSprite.borderSize = 2;
        interactSprite.borderStyle = FlxTextBorderStyle.OUTLINE;
        interactSprite.alpha = 0;
    }

    public function UpdatePosition(){
        interactSprite.x = this.x + this.width/2 - interactSprite.width/2;
        interactSprite.y = this.y - alertOffset;


        fadeTween = FlxTween.tween(interactSprite, {y: interactSprite.y-15}, 0.5, {ease: FlxEase.circOut, type: FlxTween.PINGPONG});
    }

    override function update(elapsed:Float)
  	{
        /*
        if (isColliding && isEnabled && !isActive && justEnteredCollision == false){
            justEnteredCollision = true;
            fadeTween = FlxTween.tween(interactSprite, {alpha: 1}, 0.4, {ease: FlxEase.circOut});
        }
        else{
            if (!isColliding && justEnteredCollision == true){
                justEnteredCollision = false;
                fadeTween.cancel();
                fadeTween = FlxTween.tween(interactSprite, {alpha: 0}, 0.4, {ease: FlxEase.circOut});
            }
        }*/
        if (isColliding && isEnabled && !isActive) interactSprite.alpha = 1;
        else interactSprite.alpha = 0;
        super.update(elapsed);
  	}


    public override function OnCollideCallback():Bool{
        if (!super.OnCollideCallback()){
            return false;
        }
        isColliding = true;
        //trace("Colliding with a text object!");
        if (FlxG.keys.anyJustPressed([SPACE])){
            OnActivate();
            isActive = true;
        }
        return true;
    }

    public override function OnActivate(){
        super.OnActivate();
    }

    public function SetDialog(values:Array<String>, ?cols:Array<FlxColor>=null, ?times:Array<Float> = null){
        if (values != null) callbackParams = values.copy();
        if (values != null) stringsSequence = values.copy();
        if (cols!=null) colorSequence = cols.copy();
        if (times != null) timingSequence = times.copy();
    }

    public function ResetDialog(){
        callbackParams = stringsSequence.copy();
    }

    public function GetCurrColor():FlxColor{
        if (colorSequence != null) return colorSequence[stringsSequence.length - callbackParams.length];
        return FlxColor.WHITE;
    }

    public function GetCurrTiming():Float{
        if (timingSequence != null) return timingSequence[stringsSequence.length - callbackParams.length];
        return 2;
    }

}
