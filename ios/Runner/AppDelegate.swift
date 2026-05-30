import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    /// Pending shared image path — consumed by Dart when it calls getSharedImage.
    static var pendingSharePath: String?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupShareChannel(engineBridge: engineBridge)
    }

    // MARK: - Share channel

    private func setupShareChannel(engineBridge: FlutterImplicitEngineBridge) {
        guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ShareHandler") else {
            NSLog("[ShareHandler] Failed to create plugin registrar")
            return
        }
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(name: "com.apurse.app/share", binaryMessenger: messenger)
        channel.setMethodCallHandler { (call, result) in
            if call.method == "getSharedImage" {
                let path = AppDelegate.pendingSharePath
                AppDelegate.pendingSharePath = nil
                NSLog("[ShareHandler] getSharedImage → path=\(path ?? "nil")")
                result(path)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - URL handling (pre-iOS 13 fallback)

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleSharedFile(url: url)
        return true
    }

    // MARK: - Shared file handling

    static func handleSharedFile(url: URL) {
        NSLog("[ShareHandler] Received URL: \(url)")

        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let shareDir = cacheDir.appendingPathComponent("share")
        try? FileManager.default.createDirectory(at: shareDir, withIntermediateDirectories: true)

        let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        let fileName = "share_\(Int(Date().timeIntervalSince1970 * 1000)).\(ext)"
        let destURL = shareDir.appendingPathComponent(fileName)

        // Security-scoped resource access (required for files from other apps)
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            try FileManager.default.copyItem(at: url, to: destURL)
            pendingSharePath = destURL.path
            NSLog("[ShareHandler] Saved to: \(destURL.path)")
        } catch {
            NSLog("[ShareHandler] Copy failed: \(error.localizedDescription)")
            pendingSharePath = nil
        }
    }
}
