package macropm;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;

class CompileAll {
    public static function compileAll(path:String) {
        var compiler = new HxmlCompiler();
        var hxmls = FileSystem.readDirectory(Path.join([path,'macropm_hxmls']));
        var script = File.getContent(Path.join([path,'packages.hscript']));
        compiler.configureByHscript(script);
        for(hxml in hxmls){
            File.saveContent(Path.join([path,hxml]),
                compiler.compileHxml(Path.join([path,'macropm_hxmls',hxml]))
            );
        }
    }
    public static function main(){
        compileAll('.');
    }
}