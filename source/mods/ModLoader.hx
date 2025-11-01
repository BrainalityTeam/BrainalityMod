package mods;

import sys.net.Address;
import utils.SemVer;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

using StringTools;

typedef LoaderConfig =
{
    var framework:String;
    var assetsPath:String;
    @:optional var gameID:String;
}
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
    @:optional var customFields:Array<CustomField>;
    @:optional var gameID:String;
    @:optional var dependencies:Array<Dependency>;
}

class ModLoader
{
    public static var GAME_ID = null;
    public static var path:String = "./mods/";
    public static var metaFile:String = "meta.json";
    public static var minimumApiVersion:SemVer = new SemVer("0.0.0");
    public static var apiVersion:SemVer = new SemVer("0.1.0");
    public static var enabledMods:Map<String, Bool> = new Map();
    public static var paths:Map<String, String> = new Map();
    public static var assets:Assets = null;

    public inline static function enable(mod:String)  enabledMods.set(mod, true);

    public inline static function disable(mod:String) enabledMods.set(mod, false);

    public static function checkGameID(id:String):Bool
    {
        if (GAME_ID == null || GAME_ID == "") return true;

        return (GAME_ID == id);
    }

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

                var vers:SemVer = new SemVer(mod.apiVersion);

                if (checkGameID(mod.gameID) && vers.isAtLeast(minimumApiVersion))
                {
                    enabledMods.set(mod.name, true);
                    return mod;
                } else return null;
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

    public static function init(config:LoaderConfig)
    {
        GAME_ID = config.gameID;
        for (mod in getMods())
        {
            trace('Loaded mod: ${mod.name} ${mod.version}');
        }

        assets = new Assets(config.framework, config.assetsPath);
    }
}

class Assets
{
    public var framework:String;
    public var assetsPath:String;

    public function new(framework:String, assetsPath:String) 
    {
        this.framework = framework;
        this.assetsPath = assetsPath;
    }

    public function getPath(path:String)#if sys :String #else :Null #end
    {
        #if sys
        var finalPath:String = '${assetsPath}${path}';

        for (mod in ModLoader.getMods())
        {
            var curPath = ModLoader.paths.get(mod.name);
            if (FileSystem.exists(curPath))
                finalPath = curPath;
        }

        return finalPath;
        #else
        throw 'Function only available in sys target!';
        return null;
        #end
    }

    public function getText(path:String)#if sys :String #else :Null #end
    {
        //this function is framework independent yaya
        //for now this function only works in sys targets. Hopefully not a problem.
        #if sys        
        return File.getContent(getPath(path));
        #else
        throw 'Function only available in sys target!';
        return null;
        #end
    }

    public function getJSON(path:String) #if sys :Dynamic #else :Null #end
    {
        #if sys
        try 
        {
            return Json.parse(getText(path));
        } catch (e:Dynamic)
        {
            haxe.Log.trace('Error parsing JSON at ' + path);
            return null;
        }
        #else
        throw 'Function only available in sys target!';
        return null;
        #end
    }
}