import { HTTPService } from "../../http-service.js";

let backIcon = document.querySelector("#back-icon");
backIcon.onclick = () => onBackIconClick();

await loadCustomers();
await loadHouses();


function hideBackIcon() {
    let backIcon = document.querySelector("#back-icon");
    backIcon.classList.add('hidden');
}
function showBackIcon() {
    let backIcon = document.querySelector("#back-icon");
    backIcon.classList.remove('hidden');
}

function hideCustomerContainer() {
    let customerContainer = document.querySelector("#customer-container");
    customerContainer.classList.add('hidden');
}
function showCustomerContainer() {
    let customerContainer = document.querySelector("#customer-container");
    customerContainer.classList.remove('hidden');
    loadCustomers();
}
function hideUserBookingContainer() {
    let userBookingContainer = document.querySelector("#user-booking-container");
    userBookingContainer.classList.add('hidden');
}
function showUserBookingContainer() {
    let userBookingContainer = document.querySelector("#user-booking-container");
    userBookingContainer.classList.remove('hidden');
}
function hideInvoiceContainer() {
    let invoiceContainer = document.querySelector("#invoice-container");
    invoiceContainer.classList.add('hidden');
}
function showInvoiceContainer() {
    let invoiceContainer = document.querySelector("#invoice-container");
    invoiceContainer.classList.remove('hidden');
}
function hideHistoryContainer() {
    let historyContainer = document.querySelector("#history-container");
    historyContainer.classList.add('hidden');
}
function showHistoryContainer(historyText) {
    let historyContainer = document.querySelector("#history-container");
    historyContainer.classList.remove('hidden');
    let historyContainerText = document.querySelector("#history-text");
    historyContainerText.textContent = historyText;
}

function hideHouseContainer() {
    let houseContainer = document.querySelector("#house-container");
    houseContainer.classList.add('hidden');
}
function showHouseContainer() {
    let houseContainer = document.querySelector("#house-container");
    houseContainer.classList.remove('hidden');
    loadHouses();
}
function hideHouseBookingContainer() {
    let houseBookingContainer = document.querySelector("#house-booking-container");
    houseBookingContainer.classList.add('hidden');
}
function showHouseBookingContainer() {
    let houseBookingContainer = document.querySelector("#house-booking-container");
    houseBookingContainer.classList.remove('hidden');
}


async function loadCustomers() {
    const res = await HTTPService.getData('get_customers.php');
    displayCustomers(res);
}

async function loadHouses() {
    const res = await HTTPService.postData('get_houses.php', {
        "query": "",
        "roomCount": null,
        "bedCount": null,
        "startDate": null,
        "endDate": null
    });

    displayHouses(res);
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

        deleteCell.onclick = (event) => deleteUser(event, customer.NutzerID);

        deleteCell.classList.add("image-container");
        row.classList.add("clickable");

        row.appendChild(nameCell);
        row.appendChild(emailCell);
        row.appendChild(phoneCell);
        row.appendChild(deleteCell);

        row.onclick = () => onCustomerRowClick(customer.Email, customer.Name);

        customerTableBody.appendChild(row);
    }
}

