import { HTTPService } from "./http-service.js";
const { getOverviewClass } = await import('./class/overview.js');
const Overview = await getOverviewClass();

initializeData();

//------------------------------------------
//----------- Initialisation ---------------
//------------------------------------------

async function initializeData(){
  checkLogoutButtonVisibility();
  initialiseComponents();
  await loadHouses();
  await loadActivities();
  setTimeout(() => {
    disableBookButton();
  });
}

function initialiseComponents(){
  // Login-component
  loadComponent('./components/authentification/login/login.html', 'login_dialog', 
    './components/authentification/login/login.css', './components/authentification/login/login.js');
  
  // Registration-component
  loadComponent('./components/authentification/regionstation/registration.html', 'reg_dialog',
    './components/authentification/regionstation/registration.css', './components/authentification/regionstation/registration.js');

  // Maengelanzeige-component
  loadComponent('./components/authentification/maengelanzeige/maengel.html', 'maengel_dialog',
    './components/authentification/maengelanzeige/maengel.css', './components/authentification/maengelanzeige/maengel.js');
}

// Function is being used in login and registration too
export async function checkLogoutButtonVisibility(){
  const loginButton = document.getElementById('open_Login');
  const registrationButton = document.getElementById('open_registration');
  const logoutButton = document.getElementById('logout');
  const notificationOfDefectsButton = document.getElementById('open_maengelanzeige');
  const username = document.getElementById('username');
  const overview = document.getElementById('overview');
  const adminPageButton = document.getElementById('open_admin_page');

  const res = await HTTPService.getData('get_user.php');
  if(res.username !== null){
    loginButton.style.display = 'none';
    registrationButton.style.display = 'none';
    logoutButton.style.display = 'block';
    username.style.display = 'block';
    username.textContent = `Welcome ${res.username}`;

    if(res.rolename === 'Admin'){
      notificationOfDefectsButton.style.display = 'none';
      overview.style.display = 'none';
      adminPageButton.style.display = 'block';
    }
    else{
      overview.style.display = 'block';
      notificationOfDefectsButton.style.display = 'block';
    }
    
  }
  else{
    logoutButton.style.disBplay = 'none';
    notificationOfDefectsButton.style.display = 'none';
    username.style.display = `none`;
    overview.style.display = 'none';
    adminPageButton.style.display = 'none';
    loginButton.style.display = 'block';
    registrationButton.style.display = 'block';
  }
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

function renderHouseCards(cardElements) {
  const roomContainer = document.getElementById('holiday-rooms-container');

  if(roomContainer.firstChild){
    while(roomContainer.firstChild){
      roomContainer.removeChild(roomContainer.firstChild);
    }
  }

  cardElements.forEach(element => {
    const card = document.createElement('p-card');
    card.setAttribute('id', element.HausID);
    card.setAttribute('image', element.Haus_Bild);
    card.setAttribute('owner', element.EigentuemerName);
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
    card.setAttribute('id', el.AktivitaetsID);
    card.setAttribute('title', el.Name);
    card.setAttribute('price', el.Preis);
    card.setAttribute('participants', el.AnzahlTeilnehmer);
    card.setAttribute('place', el.OrtName)
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
  script.src = src;
  script.id = src;
  script.defer = true;
  script.type = 'module';
  document.body.appendChild(script);
}

function loadStyle(href){
  let link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = href;
  link.defer = true;
  link.id = href;
  document.head.appendChild(link);
}

//------------------------------------------
//-------- Apply-Filter-Buttons ------------
//------------------------------------------
// document.querySelector(input[type='date']).addEventListener('click', () => {

// })

function disableBookButton(){
  const dateStart = document.getElementById('date_start');
  const dateEnd = document.getElementById('date_end');
  const applyFilterButton = document.getElementById('apply_filter');

  const shadowHost = document.querySelectorAll("p-card");
  if(shadowHost){
    shadowHost.forEach(cardShadowHost => {
      const shadowRoot = cardShadowHost.shadowRoot; // Zugriff auf das Shadow DOM Element
      const bookButton = shadowRoot.querySelector(".book-button");

      let dateChanged = false;
  
      function disableButton(){
        bookButton.disabled = true;
        dateChanged = true;
      }
    
      dateStart.addEventListener('input', disableButton);
      dateEnd.addEventListener('input', disableButton);
    
      applyFilterButton.addEventListener('click', () => {
        if(dateChanged){
          dateChanged = false;
          bookButton.disabled = false;
        }
      })
    })
  }
}

document.getElementById('apply_filter').addEventListener('click', async () => {
  const inputs = document.querySelectorAll('.input');
  const data = {
    query: inputs[0].value,
    roomCount: parseInt(inputs[1].value),
    bedCount: parseInt(inputs[2].value),
    startDate: inputs[3].value,
    endDate: inputs[4].value
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
document.getElementById('shopIcon').addEventListener('click', (e) => {
  e.stopPropagation();
  handleShoppingCardDialog();
  handleBookButton();
  Overview.getInstance().calculatePrice();
})

function handleBookButton(){
  if(Overview.getInstance().getHouseItem().houseId === -1 && Overview.getInstance().getActivityItems().length === 0){
    document.querySelector('#book').disabled = true;
  }
  else{
    document.querySelector('#book').disabled = false;
  }
}

document.addEventListener('click', (event) => {
  const itemsContainer = document.getElementById('cardDialog');

  if(itemsContainer && !itemsContainer.contains(event.target)){
    itemsContainer.style.display = 'none';
  }
})

document.getElementById('closeDialog').addEventListener('click', handleShoppingCardDialog);

function handleShoppingCardDialog(){
  let cardDialog = document.getElementById('cardDialog');
  cardDialog.style.display = cardDialog.style.display === 'block' ? 'none' : 'block';
}

document.getElementById('book').addEventListener('click', () => Overview.getInstance().book());

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

document.querySelector('#open_maengelanzeige').addEventListener('click', () => {
  document.getElementById('maengel_dialog').style.display = 'block';
  document.getElementById("dark_background").style.display = 'block';
})

//------------------------------------------
//---------------- Logout ------------------
//------------------------------------------
document.getElementById('logout').addEventListener('click', async () => {
  const res = await HTTPService.postData('sign_out.php');

  if(res)
    window.location.reload();
})


//------------------------------------------
//-------------- Admin Page ----------------
//------------------------------------------
document.getElementById('open_admin_page').addEventListener('click', () => {
  window.location.href = './components/admin/admin.html';
})