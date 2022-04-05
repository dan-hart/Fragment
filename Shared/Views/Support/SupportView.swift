//
//  SupportView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Support this project")
                .font(.system(.title, design: .monospaced))
            Text("")
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
