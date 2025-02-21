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
async function loadHouses(ort = '', region = ''){
  const searchParams = {
    ort: ort,
    region: region
  };

  try{
    // const data = await HTTPService.getData('get_houses', searchParams);

    // TODO: Häuser in das HTML hinzufügen mit der shared-card-componente
  }
  catch(err){
    console.log('SOMETHING WENT WRONG WHILE GETTING THE HOUSES: ', err);
  }
}
//#endregion initialize_Data

//#region helper_functions_dialog
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
//#endregion helper_function_dialog

document.addEventListener('click', (event) => {
  const placeDropDown = document.getElementById('dropdown_place');
  const regionDropDown = document.getElementById('dropdown_region');
  

  if (!event.target.closest('#place_filter')) {
    placeDropDown.style.display = 'none';
  }

  if (!event.target.closest('#reg_filter')) {
    regionDropDown.style.display = 'none';
  }
})

// dropdown-handling for place-filter
document.getElementById('place_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown_place');
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
});

// place selection
document.querySelectorAll('#dropdown_place a').forEach(link => {
  link.addEventListener('click', (event) => {
    event.preventDefault();

    const input = document.getElementById('place_input');
    const selectedPlace = event.target.textContent;
    input.value = selectedPlace;


    // refresh houses
    const regionValue = document.getElementById('region_input').value;
    loadHouses(selectedPlace, regionValue ? regionValue : '');
  })
})

// dropdown-handling for region-filter
document.getElementById('reg_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown_region');
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
})

// region selection
document.querySelectorAll('#dropdown_region a').forEach(link => {
  link.addEventListener('click', (event) => {
    event.preventDefault();

    const input = document.getElementById('region_input');
    const selectedRegion = event.target.textContent;
    input.value = selectedRegion;

    // refresh houses
    const placeValue = document.getElementById('place_input').value;
    loadHouses(placeValue ? placeValue : '', selectedRegion);
  })
})

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
