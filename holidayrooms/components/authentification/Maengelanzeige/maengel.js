import { HTTPService } from "../../../http-service.js";


// Close button
document.getElementById('close_mae_dialog').addEventListener('click', () => {
    closeDialog();
  });

  
//document.getElementById('dropdownBtn').addEventListener('click', function(event) {
  //  event.stopPropagation();
   // document.getElementById('dropdownMenu').classList.toggle('hidden');
//});


document.addEventListener('click', function(event) {
    const dropdownMenu = document.getElementById('dropdownMenu');
    if (!dropdownMenu.classList.contains('hidden')) {
        dropdownMenu.classList.add('hidden');
    }
});

function openModal(item) {
    document.getElementById('modalText').innerText = 'You selected: ' + item;
    document.getElementById('modal').classList.remove('hidden');
    document.body.classList.add('dimmed');
}


function closeModal() {
    document.getElementById('modal').classList.add('hidden');
    document.body.classList.remove('dimmed');
}




function closeDialog(){
    document.getElementById("dark_background").style.display = 'none';
    document.getElementById("maengel_dialog").style.display = 'none'; 
  }

// Load all houses that have been booked in the past by the loged in User. 
//Admins can see all booked houses. Owners can see all their houses.

async function loadBookedHousesinPast() {
    try {
        const houses = await HTTPService.getData('get_houses_booked_in_past.php');
           
        const dropdown = document.getElementById('dropdownMenu');
      
        // Add default option
        let defaultOption = document.createElement('li');
        defaultOption.textContent = "Bitte wählen...";
        defaultOption.classList.add("disabled");

        dropdown.appendChild(defaultOption);
      
        houses.forEach(house => {
            console.log(house);
            let listItem = document.createElement('option');
            listItem.value = house.HausID; // Assuming house has an "Adresse" field
            listItem.textContent = house.Adresse;
            listItem.onclick = () => openModal(house.HausID);
            dropdown.appendChild(listItem);
        });
      

        
    } catch (error) {
        console.error('Error loading booked houses:', error);
    }
}
document.addEventListener('DOMContentLoaded', loadBookedHousesinPast);

document.addEventListener('DOMContentLoaded', loadBookedHousesinPast());

  //Sends a complaint to the Database 
async function sendComplaint(){

    const HouseID = document.getElementById('dropdownMenu').value;
    const description = document.getElementById('inputField').value;

    const jsonData = {
            
            houseId: HouseID,
            description: description
        
    }
   
  HTTPService.postData('create_complaint.php', jsonData);

    closeDialog();
  
}


document.getElementById('submitButton').addEventListener('click', sendComplaint);

