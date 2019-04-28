package macropm;

import haxe.io.StringInput;
import hscript.Parser;
import hscript.Interp;

class PackageHolderWrapper {
    var holder:PackagesHolder;
    public function new(){
        holder = new PackagesHolder();
    }
}

class HxmlCompiler {
    var parser:Parser;
    public var holder = new PackagesHolder();
    var rewriter = new HxmlRewrite();
    var classpathPrefix = '.';
    public function new(){
        parser = new Parser();
        parser.allowJSON = true;
        parser.allowMetadata = true;
        parser.allowTypes = true;
        rewriter.getLibDefinition = holder.getLibraryDefinition;
    }
    public function configureByHscript(code:String){
        var interp = new Interp();
        interp.variables.set('print',Sys.print);
        interp.variables.set('println',Sys.println);
        interp.variables.set('packages',holder);
        interp.variables.set('CopyFromHaxelib',macropm.packageloaders.CopyFromHaxelib);
        interp.variables.set('HaxelibFromGit',macropm.packageloaders.HaxelibFromGit);
        interp.variables.set('classpathPrefix','');
        interp.execute(
            parser.parse( new StringInput(code) )
        );
        holder.download();
        classpathPrefix = interp.variables.get('classpathPrefix');
    }
    public function compileHxml(code:String){
        return rewriter.rewrite(code,{
            rootPath: classpathPrefix
        });
    }
}