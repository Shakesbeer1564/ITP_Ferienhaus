class HttpService{
  baseURL = '';

  constructor(baseURL){
    this.baseURL = baseURL
  }

  async getData(endpoint, searchParams = null){
    const url = new URL(`/ITP_Ferienhaus/holidayrooms${this.baseURL}/${endpoint}`, window.location.origin);
    if(searchParams){
      Object.keys(searchParams).forEach(key => url.searchParams.append(key, searchParams[key]));
    }

    try{
      const res = await fetch(url, {
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

  async postData(endpoint, data, searchParams = null){
    let url;

    if(!searchParams){
      url = `${this.baseURL}/${endpoint}`;
    }
    else{
      url = new URL(`/ITP_Ferienhaus/holidayrooms${this.baseURL}/${endpoint}`, window.location.origin);
      Object.keys(searchParams).forEach(key => url.searchParams.append(key, searchParams[key]));
    }

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

export const HTTPService = new HttpService('/backend/endpoints');