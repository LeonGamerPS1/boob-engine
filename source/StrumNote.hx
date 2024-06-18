import Note.NoteHitState;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.input.keyboard.FlxKey;

class StrumNote extends Note
{
	public var strumRGB:RGBPalette = new RGBPalette();

	private var dumpRGB:RGBPalette = new RGBPalette();
	var blurSpr:Note;

	public var inputs:Array<FlxKey> = null;
	public var notes:Array<Note> = [];
	public var autoHit:Bool = false;
	public var blocked:Bool = false;

	public override function set_hit(v:NoteHitState):NoteHitState
	{
		return hit = NONE;
	}

	public function new(?noteData:Int = 2)
	{
		super(noteData);
		sustain = null;
		shader = strumRGB.shader;
		strumRGB.set(0x87a3ad, -1, 0);
		dumpRGB.set(FlxColor.interpolate(strumRGB.r, rgb.r, 0.3).getDarkened(0.15), -1, 0x201e31);
		blurSpr = new Note(noteData);
		blurSpr.shader = rgb.shader;
		blurSpr.blend = ADD;
		blurSpr.alpha = 0.75;
		blurSpr.visible = false;
		createFilterFrames(blurSpr, new BlurFilter(58, 58));

		animation.addByIndices('confirm', 'idle', [0, 0, 0], '', 24, false);
		animation.addByIndices('press', 'idle', [0, 0, 0], '', 24, false);
		animation.callback = function(a, b, c)
		{
			if (a == 'confirm')
			{
				shader = strumRGB.shader;
				switch (b)
				{
					case 0:
						var mult = 1.15;
						scaleMult.set(mult, mult);
						blurSpr.visible = true;
						blurSpr.alphaMult = 1;
						blurSpr.colorTransform.redOffset = blurSpr.colorTransform.greenOffset = blurSpr.colorTransform.blueOffset = 30;
					case 1:
						blurSpr.colorTransform.redOffset = blurSpr.colorTransform.greenOffset = blurSpr.colorTransform.blueOffset = 0;
					case 2:
						var mult = 1.06;
						blurSpr.alphaMult = 0.75;
						scaleMult.set(mult, mult);
				}
			}
			else if (a == 'press')
			{
				shader = dumpRGB.shader;
				blurSpr.visible = false;
				switch (b)
				{
					case 0:
						var mult = 0.9;
						scaleMult.set(mult, mult);
					case 2:
						var mult = 0.95;
						scaleMult.set(mult, mult);
						blurSpr.alpha = 0.75;
				}
			}
			else
			{
				scaleMult.set(1, 1);
				blurSpr.visible = false;
				shader = strumRGB.shader;
			}
		}
	}

	function createFilterFrames(sprite:FlxSprite, filter:BitmapFilter)
	{
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, 64, 64, [filter]);
		updateFilter(sprite, filterFrames);
		return filterFrames;
	}

	function updateFilter(spr:FlxSprite, sprFilter:FlxFilterFrames)
	{
		sprFilter.applyToSprite(spr, false, true);
	}

	override function draw()
	{
		if (visible && alpha != 0)
		{
			super.draw();
			if (blurSpr.visible && blurSpr.alpha != 0)
				blurSpr.draw();
		}
	}

	var confirmTime:Float = 0.0;
	var pressingNote:Note = null;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		blurSpr.setPosition(x, y);
		blurSpr.angle = angle;
		blurSpr.alpha = alpha;
		blurSpr.scale.copyFrom(scale);
		blurSpr.scaleMult.copyFrom(scaleMult);
		dumpRGB.r = FlxColor.interpolate(strumRGB.r, rgb.r, 0.3).getDarkened(0.15);

		if (inputs is Array && inputs != null)
		{
			if (FlxG.keys.anyPressed(inputs) && !blocked)
			{
				for (note in notes)
				{
					// sustain notes
					if ((note.hit == HELD && note._shouldDoHit))
					{
						note._shouldDoHit = true;
						note.doHit();
						if (note.hit != HIT)
							pressingNote = note;
					}
				}
			}

			if (FlxG.keys.anyJustPressed(inputs) && !blocked)
			{
				for (note in notes)
				{
					// nomal notes
					if (Math.abs(note.strumTime - Conductor.time) <= 100 && note.hit == NONE)
					{
						if (note.sustain.length > 40)
							note._shouldDoHit = true;
						note.doHit();
						pressingNote = note;
					}
				}

				animation.play((pressingNote != null) ? 'confirm' : 'press', true);
			}

			if (FlxG.keys.anyJustReleased(inputs))
			{
				for (note in notes)
				{
					// sustain notes
					note._shouldDoHit = false;
				}

				pressingNote = null;
				animation.play('idle', true);
			}
		}
		else
		{
			if (autoHit)
			{
				for (note in notes)
				{
					if (note.strumTime <= Conductor.time && note.hit != HIT)
					{
						if (note.hit == NONE)
							animation.play('confirm', true);

						confirmTime = 0.13;
						note._shouldDoHit = true;
						note.doHit();
					}
				}
				if (confirmTime > 0)
					confirmTime -= elapsed;
				else
				{
					animation.play('idle', true);
					confirmTime = 0;
				}
			}
		}
	}
}
