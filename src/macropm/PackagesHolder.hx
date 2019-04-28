package macropm;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;

typedef PackageInfo = {
	name:String,
	?version:String,
    ?dependencies:Array<PackageInfo>,
    loader: PackageLoader
}

class PackagesHolder {
    private var packages_path = 'macropm_modules';
    private var loaded:Array<String>;
    private var not_loaded:Array<PackageInfo> = [];
    public var offset(default,set) = '.';
    function set_offset(val){
        loaded = FileSystem.readDirectory(Path.join([val,packages_path]));
        return this.offset = val;
    }

    public var hxmlOffset = '.';
	public function new() {
        if(!FileSystem.exists(packages_path)){
            FileSystem.createDirectory(packages_path);
        }
        loaded = FileSystem.readDirectory(Path.join([offset,packages_path]));
    }

    private function getPath(name,force = false):Null<String>{
        return Path.join([offset,packages_path,name]);
    }
	private var packages(default, never):Map<String, PackageInfo> = [];
    private var recentlyAdded:Array<PackageInfo> = [];

	public function addPackage(p:PackageInfo):Bool {
		/*if (p.version == null)
			p.version = '@haxelib'
		else if (p.version.substr(0, 1) != '@')
			p.version = '@haxelib:' + p.version;*/
        var current = packages[p.name];
        if(current==null){
            var path = getPath(p.name);
            var exists = loaded.indexOf(p.name)!=-1;
            p.loader.setPackagePath(path,exists);
            packages[p.name] = p;
            recentlyAdded.push(p);
            if(!exists){
                not_loaded.push(p);
            }
            /*if(p.dependencies!=null){
                for(pkg in p.dependencies){
                    addPackage(pkg);
                }
            }*/
        } else if(current.version!=p.version){
            throw 'Version mismatch! '+p.version+' and '+current.version;
        }
        return current==null;
	}

    public function addPackages(a:Array<PackageInfo>){
        for(pkg in a){
            addPackage(pkg);
        }
    }

    private function addDependencies(pkgs:Array<PackageInfo>){
        for(pkg in pkgs){
            for(dep in pkg.dependencies){
                var isLoaded = addPackage(dep);
                if(!isLoaded&&dep.dependencies!=null){
                    addDependencies(dep.dependencies);
                }
            }
        }
    }

    public function download(){
        addDependencies(recentlyAdded);
        for(pkg in not_loaded){
            var path = getPath(pkg.name,true);
            FileSystem.createDirectory(path);
            pkg.loader.downloadTo(path);
            pkg.loader.setPackagePath(path,true);
            var version = pkg.version==null?'':pkg.version;
            File.saveContent(Path.join([path,'.macropm_package_version']),version);
            loaded.push(pkg.name);
            //Sys.println('Loaded '+pkg.loader.getArguments(path));
        }
    }
    public function getLibraryDefinition(libname,_){
        var pkg = packages[libname];
        if(pkg==null){
            throw 'Package ${libname} is not installed!';
        }
        return pkg.loader.getArguments(
            Path.join([hxmlOffset,getPath(pkg.name)])
            );
    }
}
