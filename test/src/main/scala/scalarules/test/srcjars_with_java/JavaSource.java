package fish;

public class JavaSource {
  // We do not make this final - a bug in dependency analyzer in 2.11
  // and below means that dependencies on static final variables are not
  // detected
  public static String line = "one fish, two fish";
}
