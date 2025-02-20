import { HTTPService } from "./http-service.js";
import { Overview } from "./class/overview.js";


//? Beispiel:
// button events
// document.getElementById('test-click').addEventListener('click', loadData);

// async function loadData() {
//   const data = await HTTPService.getData('data.php');
  
//   data.forEach(element => {
//     const node = document.createElement('li');
//     const text = document.createTextNode(`Name: ${element.name}, Alter: ${element.alter}`);
//     node.appendChild(text);

//     document.getElementById('testList').appendChild(node);
//   });
// }

initializeData();

//#region initialize_Data
function initializeData(){
  initialiseComponents();
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
    const data = await HTTPService.getData('get_houses', searchParams);

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

// dropdown-handling for place-filter
document.getElementById('place_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown-place');
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
});

// dropdown-handling for region-filter
document.getElementById('region_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown_region');
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
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


// const test = new Overview();
// test.addItem({
//   '1': {
//     key: 1,
//     name: 'Test',
//     beschreibung: 'Dies ist ein Test'
//   }
// })