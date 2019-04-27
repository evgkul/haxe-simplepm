package macropm;

import parsihax.*;
import parsihax.Parser.*;
import parsihax.ParseObject;

import haxe.io.Path;
import tink.core.Future;

using parsihax.Parser;

typedef ParserContext = {
    rootPath:String
}

class HxmlRewrite {
	// public var parser:parsihax.ParseObject<String>;
	public function new() {}

	public var argProcessor:Map<String, String->ParserContext->ParseObject<String>> = [
		'cp' => function(arg,context) {
			return all().map(function(s) {
                trace('classpath', arg, s);
				return '-' + arg + ' ' + Path.join([context.rootPath,s]);
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
			var after = '\n#Finishing ${path}';
			return before + rewrite(sys.io.File.getContent(path)) + after;
		});
		var processLine = alt([
			'-'.char().then(processArgument),
			'#'.char().then(all()).map(function(s) return '#' + s),
			processPath
		]);
		return processLine;
	}

	public function rewrite(src:String) {
		var parser = getParser({
            rootPath: '.'
        });
		return src.split('\n').map(function(c) return parser.apply(c).value).join('\n');
	}
}
