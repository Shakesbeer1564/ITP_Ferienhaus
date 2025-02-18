import { HTTPService } from "../../../http-service.js";

// Close button
document.getElementById('close_dialog').addEventListener('click', () => {
  closeDialog();
});

// sign in button
document.querySelector('#sign_in').addEventListener('click', async () => {
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  
  try {
    const dataJson = JSON.stringify({
      username: username,
      password: password
    });

    const data = await HTTPService.postData('login.php', dataJson);

    if(data.username === username && data.password === password){
      // TODO: Cookie-Handling

      // Close the dialog after login was successfull
      closeDialog();
    }
  } catch (error) {
    console.log('SOMETHING WENT WRING WHILE LOGIN: ', error);
  }
})

function closeDialog(){
  document.getElementById("dark_background").style.display = 'none';
  document.getElementById("login_dialog").style.display = 'none'; 
}