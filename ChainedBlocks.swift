//
//  ChainedBlock.swift
//
//  Created by Daniel Love on 14/02/2016.
//  Copyright © 2016 Daniel Love. All rights reserved.
//

import UIKit

class ChainedBlocks
{
	private var blocks = [ChainBlock]()
	private var completion: ((Bool) -> Void)? = nil
	private var canceled: Bool = false
	
	/**
	Queues up a ChainBlock, may be a code block, or animation etc
	*/
	func queue(queueBlock: ChainBlock) -> ChainedBlocks
	{
		blocks.append(queueBlock)
		return self
	}
	
	/**
	Starts it off, then fires the completion
	*/
	func begin(then completion: ((Bool) -> Void)? = nil)
	{
		self.completion = completion
		
		nextBlock()
	}
	
	/**
	Cancel the queue execution, if something is already running, it'll complete then kill
	*/
	func cancel()
	{
		canceled = true
	}
	
	private func nextBlock()
	{
		guard let object = blocks.first where canceled == false else {
			notifyCompletion()
			return
		}
		
		blocks.removeFirst()
		
		object.perform
			{
				() -> Void in
				self.nextBlock()
		}
	}
	
	private func notifyCompletion()
	{
		guard let completion = completion else {
			return print("No completion block")
		}
		
		completion(true)
	}
}

protocol ChainBlock
{
	var block: (() -> Void)? { get set }
	
	func perform(finished:() -> Void)
}

/**
Chained code executions
*/
extension ChainedBlocks
{
	func execute(asynchronous: Bool = true, codeBlock:() -> Void) -> ChainedBlocks
	{
		guard asynchronous else {
			return executeSynchronously(codeBlock)
		}
		
		let object = AsynchronousChainCodeObject()
		object.block = codeBlock
		
		queue(object)
		
		return self
	}
	
	func executeSynchronously(codeBlock: () -> Void) -> ChainedBlocks
	{
		let object = SynchronousChainCodeObject()
		object.block = codeBlock
		
		queue(object)
		
		return self
	}
}

class SynchronousChainCodeObject: ChainBlock
{
	var block: (() -> Void)? = nil
	
	func perform(finished:() -> Void)
	{
		block?()
		finished()
	}
}

class AsynchronousChainCodeObject: ChainBlock
{
	var block: (() -> Void)? = nil
	
	func perform(finished:() -> Void)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
			{
				self.block?()
				
				dispatch_async(dispatch_get_main_queue(), {
					finished()
				})
		})
	}
}

/**
Chained animations
*/
extension ChainedBlocks
{
	enum AnimationSpeed: NSTimeInterval
	{
		case Slow = 0.6
		case Normal = 0.2
		case Fast = 0.1
	}
	
	func animate(speed: AnimationSpeed, animation: () -> Void) -> ChainedBlocks
	{
		return animate(speed.rawValue, animation: animation)
	}
	
	func animate(duration: NSTimeInterval = 0.2, animation: () -> Void) -> ChainedBlocks
	{
		let object = ChainAnimationObject()
		object.duration = duration
		object.block = animation
		
		queue(object)
		
		return self
	}
	
	func animate(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animation: () -> Void) -> ChainedBlocks
	{
		let object = ChainAnimationObject()
		object.duration = duration
		object.delay = delay
		object.options = options
		object.block = animation
		
		queue(object)
		
		return self
	}
}

class ChainAnimationObject: ChainBlock
{
	var duration: NSTimeInterval = 0.2
	var delay: NSTimeInterval = 0.0
	var options: UIViewAnimationOptions = .CurveEaseInOut
	var completion: ((Bool) -> Void)? = nil
	
	// MARK: ChainBlock
	
	var block: (() -> Void)? = nil
	
	func perform(finished:() -> Void)
	{
		guard let block = block else
		{
			completion?(false)
			finished()
			return
		}
		
		UIView.animateWithDuration(duration, delay: delay, options: options, animations: block)
			{
				[weak self]
				(complete) -> Void in
				self?.completion?(complete)
				finished()
		}
	}
}

extension UIView
{
	class func animate(animations: ((ChainedBlocks) -> Void)? = nil) -> ChainedBlocks
	{
		let chainBlock = ChainedBlocks()
		
		if let animations = animations {
			animations(chainBlock)
		}
		
		return chainBlock
	}
}
