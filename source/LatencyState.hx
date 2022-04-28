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

class LatencyState extends MusicBeatState
{
	var offsetText:FlxText;
	var noteGrp:FlxTypedGroup<Note>;
	var strumLine:FlxSprite;

	public var init:Bool = false;
	var values:Array<Float> = [];
	//var credGroup:FlxGroup;
	var staticTextGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var calibrateGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var transitionGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var beatsGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var manualGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var noteCount:Int = 1024;
	var currState:String = "calibrate";
	var manualText:FlxText;

	override function create()
	{
		//Weird bs about loading the song for the first time. It adds latency, so we just reset the state after a short load
		FlxG.sound.playMusic(Paths.sound('bfsoundtest','shared'));

		if (!init) FlxG.sound.music.stop();
		else{
				var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
				menuBG.color = 0xFFea71fd;
				menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
				menuBG.updateHitbox();
				menuBG.screenCenter();
				menuBG.antialiasing = true;
				menuBG.alpha = 0;
				add(menuBG);
				FlxTween.tween(menuBG, {alpha: 1}, 1, {ease: FlxEase.circOut});

				var tempText = new FlxText(0, 0, 700, "Press SPACEBAR \nWith the Beat", 60);
				tempText.bold = true;
				tempText.screenCenter();
				tempText.alignment = "center";
				tempText.borderColor = FlxColor.BLACK;
				tempText.borderSize = 8;
				tempText.borderStyle = FlxTextBorderStyle.OUTLINE;
				calibrateGroup.add(tempText);

				tempText = new FlxText(0, 0, 1000, "Press BACKSPACE to input a value instead.", 20);
				tempText.bold = true;
				tempText.screenCenter();
				tempText.y += 280;
				tempText.alignment = "center";
				tempText.borderColor = FlxColor.BLACK;
				tempText.borderSize = 4;
				tempText.borderStyle = FlxTextBorderStyle.OUTLINE;
				calibrateGroup.add(tempText);

				tempText = new FlxText(0, 0, 1000, "Audio Calibration", 70);
				tempText.bold = true;
				tempText.screenCenter();
				tempText.y += -250;
				tempText.alignment = "center";
				tempText.borderColor = FlxColor.BLACK;
				tempText.borderSize = 10;
				tempText.borderStyle = FlxTextBorderStyle.OUTLINE;
				staticTextGroup.add(tempText);

				//Creates the beat squares
				for (x in 0...16)
				{
						var noteSprite = new FlxSprite(0,0).makeGraphic(30, 30, 0xFFFFFFFF);
						noteSprite.screenCenter();
						noteSprite.x = Math.round((FlxG.width-100)/16)*x + 65;
						noteSprite.y += 200;
						beatsGroup.add(noteSprite);
				}

				add(staticTextGroup);
				add(calibrateGroup);
				add(transitionGroup);
				add(beatsGroup);
				add(manualGroup);
		}
		noteGrp = new FlxTypedGroup<Note>();

		//Creates a lot of invisible arrows, just in case somebody leaves the latency state running for half an hour
		FlxG.save.data.offset = 0;
		for (i in 0...noteCount)
		{
				var note:Note = new Note(Conductor.crochet * i, 1);
				noteGrp.add(note);
		}
		strumLine = new FlxSprite(FlxG.width / 2, 100).makeGraphic(FlxG.width, 5);
		//add(strumLine);
		Conductor.changeBPM(120);
		super.create();
	}

