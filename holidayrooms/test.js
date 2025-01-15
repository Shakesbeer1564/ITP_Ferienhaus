import { HTTPService } from "./http-service.js";

//button events
document.getElementById('test-click').onclick = loadData;

async function loadData() {
  const data = await HTTPService.getData('data.php');
  
  data.forEach(element => {
    const node = document.createElement('li');
    const text = document.createTextNode(`Name: ${element.name}, Alter: ${element.alter}`);
    node.appendChild(text);

    document.getElementById('testList').appendChild(node);
  });
}