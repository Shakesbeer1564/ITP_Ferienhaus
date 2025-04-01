(async () => {
  const { getOverviewClass } = await import('../class/overview.js');
  const Overview = await getOverviewClass();

  class ActivityItemCardComponent extends HTMLElement{
    constructor(){
      super();

      setTimeout(() => {
        this.attachShadow({ mode: 'open' });

        const activityID = this.getAttribute('id').toString();
        
        const container = document.createElement('div');
        container.classList.add('ac-item-card');

        const header = document.createElement('div');
        header.classList.add('ac-item-header');

        const title = document.createElement('h3');
        title.textContent = Overview.getInstance().getActivityItemById(activityID)?.title;

        const body = document.createElement('div');
        body.classList.add('ac-item-body');

        const placeText = document.createElement('p');
        placeText.textContent = `Place: ${Overview.getInstance().getActivityItemById(activityID)?.place}`;
        
        const participants = document.createElement('p');
        participants.textContent = `Participants: ${Overview.getInstance().getActivityItemById(activityID)?.participants}`;
      
        const price = document.createElement('p');
        price.textContent = `Price: ${Overview.getInstance().getActivityItemById(activityID)?.price}`;

        const button = document.createElement('button');
        button.textContent = '❌';
        button.onclick = (e) => {
          e.stopPropagation();
          Overview.getInstance().deleteActivityItem(activityID);
          this.closest('p-activity-item').remove();
          Overview.getInstance().calculatePrice();
        }

        header.append(title);
        header.append(button);
        body.append(placeText);
        body.append(participants);
        body.append(price);
        container.append(header);
        container.append(body);

        const style = document.createElement('style');
        style.textContent = `
          .ac-item-card{
            border-top: 1px solid black;
            border-bottom: 1px solid black;
            width: 100%;
            height: fit-content;
          } 

          .ac-item-card .ac-item-header{
            position: relative;
            display: flex;
            align-items: center;
            width: 100%;
            height: 10%;
          }

          .ac-item-card .ac-item-header button{
            margin-left: auto;
            border: none;
            outline: none;
            width: 30px;
            height: 30px;
            cursor: pointer;
          }

          .ac-item-card .ac-item-body{
            display: flex;
            flex-flow: column;
            width: 100%;
            height: 90%;
          }

          .ac-item-card .ac-item-body p{
            flex: 1;
            padding: 0px 0px 0px 10px;
            margin: 5px;
            color: rgb(116, 116, 116);
            font-size: 9pt;
          }
        `;

        this.shadowRoot.append(style, container);
      })
    }
  }

  // registrate the web-component
  customElements.define('p-activity-item', ActivityItemCardComponent);
})();