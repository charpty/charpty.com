export default {
  /**
   * transform a funtion to a debounced function
   * @param {Function} func - the function to debounce
   * @param {Number} wait - debounce time
   * @param {Boolean} immediate - whether apply the function immediatly
   * @return {Fcuntion} the wrapped funciton
   */
  _debounce(func, wait = 200, immediate = false) {
    let _timestamp
    let _timer
    if (immediate) {
      return function() {
        let now = Date.now()
        if (_timestamp && now - _timestamp < wait) {
          _timestamp = now
          console.log(now)
          return
        }
        _timestamp = now
        func.apply(this, arguments)
      }
    }
    return function() {
      let now = Date.now()
      if (_timestamp && now - _timestamp < wait) {
        clearTimeout(_timer)
      }
      _timestamp = now
      _timer = setTimeout(func.bind(this, ...arguments), wait)
    }
  },
  _throttle(func, wait = 200, atleast = 200) {
    let _timestamp
    let _timer
    return function() {
      let now = Date.now()
      if (!_timestamp) {
        _timestamp = now
      }
      if (now - _timestamp > atleast) {
        func.apply(this, arguments)
        _timestamp = now
      } else {
        clearTimeout(_timer)
        _timer = setTimeout(func.bind(this, ...arguments), wait)
      }
    }
  },
  trim(str) {
    const {replace} = String.prototype
    return str.replace(/(^\s*)|(\s*$)/g, '')
  }
}
