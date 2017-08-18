import service from './service.js'

export default {
  async getPostList (params) {
    return await service.get('posts', params)
  },
  async getPost (title) {
    return await service.get(`posts/${title}`)
  },
  async getAllTags () {
    return await service.get('tags')
  },
  async getCategories (params) {
    return await service.get('categories', params)
  },
  async postComment (params) {
    return await service.post('comments', params)
  }
}
