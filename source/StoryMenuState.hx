package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.tweens.FlxEase;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [/*
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', "Monster"],
		['Pico', 'Philly', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns'],*/
		['Overwrite', 'InkingMistake', "Relighted"]
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true];

	var weekCharacters:Array<Dynamic> = [/*
		['dad', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf'],*/
		['xchara', 'bf', 'gf']
	];

	var weekNames:Array<String> = [/*
		"",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"hating simulator ft. moawling",*/
		"The X!Event"
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxSpriteGroup;
	var nyxCharacters:FlxSpriteGroup = new FlxSpriteGroup();
	var nyxDiff:FlxSpriteGroup = new FlxSpriteGroup();
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		//Nyx: BG

		var blackvarLength = 147;
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, blackvarLength).makeGraphic(FlxG.width, 298, 0xFFE0B1FF);

		grpWeekText = new FlxTypedGroup<MenuItem>();

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, blackvarLength, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, 7-i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			weekThing.week.y = 0;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[curWeek][char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;
			switch (weekCharacterThing.character)
			{
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();

				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'pico':
					weekCharacterThing.flipX = true;
				case 'parents-christmas':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
				case 'xchara':
						weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.65));
						weekCharacterThing.updateHitbox();
			}

			//grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxSpriteGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		difficultySelectors.x -= 400;
		difficultySelectors.y += 50;
		//difficultySelectors.screenCenter(X);
		//difficultySelectors.screenCenter(Y);
		//difficultySelectors.y += 200;

		add(yellowBG);
		add(grpWeekText);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");
		//Loads BG
		add(new FlxSprite().loadGraphic(Paths.image('seldif', 'shared')));

				//load characters
				var charSprite = new FlxSprite();
				var tex = Paths.getSparrowAtlas('xcharatest', 'shared');
				charSprite.frames = tex;
				charSprite.animation.addByPrefix('idle', 'Dad idle dance', 24);
				charSprite.animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				charSprite.animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				charSprite.animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				charSprite.animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				charSprite.animation.play('idle');
				charSprite.scale.set(0.4,0.4);
				charSprite.centerOffsets();
				charSprite.centerOrigin();
				charSprite.updateHitbox();
				charSprite.screenCenter();
				charSprite.x -=  FlxG.width;

				charSprite.y -= 60;
				nyxCharacters.add(charSprite);

				charSprite = new FlxSprite();
				tex = Paths.getSparrowAtlas('inktest', 'shared');
				charSprite.frames = tex;
				charSprite.animation.addByPrefix('idle', 'Ink idle dance', 24);
				charSprite.animation.addByPrefix('singUP', 'Ink Sing Note UP', 24, false);
				charSprite.animation.addByPrefix('singRIGHT', 'Ink Sing Note RIGHT', 24, false);
				charSprite.animation.addByPrefix('singDOWN', 'Ink Sing Note DOWN', 24, false);
				charSprite.animation.addByPrefix('singLEFT', 'Ink Sing Note LEFT', 24, false);
				charSprite.animation.play('idle');
				charSprite.scale.set(0.4,0.4);
				charSprite.centerOffsets();
				charSprite.centerOrigin();
				charSprite.updateHitbox();
				charSprite.screenCenter();
				charSprite.y -= 60;
				nyxCharacters.add(charSprite);


				// DAD ANIMATION LOADING CODE
				charSprite = new FlxSprite();
				tex = Paths.getSparrowAtlas('xgaster1', 'shared');
				tex.frames = tex.frames.concat(Paths.getSparrowAtlas('xgaster2','shared').frames);
				charSprite.frames = tex;
				charSprite.animation.addByPrefix('idle', 'Xgaster idle dance', 24);
				charSprite.animation.addByPrefix('singUP', 'Xgaster Sing Note UP', 24, false);
				charSprite.animation.addByPrefix('singRIGHT', 'Xgaster Sing Note RIGHT', 24, false);
				charSprite.animation.addByPrefix('singDOWN', 'Xgaster Sing Note DOWN', 24, false);
				charSprite.animation.addByPrefix('singLEFT', 'Xgaster Sing Note LEFT', 24, false);
				charSprite.animation.play('idle');
				charSprite.scale.set(0.3,0.3);
				charSprite.centerOffsets();
				charSprite.centerOrigin();
				charSprite.updateHitbox();
				charSprite.screenCenter();
				charSprite.y -= 60;
				charSprite.x +=  FlxG.width;
				nyxCharacters.add(charSprite);


		add(nyxCharacters);
		add(nyxDiff);

		nyxDiff.add(new FlxSprite().loadGraphic(Paths.image('easy', 'shared')));
		nyxDiff.add(new FlxSprite().loadGraphic(Paths.image('normal', 'shared')));
		nyxDiff.add(new FlxSprite().loadGraphic(Paths.image('hard', 'shared')));

		nyxDiff.members[0].alpha = 0;
		nyxDiff.members[1].alpha = 1;
		nyxDiff.members[2].alpha = 0;


		super.create();
		changeDifficulty();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				/*
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}*/

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new RPGMainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				//grpWeekText.members[curWeek].startFlashing();
				nyxCharacters.members[curDifficulty].animation.play('singLEFT');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}


	var currTween:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{


		if(nyxCharacters != null && nyxDiff != null && nyxDiff.members != null){
			if (currTween != null) currTween.cancel();

			//var currChar = nyxCharacters.members[curDifficulty];
			//var targetChar = nyxCharacters.members[ Math.round(FlxMath.bound((curDifficulty + change)%2, 0 , 2)) ];
			var targetDiff = Math.round( FlxMath.wrap(curDifficulty + change, 0 , 2) );
			var startPos = nyxCharacters.x;
			var targetPos =  [FlxG.width, 0, -FlxG.width][targetDiff];

			var tweenFunc = function(twn:Float){
					nyxCharacters.x = twn;
			}
			currTween = FlxTween.num(startPos, targetPos, 0.4, { ease: FlxEase.sineInOut}, tweenFunc);

			trace("Curr diff" + curDifficulty);
			trace("Target diff" + targetDiff);

			for (member in nyxDiff.members){
					member.alpha = 0;
			}
			trace("past this");
			nyxDiff.members[targetDiff].alpha = 1;
		}
		else{

		}

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
		trace("And past the change difficulty");
		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		/*
		grpWeekCharacters.members[0].animation.play(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].animation.play(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].animation.play(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";

		switch (grpWeekCharacters.members[0].animation.curAnim.name)
		{
			case 'parents-christmas':
				grpWeekCharacters.members[0].offset.set(200, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 0.99));

			case 'senpai':
				grpWeekCharacters.members[0].offset.set(130, 0);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.4));

			case 'mom':
				grpWeekCharacters.members[0].offset.set(100, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			case 'dad':
				grpWeekCharacters.members[0].offset.set(120, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			default:
				grpWeekCharacters.members[0].offset.set(100, 100);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
				// grpWeekCharacters.members[0].updateHitbox();
		}*/

		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
