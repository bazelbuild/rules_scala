package com.example.consumer

import java.net.URL

import org.scalatest.flatspec._
import org.scalatest.matchers.should._

class ConsumerSpec extends AnyFlatSpec with Matchers {

    "ConsumerSpec" should "have valid classloaders" in {
      val fixture = new Consumer()
      fixture.resourceList.hasMoreElements should be (true)
      val element = fixture.resourceList.nextElement
      element shouldBe a [URL]
      println(element)
    }

}