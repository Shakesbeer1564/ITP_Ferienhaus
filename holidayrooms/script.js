import { Overview } from "./class/overview.js";
import { HTTPService } from "./http-service.js";


//? Beispiel:
/*button events
document.getElementById('test-click').addEventListener('click', loadData);

async function loadData() {
  const data = await HTTPService.getData('data.php');
  
  data.forEach(element => {
    const node = document.createElement('li');
    const text = document.createTextNode(`Name: ${element.name}, Alter: ${element.alter}`);
    node.appendChild(text);

    document.getElementById('testList').appendChild(node);
  });
}
  */

initializeData();

//#region initialize_Data
function initializeData(){
  initialiseComponents();
  loadHouses();
}

function initialiseComponents(){
  // Login-component
  loadComponent('./components/authentification/login/login.html', 'login_dialog', 
    './components/authentification/login/login.css', './components/authentification/login/login.js');
  
  // Registration-component
  loadComponent('./components/authentification/regionstation/registration.html', 'reg_dialog',
    './components/authentification/regionstation/registration.css', './components/authentification/regionstation/registration.js');
}

// TODO: Häuser holen testen
async function loadHouses(query = null, data = null){
  try{
    // const res = await HTTPService.postData('get_houses', data, query);

    // if(res){
    //   this.renderHouseCards(res);
    // }
  }
  catch(err){
    console.log('SOMETHING WENT WRONG WHILE GETTING THE HOUSES: ', err);
  }
}
//#endregion initialize_Data

//#region helper_functions_loadComponents
function loadComponent(url, containerId, cssFile, jsFile){
  fetch(url)
    .then(res => res.text())
    .then(data => {
      document.getElementById(containerId).innerHTML = data;

      if(!document.getElementById(cssFile)){
        loadStyle(cssFile);
      }

      if(!document.getElementById(jsFile)){
        loadScript(jsFile);
      }
    })
}

function loadScript(src){
  let script = document.createElement('script');
  script.src = `${src}?v=${new Date().getTime()}`;
  script.id = src;
  script.defer = true;
  script.type = 'module';
  document.body.appendChild(script);
}

function loadStyle(href){
  let link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = `${href}?v=${new Date().getTime()}`
  link.defer = true;
  link.id = href;
  document.head.appendChild(link);
}
//#endregion helper_functions_loadComponents

document.getElementById('apply_filter').addEventListener('click', async () => {
  const inputs = document.querySelectorAll('.input');
  const query = {
    place: inputs[0].value,
    region: inputs[1].value
  };
  const data = {
    roomCount: inputs[2].value,
    bedCount: inputs[3].value,
    startDate: inputs[4].value,
    endDate: inputs[5].value
  };

  await loadHouses(query, data);
})

// Render room cards
function renderHouseCards(cardElements){
  const roomContainer = document.getElementById('holiday-rooms-container');

  cardElements.forEach(element => {
    const card = document.createElement('p-card');
    card.setAttribute('image', element.image);
    card.setAttribute('region', element.region);
    card.setAttribute('place', element.place);
    card.setAttribute('room_count', element.roomCount);
    card.setAttribute('bed_count', element.bedCount);
    card.setAttribute('description', element.description);
    card.setAttribute('button-text', 'Book');

    roomContainer.appendChild(card);
  });
}

// load login dialog
document.querySelector('#open_Login').addEventListener('click', () => {
  document.getElementById('login_dialog').style.display = 'block';
  document.getElementById("dark_background").style.display = 'block';
})

// load registration dialog
document.querySelector('#open_registration').addEventListener('click', () => {
  document.getElementById('reg_dialog').style.display = 'block';
  document.getElementById("dark_background").style.display = 'block';
})
