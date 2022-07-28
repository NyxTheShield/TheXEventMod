package;

#if android
import android.flixel.FlxJoyStick;
#end
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

using StringTools;

class RPGState extends MusicBeatState
{
	var player:RPGBoyfriend;
	var levelCollision:FlxGroup = new FlxGroup();
	var interactableCollisions:FlxSpriteGroup = new FlxSpriteGroup();
	var bg0:FlxSpriteGroup = new FlxSpriteGroup();
	var bg1:FlxSpriteGroup = new FlxSpriteGroup();
	var bg2:FlxSpriteGroup = new FlxSpriteGroup();
	var bg3:FlxSpriteGroup = new FlxSpriteGroup();
	var bg4:FlxSpriteGroup = new FlxSpriteGroup();
	var bg5:FlxSpriteGroup = new FlxSpriteGroup();
	var groundLayer:FlxSpriteGroup = new FlxSpriteGroup();
	var mapUILayer:FlxSpriteGroup = new FlxSpriteGroup();
	var playerLayer:FlxSpriteGroup = new FlxSpriteGroup();
	var fg1:FlxSpriteGroup = new FlxSpriteGroup();
	var hud:FlxSpriteGroup = new FlxSpriteGroup();
	var followTarget:FlxObject;

	var box:DialogBox;
	var currInteractable:InteractableObject;
	var currentLevel:FlxTilemapExt;
	var cachedLevel:FlxTilemapExt;
	var curtain = new Curtain();
	#if android
	var joystick:FlxJoyStick;
	#end

	public var levelState:String = "relighted";

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();
		FlxG.debugger.drawDebug = false;
		FlxG.fixedTimestep = true;
		CreatePlayer();
		followTarget = player;
		AddBackgroundLayers();
		player.currentState = 'dialog';
		switch (levelState)
		{
			case("relighted"):
				RelightenedLevelInit();
		}

