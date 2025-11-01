package;

import openfl.display.Sprite;
import flixel.FlxGame;
class Main extends Sprite
{
    static function main() {
        addChild(new FlxGame(0, 0, PlayState));
    }
}