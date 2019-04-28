package simplepm.packageloaders;

import sys.FileSystem;
import simplepm.PackagesHolder;
import simplepm.FileUtils;
import sys.io.Process;
import haxe.io.Path;
import sys.io.File;

class HaxelibFromGit extends CopyFromHaxelib {
	var repo:String;

	override public static function create(repo:String, ?version:String, ?as:String) {
		var name_a = repo.split('/');
		var name = name_a[name_a.length - 1];
		var pkg:PackageInfo = {
			name: name,
			version: version,
			dependencies: [],
			loader: null
		};
		var loader = new HaxelibFromGit(pkg);
		pkg.loader = loader;
		if (as != null) {
			pkg.name = as;
		}
		loader.repo = repo;
		return pkg;
	}

	override public function setPackagePath(path:String,exists:Bool) {
		if (!exists) {
			// Downloading from git...
			//path = Path.join(['simplepm_modules', info.name]);
			var git_args = ['subtree','add','--squash','--prefix=${path}', repo];
            if(info.version!=null){
                git_args.push(info.version);
            } else {
				git_args.push('master');
			}
			// var process = new Process('git',git_args);
			var ecode = Sys.command('git', git_args);
			if (ecode != 0) {
				throw 'Unable to download package ' + info.name + ' from ' + repo;
			}

		}
        return super.setPackagePath(path,true);
	}
    override public function downloadTo(path:String){}
}
