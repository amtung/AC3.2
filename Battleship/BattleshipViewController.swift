//
//  BattleshipViewController.swift
//  Battleship
//
//  Created by Jason Gresh on 9/16/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class BattleshipViewController: UIViewController {
    
    @IBOutlet weak var gridView: UIView! //creating a grid for the buttons
    @IBOutlet weak var messageLabel: UILabel!
    
    let brain: BattleshipBrain
    
    required init?(coder aDecoder: NSCoder) {
        self.brain = BattleshipBrain(rows: 5, columns: 5)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // better than viewDidLayoutSubviews but not all the way there
        self.view.layoutIfNeeded()
        
        startGame()
    }
    
    func buttonTapped(_ sender: UIButton) { //starts at (0,0)
        // our tag is one-based so we subtract 1 before indexing
        let r = (sender.tag - 1) / brain.columns //divided by 5, r&c represent the coordinate, tag starts at 1
        let c = (sender.tag - 1) % brain.columns
        
        // note how the strike itself isn't updating the interface
        _ = brain.strike(atRow: r, andColumn: c)
        
        // everytime it's tapped it will scan/redraw the whole board and place on the matrix
        drawBoard()
        
        // check for win
        if brain.gameFinished() {
            messageLabel.text = "You win!"
        }
        else {
            messageLabel.text = "Keep guessing"
        }
    }
    
    func drawBoard() {
        for r in 0..<brain.rows { //goes from (0,1)(0,2)..(1,0)(2,0)
            for c in 0..<brain.columns {
                // find the button by tag
                // our tag is one-based so we add 1
                if let button = gridView.viewWithTag(r * brain.columns + c + 1) as? UIButton { //unwrapping the buttons
                    
                    // funky subscript call with two indexes ([r][c] doesn't seem to work)
                    switch brain[r, c] { //matrix of random states
                    case .empty(let state):
                        switch state {
                        case .shown:
                            button.backgroundColor = UIColor.lightGray
                        case .hidden:
                            button.backgroundColor = UIColor.blue
                        }
                    case .occupied(let state, _):
                        switch state {
                        case .shown: //either tapped or not
                            button.backgroundColor = UIColor.red
                        case .hidden:
                            button.backgroundColor = UIColor.blue
                        }
                    }
                }
            }
        }
    }
    //0 * 5 + 0 + 1 = 1
    //0 * 5 + 1 + 1 = 1
    //0 * 5 + 2 + 1 = 1
    //..
    //1 * 5 + 0 + 1 = 6
    //2 * 5 + 0 + 1 = 11
    func setUpGameButtons(v: UIView) {
        // remove all views from the container
        // this helps both with resetting and if viewDidLayoutSubviews is called more than once
        for v in v.subviews {
            v.removeFromSuperview() //resetting the game
        }
        
        let side : CGFloat = v.bounds.size.width / CGFloat(brain.rows)
        for row in 0..<brain.rows {
            for col in 0..<brain.columns {
                
                let rect = CGRect(origin: CGPoint(x: CGFloat(row) * side,
                                                  y: CGFloat(col) * side),
                                  size: CGSize(width: side - 1, height: side - 1))
                let button = UIButton(frame: rect)
                
                // this flattens the 2d matrix into a sequence of numbers
                // our tag is one-based so we add 1
                button.tag = row * brain.columns + col + 1
                
                let letter = String(Character(UnicodeScalar(65 + row)!)) //#65 is A and so on
                button.setTitle("\(letter)\(col + 1)", for: UIControlState()) //+1 will make the first column/row start at 1
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                v.addSubview(button)
                //button.tag = 0 * 5 + 0 + 1 = 1 column 1-5
                //button.tag = 0 * 5 + 1 + 1 = 1
            }
        }
        drawBoard() //redraw the board, going to be called over and over again and check the state of the buttons from the already randomized grid
    }
    
    func startGame() {
        brain.resetBoard()
        setUpGameButtons(v: gridView)
        messageLabel.text = "Good luck"
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        startGame()
    }
}

//have an enum of different type of boats
//r + 1, c + 5 to go to the next button

