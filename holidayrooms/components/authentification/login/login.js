import { HTTPService } from "../../../http-service.js";


document.querySelector('#sign_in').addEventListener('click', async () => {
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  
  try {
    const dataJson = {
      username: username,
      password: password
    };

    const data = await HTTPService.postData('login.php', dataJson);

    if(data.username === username && data.password === password){
      console.log('Login erfolgreich');
      // TODO: session-handling --> cookies


      
      // Close the dialog after login was successfull
      document.getElementById("dark_background-overlay").style.display = 'none';
      document.getElementById("login_dialog").innerHTML = ''; 
    }
  } catch (error) {
    console.log('SOMETHING WENT WRING WHILE LOGIN: ', error);
  }
})