package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;

using StringTools;

class NyxDialog extends FlxSpriteGroup
{
	var currDialog:FlxSprite;
	var dialogueList:Array<String> = [];
  var soundList:Array<String> = [];
  var charZooms:Array<Bool> = [];

  public var fadeTime:Float = 0.3;
  public var holdTime:Float = 2;
	public var onCompleteCallback:Void->Void;
  public var onFocusCallback:Bool->Void;

	public function new(dial:Array<String>, sfx:Array<String>, ?zooms:Array<Bool>, ?camFollow:FlxObject )
	{
		super();
    trace("Created dialog!!");
    trace(dial);
    dialogueList = dial;
    soundList = sfx;
    charZooms = zooms;
    /*
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);
    FlxG.sound.play(Paths.sound('clickText'), 0.8);
    */
	}

	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (!dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
      trace("Started Dialog!!");
      return;
		}

		if (FlxG.keys.justPressed.SPACE)
		{
        cleanDialog();
		}
		super.update(elapsed);
	}

  var currentTween:FlxTween;

	function startDialogue():Void
	{
    if (dialogueList.length == 0){
        onCompleteCallback();
        this.kill();
        return;
    }

    var imageName = dialogueList.shift();
    var soundName = soundList.shift();
    trace(imageName);
    trace(dialogueList);
    currDialog = new FlxSprite(0, 0).loadGraphic(Paths.image(imageName));
    currDialog.antialiasing = true;
    currDialog.scrollFactor.set(0, 0);
    currDialog.alpha = 0;
    add(currDialog);

    if (charZooms.length > 0){
        onFocusCallback(charZooms.shift());
    }

    FlxG.sound.play(Paths.sound(soundName), 0.8);

    currentTween = FlxTween.tween(currDialog, { alpha: 1 }, fadeTime, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){holdDialogue();} });
	}

  function holdDialogue(){
      currentTween = FlxTween.tween(currDialog, { alpha: 1 }, holdTime,
          {ease: FlxEase.quadInOut ,
           onComplete: function(twn:FlxTween)
              {
                endDialog();
              }
          }
      );
  }

  function endDialog(){
      currentTween = FlxTween.tween(currDialog, { alpha: 0 }, fadeTime,
          {ease: FlxEase.quadInOut ,
           onComplete: function(twn:FlxTween)
              {
                cleanDialog();
              }
          }
      );
  }

  function cleanDialog():Void{
      currentTween.cancel();
      currDialog.destroy();
      startDialogue();
  }


}
