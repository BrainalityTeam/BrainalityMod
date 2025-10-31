package;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

using StringTools;

typedef CustomField = {
    var name:String;
    var value:Dynamic;
}
typedef Dependency = {
    var name:String;
    var version:String;
}
typedef ModMeta = {
    var name:String;
    var description:String;
    var authors:Array<String>;
    var version:String;
    var apiVersion:String;
    var customFields:Array<CustomField>;
    @:optional var gameID:String;
    @:optional var dependencies:Array<Dependency>;
}

class ModLoader
{
    public static var GAME_ID = null;
    public static var path:String = "./mods/";
    public static var metaFile:String = "meta.json";
    public static var enabledMods:Map<String, Bool> = new Map();

    public inline static function enable(mod:String) enabledMods.set(mod, true);
    public inline static function disable(mod:String) enabledMods.set(mod, false);

    public static function getMod(modPath:String):Null<ModMeta>
    {
        var fullPath = '${path}${modPath.trim()}/${metaFile}';

        try {
            if (FileSystem.exists(fullPath))
            {
                var data:Dynamic = Json.parse(File.getContent(fullPath));
                var mod:ModMeta = {
                    name: data.name,
                    description: data.description,
                    authors: data.authors,
                    version: data.version,
                    apiVersion: data.apiVersion,
                    customFields: data.customFields,
                    gameID: data.gameID,
                    dependencies: data.dependencies
                };
                enabledMods.set(mod.name, true);
                return mod;
            }
            else 
                return null;
        } catch(e:Dynamic)
        {
            trace("Error parsing mod!");
            return null;
        }
    }

    public static function getMods():Array<ModMeta>
    {
        var mods:Array<ModMeta> = new Array();
        var paths:Array<String> = new Array();
        
        if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
            for (file in FileSystem.readDirectory(path)) {
                var fullPath = path + "/" + file;
                if (FileSystem.isDirectory(fullPath)) {
                    paths.push(fullPath);
                }
            }
        }

        for (modPath in paths)
        {
            var curMod = getMod(modPath);
            if (curMod != null)
                mods.push(curMod);
        }

        return mods;
    }

    public static function init()
    {
        for (mod in getMods())
        {
            trace('Loaded mod: ${mod.name} ${mod.version}');
        }
    }
}