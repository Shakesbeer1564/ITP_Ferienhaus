class HttpService{
  baseURL = '';

  constructor(baseURL){
    this.baseURL = baseURL
  }

 
  async getData(endpoint, searchParams = null, contentType = 'json') {
    const url = new URL(`${this.baseURL}/${endpoint}`, import.meta.url);
    if (searchParams) {
      Object.keys(searchParams).forEach(key => url.searchParams.append(key, searchParams[key]));
    }

    try {
      const res = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (!res.ok) {
        throw new Error('Error while getting data');
      }

      return contentType == 'json' ? res.json() : res.blob();
    }
    catch (err) {
      console.error('Error GET: ', err);
      throw err;
    }
  }

  async postData(endpoint, data){
    try{
      const url = new URL(`${this.baseURL}/${endpoint}`, import.meta.url);
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });
  
      if(!res.ok){
        throw new Error('Error while getting data');
      }
  
      return res.json();
    }
    catch(err){
      console.log('HTTP-Post error: ', err);
    }
  }

  async putData(endpoint, data){
    const url = new URL(`${this.baseURL}/${endpoint}`, import.meta.url);
    const res = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if(!res.ok){
      throw new Error('Error while getting data');
    }

    return await res.json();
  }

  async deleteData(endpoint){
    const url = new URL(`${this.baseURL}/${endpoint}`, import.meta.url);
    const res = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if(!res.ok){
      throw new Error('Error while getting data');
    }

    return await res.json();
  }
}

export const HTTPService = new HttpService('./backend/endpoints');