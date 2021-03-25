//// A module for working with values between a minimum and maximum bound. 
////
//// ---
////
//// * **The `Bounded` type**
////   * [`Bounded`](#Bounded)
//// * **Creating bounded values**
////   * [`by`](#by)
////   * [`between`](#between)
//// * **Updating bounded values**
////   * [`set`](#set)
////   * [`set_to_min`](#set_to_min)
////   * [`set_to_max`](#set_to_max)
////   * [`update`](#update)
//// * **Unpacking bounded values**
////   * [`value`](#value)
////   * [`min`](#max)
////   * [`max`](#max)
////   * [`comparator`](#comparator)
////


import gleam/order.{Order, Lt, Eq, Gt}


// TYPES -----------------------------------------------------------------------


/// <div style="text-align: right; margin-top: 1em;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Represents a value bounded by some minimum and maximum values, **inclusive**. 
///
/// Note how this is parameterized by the type variable `a`. By using the exposed
/// constructor functions `bounded` or `between` you can supply a custom comparison
/// function so that you can create _any_ sort of bounded value.
///
/// For common bounded types such as `Bounded(Int)` and `Bounded(Float)` some
/// convenience modules exist to cover them:
///
///   * [`bounded/int`](/bounded/int)
///   * [`bounded/float`]()
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub opaque type Bounded(a) {
    Bounded(
        comparator: fn (a, a) -> Order,
        min: a,
        max: a,
        val: a
    )
}


// CREATING BOUNDED VALUES -----------------------------------------------------



/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Create a [`Bounded`](#Bounded) value by supplying a minimum and maximum value
/// and a comparison function to be used when setting or updating this value.
///
/// This defaults to using the supplied _minimum_ value as the initial value.
/// Although function parameters are named `min` and `max` for convenience, this
/// will always use whichever value is smaller as the minimum bound as determined
/// by your comparison function.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/int
///     import gleam/should
///
///     pub fn example () {
///         let foo = bounded.by(0, 100, int.compare)
///
///         bounded.value(of: foo) |> should.equal(0)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn by (min: a, max: a, compare: fn (a, a) -> Order) -> Bounded(a) {
    case compare(min, max) {
        Lt -> Bounded(compare, min, max, min)
        Eq -> Bounded(compare, min, max, min)
        Gt -> Bounded(compare, max, min, max)
    }
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Create a [`Bounded`](#Bounded) value by supplying an initial, minimum, and maximum value
/// and a comparison function. If the initial value is out of bounds it will be
/// clamped to either the supplied `min` or `max` value.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/int
///     import gleam/should
///
///     pub fn example () {
///         let foo = 50  |> bounded.between(0, 100, int.compare)
///         let bar = 999 |> bounded.between(0, 100, int.compare)
///
///         bounded.value(of: foo) |> should.equal(50)
///         bounded.value(of: bar) |> should.equal(100)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn between (val: a, min: a, max: a, compare: fn(a, a) -> Order) -> Bounded(a) {
    // We can cut down on a load of bloated logic by just creating a bounded
    // value using the `bounded` function above and then calling `set` with the
    // supplied value.
    by(min, max, compare)
        |> set(val)
}


// UPDATING BOUNDED VALUES -----------------------------------------------------


/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Replace the value stored inside a [`Bounded`](#Bounded) with a new one. If it is out of
/// bounds it will clamp to the existing min or max value.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = bounded.by(0, 100, int.compare)
///
///         bounded.set(foo, to: 20)
///             |> bounded.value
///             |> should.equal(20)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn set (bounded: Bounded(a), to val: a) -> Bounded(a) {
    let Bounded(comparator, min, max, _) = bounded

    case comparator(min, val) {
        Gt -> Bounded(..bounded, val: min)
        _  -> case comparator(val, max) {
            Gt -> Bounded(..bounded, val: max)
            _  -> Bounded(..bounded, val: val)
        }
    }
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Reset a [`Bounded`](#Bounded) value to its minimum.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = 50 |> bounded.between(0, 100, int.compare)
///
///         bounded.set_to_min(foo)
///             |> bounded.value
///             |> should.equal(0)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn set_to_min (bounded: Bounded(a)) -> Bounded(a) {
    Bounded(..bounded, val: bounded.min)
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Reset a [`Bounded`](#Bounded) value to its maximum.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = 50 |> bounded.between(0, 100, int.compare)
///
///         bounded.set_to_max(foo)
///             |> bounded.value
///             |> should.equal(100)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn set_to_max (bounded: Bounded(a)) -> Bounded(a) {
    Bounded(..bounded, val: bounded.max)
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Updated the value stored inside a [`Bounded`](#Bounded) by applying a
/// function to it. This will clamp to the existing min or max value if it is
/// out of bounds.
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = 20 |> bounded.between(0, 100, int.compare)
///
///         bounded.update(foo, by: fn (n) { n * 2 }) 
///             |> bounded.value
///             |> should.equal(40)
///
///         bounded.update(foo, by: fn (n) { n * 999 }) 
///             |> bounded.value
///             |> should.equal(100)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn update (bounded: Bounded(a), by f: fn(a) -> a) -> Bounded(a) {
    set(bounded, to: f(bounded.val))
}


// UNPACKING BOUNDED VALUES ----------------------------------------------------


/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Retrieve the value stored inside a [`Bounded`](#Bounded).
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = 50 |> bounded.between(0, 100, int.compare)
///
///         bounded.value(of: foo) |> should.equal(50)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn value (of bounded: Bounded(a)) -> a {
    bounded.val
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Retrieve the minimum value set by a [`Bounded`](#Bounded).
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = bounded.by(0, 100, int.compare)
///
///         bounded.min(of: foo) |> should.equal(0)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn min (of bounded: Bounded(a)) -> a {
    bounded.min
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Retrieve the maximum value set by a [`Bounded`](#Bounded).
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/should
///
///     pub fn example () {
///         let foo = bounded.by(0, 100, int.compare)
///
///         bounded.max(of: foo) |> should.equal(100)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn max (of bounded: Bounded(a)) -> a {
    bounded.max
}

/// <div style="text-align: right;">
///     <a href="https://github.com/pd-andy/gleam_bounded/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
/// </div>
///
/// Retrieve the comparison function used by a [`Bounded`](#Bounded).
///
/// <details>
///     <summary>Example:</summary>
///
///     import bounded
///     import gleam/order
///     import gleam/should
///
///     pub fn example () {
///         let foo = bounded.by(0, 100, int.compare)
///         let compare = bounded.comparator(of: foo)
///
///         compare(10, 50) |> should.equal(order.Lt)
///     }
/// </details>
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn comparator (of bounded: Bounded(a)) -> fn (a, a) -> Order {
    bounded.comparator
}
