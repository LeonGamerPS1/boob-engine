package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import objects.Alphabet;
import objects.ui.AlphabetList;
import objects.ui.ImageButton;
import util.GradientMap;

class OptionsState extends FlxState {
	override public function create() {
		super.create();

		var bg = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, -1, 0));
		bg.scale.set(30, 30);
		bg.velocity.set(20, -20);
		bg.alpha = 0.1;
		add(bg);

		var menu:AlphabetList = new AlphabetList();
		menu.setPosition(90, FlxG.height * 0.5);
		menu.list = ['INPUT', 'VISUALS', 'MISC'];
		add(menu);

		menu.forEach((a) -> {
			a.x -= 500;
		});
		menu.followFunction = function(a, elapsed) {
			final isTarget:Bool = a.ID == menu.curSelected;
			a.y = menu.y;
			a.y -= 32;
			a.y -= 60 * (menu.list.length - 1);
			a.y += 120 * a.ID;
			a.alpha = isTarget ? 1 : 0.6;
			a.x = FlxMath.lerp(a.x, menu.x + (isTarget ? 69 : 0), elapsed * 8);
		}

		menu.press = function(a) {
			switch (menu.list[a].toLowerCase()) {
				case 'input':
					trace('a');
				case 'visuals':
					trace('b');
				case 'misc':
					trace('c');
				default:
					Log.anonprint('no function set for this button!', 0xff6666);
			}
		}

		var omenu:AlphabetList = new AlphabetList();
		omenu.setPosition(FlxG.width * 0.5, 50);
		omenu.list = ['downscroll', 'ghost tapping', 'evil mode', 'gwa gwa', 'camera zooming'];
		add(omenu);
		omenu.prevInputs = omenu.nextInputs = [];
		omenu.followFunction = function(a, elapsed) {
			final isTarget:Bool = a.ID == omenu.curSelected;
			a.alpha = isTarget ? 1 : 0.6;
			a.x = omenu.x;
			a.y = omenu.y + (156 * a.ID);
		}

		/*
			var menu:AlphabetList = new AlphabetList();
			menu.setPosition(90, (FlxG.height * 0.5) - 32);
			menu.list = [
				'I SWEAR TO GOD',
				'IF THIS GOES WRONG',
				"I'M GOING TO DIE",
				'balls, testicles even'
			];
			add(menu);
			menu.forEach(alp -> {
				if (menu.followFunction != null)
					menu.followFunction(alp, 0.1);
			});
			menu.press = function(a) {
				menu.members[a].angle = 0;
				FlxTween.cancelTweensOf(menu.members[a]);
				FlxTween.tween(menu.members[a], {angle: 360}, 1);
			}

			var button:ImageButton = new ImageButton(Paths.image('ui/editor/image_button/plus'));
			add(button);
			button.setPosition(FlxG.width - 270, FlxG.height - 150);
			button.quickColor(0x33cccc, 0x336666);

			var rand:Array<String> = [
				'hi guys',
				'uwu',
				'GET THE FUCK OUT OF MY HOUSE',
				'Null Object Reference',
				'a',
				'THIS IS NOT FUNNY',
				'+',
				'Alphabet',
				'WHY DID YOU CLICK THAT...........',
				'Ñ',
				'aeiou',
				'unholy',
				'cobalt'
			];
			button.onPress.add(() -> {
				menu.list.push(rand[FlxG.random.int(1, rand.length) - 1]);
				menu.refresh();
				if (menu.members[menu.members.length - 1].text == 'cobalt') {
					var grad:GradientMap = new GradientMap();
					grad.set(0x6699ff, 0x000099);
					menu.members[menu.members.length - 1].forEach(a -> {
						a.shader = grad.shader;
					});
				}
			});

			var button:ImageButton = new ImageButton(Paths.image('ui/editor/image_button/minus'));
			add(button);
			button.setPosition(FlxG.width - 150, FlxG.height - 150);
			button.quickColor(0xff3399, 0x660099);

			button.onPress.add(() -> {
				menu.list.pop();
				menu.refresh();
			});

			var button:ImageButton = new ImageButton(Paths.image('ui/editor/image_button/reset'));
			add(button);
			button.setPosition(FlxG.width - 150, FlxG.height - 270);
			button.quickColor(0xffcc99, 0x990066);

			button.onPress.add(() -> {
				FlxG.resetState();
			});
		 */
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new states.TitleState());
		}
	}
}
