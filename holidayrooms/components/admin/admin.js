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

function onCustomerRowClick(email) {
    console.log(email);

    const res = HTTPService.postData('get_users_bookings.php', {
        "userEmail": email
    });

    console.log(res);
}

await loadCustomers();