import ModLoader;

class Main
{
    static function main() {
        ModLoader.init({
            "framework": "none",
            "assetsPath": "assets/"
        });

        haxe.Log.trace(ModLoader.assets.getText("text.txt"));
    }
}