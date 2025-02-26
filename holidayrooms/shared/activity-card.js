(async () => {
  const { getOverviewClass } = await import('../class/overview.js');
  const Overview = await getOverviewClass();

  class ActivityCardComponent extends HTMLElement{
    constructor(){
      super();
      setTimeout(() => {
        this.attachShadow({ mode: 'open' });
  
        const container = document.createElement('div');
        container.classList.add('ac_card');
        
        //------------------------------------------
        //---------------- Header ------------------
        //------------------------------------------
        const header = document.createElement('div');
        header.classList.add('ac_header');
        const title = document.createElement('h2');
        title.textContent = this.getAttribute('title') || 'No title available';
        
        //------------------------------------------
        //----------------- Body -------------------
        //------------------------------------------
        const body = document.createElement('div');
        body.classList.add('ac_body');
        
        
        const description = document.createElement('p');
        description.classList.add('ac_desc');
        description.textContent = `Description: ${this.getAttribute('description') || 'No description'}`;
        
        const price = document.createElement('p');
        price.classList.add('ac_price');
        price.textContent = `Price: ${this.getAttribute('price') || 'No price available'}`;
        
        const participants = document.createElement('p');
        participants.classList.add('ac_price');
        participants.textContent = `Participants: ${this.getAttribute('participants') || 'No participants available'}`;
  
  
        const place = document.createElement('p');
        place.classList.add('ac_price');
        place.textContent = `Place: ${this.getAttribute('place') || 'No place available'}`;
  
        //------------------------------------------
        //--------------- Footer -------------------
        //------------------------------------------
        const footer = document.createElement('div');
        footer.classList.add('ac_card_footer');
        
        const button = document.createElement('button');
        button.textContent = 'Book';
        button.onclick = () => {
          const item = {
            id: this.getAttribute('id'),
            title: this.getAttribute('title'),
            price: this.getAttribute('price'),
            participants: this.getAttribute('participants'),
            place: this.getAttribute('place'),
            description: this.getAttribute('description')
          };

          Overview.getInstance().addActivity(item);
          console.log(Overview.getInstance().getActivityItems());
        }
      
        // Zusammenfügen
        header.appendChild(title);
        body.appendChild(price);
        body.appendChild(participants);
        body.appendChild(place);
        body.appendChild(description);
        footer.appendChild(button);
      
        container.appendChild(header);
        container.appendChild(body);
        container.appendChild(footer);
      
      
        // Adding style
        const style = document.createElement('style');
        style.textContent = `
          .ac_card{
            border: 1px solid black; 
            border-radius: 10px; 
            width: 20em; 
            height: 20em; 
            margin: 20px 10px 10px 10px;
            display: flex; 
            flex-direction: column; 
            position: relative; 
            box-shadow: 0px 0px 20px 1px rgba(0, 0, 0, 0.5);
            overflow: hidden;
          }
      
          .ac_card .ac_header{
            position: relative; 
            width: 100%; 
            height: 20%; 
            overflow: hidden; 
            display: flex;
            align-items: center;
            justify-content: center;
            border-bottom: 1px solid black;
          }
      
          .ac_card .ac_header h2{
            text-align: center;
          }
      
          .ac_card .ac_body{
            height: calc(100% - 20% - 40.69px);
            display: flex;
            flex-direction: column;
            margin-left: 5px;
            overflow-y: auto;
          }
      
          .ac_card .ac_body p{
            margin: 5px;
            flex: 1;
          }
      
          .ac_card .ac_card_footer{
            height: 40.69px;
            display: flex;
            align-items: center;
            border-top: 1px solid black;
          }
      
          .ac_card .ac_card_footer button{
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
      
          .ac_card .ac_card_footer button:hover{
            background-color: rgb(214, 214, 214);
          }
      
          .ac_card .ac_card_footer button:active{
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
      });
    }
  } 
  
  customElements.define('p-card-activity', ActivityCardComponent);
})();

