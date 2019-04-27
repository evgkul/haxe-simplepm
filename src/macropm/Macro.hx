package macropm;

class Macro {
    #if macro
    public static function init(){
        trace('Init macro!');
    }
    #end
}