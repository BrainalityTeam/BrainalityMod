package util;

class SemVer
{
    var major:Int;
    var minor:Int;
    var patch:Int;

    public function new(version:String)
    {
        var vers:Array<String> = version.split('.');
        var semVer:Array<Int> = new Array();

        for (ver in vers)
        {
            semVer.push(Std.parseInt(ver) != null ? Std.parseInt(ver) : 0);
        }

        major = semVer.length > 0 ? semVer[0] : 0;
        minor = semVer.length > 1 ? semVer[1] : 0;
        patch = semVer.length > 2 ? semVer[2] : 0;
    }

    public function isAtLeast(other:SemVer):Bool {
        if (major != other.major) return major > other.major;
        if (minor != other.minor) return minor > other.minor;
        return patch >= other.patch;
    }
}