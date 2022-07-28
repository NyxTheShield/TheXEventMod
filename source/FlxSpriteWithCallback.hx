package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;

using StringTools;

class FlxSpriteWithCallback extends FlxSprite
{
	public var animationCallbacks:Map<String, Void->Void> = [];

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.animation.finishCallback = CallbackFunction;
	}

	public function CallbackFunction(animName:String):Void
	{
		try
		{
			if (animationCallbacks.exists(animName))
				animationCallbacks[animName]();
		}
		catch (e)
		{
			trace("There is no callback for animation:" + animName);
		}
	}
}
