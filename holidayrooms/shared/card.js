// !Müssen wir dynamisch importieren, da wir keine html-Datei haben um es als type=module zu kennzeichnen
(async () => {
  const { getOverviewClass } = await import('../class/overview.js');
  const Overview = await getOverviewClass();
  
  class CardComponent extends HTMLElement {
    constructor() {
      super();

      setTimeout(() => {
        // create the shadow dom direct
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
        
        const reg_Text = document.createElement('p');
        reg_Text.classList.add('reg-text');
        reg_Text.textContent = `Owner: ${this.getAttribute('owner') || 'No Owner'}`;
        
        const placeText = document.createElement('p');
        placeText.classList.add('place-text');
        placeText.textContent = `Place: ${this.getAttribute('place') || 'No place'}`;
        
        const roomText = document.createElement('p');
        roomText.classList.add('room-count-text');
        roomText.textContent = `Room-Count: ${this.getAttribute('room_count') || 'No place'}`;
        
        const bedText = document.createElement('p');
        bedText.classList.add('bed-count-text');
        bedText.textContent = `Bed-Count: ${this.getAttribute('bed_count') || 'No place'}`;

        const price = document.createElement('p');
        price.textContent = `Price: ${this.getAttribute('price') || 'No price'}`
        
        const description = document.createElement('p');
        description.classList.add('description');
        description.textContent = `Description: ${this.getAttribute('description') || 'No description'}`;
        
        const footer = document.createElement('div');
        footer.classList.add('card_footer');
        
        const button = document.createElement('button');
        button.textContent = 'Book';
        button.onclick = () => {
          if(document.getElementById('date_start').value === '' || document.getElementById('date_end').value === ''){
            alert('Please select a date');
            return;
          }

          if(Overview.getInstance().getHouseItem().houseId === -1){
            Overview.getInstance().addHouse({
              houseId: this.getAttribute('id'),
              roomCount: this.getAttribute('room_count'),
              bedCount: this.getAttribute('bed_count'),
              place: this.getAttribute('place'),
              price: this.getAttribute('price'),
              startDate: document.getElementById('date_start').value,
              endDate: document.getElementById('date_end').value
            });
  
            const itemContainer = document.querySelector('.items');
            const houseItem = document.createElement('p-house-item');
            itemContainer.appendChild(houseItem);
          }
          else{
            alert('Please remove the booked house at first');
          }
        }
      
        // Zusammenfügen der Elemente
        header.appendChild(img);
        body.appendChild(reg_Text);
        body.appendChild(placeText);
        body.appendChild(roomText);
        body.appendChild(bedText);
        body.appendChild(price);
        body.appendChild(description);
        footer.appendChild(button);
      
        container.appendChild(header);
        container.appendChild(body);
        container.appendChild(footer);
      
        // Styling für das Shadow DOM
        const style = document.createElement('style');
        style.textContent = `
          .card {
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
          .card .card_header {
            position: relative; 
            width: 100%; 
            height: 40%; 
            overflow: hidden; 
          }
          .card .card_header img {
            width: 100%;  
            height: 100%;  
            object-fit: cover;  
          }
          .card .text-container {
            height: calc(100% - 40% - 40.69px);
            display: flex;
            flex-direction: column;
            margin-left: 5px;
            overflow-y: auto;
          }
          .card .text-container p {
            margin: 5px;
            flex: 1;
          }
          .card .card_footer {
            height: 40.69px;
            display: flex;
            align-items: center;
            border-top: 1px solid black;
          }
          .card .card_footer button {
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
          .card .card_footer button:hover {
            background-color: rgb(214, 214, 214);
          }
          .card .card_footer button:active {
            background-color: rgb(198, 198, 198);
          }
          ::-webkit-scrollbar {
            width: 5px;
          }
          ::-webkit-scrollbar-track {
            background: #f1f1f1;
          }
          ::-webkit-scrollbar-thumb {
            background: #888;
          }
          ::-webkit-scrollbar-thumb:hover {
            background: #555;
          }
        `;
    
        this.shadowRoot.append(style, container);
      });
    }
  }

  // registrate the web-component
  customElements.define('p-card', CardComponent);
})();
