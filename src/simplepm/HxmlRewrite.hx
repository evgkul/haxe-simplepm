package simplepm;

import parsihax.*;
import parsihax.Parser.*;
import parsihax.ParseObject;

import haxe.io.Path;
import tink.core.Future;

using parsihax.Parser;

typedef ParserContext = {
    rootPath:String,
    ?rewriter:HxmlRewrite
}

class HxmlRewrite {
	// public var parser:parsihax.ParseObject<String>;
	public function new() {}

    public dynamic function getLibDefinition(libname:String,context:ParserContext):String{
        throw 'Lib loading not implemented!';
    }

	public var argProcessor:Map<String, String->ParserContext->ParseObject<String>> = [
		'cp' => function(arg,context) {
			return all().map(function(s) {
				return '-' + arg + ' ' + Path.join([context.rootPath,s]);
			});
		},
        'lib' => function(arg,context) {
            return all().map(function(s){
                var before = '#Starting loading library '+s+'\n';
                var after = '\n#Finished loading library '+s;
                return before+context.rewriter.rewrite(context.rewriter.getLibDefinition(s,context),context)+after;
            });
        }
	];

	function getParser(context:ParserContext) {
		var processArgument = takeWhile(function(s) {
			return s != ' ';
		}).skip(whitespace().many()).flatMap(function(arg) {
				//trace('Argument!', arg);
				var processor = argProcessor[arg];
				if (processor == null) {
					processor = function(arg,context) return all().map(function(s) return '-' + arg + ' ' +s);
				}
				return processor(arg,context);
			});
		var processPath = all().skip(whitespace().many()).map(function(path) {
			// trace('RewriteFile!',path);
			var before = '#Starting ${path}\n';
			var after = '\n#Finished ${path}';
			return before + rewrite(sys.io.File.getContent(path),context) + after;
		});
		var processLine = alt([
            eof().result(''),
			'-'.char().then(processArgument),
			'#'.char().then(all()).map(function(s) return '#' + s),
			processPath
		]);
		return processLine;
	}

	public function rewrite(src:String,?context:ParserContext) {
        if(context==null) context = {
            rootPath: '.'
        };
        context.rewriter = this;
		var parser = getParser(context);
		return src.split('\n').map(function(c) return parser.apply(c).value).join('\n');
	}
}
