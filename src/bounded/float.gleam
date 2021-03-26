//// A wrapper for the base [`bounded`](/bounded) module to work with floats.
////
//// ---
////
//// * **Creating bounded floats**
////   * [`by`](#by)
////   * [`between`](#between)
////


import bounded.{Bounded}
import gleam/float.{Float}


// CREATING BOUNDED VALUES -----------------------------------------------------


/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Create an float bounded by a min and max value. This defaults to using the
/// provided min as the initial value.
///
/// Although function parameters are named `min` and `max` for convenience, this
/// will always use whichever value is smaller as the minimum bound as determined
/// by your comparison function.
///
/// See also: [`bounded.by`](/bounded#by)
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn by (min: Float, max: Float) -> Bounded(Float) {
    bounded.by(min, max, float.compare)
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Create an float bounded by a min and max value. The first parameter determines
/// the initial value, although it will be clamped if it is out of bounds.
///
/// Although function parameters are named `min` and `max` for convenience, this
/// will always use whichever value is smaller as the minimum bound as determined
/// by your comparison function.
///
/// See also: [`bounded.between`](/bounded#between)
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn between (val: Float, min: Float, max: Float) -> Bounded(Float) {
    bounded.between(val, min, max, float.compare)
}
