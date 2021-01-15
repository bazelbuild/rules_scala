package examples.jni;

public class Hello {
  static {
    System.loadLibrary("hello-jni");
  }
  public native String hello(String name);
}
