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

class InteractableObject extends FlxSprite
{
	public var objectID:String = "default";
	public var isEnabled:Bool = true;
	public var isActive:Bool = false;
	public var isColliding:Bool = false;
	public var reactivateAfterTriggered:Bool = true;

	public var callbackParams:Array<String>;
	public var onActivateCallback:Array<String>->Void;
	public var onCompleteCallback:Void->Void;

	public function OnCollideCallback():Bool
	{
		if (!isEnabled)
			return false;
		if (isActive)
			return false;
		isColliding = true;
		return true;
	}

	public function OnActivate()
	{
		isActive = true;
		onActivateCallback(callbackParams);
	}

	public function EnableInteractable(activeVal:Bool = true, enabledVal:Bool = true)
	{
		isActive = activeVal;
		isEnabled = enabledVal;
	}
}
