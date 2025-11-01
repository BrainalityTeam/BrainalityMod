package;

import mods.ModLoader;
import openfl.display.Sprite;
import flixel.FlxGame;
class Main extends Sprite
{
    override public function new() {
        super();
        ModLoader.init({
            framework: "flixel",
            assetsPath: "assets/",
            gameID: "flixeltest"
        });

        addChild(new FlxGame(0, 0, PlayState, 60, 60, true));
    }
}