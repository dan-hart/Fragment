//
//  Throttler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

public class Throttler {
    
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private var maxInterval: TimeInterval
    
    public init(maxInterval: TimeInterval) {
        self.maxInterval = maxInterval
    }
    
    public func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date().timeIntervalSince(previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}
