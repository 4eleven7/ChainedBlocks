//
//  ViewController.swift
//  ChainedBlockExample
//
//  Created by Daniel Love on 15/02/2016.
//  Copyright © 2016 Daniel Love. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet var topBlock: UIView!
	@IBOutlet var bottomBlock: UIView!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		assert(topBlock != nil)
		assert(bottomBlock != nil)
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		demoExampleOne()
	}
	
	func demoExampleOne()
	{
		UIView.animate
		{
			(chain) -> Void in
				chain.animate {
					self.topBlock.alpha = 0.1
				}
				chain.animate(1.0) {
					self.topBlock.alpha = 1.0
				}
				chain.animate(.Fast) {
					self.topBlock.alpha = 0.5
				}
				chain.animate(0.1, delay: 0.2, options: .CurveEaseOut) {
					self.topBlock.alpha = 1.0
				}
				chain.begin(then:
				{
					(completed) -> Void in
						self.demoExampleTwo()
				})
		}
	}
	
	func demoExampleTwo()
	{
		UIView.animate
		{
			(chain) -> Void in
				chain.animate {
					self.bottomBlock.alpha = 0.5
				}
				.animate {
					self.bottomBlock.alpha = 1.0
				}
				.execute {
					self.demoExampleThree()
				}
				.animate {
					self.bottomBlock.alpha = 0.5
				}
				.begin(then:
				{
					(completed) -> Void in
						self.demoExampleFour()
				})
		}
	}
	
	func demoExampleThree()
	{
		UIView.animate
		{
			(chain) -> Void in
				chain.animate {
					self.topBlock.alpha = 0.1
				}
				.animate(1.0) {
					self.topBlock.alpha = 1.0
				}
				.animate(.Fast) {
					self.topBlock.alpha = 0.5
				}
				.begin(then:
				{
					(completed) -> Void in
					
				})
		}
	}
	
	func demoExampleFour()
	{
class ChainFakeObject: ChainBlock
{
	// MARK: ChainBlock
	
	var block: (() -> Void)? = nil
	
	func perform(finished:() -> Void)
	{
		guard let block = block else
		{
			finished()
			return
		}
		
		print("This is a block that takes a long time")
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			block()
			print("Done, and off to the next block")
			finished()
		}
	}
}

let object = ChainFakeObject()
object.block = {
	self.topBlock.alpha = 0.0
	self.bottomBlock.alpha = 0.0
}

ChainedBlocks().queue(object)
				.animate
				{
					self.topBlock.alpha = 1.0
					self.bottomBlock.alpha = 1.0
					print("done!")
				}
				.begin()
	}
}


