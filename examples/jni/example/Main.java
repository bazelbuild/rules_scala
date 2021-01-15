package example;

public class Main {

  static {
    System.loadLibrary("hello-jni");
  }

  public static void main(String[] args) {
    Hello hello = new Hello();
    System.out.println(hello.hello("Java"));
  }

}
