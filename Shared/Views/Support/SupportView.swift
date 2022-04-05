//
//  SupportView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        VStack() {
            Text("Support this project")
                .font(.system(.title, design: .monospaced))
                .padding()
            Text("\(Constants.appName) will always be free.")
                .font(.system(.subheadline, design: .monospaced))
        }
        .padding()
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