	var lastTime:Float = 0;
	var delta:Float = 0;
	var totalTime:Float = 0;
	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		if (!init) {
			totalTime += elapsed;
			trace(totalTime);
			if (totalTime > 1.5){
					FlxG.sound.music.stop();
					var auxState = new LatencyState();
					auxState.init = true;
					FlxG.switchState(auxState);
			}
			return;
		}
		if (currState == "calibrate"){
				//Go back to the mainmenu
				if (values.length == 16){
						values.sort(Reflect.compare);
						//Remove Outliers
						values.shift();
						values.shift();
						values.shift();
						values.pop();
						values.pop();
						values.pop();
						delta = 0;
						for (i in values){
								delta+=i;
						}
						delta = delta/values.length;
						//If for some ungodly reason somebody presses enter as soon as they begin, we reset the offset.
						delta = Math.isNaN(delta)? 0 : delta;
						currState == "transition";

						//Creates the text
						var tempText = new FlxText(0, 0, 700, "New Note Offset:\n" + Math.floor(delta) + " ms", 60);
						tempText.bold = true;
						tempText.screenCenter();
						tempText.alignment = "center";
						tempText.borderColor = FlxColor.BLACK;
						tempText.borderSize = 8;
						tempText.borderStyle = FlxTextBorderStyle.OUTLINE;
						transitionGroup.add(tempText);
						trace("Final Delay:" + delta);
						UpdateOffsetAndTransition(delta);
				}

				if (FlxG.keys.justPressed.SPACE){
						trace("=================================");
						trace("Current Time:" +Conductor.songPosition);
						trace("Last Note" +lastTime);
						trace("Delta:" + (Conductor.songPosition - lastTime));
						delta = Conductor.songPosition - lastTime;

						values.push(delta);

						for (i in calibrateGroup){
							FlxTween.tween(i, {alpha: 1}, 0.5, {
									ease: FlxEase.circOut,
									onUpdate: function(tween:FlxTween)
									{
										var aux = 1.5-tween.scale*0.5;
										i.scale.set(aux,aux );
									}
							});
						}
						var noteToChange = beatsGroup.members[values.length-1];

						//Tween Scale
						noteToChange.color = 0x00000000;
						FlxTween.tween(noteToChange, {alpha: 1}, 0.5, {
								ease: FlxEase.circOut,
								onUpdate: function(tween:FlxTween)
								{
									var aux = 1.5-tween.scale*0.5;
									noteToChange.scale.set(aux,aux );
								}
						});

				}

				if (FlxG.keys.justPressed.BACKSPACE){
						currState = "manual";
						remove(calibrateGroup);
						remove(beatsGroup);
						FlxG.save.data.offset = 0;
						var manualText = new FlxText(0, 0, 700, "Your Offset:\n" + 0 + " ms", 60);
						manualText.bold = true;
						manualText.screenCenter();
						manualText.alignment = "center";
						manualText.borderColor = FlxColor.BLACK;
						manualText.borderSize = 8;
						manualText.borderStyle = FlxTextBorderStyle.OUTLINE;
						manualGroup.add(manualText);

						var tempText = new FlxText(0, 0, 1200, "LEFT: -1    RIGHT: +1    Hold UP: Keep Increasing    Hold DOWN: Keep Decreasing", 20);
						tempText.bold = true;
						tempText.screenCenter();
						tempText.y += 310;
						tempText.alignment = "center";
						tempText.borderColor = FlxColor.BLACK;
						tempText.borderSize = 3;
						tempText.borderStyle = FlxTextBorderStyle.OUTLINE;

						manualGroup.add(tempText);
						return;
				}
		}
		else if (currState == "transition"){
			//Do nothing, just tweening
		}
		else if (currState == "manual"){
				if (FlxG.keys.justPressed.LEFT){
						delta -= 1;
				}
				if (FlxG.keys.justPressed.RIGHT){
						delta += 1;
				}
				if (FlxG.keys.pressed.UP){
						delta += 1;
				}
				if (FlxG.keys.pressed.DOWN){
						delta -= 1;
				}

				manualGroup.members[0].text = "New Note Offset:\n" + delta  + " ms";
				if (FlxG.keys.justPressed.ENTER){
						var tempText = new FlxText(0, 0, 700, "New Note Offset:\n" + Math.floor(delta) + " ms", 60);
						tempText.bold = true;
						tempText.screenCenter();
						tempText.alignment = "center";
						tempText.borderColor = FlxColor.BLACK;
						tempText.borderSize = 8;
						tempText.borderStyle = FlxTextBorderStyle.OUTLINE;
						transitionGroup.add(tempText);

						UpdateOffsetAndTransition(delta);
				}

		}
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		trace(curBeat);
		lastTime = Conductor.songPosition;
		trace("BeatHit:" + Conductor.songPosition);
	}

	override function stepHit()
	{
		super.stepHit();
		trace(curStep);
		//lastTime = Conductor.songPosition;
		trace("StepHit:" + Conductor.songPosition);
	}

	function UpdateOffsetAndTransition(value:Float){
		remove(calibrateGroup);
		remove(beatsGroup);
		remove(manualGroup);
		FlxG.save.data.offset = value;
		//tween to transition
		FlxTween.tween(strumLine, {alpha: 0}, 3, {
				onComplete: function(tween:FlxTween)
				{
					FlxG.sound.music.stop();
					//If it's the first time running the game, we go back to the main menu. otherwise, we go back to the options menu.
					if (FlxG.save.data.firstRun == true){
							FlxG.save.data.firstRun = false;
							FlxG.switchState(new RPGMainMenuState());
					}
					else{
							FlxG.switchState(new OptionsMenu());
					}

				}
		});

	}
}
