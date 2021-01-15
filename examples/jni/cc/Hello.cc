#include <jni.h>
#include <stdio.h>
#include <string>
#include "Hello.h"

JNIEXPORT jstring JNICALL Java_examples_jni_Hello_hello
  (JNIEnv *env, jobject thisObj, jstring name) {
    const char* nameCharPointer = env->GetStringUTFChars(name, NULL);

    std::string greeting = "Hello, " + std::string(nameCharPointer);

    return env->NewStringUTF(greeting.c_str());
}