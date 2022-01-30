package;

import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.media.Sound;
import openfl.Lib;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import webm.*;

using StringTools;

class WebmFlxVideo extends FlxSprite
{
	public var player:WebmPlayer;
	public var endcallback:Void->Void = null;
	public var startcallback:Void->Void = null;
	public var audio:FlxSound;
        public var io:WebmIo;
        public var altSource:String;

    public function new() {
        super();
    }
	
    public function playVideo(source:String, ownCamera:Bool = false, frameSkipLimit:Int = -1) {
                altSource = source;

		try {
		io = new WebmIoFile(altSource);
		} catch (e) {
			throw e;
		}

		try {
			audio = new FlxSound().loadEmbedded(Sound.fromFile(altSource.replace(".webm", ".ogg")), false);
		} catch (e) {
			throw e;
		}

		if (audio != null) {
			FlxG.sound.music = audio;
			FlxG.sound.music.play();
		}

		player = new WebmPlayer();
		player.fuck(io, false);

		player.addEventListener(WebmEvent.PLAY, onPlay);
		player.addEventListener(WebmEvent.STOP, onStop);
		player.addEventListener(WebmEvent.COMPLETE, onComplete);
		player.addEventListener(WebmEvent.RESTART, onRestart);

		loadGraphic(player.bitmapData);

		if (frameSkipLimit != -1)
		{
			player.SKIP_STEP_LIMIT = frameSkipLimit;	
		}

		if (ownCamera) 
		{
		    var cam = new flixel.FlxCamera();
		    FlxG.cameras.add(cam);
		    cam.bgColor.alpha = 0;
		    cameras = [cam];
		}

        updateHitbox();
        player.play();
    }

    public function onPlay(e:WebmEvent) {
		if (startcallback != null) {
			startcallback();
		}
		if (audio != null) {
			audio.play();
		}
	}

	public function onStop(e:WebmEvent) {
		player.stop();
		if(audio != null)
			audio.stop();
	}

	public function onComplete(e:WebmEvent) {
		if (endcallback != null) {
			endcallback();
		}
	}

	public function onRestart(e:WebmEvent) {
		player.restart();
	}

	public static function calc(ind:Int):Dynamic
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var width:Float = 1280;
		var height:Float = 720;
				
		var ratioX:Float = height / width;
		var ratioY:Float = width / height;
		var appliedWidth:Float = stageHeight * ratioY;
		var appliedHeight:Float = stageWidth * ratioX;
		var remainingX:Float = stageWidth - appliedWidth;
		var remainingY:Float = stageHeight - appliedHeight;
		remainingX = remainingX / 2;
		remainingY = remainingY / 2;
		
		appliedWidth = Std.int(appliedWidth);
		appliedHeight = Std.int(appliedHeight);
		
		if (appliedHeight > stageHeight)
		{
			remainingY = 0;
			appliedHeight = stageHeight;
		}
		
		if (appliedWidth > stageWidth)
		{
			remainingX = 0;
			appliedWidth = stageWidth;
		}
		
		switch(ind)
		{
			case 0:
				return remainingX;
			case 1:
				return remainingY;
			case 2:
				return appliedWidth;
			case 3:
				return appliedHeight;
		}
		
		return null;
	}

	public function updatePlayer()
	{
		player.x = calc(0);
		player.y = calc(1);
		player.width = calc(2);
		player.height = calc(3);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		updatePlayer();

                if (audio != null) {// a thing
                        audio.time = player.getElapsedTime();
		}
	}
}
