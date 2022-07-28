package;

import Conductor.BPMChangeEvent;
#if android
import android.AndroidControls;
import android.flixel.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if android
	var virtualPad:FlxVirtualPad;
	var androidControls:AndroidControls;
	var trackedinputs:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPad(virtualPad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];
	}

	public function removeVirtualPad()
	{
		if (trackedinputs != [])
			controls.removeFlxInput(trackedinputs);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addAndroidControls()
	{
		androidControls = new AndroidControls();

		switch (AndroidControls.getMode())
		{
			case 0 | 1 | 2: // RIGHT_FULL | LEFT_FULL | CUSTOM
				controls.setVirtualPad(androidControls.virtualPad, RIGHT_FULL, NONE);
			case 3: // BOTH_FULL
				controls.setVirtualPad(androidControls.virtualPad, BOTH_FULL, NONE);
			case 4: // HITBOX
				controls.setHitBox(androidControls.hitbox);
			case 5: // KEYBOARD
		}

		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];

		var camControls = new flixel.FlxCamera();
		FlxG.cameras.add(camControls);
		camControls.bgColor.alpha = 0;

		androidControls.cameras = [camControls];
		androidControls.visible = false;
		add(androidControls);
	}

	public function removeAndroidControls()
	{
		if (trackedinputs != [])
			controls.removeFlxInput(trackedinputs);

		if (androidControls != null)
			remove(androidControls);
	}

	public function addPadCamera()
	{
		if (virtualPad != null)
		{
			var camControls = new flixel.FlxCamera();
			FlxG.cameras.add(camControls);
			camControls.bgColor.alpha = 0;
			virtualPad.cameras = [camControls];
		}
	}
	#end

	override function destroy()
	{
		#if android
		if (trackedinputs != [])
			controls.removeFlxInput(trackedinputs);
		#end

		super.destroy();

		#if android
		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (androidControls != null)
		{
			androidControls = FlxDestroyUtil.destroy(androidControls);
			androidControls = null;
		}
		#end
	}

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
