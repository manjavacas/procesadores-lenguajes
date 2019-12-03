public class GachaneitorWalker extends GachaneitorBaseListener {
  public void enterMenu(GachaneitorParser.MenuContext ctx ) {
    System.out.println( "Entering Menu : ");// + ctx.ID().getText() );
  }

  public void exitMenu(GachaneitorParser.MenuContext ctx ) {
    System.out.println( "Exiting Menu" );
  }
}
