import { HTTPService } from "./http-service.js";

//button events
document.getElementById('test-click').onclick = loadData;
document.getElementById('test-session').onclick = getSession;

async function loadData() {
  const data = await HTTPService.getData('data.php');

  data.forEach(element => {
    const node = document.createElement('li');
    const text = document.createTextNode(`Name: ${element.name}, Alter: ${element.alter}`);
    node.appendChild(text);

    document.getElementById('testList').appendChild(node);
  });
}

async function getSession() {
  const data = await HTTPService.postData("login.php", {
    "username": "passwordIs:PW",
    "password": "PW"
  });

  console.log(data);
}