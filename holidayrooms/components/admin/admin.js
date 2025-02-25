import { HTTPService } from "../../http-service.js";

async function loadCustomers() {
    const res = await HTTPService.getData('get_customers.php');
    displayCustomers(res);
}

function displayCustomers(customers) {
    const customerTableBody = document.querySelector('#customer-table tbody');
    // Clear any existing content
    customerTableBody.innerHTML = '';

    customers.forEach(customer => {
        const row = document.createElement('tr');

        const nameCell = document.createElement('td');
        const emailCell = document.createElement('td');
        const phoneCell = document.createElement('td');

        nameCell.textContent = customer.Name;
        emailCell.textContent = customer.Email;
        phoneCell.textContent = customer.Telefonnummer;

        row.appendChild(nameCell);
        row.appendChild(emailCell);
        row.appendChild(phoneCell);

        row.onclick = () => onCustomerRowClick(customer.Email);

        customerTableBody.appendChild(row);
    });
}

function displayBookings(bookings) {
    const bookingTableBody = document.querySelector('#booking-table tbody');
    // Clear any existing content
    bookingTableBody.innerHTML = '';

    console.log(bookings);

    for (let booking of bookings) {
        const row = document.createElement('tr');

        const startDateCell = document.createElement('td');
        const endDateCell = document.createElement('td');
        const priceCell = document.createElement('td');

        startDateCell.textContent = booking.Startdatum;
        endDateCell.textContent = booking.Enddatum;
        priceCell.textContent = booking.Preis;

        row.appendChild(startDateCell);
        row.appendChild(endDateCell);
        row.appendChild(priceCell);

        bookingTableBody.appendChild(row);
    }
}

async function onCustomerRowClick(email) {

    let customerContainer = document.querySelector("#customer-container");
    let bookingContainer = document.querySelector("#booking-container");

    customerContainer.classList.toggle('hidden');
    bookingContainer.classList.toggle('hidden');

    console.log(email);

    const res = await HTTPService.postData('get_users_bookings.php', {
        "userEmail": email
    });

    displayBookings(res);
}

await loadCustomers();