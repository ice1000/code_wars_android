package org.ice1000.code_wars_android;

import android.os.Bundle;

import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

/**
 * Android Main Activity
 *
 * @author ice1000
 */
public class MainActivity extends FlutterActivity {

	/**
	 * To do some log jobs
	 * <p>
	 * Here it's used to do some log
	 *
	 * @param savedInstanceState saved state
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		GeneratedPluginRegistrant.registerWith(this);
		Log.i(toString(), "app started (logged by ice1000)");
	}

	/**
	 * To do some log jobs
	 * <p>
	 * Here it's used to do some log
	 */
	@Override
	protected void onDestroy() {
		super.onDestroy();
		Log.i(toString(), "app exited (logged by ice1000)");
	}

	/**
	 * This method is interesting.
	 */
	@Override
	protected void onFlutterReady() {
		super.onFlutterReady();
	}
}
