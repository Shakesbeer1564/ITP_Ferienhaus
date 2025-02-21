class CardComponent extends HTMLElement{
  constructor(){
    super();
    this.attachShadow({ mode: 'open' });

    const container = document.createElement('div');
    container.classList.add('card');

    const header = document.createElement('div');
    header.classList.add('card_header');

    const img = document.createElement('img');
    img.src = this.getAttribute('image') || 'No image available';
    img.alt = 'Card image';

    const body = document.createElement('div');
    body.classList.add('text-container');

    const text = document.createElement('p');
    text.textContent = this.getAttribute('text') || 'No text available';


    const footer = document.createElement('div');
    footer.classList.add('card_footer');

    const button = document.createElement('button');
    button.textContent = this.getAttribute('button-text') || 'No text available';
    button.onclick = () => {
      console.log(`Geklickt: ${this.getAttribute('text')}`); // --> Statt dem hier die ID holen
    }

    // Zusammenfügen
    header.appendChild(img);
    body.appendChild(text);
    footer.appendChild(button);

    container.appendChild(header);
    container.appendChild(body);
    container.appendChild(footer);


    // Styling
    const style = document.createElement('style');
    style.textContent = `
      .card{
        border: 1px solid black; 
        border-radius: 10px; 
        width: 20em; 
        height: 25em; 
        margin: 20px 10px 10px 10px;
        display: flex; 
        flex-direction: column; 
        position: relative; 
        box-shadow: 0px 0px 20px 1px rgba(0, 0, 0, 0.5);
        overflow: hidden;
      }
      
      .card .card_header{
        position: relative; 
        width: 100%; 
        height: 40%; 
        overflow: hidden; 
      }

      .card .card_header img{
        width: 100%;  
        height: 100%;  
        object-fit: cover;  
      }

      .card .text-container{
        height: 50%;
        margin-left: 5px;
        overflow-y: auto;
      }

      .card .text-container p{
        margin: 5px;
      }

      .card .card_footer{
        height: 10%;
        display: flex;
        align-items: center;
        border-top: 1px solid black;
      }
      
      .card .card_footer button{
        margin-left: auto;
        margin-right: 5px;
        color: rgb(78, 74, 74);
        border: 1px solid rgb(185, 185, 185);
        border-radius: 2px;
        background-color: rgb(227, 227, 227);
        width: 100px;
        height: 90%;
        cursor: pointer;
      }

      .card .card_footer button:hover{
        background-color: rgb(214, 214, 214);
      }

      .card .card_footer button:active{
        background-color: rgb(198, 198, 198);
      }

      /* width */
      ::-webkit-scrollbar {
        width: 5px;
      }

      /* Track */
      ::-webkit-scrollbar-track {
        background: #f1f1f1;
      }

      /* Handle */
      ::-webkit-scrollbar-thumb {
        background: #888;
      }

      /* Handle on hover */
      ::-webkit-scrollbar-thumb:hover {
        background: #555;
      }
    `;

    this.shadowRoot.append(style, container);
  }
}

customElements.define('p-card', CardComponent);