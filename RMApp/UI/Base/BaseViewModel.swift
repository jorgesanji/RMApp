//
//  BaseViewModel.swift
//  RMApp
//
//  Created by jorge Sanmartin on 21/11/22.
//

import Foundation

open class BaseViewModel<State, Event>: NSObject, ObservableObject, ViewModel where State: Equatable {
    
    // MARK: Lifecycle
    
    public init(_ initialState: State) {
        state = initialState
    }
    
    // MARK: Open
    
    open func handleStateUpdate(_ oldState: State, new newState: State) {
        fatalError("Override handleStateUpdate(_:, new:) before continuing.")
    }
    
    open func handleEvent(_ event: Event) -> State? {
        fatalError("Override handleEvent(_:) before continuing.")
    }
    
    open func send(event: Event) {
        if let state = handleEvent(event) {
            self.state = state
        }
    }
    
    open func leaveState(_ state: State) {}
    open func enterState(_ state: State) {}
    
    // MARK: Public
    
    @Published public var stateError: Error?
    
    @Published private(set) public var state: State {
        willSet {
            leaveState(state)
        }
        
        didSet {
            enterState(state)
            handleStateUpdate(oldValue, new: state)
        }
    }
    
}

