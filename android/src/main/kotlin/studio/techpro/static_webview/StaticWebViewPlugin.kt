package studio.techpro.static_webview

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.webkit.URLUtil
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

object StaticWebViewMethods {
    const val show = "show"
}


data class StaticWebViewConfig(val url: String, val title: String)

/** StaticWebViewPlugin */
class StaticWebViewPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activityPluginBinding: ActivityPluginBinding
    private lateinit var result: Result


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "studio.techpro.static_webview")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
      when (call.method) {
        StaticWebViewMethods.show -> {
          try {
            val errCode = "studio.techpro.static_web_wiew.error.invalid_input"
            val title: String? = call.argument("title")
            if (title == null) {
              result.error(errCode, "String `title` not exists", null)
              return
            }
            val urlString: String? = call.argument("url")
            if (urlString == null) {
              result.error(errCode, "String `url` not exists", null)
              return
            }

            if (!URLUtil.isValidUrl(urlString)){
              result.error(errCode, "URL should be valid", null)
              return
            }
            if (!URLUtil.isHttpUrl(urlString) && !URLUtil.isHttpsUrl(urlString)){
              result.error(errCode, "URL should be http or https", null)
              return
            }
            this.result = result
            showStaticWebViewActivity(StaticWebViewConfig(urlString, title))
          } catch (err: Exception){
            result.error("exception", err.localizedMessage, null)
          }
        }
        else -> {
          result.notImplemented()
        }
      }
    }


  private fun showStaticWebViewActivity(config: StaticWebViewConfig) {
        val intent = Intent(activityPluginBinding.activity, StaticWebViewActivity::class.java)
        intent.putExtra("url", config.url)
        intent.putExtra("title", config.title)
        activityPluginBinding.activity.startActivityForResult(intent, 23)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK && requestCode == 23) {
            result.success(hashMapOf("ok" to 1))
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activityPluginBinding.removeActivityResultListener(this)
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding.removeActivityResultListener(this)
    }
}
