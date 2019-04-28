package macropm;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class FileUtils {
    public static function copyDirectory(from:String,to:String){
        try{
            FileSystem.createDirectory(to);
        } catch(e:Dynamic){}
        for(item in FileSystem.readDirectory(from)){
            //Sys.println('Item '+item);
            var item_path = Path.join([from,item]);
            var to_path = Path.join([to,item]);
            if(FileSystem.isDirectory(item_path)){
                copyDirectory(item_path,to_path);
            } else {
                File.copy(item_path,to_path);
            }
        }
    }
}