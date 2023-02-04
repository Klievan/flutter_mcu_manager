package com.iosatracking.device_manager

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.runtime.mcumgr.McuMgrTransport
import io.runtime.mcumgr.ble.McuMgrBleTransport
import io.runtime.mcumgr.dfu.FirmwareUpgradeCallback
import io.runtime.mcumgr.dfu.FirmwareUpgradeController
import io.runtime.mcumgr.dfu.FirmwareUpgradeManager
import io.runtime.mcumgr.exception.McuMgrException
import java.io.File
import java.io.IOException
import java.io.InputStream

/** DeviceManagerPlugin */
class DeviceManagerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

  private var mContext: Context? = null

  private lateinit var methodChannel : MethodChannel

  private lateinit var eventChannel: EventChannel
  private var sink: EventChannel.EventSink? = null
    private var binding: FlutterPluginBinding? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
     mContext = flutterPluginBinding.applicationContext

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_manager")
    methodChannel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "device_manager/event")
    eventChannel.setStreamHandler(this)

      binding = flutterPluginBinding
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
            "startDFU" -> startDFU(call, result)
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            else -> result.notImplemented()
        }

  }

  override fun onDetachedFromEngine(flutterPluginBinding: FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    mContext = null
      binding = null
      
  }



  private fun startDFU(call: MethodCall, result: Result) {
    val uuid = call.argument<String>("uuid")
    val path = call.argument<String>("path")
    val mode = call.argument<String>("mode")
    var fileInAsset = call.argument<Boolean>("fileInAsset")
    val estimatedSwapTime = call.argument<Int>("estimatedSwapTime")
    val pipelineDepth = call.argument<Int>("pipelineDepth")
    val reassemblyBufferSize = call.argument<Int>("reassemblyBufferSize")
      val memoryAlignment = call.argument<Int>("memoryAlignment")
      var eraseAppSettings = call.argument<Boolean>("eraseAppSettings")

    if (fileInAsset == null) fileInAsset = false
    if (uuid == null || path == null) {
        result.error("Abnormal parameter", "uuid and path are required", null)
        return
    }

      val firmwareData: ByteArray

    if (fileInAsset) {
        // Grab the true asset path
        val assetPath = binding?.flutterAssets?.getAssetFilePathBySubpath(path)

        try {
            val inputStream: InputStream = binding!!.applicationContext.assets.open(assetPath!!)
            firmwareData = inputStream.readBytes()
            inputStream.close()
        } catch (e: IOException) {
            e.printStackTrace();
            result.error("IO_ERROR_ASSET_READING", e.message, null)
            return
        }

        } else {
        firmwareData = File(path).readBytes()
    }

      // Get the BluetoothAdapter
      val bluetoothManager: BluetoothManager = mContext!!.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
      val bluetoothAdapter: BluetoothAdapter = bluetoothManager.adapter





      // Get the Bluetooth Device
      val bluetoothDevice: BluetoothDevice? = bluetoothAdapter.getRemoteDevice(uuid)
      if(bluetoothDevice == null) {
          result.error("INVALID_BLE_UUID", "An invalid BLE UUID was specified.", "$uuid is not a valid BLE UUID in Android")
          return
      }

      // Initialize the BLE transporter with context and a BluetoothDevice
      val mcuMgrTransport: McuMgrTransport = McuMgrBleTransport(mContext!!, bluetoothDevice)

      // Initialize the Firmware Upgrade Manager
      val firmwareUpgradeManager = FirmwareUpgradeManager(mcuMgrTransport, mFirmwareUpgradeCallback)

      // Set the estimated swap time
      if (estimatedSwapTime != null) {
          firmwareUpgradeManager.setEstimatedSwapTime(estimatedSwapTime)
      }

      // Set the pipeline depth
      if (pipelineDepth != null) {
          firmwareUpgradeManager.setWindowUploadCapacity(pipelineDepth)
      }

      // Set the memory alignment
      if (memoryAlignment != null) {
          firmwareUpgradeManager.setMemoryAlignment(memoryAlignment)
      }

      // Set the mode
      when(mode) {
          "testOnly" -> firmwareUpgradeManager.setMode(FirmwareUpgradeManager.Mode.TEST_ONLY)
          "confirmOnly" -> firmwareUpgradeManager.setMode(FirmwareUpgradeManager.Mode.CONFIRM_ONLY)
          "testAndConfirm" -> firmwareUpgradeManager.setMode(FirmwareUpgradeManager.Mode.TEST_AND_CONFIRM)
      }


      if(eraseAppSettings == null) {
          eraseAppSettings = false
      }
      firmwareUpgradeManager.start(firmwareData)
  }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.sink = events

    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }



    private val mFirmwareUpgradeCallback: FirmwareUpgradeCallback = object :
        FirmwareUpgradeCallback {
        override fun onUpgradeStarted(controller: FirmwareUpgradeController?) {
            sink?.success(mapOf("upgradeDidStart" to ""))
        }

        override fun onStateChanged(
            prevState: FirmwareUpgradeManager.State?,
            newState: FirmwareUpgradeManager.State?
        ) {
            sink?.success(mapOf("upgradeStateDidChange" to mapOf("previousState" to prevState!!.name,
                "newState" to newState!!.name)))
        }

        override fun onUpgradeCompleted() {
            sink?.success(mapOf("upgradeDidComplete" to ""))
        }

        override fun onUpgradeFailed(state: FirmwareUpgradeManager.State?, error: McuMgrException?) {
            sink?.success(mapOf("upgradeDidFail" to mapOf("state" to state!!.name,
                "error" to error!!.localizedMessage)))
        }

        override fun onUpgradeCanceled(state: FirmwareUpgradeManager.State?) {
            sink?.success(mapOf("upgradeDidCancel" to ""))
        }

        override fun onUploadProgressChanged(bytesSent: Int, imageSize: Int, timestamp: Long) {
            sink?.success(mapOf("uploadProgressDidChange" to mapOf("bytesSent" to bytesSent,
                "imageSize" to imageSize, "timestamp" to timestamp)))
        }

    };

}
