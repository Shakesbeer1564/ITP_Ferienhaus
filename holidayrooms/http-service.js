class HttpService{
  baseURL = '';

  constructor(baseURL){
    this.baseURL = baseURL
  }

  async getData(endpoint){
    try{
      const res = await fetch(`${this.baseURL}/${endpoint}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if(!res.ok){
        throw new Error('Error while getting data');
      }

      return await res.json();
    }
    catch(err){
      console.error('Error GET: ', err);
      throw err;
    }
  }

  async postData(endpoint, data){
    const res = await fetch(`${this.baseURL}/${endpoint}`, {
      method: 'POST',
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

  async putData(endpoint, data){
    const res = await fetch(`${this.baseURL}/${endpoint}`, {
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
    const res = await fetch(`${this.baseURL}/${endpoint}`, {
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

export const HTTPService = new HttpService('./backend');