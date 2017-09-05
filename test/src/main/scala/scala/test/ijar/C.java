package scala.test.ijar;

class C {
	public static void foo() {
		System.out.println("orig");
	}

	public C() {
		B$.MODULE$.bar();
	}
}
