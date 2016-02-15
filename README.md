# ChainedBlocks
ChainedBlocks. Better UIView animations and chaining of code blocks.   
Knocked up for rapid prototyping, I'll clean it, check for retain cycles, comment, and document it sometime (which likely means never).

## Examples:

There is an example project, within contains sample code within `ViewController.swift`.

### UIView Animations

```swift
UIView.animate
{
	(chain) -> Void in
		chain.animate(0.1) {
			self.view.alpha = 0.7
		}
		chain.animate(.Fast) {
			self.view.alpha = 0.2
		}
		chain.execute {
			print("alpha is \(self.view.alpha)")
		}
		chain.executeSynchronously {
			print("frame is \(self.view.frame)")
		}
		chain.animate(.Slow) {
			self.view.alpha = 0.8
		}
		chain.animate(1.0) {
			self.view.alpha = 0.0
		}
		chain.begin {
			(completed) -> Void in
				self.view.hidden = true
		}
}
```

Example with chaining:

```swift
let chain = UIView.animate()
chain.animate {
		self.view.alpha = 0.5
	}
	.animate {
		self.view.alpha = 0.0
	}
	.begin { (completed) -> Void in
		self.view.alpha = 1.0
	}
```

Succinct example:
```swift
UIView.animate().animate { self.view.alpha = 0.5 }.animate { self.view.alpha = 0.0 }.begin()
```

### CodeBlocks
```swift
ChainedBlocks().execute { print("do something here") }.executeSynchronously { print("something was done, so do something else here") }.begin()
```

```swift
ChainedBlocks().execute { print("do something here") }.execute { print("something was done, so do something else here") }.begin {
	(completed) -> Void in
		print("two somethings were done in order")
}
```

### Custom

```swift
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
```
