class Main {
    static function main(){
        trace('It works!');
        var rewriter = new macropm.HxmlRewrite();
        Sys.println(
            rewriter.rewrite('#ddd\ntest.hxml\n#d2')
        );
    }
}