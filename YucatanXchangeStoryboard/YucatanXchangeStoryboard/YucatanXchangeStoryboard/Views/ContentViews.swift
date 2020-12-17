//
//  ContentViews.swift
//  YucatanXchangeStoryboard
//
//  Created by LARRY COMBS on 12/7/20.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var webViewStore = WebViewStore()
  
  var body: some View {
    NavigationView {
      WebView(webView: webViewStore.webView)
        .navigationBarTitle(Text(verbatim: webViewStore.webView.title ?? ""), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
          Button(action: goBack) {
            Image(systemName: "chevron.left")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.webView.canGoBack)
          Button(action: goForward) {
            Image(systemName: "chevron.right")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.webView.canGoForward)
        })
    }.onAppear {
      self.webViewStore.webView.load(URLRequest(url: URL(string: "https://reptulum.dhowardlakers.com/")!))
    }
  }
  
  func goBack() {
    webViewStore.webView.goBack()
  }
  
  func goForward() {
    webViewStore.webView.goForward()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
