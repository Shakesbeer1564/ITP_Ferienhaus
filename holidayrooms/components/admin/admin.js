import { HTTPService } from "../../http-service.js";

// Store the users id to their mail
let customersByMail = {};
let backIcon = document.querySelector("#back-icon");
backIcon.onclick = () => onBackIconClick();


async function loadCustomers() {
    const res = await HTTPService.getData('get_customers.php');
    displayCustomers(res);

    for (let customer of res) {
        customersByMail[customer.Email] = customer;
    }
}

function displayCustomers(customers) {
    const customerTableBody = document.querySelector('#customer-table tbody');
    // Clear any existing content
    customerTableBody.innerHTML = '';

    const trashcanCell = document.createElement('td');
    const trashcanImage = document.createElement('img');
    trashcanImage.src = "../../assets/trashcan_icon.png";
    trashcanImage.width = 32;
    trashcanImage.height = 32;
    trashcanCell.appendChild(trashcanImage);

    for (let customer of customers) {
        const row = document.createElement('tr');

        const nameCell = document.createElement('td');
        const emailCell = document.createElement('td');
        const phoneCell = document.createElement('td');
        const deleteCell = trashcanCell.cloneNode(true);

        nameCell.textContent = customer.Name;
        emailCell.textContent = customer.Email;
        phoneCell.textContent = customer.Telefonnummer;

        deleteCell.onclick = (event) => deleteUser(event, customersByMail[customer.Email].NutzerID);

        row.appendChild(nameCell);
        row.appendChild(emailCell);
        row.appendChild(phoneCell);
        row.appendChild(deleteCell);

        row.onclick = () => onCustomerRowClick(customer.Email);

        customerTableBody.appendChild(row);
    }
}

async function loadBookings(email) {
    const res = await HTTPService.postData('get_users_bookings.php', {
        "userEmail": email
    });

    displayBookings(res);
}

function displayBookings(bookings) {
    const bookingTableBody = document.querySelector('#booking-table tbody');
    // Clear any existing content
    bookingTableBody.innerHTML = '';

    for (let booking of bookings) {
        const row = document.createElement('tr');

        const startDateCell = document.createElement('td');
        const endDateCell = document.createElement('td');
        const priceCell = document.createElement('td');

        startDateCell.textContent = new Date(booking.Startdatum).toLocaleDateString(undefined, { day: '2-digit', month: '2-digit', year: 'numeric' });
        endDateCell.textContent = new Date(booking.Enddatum).toLocaleDateString(undefined, { day: '2-digit', month: '2-digit', year: 'numeric' });
        priceCell.textContent = booking.Preis;

        row.appendChild(startDateCell);
        row.appendChild(endDateCell);
        row.appendChild(priceCell);

        bookingTableBody.appendChild(row);
    }
}

async function loadInvoices(email) {
    const res = await HTTPService.postData('get_invoices.php', {
        "userEmail": email
    });

    displayInvoices(res);
}

function displayInvoices(invoices) {
    const invoiceTableBody = document.querySelector('#invoice-table tbody');
    // Clear any existing content
    invoiceTableBody.innerHTML = '';

    for (let invoice of invoices) {
        const row = document.createElement('tr');

        const invoiceDateCell = document.createElement('td');
        const moneyValueCell = document.createElement('td');

        invoiceDateCell.textContent = new Date(invoice.Rechnungsdatum).toLocaleDateString(undefined, { day: '2-digit', month: '2-digit', year: 'numeric' });
        moneyValueCell.textContent = invoice.Betrag;

        row.appendChild(invoiceDateCell);
        row.appendChild(moneyValueCell);

        invoiceTableBody.appendChild(row);
    }
}


async function onCustomerRowClick(email) {

    let customerContainer = document.querySelector("#customer-container");
    let bookingContainer = document.querySelector("#booking-container");
    let invoiceContainer = document.querySelector("#invoice-container");
    let historyContainer = document.querySelector("#history-container");
    let historyUsernameInfo = document.querySelector("#username-info");

    customerContainer.classList.add('hidden');
    bookingContainer.classList.remove('hidden');
    invoiceContainer.classList.remove('hidden');
    historyContainer.classList.remove('hidden');

    historyUsernameInfo.textContent = "test";

    loadBookings(email);
    loadInvoices(email);
}

function onBackIconClick() {
    let customerContainer = document.querySelector("#customer-container");
    let bookingContainer = document.querySelector("#booking-container");
    let invoiceContainer = document.querySelector("#invoice-container");
    let historyContainer = document.querySelector("#history-container");
    let historyUsernameInfo = document.querySelector("#username-info");

    customerContainer.classList.remove('hidden');
    bookingContainer.classList.add('hidden');
    invoiceContainer.classList.add('hidden');
    historyContainer.classList.add('hidden');

    loadCustomers();
}

async function deleteUser(event, userId) {
    // Prevent other click events from triggering
    event.stopPropagation();

    await HTTPService.postData('delete_user.php', {
        "userId": userId
    });

    // Update the customer table after the user has been deleted
    loadCustomers();
}

await loadCustomers();