package com.example.consumer

import com.example.resource.Util

import java.lang.Thread
import java.net.URL
import java.util.Enumeration

class Consumer {
  val hello: String = Util.hello

  val classLoader = Thread.currentThread.getContextClassLoader
  val resourceList: Enumeration[URL] = classLoader.getResources("com/example/resource")
}