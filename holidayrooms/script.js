import { HTTPService } from "./http-service.js";


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


//#region initialize_Data
function initializeData(){

}

function loadPlaces(){

}

function loadRegions(){

}

function loadRooms(){

}

function loadActivities(){

}
//#endregion initializeData


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
  loadComponent('./components/authentification/login/login.html', 'login_dialog', 
    './components/authentification/login/login.css', './components/authentification/login/login.js');

  document.getElementById("dark_background").style.display = "block";
})
