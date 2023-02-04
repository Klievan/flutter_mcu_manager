import Flutter
import UIKit
import iOSMcuManagerLibrary

public class SwiftDeviceManagerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FirmwareUpgradeDelegate{
    public func upgradeDidStart(controller: iOSMcuManagerLibrary.FirmwareUpgradeController) {
        sink?(["upgradeDidStart": ""])
    }
    
    public func upgradeStateDidChange(from previousState: iOSMcuManagerLibrary.FirmwareUpgradeState, to newState: iOSMcuManagerLibrary.FirmwareUpgradeState) {
        sink?(["upgradeStateDidChange": ["previousState": String(describing: previousState), "newState": String(describing: newState)]])
    }
    
    public func upgradeDidComplete() {
        sink?(["upgradeDidComplete": ""])
    }
    
    public func upgradeDidFail(inState state: iOSMcuManagerLibrary.FirmwareUpgradeState, with error: Error) {
        sink?(["upgradeDidFail":["state": String(describing: state),"error": error.localizedDescription]])
    }
    
    public func upgradeDidCancel(state: iOSMcuManagerLibrary.FirmwareUpgradeState) {
        sink?(["upgradeDidCancel":["state": String(describing: state)]])
    }
    
    public func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        sink?(["uploadProgressDidChange":["bytesSent": bytesSent, "imageSize": imageSize, "timestamp": timestamp.encode()]])
    }
    
    
    
    let registrar: FlutterPluginRegistrar
    var sink: FlutterEventSink!
    
    init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "device_manager", binaryMessenger: registrar.messenger())
        let event = FlutterEventChannel(name:
                                            "device_manager/event", binaryMessenger: registrar.messenger())
        let instance = SwiftDeviceManagerPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        event.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS test " + UIDevice.current.systemVersion)
        case "startDFU":
            startDFU(call, result);
        default: result(FlutterMethodNotImplemented)
            
        }
    }
    
    
    public func startDFU(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        
        guard let arguments = call.arguments as? Dictionary<String, AnyObject> else {
            result(FlutterError(code: "ABNORMAL_PARAMETER", message: "no parameters", details: nil))
            return
        }
        
        guard let uuid = arguments["uuid"] as? String,
              var path = arguments["path"] as? String else {
            result(FlutterError(code: "ABNORMAL_PARAMETER", message: "uuid and path are required", details: nil))
            return
        }
        
        guard let device_uuid = UUID(uuidString: uuid) else {
            result(FlutterError(code: "DEVICE_ADDRESS_ERROR", message: "Device address conver to uuid failed", details: "Device uuid \(uuid) convert to uuid failed"))
            return;
        };
        
        let fileInAsset = (arguments["fileInAsset"] as? Bool) ?? false;
        
        if (fileInAsset) {
                    let key = registrar.lookupKey(forAsset: path)
                    guard let pathInAsset = Bundle.main.path(forResource: key, ofType: nil) else {
                        result(FlutterError(code: "ABNORMAL_PARAMETER", message: "file in asset not found \(path)", details: nil))
                        return
                    }
                    
                    path = pathInAsset
                }
        do {
            let bleTransport = McuMgrBleTransport(device_uuid);
             let firmwareData = try Data(contentsOf: URL(fileURLWithPath: path));
            let dfuManager = FirmwareUpgradeManager(transporter: bleTransport, delegate: self);
            
            if(arguments["firmwareUpgradeMode"] != nil) {
                switch(arguments["firmwareUpgradeMode"] as! String) {
                case "testOnly":
                    dfuManager.mode = FirmwareUpgradeMode.testOnly;
                    break;
                case "confirmOnly":
                    dfuManager.mode = FirmwareUpgradeMode.confirmOnly;
                    break;
                case "testAndConfirm":
                    dfuManager.mode = FirmwareUpgradeMode.testAndConfirm;
                    break;
                default:
                    break;
                }
            }
            
            var estimatedSwapTime: TimeInterval?;
            if(arguments["estimatedSwapTime"] != nil && !(arguments["estimatedSwapTime"] is NSNull)) {
                estimatedSwapTime = (arguments["estimatedSwapTime"] as! Double)/1000.0;
            }
            
            
            let upgradeConfig = FirmwareUpgradeConfiguration(estimatedSwapTime: estimatedSwapTime ?? 0, reassemblyBufferSize: (arguments["reassemblyBufferSize"] as? UInt64) ?? 0);
            try dfuManager.start(data: firmwareData,using: upgradeConfig);
        } catch {
            print("Unexpected error: \(error).")
        }
        
    }
    
}
