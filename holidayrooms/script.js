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

document.getElementById('place_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown-place');
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
});

document.getElementById('region_filter').addEventListener('click', () => {
  const dropDown = document.getElementById('dropdown_region');
  console.log(dropDown);
  dropDown.style.display = dropDown.style.display === 'block' ? 'none' : 'block';
})
