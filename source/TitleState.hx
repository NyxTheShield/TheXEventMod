package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var customTitle:String = "xchara";
	override public function create():Void
	{
		FlxG.sound.muteKeys = null;

		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "\\assets\\replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "\\assets\\replays");
		#end

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.firstRun == null)
				FlxG.save.data.firstRun = true;

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		//var aux = new RPGState();
		//aux.InitRPGState("relighted");
		//FlxG.switchState(aux);

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var xcharaTitle:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('truce'), 0);

			FlxG.sound.music.fadeIn(1, 0, 0.7);
		}

		Conductor.changeBPM(81);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);


		if (customTitle == "xchara"){
			//Nyx: new Background
			var bg:FlxSprite = new FlxSprite(-650, -250 ).loadGraphic(Paths.image('overwrite_bg', "shared"));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			bg.scale.set(0.5,0.5);
			add(bg);

			//White floating squares
			for (i in 0...7){
				var sqr:FlxSprite = new FlxSprite( (1280/7)*i, 0).loadGraphic(Paths.image('overwrite_square',  "shared"));
				sqr.antialiasing = true;
				sqr.scrollFactor.set(1.2, 1.2);
				sqr.active = false;
				sqr.scale.set(0.5,0.5);
				PlayState.TweenOverwriteBGPosition(sqr, sqr.x+0, sqr.y+200, (Math.random()*5+2)/3, Math.random()/2,  FlxEase.sineInOut);
				add(sqr);
			}
		}


		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		//add(gfDance);
		add(logoBl);

		//Xchara on title screen
		if (customTitle == "xchara"){
				//Demo 1
				/*
				xcharaTitle = new FlxSprite(0, 0);
				xcharaTitle.screenCenter();
				xcharaTitle.frames = Paths.getSparrowAtlas('xcharaTitle', "shared");
				xcharaTitle.antialiasing = true;
				xcharaTitle.animation.addByPrefix('idle', 'xchara idle', 24);
				xcharaTitle.animation.addByPrefix('singUP', 'xchara up',24);
				xcharaTitle.animation.addByPrefix('singRIGHT', 'xchara right', 24);
				xcharaTitle.animation.addByPrefix('singDOWN', 'xchara down', 24);
				xcharaTitle.animation.addByPrefix('singLEFT', 'xchara left', 24);
				//xcharaTitle.flipX = true;
				xcharaTitle.x += 150;
				xcharaTitle.y += -300;
				xcharaTitle.scale.set(1.15,1.15);
				xcharaTitle.animation.play('idle');
				xcharaTitle.updateHitbox();
				add(xcharaTitle);*/


				//Demo 2
				/*
				xcharaTitle = new FlxSprite(0, 0);
				xcharaTitle.screenCenter();
				xcharaTitle.frames = Paths.getSparrowAtlas('inktest', "shared");
				xcharaTitle.antialiasing = true;
				xcharaTitle.animation.addByPrefix('idle', 'Ink idle dance', 24);
				xcharaTitle.animation.addByPrefix('singUP', 'Ink Sing Note UP', 24);
				xcharaTitle.animation.addByPrefix('singRIGHT', 'Ink Sing Note RIGHT', 24);
				xcharaTitle.animation.addByPrefix('singDOWN', 'Ink Sing Note DOWN', 24);
				xcharaTitle.animation.addByPrefix('singLEFT', 'Ink Sing Note LEFT', 24);

				xcharaTitle.flipX = true;
				xcharaTitle.x += 0;
				xcharaTitle.y += -400;
				xcharaTitle.scale.set(1.1,1.1);
				xcharaTitle.animation.play('idle');
				add(xcharaTitle);
				*/

				//Demo 3
				xcharaTitle = new FlxSprite(0, 0);
				xcharaTitle.frames = Paths.getSparrowAtlas('xgastertitle', "shared");
				xcharaTitle.animation.addByPrefix('idle', 'IDLE', 24);
				xcharaTitle.animation.addByPrefix('singLEFT', 'LEFT', 24);
				xcharaTitle.antialiasing = true;
				xcharaTitle.flipX = true;
				xcharaTitle.x += 500;
				xcharaTitle.y += -130;
				xcharaTitle.scale.set(0.7,0.7);
				xcharaTitle.animation.play('idle');
				add(xcharaTitle);
				FlxTween.tween(xcharaTitle, {y: xcharaTitle.y + 25}, 1, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay:1});

				//Nyx Xevent Animation
				var logoX:FlxSprite = new FlxSprite().loadGraphic(Paths.image('xevent'));
				logoX.screenCenter();
				trace("Screen Coordinates:");
				trace(logoX.x);
				trace(logoX.y);
				logoX.x -= 80;
				logoX.antialiasing = true;
				add(logoX);
				FlxTween.tween(logoX, {y: logoX.y + 25}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

				//Nyx: Overwrite lights

				var lg:FlxSprite = new FlxSprite(-650, -250).loadGraphic(Paths.image('overwrite_light', "shared"));
				lg.antialiasing = true;
				lg.scrollFactor.set(0.9, 0.9);
				lg.active = false;
				lg.scale.set(0.5,0.5);
				lg.y-= 100;

				FlxTween.tween(lg, {alpha:0.4}, 2, {
					ease: FlxEase.quadInOut,
					type: FlxTween.PINGPONG,
					loopDelay:0.5
				});

				add(lg);

				//Particles
				for (i in 0...30){
					var part:FlxSprite = new FlxSprite(-100 + (1500/30) * i, 1000).loadGraphic(Paths.image('particle', "shared"));
					part.antialiasing = true;
					part.scrollFactor.set(0.92, 0.92);
					part.active = false;
					PlayState.TweenParticles(part, part.x, 120, part.y-1500, 0, (Math.random()*5+3),0, FlxEase.quadInOut, 0.7);

					add(part);
				}
		}


		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er\n \nMod by NyxTheShield", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{

		if (FlxG.keys.justPressed.L) FlxG.switchState(new LatencyState());

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
					if (FlxG.save.data.firstRun == true){
							FlxG.switchState(new LatencyState());
					}
					else{
							FlxG.switchState(new RPGMainMenuState());
					}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft){
			gfDance.animation.play('danceRight');
			if (customTitle == "xchara") {
				xcharaTitle.animation.play('singLEFT');
				//xcharaTitle.offset.set(60,35);
			}
		}
		else{
			gfDance.animation.play('danceLeft');
			if (customTitle == "xchara") {
				xcharaTitle.animation.play('idle');
				//xcharaTitle.offset.set(0,0);
			}
		}

		//FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 2:
				createCoolText(['X!Event Mod']);
				addMoreText('by NyxTheShield');
			case 6:
				deleteCoolText();
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText(['Special Thanks:']);
				addMoreText('Comyet');
				addMoreText('Jakei95');
				addMoreText('Lukas Wolf child');
			// credTextShit.visible = true;
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
