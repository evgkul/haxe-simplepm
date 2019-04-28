package macropm;

import parsihax.*;
import parsihax.Parser.*;
import parsihax.ParseObject;
import haxe.io.Path;
import tink.core.Future;

using parsihax.Parser;

class HaxelibLoader {
    function lineProcessor(){
        return alt([
            eof().result(''),
            '#'.char().then(all().map(function(s) return '#'+s)),
            '-'.char().then(all().map(function(s) return '-'+s)),
            all().map(function(s) return '-cp '+s)
        ]);
    }
	public function load(name, context) {
		var process = new sys.io.Process('haxelib', ['path', name]);
		var exitCode = process.exitCode();
		var resb = process.stdout.readAll();
		var res = resb.getString(0, resb.length);
        var processor = lineProcessor();
		// Preprocessing...
		var str = res.split('\n').map(function(s) {
            return processor.apply(s).value;
        }).join('\n');
        return str;
	}

	public function new() {}
}
