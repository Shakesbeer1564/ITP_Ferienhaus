import { HTTPService } from "../../../http-service.js";

// Close button
document.getElementById('close_dialog').addEventListener('click', () => {
  closeDialog();
});

// sign in button
document.querySelector('#sign_in').addEventListener('click', async () => {
  const email = document.getElementById('log_email').value;
  const password = document.getElementById('password').value;
  
  try {
    if(!emailValidation(email) || password === ''){
      console.log('EMAIL OR PASSWORD ARE WRONG');
      return;
    }

    const dataJson = {
      email: email,
      password: password
    };

    const data = await HTTPService.postData('login.php', dataJson);

    if(!!data){
      closeDialog();
    }
  } catch (error) {
    console.log('SOMETHING WENT WRING WHILE LOGIN: ', error);
  }
})

function emailValidation(email){
  const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

  return emailRegex.test(email);
}

function closeDialog(){
  document.getElementById("dark_background").style.display = 'none';
  document.getElementById("login_dialog").style.display = 'none'; 
}