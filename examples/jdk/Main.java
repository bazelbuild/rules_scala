package examples.jdk;

public class Main {
    public static void main(String... args) {
        System.getProperties().list(System.out);
        java.nio.ByteBuffer.allocate(1).flip();
    }
}
