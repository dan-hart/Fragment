//
//  SupportView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Support this project")
                .font(.system(.title, design: .monospaced))
                .padding(.bottom)
            Text("\(Constants.appName) will always be free and open-source.")
                .font(.system(.body, design: .monospaced))
                .padding(.bottom)
            Text("If you have found this app useful, please consider:")
                .font(.system(.footnote, design: .monospaced))
        }
        .padding()
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
