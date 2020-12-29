//
//  CustomViews.swift
//  YucatanXchangeStoryboard
//
//  Created by LARRY COMBS on 12/7/20.


import WebArchiver
import SwiftUI
import Combine
import WebKit

struct CustomViews: View {
    
    
    /*
     * Just a tool for the loading spinner
     */
    class ToolbarState: NSObject, ObservableObject {
        @Published var loading = true
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            loading = change![.newKey] as! Bool // quick and dirty
        }
    }
    
    /*
     * An enum for the popup message
     */
    enum Popup: Identifiable {
        case archiveCreated
        case achivingFailed(error: Error)
        case noArchive
        
        var id: String { return self.message } // hack
        
        var message: String {
            switch self {
            case .archiveCreated:
                return "Web page stored offline."
            case .achivingFailed(let error):
                return "Error: " + error.localizedDescription
            case .noArchive:
                return "Nothing archived yet!"
            }
        }
    }
    
    let archiveURL: URL // the File where the Cached Website will be saved in the local device
    let webView: WKWebView // the webview
    let spinner: UIActivityIndicatorView // The loading spinner
    
    @ObservedObject var toolbar = ToolbarState()
    @State var popup: Popup? = nil
    
    init(homeUrl: URL) {
        
        // Initialization of the archiveURL
        self.archiveURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("cached").appendingPathExtension("webarchive")
        
        // Initialization of the spinner
        self.spinner = UIActivityIndicatorView(style: .medium)
        self.spinner.startAnimating()
        
        // Initialization of the webview
        self.webView = WKWebView()
        self.webView.addObserver(toolbar, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        
        // the website request
        let request = URLRequest(url: homeUrl)
        self.webView.load(request)
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            UIViewWrapper(view: webView)
            HStack(spacing: 20) {
                if toolbar.loading { // if it's loading, only the loading spinner will be shown
                    Spacer()
                    UIViewWrapper(view: spinner)
                    Spacer()
                } else { // if it's not loading, we show a back button and the Save and Load button`
                    Button(action: back) {
                        Image(systemName: "tray.fill")
                   }
                    Spacer()
                    Button("Save", action: archive)
                    Button("Load", action: unarchive)
                }
            }.padding().frame(height:40.0).background(Color(white:0.9))
        }.alert(item: $popup) { p in
            Alert(title: Text(p.message))
        }
    }
    
    /*
     * Go back functionality
     */
    func back() -> UIViewController? {
        var SecondViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            while let presentedViewController = SecondViewController?.presentedViewController {
                SecondViewController = presentedViewController
            }
            return SecondViewController
    }
     
        // let navVC = UINavigationController(rootViewController: rootVC)


    
    /*
     * Save the website locally function
     */
    func archive() {
        guard let url = webView.url else {
            return
        }
        
        toolbar.loading = true
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            
            WebArchiver.archive(url: url, cookies: cookies) { result in
                
                if let data = result.plistData {
                    do {
                        try data.write(to: self.archiveURL)
                        self.popup = .archiveCreated
                    } catch {
                        self.popup = .achivingFailed(error: error)
                    }
                } else if let firstError = result.errors.first {
                    self.popup = .achivingFailed(error: firstError)
                }
                
                self.toolbar.loading = false
            }
        }
    }
    
    
    /*
     * Load the stored website - for the use case where you have no internet
     */
    func unarchive() {
        if FileManager.default.fileExists(atPath: archiveURL.path) {
            webView.loadFileURL(archiveURL, allowingReadAccessTo: archiveURL)
        } else {
            self.popup = .noArchive
        }
    }
    
}



class SecondViewController: UIViewController {

    override func viewDidLoad(){
      super.viewDidLoad()
        view.backgroundColor = .systemBlue
      title = "Notifications"
    }
}


