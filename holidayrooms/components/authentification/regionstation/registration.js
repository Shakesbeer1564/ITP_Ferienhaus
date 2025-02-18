import { HTTPService } from "../../../http-service.js";

document.getElementById('close_reg_dialog').addEventListener('click', closeDialog);

document.getElementById('register').addEventListener('click', async () => {
  const username = document.getElementById('reg_username').value;
  const password = document.getElementById('reg_password').value;
  const email = document.getElementById('reg_email').value;
  const tel = document.getElementById('reg_tel').value;

  if(username !== '' && password !== '' && emailValidation(email) && telValidation(tel)){
    const jsonData = JSON.stringify({
      username: username,
      password: password,
      email: email
    });

    try {
      const data = await HTTPService.postData('register.php', jsonData);

      // TODO: Schauen was wir zurückbekommen
      if(!!data){
        // TODO: Cookie-Handling

        // Close dialog
        closeDialog();
      }
    } catch (error) {
      console.log('ERROR WHILE REGISTER AN USER: ', error);
    }
  }
  else{
    console.log('name, password, email or tel are wrong');
  }
})

function emailValidation(email){
  const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

  return emailRegex.test(email);
}

function telValidation(tel){
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(tel);
}

function closeDialog(){
  document.getElementById('reg_form').reset();
  document.getElementById("dark_background").style.display = 'none';
  document.getElementById("reg_dialog").style.display = 'none'; 
}