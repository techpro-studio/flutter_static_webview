import Flutter
import UIKit
import WebKit

enum StaticWebViewError: Error {
    case argument(String)
    case other(String)
}

extension StaticWebViewError {

    func asFlutterError() -> FlutterError {
        switch self {
        case .argument(let description):
            return FlutterError(code: "studio.techpro.static_web_wiew.error.invalid_input", message: description, details: nil)
        case .other(let description):
            return FlutterError(code: "studio.techpro.static_web_wiew.error.default", message: description, details: nil)
        }
    }
}


private struct PluginMethods {
    static let show = "show"
}
struct StaticWebViewConfig {
    let url: URL
    let title: String
}


extension StaticWebViewConfig {

    init(any: Any?) throws {
        guard let dict = any as? [String: Any] else {
            throw StaticWebViewError.argument("Input should be a dict")
        }
        guard let title = dict["title"] as? String else {
            throw StaticWebViewError.argument("String `title` not exists")
        }
        guard let urlString = dict["url"] as? String else {
            throw StaticWebViewError.argument("String `url` not exists")
        }
        guard let url = URL(string: urlString) else {
            throw StaticWebViewError.argument("URL should be valid")
        }
        self.init(url: url, title: title)
    }
}




open class WebViewController: UIViewController,  WKNavigationDelegate, WKUIDelegate {
    private let url: URL
    private let webView = WKWebView()

    var closed: (()->Void)?

    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc func close() {
        self.dismiss(animated: true, completion: closed);
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.close))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.close))
        }

        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.view.addSubview(webView)
        webView.frame = self.view.bounds
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webView.load(URLRequest(url: url))
    }

    public func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }

    deinit {
        print("Deinited Webview")
    }
}


public class SwiftStaticWebViewPlugin: NSObject, FlutterPlugin, UIAdaptivePresentationControllerDelegate  {

    private var result: FlutterResult!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "studio.techpro.static_webview", binaryMessenger: registrar.messenger())
        let instance = SwiftStaticWebViewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case PluginMethods.show:
            do {
                let config = try StaticWebViewConfig(any: call.arguments)
                self.result = result
                self.showWebViewController(with: config)
            } catch let error {
                result((error as! StaticWebViewError).asFlutterError())
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.finish()
    }

    private func showWebViewController(with config: StaticWebViewConfig){
        let webViewController = WebViewController(url: config.url, title: config.title)

        webViewController.closed = {[weak self] in
            self?.finish()
        }

        let root = UIApplication.shared.keyWindow!.rootViewController!
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.presentationController?.delegate = self
        root.present(navigationController, animated: true, completion: nil)
    }

    private func finish() {
        self.result(["ok": 1])
        self.result = nil
    }


}
