package;

import mods.ModLoader;
import flixel.FlxState;

class PlayState extends FlxState
{
    override function create()
    {
        super.create();

        haxe.Log.trace(ModLoader.getMods());

        haxe.Log.trace(ModLoader.assets.getText("text.txt"));
    }
}