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
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
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
import Controls.KeyboardScheme;
import Controls.Control;

using StringTools;

class RPGMainMenuState extends RPGState
{
	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Absolutely horrendous hack but HaxeFlixel forced my hand
		// Checks for the length of the current music to see if we are playing Fragmented Truce
		// If we dont, we play it.
		if (FlxG.sound.music.length != 213333)
		{
			FlxG.sound.playMusic(Paths.music('truce'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.7);
		}
		FlxG.debugger.drawDebug = false;
		FlxG.fixedTimestep = true;
		CreatePlayer();
		player.solid = false;
		followTarget = player;
		AddBackgroundLayers();
		player.currentState = 'dialog';
		LoadMainMenu();

		// Fixes controls not being set correctly
		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);
	}

	var playerScroll:Float;

	function LoadMainMenu()
	{
		FlxG.camera.setScrollBounds(0, 1280, -720, 720);
		FlxG.worldBounds.set(-100, -800, 1380, 2000);
		// Load PLayer
		FlxG.watch.add(this, "playerScroll", "playerScroll");
		player.screenCenter();
		player.y -= 400;
		FlxG.sound.play(Paths.sound('fall2', 'shared'), 0.7);
		FlxTween.tween(player, {y: 360, angle: 360 * 5}, 1, {
			ease: FlxEase.sineIn,
			onComplete: function(twn:FlxTween)
			{
				player.currentState = "movement";
				player.solid = true;
				followTarget = player;
				FlxG.camera.follow(followTarget, LOCKON, 1);
			}
		});

		// Load Graphics
		var rect = new FlxSprite().loadGraphic(Paths.image('xtalemenu', 'shared'));
		rect.antialiasing = true;
		rect.y = -720;
		bg0.add(rect);

		var rect = new FlxSprite().loadGraphic(Paths.image('xtalemenufg', 'shared'));
		rect.antialiasing = true;
		rect.y = -720;
		fg1.add(rect);

		FlxTween.num(0.7, 1, 0.49, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut}, function(val:Float)
		{
			rect.alpha = val;
		});

		var rect = new FlxSprite().loadGraphic(Paths.image('xtalemenulight', 'shared'));
		rect.antialiasing = true;
		rect.y = -720;
		// fg1.scrollFactor.set();
		fg1.add(rect);

		// Tween Lights
		FlxTween.num(0.4, 1, 2, {type: FlxTweenType.PINGPONG}, function(val:Float)
		{
			rect.alpha = val;
			playerScroll = 1 - Math.abs(FlxMath.bound(player.y, -650, 0)) / 650;
			rect.alpha = rect.alpha * playerScroll;
		});

		// Dialogs
		var dialogTrig = CreateDialogTrigger(["A Gamecube hooked to an old TV", "Super Smashing Fighters is playing on it."],
			[FlxColor.WHITE, FlxColor.WHITE], [1, 2], function()
		{
			return FlxG.switchState(new FreeplayState());
		});
		dialogTrig.interactSprite.text = "FREEPLAY MODE";
		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(1.5, 1.5);
		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.x = 295;
		dialogTrig.y = -488;
		dialogTrig.alpha = 0.05;
		dialogTrig.updateHitbox();
		dialogTrig.alertOffset = 110;
		dialogTrig.UpdatePosition();

		var dialogTrig = CreateDialogTrigger(["A PC running Windows XP.", "The control panel is open."], [FlxColor.WHITE, FlxColor.WHITE], [1, 2], function()
		{
			return FlxG.switchState(new OptionsMenu());
		});
		dialogTrig.interactSprite.text = "OPTIONS MENU";
		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(1.5, 1.5);
		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.x = 957;
		dialogTrig.y = -478;
		dialogTrig.alpha = 0.05;
		dialogTrig.updateHitbox();
		dialogTrig.alertOffset = 110;
		dialogTrig.UpdatePosition();

		var dialogTrig = CreateDialogTrigger(["The light blinds you."], [FlxColor.WHITE], [1], function()
		{
			return FlxG.switchState(new StoryMenuState());
		});
		dialogTrig.interactSprite.text = "STORY MODE";
		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(1.5, 1.5);
		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.alpha = 0.05;
		dialogTrig.updateHitbox();

		dialogTrig.setSize(dialogTrig.width * 3, dialogTrig.width * 3);
		dialogTrig.offset.set(dialogTrig.offset.x - 30, dialogTrig.offset.y - 60);

		dialogTrig.x = 625 - 30;
		dialogTrig.y = -508 - 60;

		dialogTrig.alertOffset = 110;
		dialogTrig.UpdatePosition();

		// Easter egg
		var dialogTrig = new OneshotTrigger();

		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(2.5, 2.5);
		dialogTrig.updateHitbox();

		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.x = 890;
		dialogTrig.y = 964;
		dialogTrig.alpha = 0;
		dialogTrig.onTriggerEnterCallback = function() return
		{
			player.currentState = "dialog";
			trace("Easter egg!");
			FlxG.sound.play(Paths.sound('dog', 'shared'), 1);
			box = new DialogBox();
			box.totalTime = 0.7;
			box.InitBox("A white dog barks at you");
			hud.add(box);
			box.onCompleteCallback = function(dummy:Array<String>)
			{
				player.currentState = "movement";
				DeleteDialog(box);
			}
			// CreateDialogSequence(["A white dog barks at you", "...", "they ran away."]);
		};

		interactableCollisions.add(dialogTrig);

		currentLevel = LoadLevelCollision(Paths.csv('xeventbg/menu', 'shared'), Paths.image('xeventbg/tiles16', 'shared'), 0, 0);
		currentLevel.y += -720 - 16;
		currentLevel.x += 16;
		levelCollision.add(currentLevel);
	}
}
