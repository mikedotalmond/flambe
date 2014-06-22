package flambe.math;

/*
* ...
* @author Mike Almond
*
*
* The Park–Miller random number generator (Lehmer random number generator)
* http://en.wikipedia.org/wiki/Park%E2%80%93Miller_random_number_generator
*
* Implemented here using the Mersenne prime M31 (16807)
*/

@:final  class PRandom {
	
	static inline var M31		:Int = 16807;
	static inline var Range		:Int = 0x7FFFFFFF;
	
	
	/**
	 * set seed with a 31 bit unsigned integer
	 * between 1 and 0X7FFFFFFE inclusive.
	 */
	public var seed(get, set):Int;
	
	var _seed:Int;
	inline function get_seed():Int return _seed;	
	inline function set_seed(value:Int):Int {
		if (value < 1 || value >= Range-1) throw "RangeError";
		return _seed = value;
	}
	
	
	/**
	 *
	 * @param	seed - optional, if not passed the starting seed will be 1
	 */
	public function new(seed:Int = 1) {
		this.seed = seed;
	}
	
	
	/**
	 * @return provides the next pseudorandom bool
	 * false if the next integer from gen() is odd, true if it's even
	 */
	inline public function nextBool():Bool {
		return (gen() & 1) == 0;
	}
	
	
	/**
	 * @return provides the next pseudorandom number
	 * as an unsigned integer (31 bits)
	 */
	inline public function nextInt():Int{
		return gen();
	}
	
	
	/**
	 * @return provides the next pseudorandom number
	 * as a float between nearly 0 and nearly 1.0.
	 */
	inline public function nextFloat():Float {
		return gen() / Range;
	}
	
	
	/**
	 * @return provides the next pseudorandom number
	 * as a float between nearly -0.5 and nearly 0.5
	 */
	public function nextZeroCrossingFloat():Float {
		return (gen() / Range) - 0.5;
	}
	
	
	/**
	 * generator:
	 * newValue = (oldValue * 16807) mod (2^31 - 1)
	 */
	inline function gen():Int {
		return _seed = Std.int((_seed * M31) % Range);
	}
}