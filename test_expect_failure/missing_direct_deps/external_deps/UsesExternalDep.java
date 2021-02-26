import com.google.common.base.Charsets;

public class UsesExternalDep {

  public void dependsOnExternalDep() {
    Empty useDirectDep = new Empty();
    System.out.println(useDirectDep);
    System.out.println(Charsets.ISO_8859_1);
  }
}