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

class DialogBox extends FlxSpriteGroup
{
    var text:FlxText;
    var spriteBox:FlxSprite;
    var fullText:String;
    var lastLength : Int = -1;
    var textTween:FlxTween;
    public var totalTime:Float = 2;

    public var callbackParams:Array<String>;
    public var onCompleteCallback:Array<String>->Void;

    public function InitBox(newText:String){

        spriteBox = new FlxSprite().loadGraphic(Paths.image('undertale_box', 'shared'));
        spriteBox.screenCenter();
        spriteBox.y+=200;
        spriteBox.updateHitbox();

        fullText = newText;
        text = new FlxText(0, 0, 500, newText, 24);
				text.bold = true;
				text.screenCenter();
        text.x += 15;
        text.y -= 50 - text.height/2;
        text .y+=200;
				text.alignment = "left";
				text.borderColor = FlxColor.BLACK;
				text.borderSize = 8;
				text.borderStyle = FlxTextBorderStyle.OUTLINE;
        text.text = "";
        this.add(spriteBox);
        this.add(text);

        //Char by char
        textTween = FlxTween.tween(text, {alpha: 1}, totalTime, {

            onUpdate: function(tween:FlxTween)
            {
                var range:Int = Math.floor(tween.percent*fullText.length);
                text.text = fullText.substr(0, range+1);
                if (lastLength != range){
                    lastLength = range;
                    FlxG.sound.play(Paths.sound('undertale_text_sfx', 'shared'));
                }
            }
        });
    }

    public function SkipDialog(){
        if (textTween.scale < 0.1) return;
        if (textTween.active){
            textTween.cancel();
            text.text = fullText;
        }
        else{
            if (onCompleteCallback != null) onCompleteCallback(callbackParams);
        }
    }

    override function update(elapsed:Float)
  	{
        super.update(elapsed);
        if (FlxG.keys.anyJustPressed([SPACE])) SkipDialog();
    }

    public function SetTextColor(col:FlxColor){
      text.color = col;
    }
}
