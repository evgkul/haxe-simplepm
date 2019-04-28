package simplepm.packageloaders;

import sys.FileSystem;
import simplepm.PackagesHolder;
import sys.io.Process;
import haxe.io.Path;
import sys.io.File;

class CopyFromHaxelib implements simplepm.PackageLoader {
    var info:PackageInfo;
    var pkgname:String;
    var path:String;
    var json:Dynamic;
    function new(info:PackageInfo){
        this.info = info;
        pkgname = info.name;
    }
    public function setPackagePath(p:String,exists:Bool){
        if(exists){
            this.path = p;
        } else {
            this.path = getHaxelibPath();
        }
        //trace('jsonpath',Path.join([path,'haxelib.json']));
        var jsonContent = File.getContent(Path.join([path,'haxelib.json']));
        json = haxe.Json.parse(jsonContent);
        var dependencies = (json.dependencies:haxe.DynamicAccess<String>);
        for(name in dependencies.keys()){
            trace('Processing package',name);
            var version = dependencies[name];
            if(version=='') version = null;
            info.dependencies.push(CopyFromHaxelib.create(name,version));
        }
    }
    public static function create(name:String,?version:String,?as:String){
        var pkg:PackageInfo = {
            name: name,
            version: version,
            dependencies : [],
            loader: null
        };
        pkg.loader = new CopyFromHaxelib(pkg);
        if(as!=null){
            pkg.name = as;
        }
        return pkg;
    }
    function getHaxelibPath(){
        var process = new Process('haxelib',['libpath','${pkgname}${info.version!=null?":"+info.version:''}']);
        var exitCode = process.exitCode();
        if(exitCode!=0){
            var err = process.stdout.readAll();

            throw 'Unable to get package ${info.name} path!\n'+err.getString(0,err.length);
        }
        return process.stdout.readLine();
    }
    public function downloadTo(path){
        //Sys.println('Loading haxelib package with name '+info.name);
        simplepm.FileUtils.copyDirectory(this.path,path);
        try {
            simplepm.FileUtils.removeDirectory(Path.join([path,'.git']));
        } catch(e:Dynamic){}
        
    }
    public function getArguments(path){
        //trace('json',json,path);
        var classpath = json.classPath;
        if(classpath==null) classpath='.';
        var res = [
            '-cp ${Path.join([path,classpath])}',
        ];
        var extra_path = Path.join([path,'extraParams.hxml']);
        if(FileSystem.exists(extra_path)){
            res.push(extra_path);
        }
        return res.join('\n');
    }
}