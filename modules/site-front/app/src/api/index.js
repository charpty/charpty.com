const apihost = '/s/api/';

const getReqHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json'
};
const reqHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json'
};

function parseResponse(response) {
  return Promise.all([response.status, response.statusText, response.json()])
}

function checkStatus([status, statusText, data]) {
  if (status >= 200 && status < 300) {
    return data
  } else {
    let error = new Error(statusText);
    error.status = status;
    error.error_message = data;
    console.log("[ERR]code=" + status + ",msg=" + statusText);
    return Promise.reject(error)
  }
}

export default {
  get (url, params = {}, host = apihost) {
    let query = [], queryStr = '';
    Object.keys(params).forEach((item) => {
      query.push(`${item}=${encodeURIComponent(params[item])}`)
    })
    if (query.length) queryStr = '?' + query.join('&');
    url = host + url;
    if (queryStr.length > 0) url = url + queryStr;
    console.log(url);
    let init = {
      method: 'GET',
      headers: getReqHeaders,
      credentials: 'include',
      cache: 'default',
      mode: 'cors'
    }
    return fetch(url, init).then(parseResponse).then(checkStatus);
  },

  post (url, data = {}, host = apihost) {
    url = host + url;
    let init = {
      method: 'POST',
      headers: reqHeaders,
      credentials: 'include',
      mode: 'cors',
      body: JSON.stringify(data)
    };
    return fetch(url, init).then(parseResponse).then(checkStatus);
  },

  put (url, data = {}, host = apihost) {
    url = host + url;
    let init = {
      method: 'PUT',
      headers: reqHeaders,
      credentials: 'include',
      mode: 'cors',
      body: JSON.stringify(data)
    };
    return fetch(url, init).then(parseResponse).then(checkStatus)
  },

  delete (url, host = apihost) {
    url = host + url;
    let init = {
      method: 'DELETE',
      credentials: 'include',
      headers: reqHeaders,
      mode: 'cors'
    };
    return fetch(url, init).then(parseResponse).then(checkStatus);
  }

}
