package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;

using StringTools;

class RPGBoyfriend extends FlxSprite
{


    public function new(x:Float = 0, y:Float = 0)
    {
         super(x, y);
    }

    public var interactSprite:FlxSprite;
    public var currentState:String = "movement";
    var currentAnimation:String = "down";
    var charSpeed:Float = 40000;

    var up:Bool;
    var down:Bool;
    var left:Bool;
    var right:Bool;
    var stickX:Float;
    var stickY:Float;
    var space:Bool;

    var isMoving:Bool = false;

    var lastElapsed:Float = 0;
    override function update(elapsed:Float)
  	{
      lastElapsed = elapsed;
      FlxG.watch.addQuick("Deltatime",lastElapsed);
      FlxG.watch.addQuick("X Speed",velocity.x);
      //Input polling
      up = FlxG.keys.anyPressed([UP, W]);
      down = FlxG.keys.anyPressed([DOWN, S]);
      left = FlxG.keys.anyPressed([LEFT, A]);
      right = FlxG.keys.anyPressed([RIGHT, D]);
      space = FlxG.keys.anyJustPressed([SPACE]);

      //State machine
      switch (currentState){
          case "movement": MovementState();
          case "dialog": DialogState();
      }
      //Update Graphics
      UpdateAnimation();
      super.update(elapsed);
  	}

    function MovementState(){
        if (up && down) up = down = false;
        if (left && right) left = right = false;

        stickY = down? 1 : (up? -1 : 0);
        stickX = right? 1 : (left? -1 : 0);

        var stickValues = map(stickX, stickY);
        velocity.x = stickValues[0]*charSpeed*lastElapsed;
        velocity.y = stickValues[1]*charSpeed*lastElapsed;

        if (left) currentAnimation = "left";
        else if (right) currentAnimation = "right";
        else if (up) currentAnimation = "up";
        else if (down) currentAnimation = "down";

        isMoving = up || down || left || right;
        //else currentAnimation = "idle";
    }

    function DialogState(){

    }

    function UpdateAnimation(){
        animation.play(currentAnimation);
        if (isMoving) animation.resume();
        else animation.pause();
    }

    public function StopPlayer(){
        velocity.x= 0;
        velocity.y = 0;
        isMoving = false;
    }

    function map(x:Float, y:Float) {
    return [
        x * Math.sqrt(1 - y * y / 2),
        y * Math.sqrt(1 - x * x / 2)];
    }

}
