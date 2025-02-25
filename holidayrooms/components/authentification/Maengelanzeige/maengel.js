import { HTTPService } from "../../../http-service";

document.getElementById('dropdownBtn').addEventListener('click', function(event) {
    event.stopPropagation();
    document.getElementById('dropdownMenu').classList.toggle('hidden');
});

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


const data = await HTTPService.postData('get_complaints.php', {});