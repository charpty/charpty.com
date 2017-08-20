export default event => {
  return {
    bind: (el, binding, vnode) => {
      window.addEventListener(event, binding.value)
    },
    unbind: (el, binding, vnode) => {
      window.removeEventListener(event, binding.value)
    }
  }
}