		#if android
		joystick = new FlxJoyStick();
		joystick.alpha = 0.6;
		add(joystick);
		#end
	}

	public function InitRPGState(targetState:String = "relighted")
	{
		levelState = targetState;
	}

	// Hard coded level inits. TODO: Modularize
	function RelightenedLevelInit()
	{
		// Fade in + enable inputs
		curtain.Flash(2, 3);
		new FlxTimer().start(2, function(timer:FlxTimer)
		{
			player.currentState = "movement";
		}, 1);

		// Loads Ambient SFX
		fireAmbientSound = FlxG.sound.load(Paths.sound("fire", 'shared'), 0.2);
		fireAmbientSound.looped = true;

		// Loads Music
		FlxG.sound.playMusic(Paths.music('relight', 'shared'), 0);
		FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music('dream', 'shared'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);
		Conductor.changeBPM(102);

		// World stuff
		var boundX = 2560;
		var boundY = 1056;
		FlxG.worldBounds.set(0, 0, boundX, boundY);
		FlxG.camera.follow(followTarget, LOCKON, 1);
		FlxG.camera.setScrollBounds(0, boundX, null, boundY);

		// forest
		var offset = 50;

		var rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/BG', 'shared'));
		rect.antialiasing = true;
		bg0.scrollFactor.set();
		bg0.add(rect);

		// Clouds
		var cloudGroup = new ParallaxBG();
		cloudGroup.InitBG(Paths.image('xeventbg/clouds', 'shared'), 50);
		bg0.add(cloudGroup);

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/Sun', 'shared'));
		rect.y += offset;
		rect.antialiasing = true;
		rect.updateHitbox();
		bg0.add(rect);

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/Mountain', 'shared'));
		rect.antialiasing = true;
		rect.updateHitbox();
		bg1.scrollFactor.set(.1, .1);
		bg1.add(rect);

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/city', 'shared'));
		rect.x -= 1000;
		rect.antialiasing = true;
		rect.updateHitbox();

		bg2.scrollFactor.set(.15, .15);
		bg2.add(rect);

		// FlxG.watch.add(rect, "x", "City x");
		// FlxG.watch.add(rect, "y", "City y");

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/forest1', 'shared'));
		rect.y += offset * 3.1;
		rect.antialiasing = true;
		rect.updateHitbox();
		bg3.scrollFactor.set(.25, .25);
		bg3.add(rect);

		// FlxG.watch.add(rect, "x", "forest1 x");
		// FlxG.watch.add(rect, "y", "forest1 y");

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/forest2', 'shared'));
		rect.y += offset + 120;
		rect.antialiasing = true;
		rect.updateHitbox();
		bg4.scrollFactor.set(.35, .35);
		bg4.add(rect);

		// FlxG.watch.add(rect, "x", "forest2 x");
		// FlxG.watch.add(rect, "y", "forest2 y");

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/forest3', 'shared'));
		rect.y += 160;
		rect.antialiasing = true;
		rect.updateHitbox();
		bg5.scrollFactor.set(.8, .8);
		bg5.add(rect);

		// FlxG.watch.add(rect, "x", "forest3 x");
		// FlxG.watch.add(rect, "y", "forest3 y");

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/ground', 'shared'));
		rect.antialiasing = true;
		rect.y += 256;
		rect.updateHitbox();

		// var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		// var waveSprite = new FlxEffectSprite(rect, [waveEffectBG]);

		groundLayer.add(rect);
		// groundLayer.scrollFactor.set();

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/lens', 'shared'));
		rect.antialiasing = true;
		bg0.add(rect);

		rect = new FlxSprite().loadGraphic(Paths.image('xeventbg/forest4', 'shared'));
		rect.y += 340;
		rect.antialiasing = true;
		rect.updateHitbox();
		fg1.scrollFactor.set(1.2, 1.2);
		fg1.add(rect);

		// FlxG.watch.add(rect, "x", "fg1 x");
		// FlxG.watch.add(rect, "y", "fg1 y");

		// Dialogs
		var dialogTrig = CreateDialogTrigger(["A small pink penguin.", "It seems to be growing at the same rate of the tree."],
			[FlxColor.WHITE, FlxColor.WHITE], [1, 2]);

		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(1.5, 1.5);
		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.x = 495;
		dialogTrig.y = 875;
		dialogTrig.alpha = 0;
		dialogTrig.updateHitbox();
		dialogTrig.alertOffset = 60;
		dialogTrig.UpdatePosition();

		dialogTrig = CreateDialogTrigger([
			"On the ground sits a shining star. ",
			"Even if it's useless for you...",
			"It fills you with DETERMINATION"
		], [FlxColor.WHITE, FlxColor.WHITE, FlxColor.YELLOW], [2.5, 2, 2.5],
			TransitionToXgaster);
		dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
		dialogTrig.scale.set(1.5, 1.5);
		dialogTrig.animation.add('idle', [0, 1], 8, true);
		dialogTrig.animation.play("idle");
		dialogTrig.y = 580;
		dialogTrig.x = 1790;
		dialogTrig.updateHitbox();
		dialogTrig.UpdatePosition();

		// Load levels
		currentLevel = LoadLevelCollision(Paths.csv('xeventbg/xevent', 'shared'), Paths.image('xeventbg/tiles16', 'shared'), 0, 0);
		cachedLevel = LoadLevelCollision(Paths.csv('xeventbg/xevent_gaster', 'shared'), Paths.image('xeventbg/tiles16', 'shared'), 0, 0);
		levelCollision.add(currentLevel);
	}

	// Generic collision cycle
	override function update(elapsed:Float)
	{
		if (currentLevel != null)
		{
			if (FlxG.debugger.drawDebug == true)
			{
				currentLevel.alpha = 1;
			}
			else
				currentLevel.alpha = 0;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.collide(player, levelCollision);
		var colliding = FlxG.overlap(player, interactableCollisions, function(object1:FlxObject, object2:FlxObject)
		{
			// trace("Colliding with interactable!!!");
			try
			{
				currInteractable = cast(object2, InteractableObject);
				currInteractable.OnCollideCallback();
			}
			catch (e)
			{
			}
		});

		if (!colliding)
		{
			for (i in interactableCollisions.members)
			{
				cast(i, InteractableObject).isColliding = false;
			}
		}

		super.update(elapsed);

		#if android
		if (player != null && joystick != null)
		{
			player.left = joystick.acceleration.x < 0;
			player.right = joystick.acceleration.x > 0;
			player.up = joystick.acceleration.y < 0;
			player.down = joystick.acceleration.y > 0;
		}
		#end
	}

	// Player Functions
	function CreatePlayer()
	{
		// Create player
		player = new RPGBoyfriend();
		player.frames = Paths.getSparrowAtlas('boyfriendrpg', 'shared');
		player.antialiasing = true;
		player.animation.addByPrefix('up', 'boyfriend_up', 8, true);
		player.animation.addByPrefix('right', 'boyfriend_right', 8, true);
		player.animation.addByPrefix('down', 'boyfriend_down', 8, true);
		player.animation.addByPrefix('left', 'boyfriend_left', 8, true);
		player.scale.set(0.25, 0.25);
		player.updateHitbox();
		player.x = 43;
		player.y = 928;
		FlxG.watch.add(player, "x", "Player X");
		FlxG.watch.add(player, "y", "Player Y");

		player.setSize(player.width / 2, 28);
		player.offset.set(player.offset.x + player.width / 2, player.offset.y + 46);
		player.solid = true;
		playerLayer.add(player);
	}

	// Dialog Functions
	function CreateDialogTrigger(texts:Array<String>, ?colors:Array<FlxColor> = null, ?timers:Array<Float> = null, ?optionalComplete:Void->Void,
			?optionalSFXArray:Array<String>):DialogTrigger
	{
		var dialogTrig:DialogTrigger = new DialogTrigger();
		dialogTrig.objectID = "dialog";
		dialogTrig.onActivateCallback = CreateDialogSequence;
		dialogTrig.SetDialog(texts, colors, timers);
		dialogTrig.callbackParams = dialogTrig.stringsSequence.copy();
		dialogTrig.onCompleteCallback = optionalComplete;
		interactableCollisions.add(dialogTrig);
		mapUILayer.add(dialogTrig.interactSprite);
		return dialogTrig;
	}

	function CreateDialogSequence(strings:Array<String>)
	{
		player.currentState = "dialog";
		player.StopPlayer();

		if (strings.length == 0)
		{
			player.currentState = "movement";
			if (currInteractable.reactivateAfterTriggered)
			{
				trace("reenabled hintable!!");
				currInteractable.EnableInteractable(false, true);
			}
			cast(currInteractable, DialogTrigger).ResetDialog();
			if (currInteractable.onCompleteCallback != null)
				currInteractable.onCompleteCallback();
			DeleteDialog(box);
			player.currentState = "movement";
			return;
		}
		DeleteDialog(box);
		box = new DialogBox();
		var trig = cast(currInteractable, DialogTrigger);
		var auxCol = trig.GetCurrColor();
		var auxTim = trig.GetCurrTiming();
		box.totalTime = auxTim;
		box.InitBox(strings.shift());
		box.SetTextColor(auxCol);
		box.callbackParams = strings;
		box.onCompleteCallback = CreateDialogSequence;
		hud.add(box);
	}

	function DeleteDialog(dialog:DialogBox)
	{
		try
		{
			if (hud.members.contains(dialog))
				hud.remove(dialog);
		}
		catch (e)
		{
			// All exceptions will be caught here
			trace(e.message);
		}
	}

	// Level Functions
	function LoadLevelCollision(levelName:String, tilemapName:FlxGraphic, xoffset:Int = 0, yoffset:Int = 0):FlxTilemapExt
	{
		FlxG.mouse.visible = false;
		var level:FlxTilemapExt = new FlxTilemapExt();
		// Load in the Level and Define Arrays for different slope types
		var tilesize = 16;
		var levelArray = csvToArray(levelName);
		level = cast(level.loadMapFrom2DArray(levelArray, tilemapName, tilesize, tilesize), FlxTilemapExt);

		// Offset by 1 tile
		level.x += -tilesize + xoffset;
		level.y += tilesize + yoffset;

		// tile tearing problem fix
		// var levelTiles = FlxTileFrames.fromBitmapAddSpacesAndBorders(tilemapName, new FlxPoint(10, 10), new FlxPoint(2, 2), new FlxPoint(2, 2));
		// level.frames = levelTiles;

		var tempNW:Array<Int> = [5, 9, 10, 13, 15];
		var tempNE:Array<Int> = [6, 11, 12, 14, 16];
		var tempSW:Array<Int> = [7, 17, 18, 21, 23];
		var tempSE:Array<Int> = [8, 19, 20, 22, 24];

		level.setSlopes(tempNW, tempNE, tempSW, tempSE);

		level.setDownwardsGlue(true);

		// set tiles steepness
		level.setGentle([10, 11, 18, 19], [9, 12, 17, 20]);
		level.setSteep([13, 14, 21, 22], [15, 16, 23, 24]);

		/*
			// set cloud tiles
			level.setTileProperties(4, FlxObject.NONE, fallInClouds);

			// set wallJump tiles
			level.setTileProperties(3, level.getTileCollisions(3), wallJump);

		 */

		return level;
	}

	function csvToArray(csv)
	{
		// trace(csv);
		var rows = Assets.getText(csv).split("\n");
		// trace(rows);
		var returnValue:Array<Array<Int>> = [for (x in 0...rows.length) []];

		for (rowCount in 0...rows.length)
		{
			var row = rows[rowCount].split(',');
			returnValue[rowCount] = [for (value in row) Std.parseInt(value)];
		}
		return returnValue;
	};

	// Background Functions
	function AddBackgroundLayers()
	{
		// Add all layers
		add(bg0);
		add(bg1);
		add(bg2);
		add(bg3);
		add(bg4);
		add(bg5);
		add(groundLayer);
		add(interactableCollisions);
		add(mapUILayer);
		add(playerLayer);
		add(fg1);
		add(levelCollision);
		add(hud);
		add(curtain);
		hud.scrollFactor.set();
	}

	function RemoveBackgroundLayers()
	{
		remove(bg0);
		remove(bg1);
		remove(bg2);
		remove(bg3);
		remove(bg4);
		remove(bg5);
		remove(groundLayer);
		remove(interactableCollisions);
		remove(mapUILayer);
		remove(playerLayer);
		remove(fg1);
		remove(levelCollision);
		remove(hud);
		remove(curtain);
	}

	function DestroyBackgroundLayers()
	{
		levelCollision.destroy();
		interactableCollisions.destroy();
		bg0.destroy();
		bg1.destroy();
		bg2.destroy();
		bg3.destroy();
		bg4.destroy();
		bg5.destroy();
		groundLayer.destroy();
		mapUILayer.destroy();
		fg1.destroy();
	}

	function ResetBackgroundLayers()
	{
		levelCollision = new FlxGroup();
		interactableCollisions = new FlxSpriteGroup();
		bg0 = new FlxSpriteGroup();
		bg1 = new FlxSpriteGroup();
		bg2 = new FlxSpriteGroup();
		bg3 = new FlxSpriteGroup();
		bg4 = new FlxSpriteGroup();
		bg5 = new FlxSpriteGroup();
		groundLayer = new FlxSpriteGroup();
		mapUILayer = new FlxSpriteGroup();
		fg1 = new FlxSpriteGroup();
	}

	function CleanBackgroundLayers()
	{
		// Destroy everything
		RemoveBackgroundLayers();
		DestroyBackgroundLayers();
		ResetBackgroundLayers();
		AddBackgroundLayers();
	}

	// Hardcoded stuff
	var fireAmbientSound:FlxSound;

	function TransitionToXgaster():Void
	{
		CleanBackgroundLayers();
		levelCollision.add(cachedLevel);
		FlxG.sound.music.stop();
		cachedLevel.alpha = 0;
		player.x = 1814;
		player.y = 945;
		var flamesCount = 5;
		// Creates fire and triggers fire
		for (j in 0...2)
		{
			for (i in 0...flamesCount)
			{
				var fire = new FlxSpriteWithCallback();
				fire.frames = Paths.getSparrowAtlas('xeventbg/rpgfire', 'shared');
				fire.scale.set(0.4, 0.4);
				fire.animation.addByPrefix('start', 'fire_start', 24, false);
				fire.animation.addByPrefix('idle', 'fire_iddle', 24, true);
				fire.x = 1700 + j * 200 - 100;
				fire.y = 960 / flamesCount * i - 200;
				fire.alpha = 0;
				fire.animationCallbacks["start"] = function() return
				{
					fire.animation.play("idle");
				};
				groundLayer.add(fire);

				var dialogTrig = new OneshotTrigger();

				dialogTrig.loadGraphic(Paths.image('ut_save', 'shared'), true, 20, 19);
				dialogTrig.scale.set(2.5, 2.5);
				dialogTrig.updateHitbox();

				dialogTrig.animation.add('idle', [0, 1], 8, true);
				dialogTrig.animation.play("idle");
				dialogTrig.x = 1800 + 20 - 15;
				dialogTrig.y = 960 / flamesCount * i + 50;
				dialogTrig.alpha = 0;
				if (i == 0 && j == 0)
				{
					dialogTrig.onTriggerEnterCallback = function() return
					{
						fire.animation.play("start");
						fire.alpha = 1;
						FlxG.sound.play(Paths.sound('litfire', 'shared'), 0.6);
						fireAmbientSound.play();
						SpawnCircleAndXGaster();
						player.currentState = "dialog";
						player.StopPlayer();
					};
				}
				else
				{
					dialogTrig.onTriggerEnterCallback = function() return
					{
						fire.animation.play("start");
						fire.alpha = 1;
						FlxG.sound.play(Paths.sound('litfire', 'shared'), 0.6);
						fireAmbientSound.play();
					};
				}
				interactableCollisions.add(dialogTrig);
			}
		}

		// World stuff
		/*
			var boundX = 2560;
			var boundY = 2500;
			FlxG.worldBounds.set(1000, -1500 ,boundX, boundY);
			FlxG.camera.setScrollBoundsRect(1000, -1500, boundX, boundY);
		 */
		FlxG.camera.follow(followTarget, LOCKON, 1);
	}

	function SpawnCircleAndXGaster():Void
	{
		var spawnFlame = function(timer:FlxTimer)
		{
			var i = timer.elapsedLoops - 1;
			var fire = new FlxSpriteWithCallback();
			var centerX = 1800;
			var centerY = -250;
			var circleWidth = 200;

			if (i == 0)
			{
				var xgaster = new FlxSprite();
				xgaster.frames = Paths.getSparrowAtlas('xgasterrpg', 'shared');
				// followTarget = xgaster;
				//                FlxG.camera.follow(null, LOCKON, 0.5);
				// followTarget =
				FlxG.camera.follow(null, null);

				xgaster.animation.addByPrefix('idle', 'xgaster_rpg', 12, true);
				xgaster.x = 1750;
				xgaster.y = -280;
				xgaster.alpha = 0;
				xgaster.animation.play("idle");
				xgaster.scale.set(0.3, 0.3);
				xgaster.updateHitbox();

				FlxG.watch.add(xgaster, "x", "gaster x");
				FlxG.watch.add(xgaster, "y", "gaster y");
				mapUILayer.add(xgaster);

				// This took 5 hours of ancient api documentation.
				// The answer was inside a defunct google groups post
				// Fuck haxeFlixel lol
				FlxTween.num(FlxG.camera.scroll.y, FlxG.camera.scroll.y - 250, 1.5, {ease: FlxEase.sineInOut}, function(twn:Float)
				{
					FlxG.camera.scroll.y = twn;
				});
				FlxTween.tween(xgaster, {alpha: 1}, 1, {
					startDelay: 6.4,
					onComplete: function(twn:FlxTween)
					{
						FlxG.sound.playMusic(Paths.music('relight', 'shared'), 0.75);
						// Transition into the actual song

						var loadLevel = function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('battle', 'shared'), 0.6);
							xgaster.alpha = 0;
							groundLayer.alpha = 0;
							FlxG.sound.music.stop();

							var balls = new FlxSprite().loadGraphic(Paths.image('balls', 'shared'));
							balls.updateHitbox();
							balls.scale.set(player.scale.x, player.scale.y);
							balls.x = player.x - 109;
							balls.y = player.y - 152;
							playerLayer.add(balls);

							FlxG.watch.add(balls, "x", "Balls x");
							FlxG.watch.add(balls, "y", "Balls y");
							FlxG.watch.add(balls, "scale", "Balls Scale");

							var flashBalls = function(tmr:FlxTimer)
							{
								balls.alpha = 1 - balls.alpha;
							};
							var flashFunc = function(tmr:FlxTimer)
							{
								new FlxTimer().start(0.07, flashBalls, 6);
							};
							new FlxTimer().start(0.52, flashFunc);

							var switchToSong = function(tmr:FlxTimer)
							{
								LoadingState.loadAndSwitchState(new PlayState(), true);
							};
							new FlxTimer().start(1.5, switchToSong);
						}

						new FlxTimer().start(4, loadLevel);
						return;
					}
				});
			}
			else
			{
				fire.frames = Paths.getSparrowAtlas('xeventbg/rpgfire', 'shared');
				fire.scale.set(0.4, 0.4);
				fire.animation.addByPrefix('start', 'fire_start', 24, false);
				fire.animation.addByPrefix('idle', 'fire_iddle', 24, true);
				fire.x = centerX + [0, -0.707, -1, -0.707, 0, 0.707, 1, 0.707][i] * circleWidth - 100;
				fire.y = centerY + [0, 0.707, 0, -0.707, -1, -0.707, 0, 0.707][i] * circleWidth - 200;
				fire.alpha = 1;
				fire.animationCallbacks["start"] = function() return
				{
					fire.animation.play("idle");
					fire.alpha = 1;
					FlxG.sound.play(Paths.sound('litfire', 'shared'), 0.6);
				};
				fire.animation.play("start");
				groundLayer.add(fire);
			}
		}

		new FlxTimer().start(0.8, spawnFlame, 8);
	}
}
