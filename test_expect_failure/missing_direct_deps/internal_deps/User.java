package test_expect_failure.missing_direct_deps.internal_deps;

public class User {

    public void foo() {
        B.foo();
        C.foo();
    }

}
