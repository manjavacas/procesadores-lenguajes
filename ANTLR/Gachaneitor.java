import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class Gachaneitor {
    public static void main(String[] args) throws Exception {
        GachaneitorLexer lexer = new GachaneitorLexer(new ANTLRFileStream(args[0]));
        GachaneitorParser parser = new GachaneitorParser(new CommonTokenStream(lexer));

        new ParseTreeWalker().walk(new GachaneitorWalker(), parser.menu());
    }
}