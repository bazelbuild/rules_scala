package rules_scala.test

import android.app.Activity
import android.os.Bundle
import android.util.Log

class ScalaAndroidLibraryActivity extends Activity {

  override def onCreate(state: Bundle): Unit = {
    super.onCreate(state)

    Log.d("ScalaAndroidLibraryActivity", "activity started")
  }

}