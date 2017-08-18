import md2html from '../markdown'
export default {
  bind: (el, biding, vnode) => {
    el.innerHTML = md2html(biding.value)
  },
  update: (el, biding, vnode) => {
    el.innerHTML = md2html(biding.value)
  }
}
