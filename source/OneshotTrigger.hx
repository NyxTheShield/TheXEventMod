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

class OneshotTrigger extends InteractableObject
{
	public var onTriggerEnterCallback:Void->Void;

	public override function OnCollideCallback():Bool
	{
		if (!isEnabled)
			return false;
		if (isActive)
			return false;
		onTriggerEnterCallback();
		EnableInteractable(false);
		this.kill();
		return true;
	}
}
