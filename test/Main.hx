import sys.io.File;
import sys.FileSystem;
import simplepm.packageloaders.CopyFromHaxelib;
import simplepm.PackagesHolder;

class Main {
    static function main(){
        /*trace('It works!');
        Sys.println(Sys.command('rm',['-rf','macropm_modules']));
        var rewriter = new macropm.HxmlRewrite();
        
        var holder = new PackagesHolder();
        holder.hxmlOffset = 'tmp';
        rewriter.getLibDefinition = holder.getLibraryDefinition;
        holder.addPackage(
            macropm.packageloaders.CopyFromHaxelib.create('tink_macro')
        );
        holder.addPackage(
            macropm.packageloaders.CopyFromHaxelib.create('tink_lang')
        );
        holder.addPackage(
            macropm.packageloaders.HaxelibFromGit.create('https://github.com/haxetink/tink_anon','0.1.0')
        );
        holder.addPackage(
            macropm.packageloaders.CopyFromHaxelib.create('hscript')
        );
        //Sys.println(@:privateAccess holder.packages);
        @:privateAccess holder.download();
        Sys.println('rewrite test!\n'+rewriter.rewrite('test.hxml'));*/
        var compiler = new simplepm.HxmlCompiler();
        compiler.configureByHscript(
            File.getContent('packages.hscript')
        );

        Sys.println('Compiled: '+compiler.compileHxml('test.hxml'));
    }
}