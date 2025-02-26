import { HTTPService } from "./http-service.js";
const { getOverviewClass } = await import('./class/overview.js');
const Overview = await getOverviewClass();

initializeData();

//------------------------------------------
//----------- Initialisation ---------------
//------------------------------------------

function initializeData(){
  initialiseComponents();
  loadHouses();
  loadActivities();
}

function initialiseComponents(){
  // Login-component
  loadComponent('./components/authentification/login/login.html', 'login_dialog', 
    './components/authentification/login/login.css', './components/authentification/login/login.js');
  
  // Registration-component
  loadComponent('./components/authentification/regionstation/registration.html', 'reg_dialog',
    './components/authentification/regionstation/registration.css', './components/authentification/regionstation/registration.js');
}

//------------------------------------------
//----------- Card-Handling ----------------
//------------------------------------------
async function loadHouses(data = {
  query: "",
  roomCount: 0,
  bedCount: 0,
  startDate: "",
  endDate: ""
}){
  try{
    const res = await HTTPService.postData('get_houses.php', data);

    if(res){
      renderHouseCards(res);
    }
  }
  catch(err){
    console.log('SOMETHING WENT WRONG WHILE GETTING THE HOUSES: ', err);
  }
}

function renderHouseCards(cardElements){
  const roomContainer = document.getElementById('holiday-rooms-container');

  if(roomContainer.firstChild){
    while(roomContainer.firstChild){
      roomContainer.removeChild(roomContainer.firstChild);
    }
  }

  cardElements.forEach(element => {
    const card = document.createElement('p-card');
    card.setAttribute('id', element.HausID);
    card.setAttribute('image', element.image);
    card.setAttribute('owner', element.EigentümerName);
    card.setAttribute('place', element.Adresse);
    card.setAttribute('room_count', element.AnzahlZimmer);
    card.setAttribute('bed_count', element.AnzahlBetten);
    card.setAttribute('description', element.Beschreibung);
    card.setAttribute('price', element.Preis);

    roomContainer.appendChild(card);
  });
}

async function loadActivities(data = {
  query: ""
}) {
  try {
    const res = await HTTPService.postData('get_activities.php', data);

    if(res){
      renderActivityCards(res);
    }
  } catch (err) {
    console.log('SOMETHIGN WENT WRONG WHILE GETTING THE ACTIVITIES: ', err);
  }
}

function renderActivityCards(acCardElements){
  const activityContainer = document.getElementById('activity_card_container');


  if(activityContainer.firstChild){
    while(activityContainer.firstChild){
      activityContainer.removeChild(activityContainer.firstChild);
    }
  }
  
  for(let el of acCardElements){
    const card = document.createElement('p-card-activity');
    card.setAttribute('id', el.AktivitätsID);
    card.setAttribute('title', el.Name);
    card.setAttribute('price', el.Preis);
    card.setAttribute('participants', el.AnzahlTeilnehmer);
    card.setAttribute('place'. el.OrtName)
    card.setAttribute('description', el.Beschreibung);

    activityContainer.appendChild(card);
  }
}

//------------------------------------------
//----------- Component-Loader -------------
//------------------------------------------
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

//------------------------------------------
//-------- Apply-Filter-Buttons ------------
//------------------------------------------
document.getElementById('apply_filter').addEventListener('click', async () => {
  const inputs = document.querySelectorAll('.input');
  const data = {
    query: inputs[0].value,
    roomCount: parseInt(inputs[2].value),
    bedCount: parseInt(inputs[3].value),
    startDate: inputs[4].value,
    endDate: inputs[5].value
  };

  await loadHouses(data);
});

document.getElementById('apply_filter_ac').addEventListener('click', async() => {
  const data = {
    query: document.getElementById('search').value
  };

  await loadActivities(data);
})

//------------------------------------------
//----------- Shoping-Card -----------------
//------------------------------------------
document.getElementById('shopIcon').addEventListener('click', () => {
  handleShoppingCardDialog();

  if(cardDialog.style.display === 'block'){
    
  }

})

document.getElementById('closeDialog').addEventListener('click', handleShoppingCardDialog);

function handleShoppingCardDialog(){
  let cardDialog = document.getElementById('cardDialog');
  cardDialog.style.display = cardDialog.style.display === 'block' ? 'none' : 'block';
}

//------------------------------------------
//----------- Dialog-Handling --------------
//------------------------------------------
document.querySelector('#open_Login').addEventListener('click', () => {
  document.getElementById('login_dialog').style.display = 'block';
  document.getElementById("dark_background").style.display = 'block';
})

document.querySelector('#open_registration').addEventListener('click', () => {
  document.getElementById('reg_dialog').style.display = 'block';
  document.getElementById("dark_background").style.display = 'block';
})
