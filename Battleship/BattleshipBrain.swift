//
//  BattleshipBrain.swift
//  Battleship
//
//  Created by Jason Gresh on 9/18/16.
//  Copyright © 2016 C4Q. All rights reserved.
//


import Foundation

class BattleshipBrain {
    enum Coordinate {
        enum Ship { //ignore this ship enum for now
            case carrier(Int)
            case battleship(Int)
        }
        enum State {
            case hidden, shown
        }
        case occupied(State, Ship) //ship type
        case empty(State)
        
        mutating func tryToHit() -> Bool { //matrix is set up first
            switch self {
            case .occupied(let state, let ship): //has a ship
                switch state {
                case .hidden:
                    self = Coordinate.occupied(.shown, ship) //show if hidden
                    return true
                case .shown:
                    return true
                }
            case .empty:
                self = Coordinate.empty(.shown) //show if empty, no ship
                return false
            }
        }
    }
    
    let rows: Int
    let columns: Int

    private var coordinates: [[Coordinate]]
    
    init(rows: Int, columns: Int){
        self.rows = rows
        self.columns = columns
        self.coordinates = [[Coordinate]]()
        setupBoard()
    }
    
    
    func setupBoard() {
        for r in 0..<rows {
            self.coordinates.append([Coordinate](repeating: .empty(.hidden), count: columns))
            
            // this just sets one hit per column
            coordinates[r][Int(arc4random_uniform(UInt32(columns)))] = Coordinate.occupied(.hidden, .carrier(5)) //randomizing the columns from 0...4
        }
    }
    
    func resetBoard() {
        self.coordinates = [[Coordinate]]() //resetting the coordinates
        setupBoard()
    }
    
    subscript(i: Int, j: Int) -> Coordinate {
        return coordinates[i][j]
    }
    
    func strike(atRow r: Int, andColumn c: Int) -> Bool {
        return coordinates[r][c].tryToHit() //checks if occupied/empty
    }
    
    func gameFinished() -> Bool {
        for r in 0..<rows {
            for c in 0..<columns {
                // if any occupied coordinates are hidden we're not done
                if case .occupied(.hidden, _) = coordinates[r][c] {
                    return false
                }
            }
        }
        return true
    }
}
