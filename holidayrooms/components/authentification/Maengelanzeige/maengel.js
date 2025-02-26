import { HTTPService } from "../../../http-service.js";


// Close button
document.getElementById('close_mae_dialog').addEventListener('click', () => {
    closeDialog();
  });

  document.addEventListener('DOMContentLoaded', loadBookedHousesinPast);

  async function loadBookedHousesinPast(data =  {
    query:""
  })
    try {
        const response = await HTTPService.postData('get_houses_booked_in_past.php', data);
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const houses = await response.json(); // Parse response as JSON
        const dropdown = document.getElementById('houseDropdown');

        dropdown.innerHTML = '<option value="">Bitte wählen...</option>'; // Clear existing options

        houses.forEach(house => {
            let option = document.createElement('option');
            option.value = house.name; // Adjust based on JSON structure
            option.textContent = house.name;
            dropdown.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading booked houses:', error);
    
}

// Load data when page loads
document.addEventListener('DOMContentLoaded', loadBookedHouses);



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


const data = await HTTPService.postData('Create_complaints.php', {});

function closeDialog(){
    document.getElementById("dark_background").style.display = 'none';
    document.getElementById("maengel_dialog").style.display = 'none'; 
  }