function displayHouses(houses) {
    const houseTableBody = document.querySelector('#house-table tbody');
    // Clear any existing content
    houseTableBody.innerHTML = '';

    const trashcanCell = document.createElement('td');
    const trashcanImage = document.createElement('img');
    trashcanImage.src = "../../assets/trashcan_icon.png";
    trashcanImage.width = 32;
    trashcanImage.height = 32;
    trashcanCell.appendChild(trashcanImage);

    for (let house of houses) {
        const row = document.createElement('tr');

        const addressCell = document.createElement('td');
        const descriptionCell = document.createElement('td');
        const roomsCell = document.createElement('td');
        const bedsCell = document.createElement('td');
        const priceCell = document.createElement('td');
        const ownerNameCell = document.createElement('td');
        const deleteCell = trashcanCell.cloneNode(true);

        const DESC_MAX_LEN = 100;
        let houseDescription = house.Beschreibung.length <= DESC_MAX_LEN ? house.Beschreibung : `${house.Beschreibung.substring(0, DESC_MAX_LEN)}...`;

        addressCell.textContent = house.Adresse;
        descriptionCell.textContent = houseDescription;
        roomsCell.textContent = house.AnzahlZimmer;
        bedsCell.textContent = house.AnzahlBetten;
        priceCell.textContent = house.Preis;
        ownerNameCell.textContent = house.EigentuemerName;

        deleteCell.onclick = (event) => deleteHouse(event, house.HausID);

        deleteCell.classList.add("image-container");
        row.classList.add("clickable");

        row.appendChild(addressCell);
        row.appendChild(descriptionCell);
        row.appendChild(roomsCell);
        row.appendChild(bedsCell);
        row.appendChild(priceCell);
        row.appendChild(ownerNameCell);
        row.appendChild(deleteCell);

        row.onclick = () => onHouseRowClick(house.HausID, house.Adresse);

        houseTableBody.appendChild(row);
    }
}

async function loadUserBookings(email) {
    const res = await HTTPService.postData('get_users_bookings.php', {
        "userEmail": email
    });

    displayUserBookings(res);
}

function displayUserBookings(bookings) {
    const userBookingTableBody = document.querySelector('#user-booking-table tbody');
    // Clear any existing content
    userBookingTableBody.innerHTML = '';

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

        userBookingTableBody.appendChild(row);
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

async function loadHouseBookings(houseId) {
    const res = await HTTPService.postData('get_home_bookings.php', {
        "houseId": houseId
    });

    displayHouseBookings(res);
}

function displayHouseBookings(bookings) {
    const houseBookingTableBody = document.querySelector('#house-booking-table tbody');
    // Clear any existing content
    houseBookingTableBody.innerHTML = '';

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

        houseBookingTableBody.appendChild(row);
    }
}


async function onCustomerRowClick(email, username) {
    hideCustomerContainer();
    hideHouseContainer();

    showBackIcon();

    showUserBookingContainer(email);
    showInvoiceContainer(email);
    showHistoryContainer(`History of user: ${username}`);

    loadUserBookings(email);
    loadInvoices(email);

    removeClickedClasses();
}

function onHouseRowClick(houseId, address) {
    hideCustomerContainer();
    hideHouseContainer();

    showBackIcon();

    showHouseBookingContainer();
    showHistoryContainer(`Information about house: ${address}`);

    loadHouseBookings(houseId);

    removeClickedClasses();
}


function onBackIconClick() {
    hideBackIcon();

    showCustomerContainer();
    showHouseContainer();

    hideUserBookingContainer();
    hideInvoiceContainer();
    hideHistoryContainer();

    hideHouseBookingContainer();
}

async function deleteUser(event, userId) {
    // Prevent other click events from triggering
    event.stopPropagation();

    let target = event.target;
    if (target.localName == "img") {
        target = target.offsetParent;
    }

    if (!target.classList.contains('delete-clicked')) {
        removeClickedClasses();
        target.classList.add('delete-clicked');
        return;
    }

    await HTTPService.postData('delete_user.php', {
        "userId": userId
    });

    // Update the customer table after the user has been deleted
    loadCustomers();
}

async function deleteHouse(event, houseId) {
    // Prevent other click events from triggering
    event.stopPropagation();

    let target = event.target;
    if (target.localName == "img") {
        target = target.offsetParent;
    }

    if (!target.classList.contains('delete-clicked')) {
        removeClickedClasses();
        target.classList.add('delete-clicked');
        return;
    }

    await HTTPService.postData('delete_house.php', {
        "houseId": houseId
    });

    // Refresh the houses after one has been deleted
    loadHouses();
}

function removeClickedClasses() {
    let tableCells = document.querySelectorAll("td");
    for (let cell of tableCells) {
        cell.classList.remove('delete-clicked');
    }
}