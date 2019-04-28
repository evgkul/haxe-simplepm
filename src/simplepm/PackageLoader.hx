package simplepm;

interface PackageLoader {
    public function setPackagePath(path:String,exists:Bool):Void;
    public function downloadTo(path:String):Void;
    public function getArguments(path:String):String;
}