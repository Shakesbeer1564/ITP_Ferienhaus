import { HTTPService } from "../http-service.js";

export class InputRequestHandler{
  #delay;
  #inputs;
  #typingtimer;

  constructor(selector, delay = 5000){
    this.#delay = delay;
    this.#typingtimer = {};
    this.#inputs = document.querySelectorAll(selector);
    this.init();
  }

  init(){
    this.#inputs.forEach(input => {
      input.addEventListener('input', (event) => this.handleInput(event))
    })
  }

  handleInput(event){
    const inputElement = event.target;
    console.log(this.#delay);
    clearTimeout(this.#typingtimer[inputElement]);
    
    this.#typingtimer[inputElement] = setTimeout(() => {
      this.request(inputElement.value);
    }, 100000000  );
  }

  request(inputText = ''){
    console.log(inputText);
    try {
      // const data = await HTTPService.postData('get_houses.php', 'test');
      return data;
    } catch (err) {
      
    }
  }
}