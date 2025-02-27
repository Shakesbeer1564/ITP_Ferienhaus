(async () => {
  const { getOverviewClass } = await import('../class/overview.js');
  const Overview = await getOverviewClass();

  class HouseItemCard extends HTMLElement{
    constructor() {
      super();

      setTimeout(() => {
        this.attachShadow({ mode: 'open' });
        
        const container = document.createElement('div');
        container.classList.add('h-item-card');

        const header = document.createElement('div');
        header.classList.add('h-item-header');

        const title = document.createElement('h3');
        title.textContent = 'House';

        const body = document.createElement('div');
        body.classList.add('h-item-body');

        const placeText = document.createElement('p');
        placeText.textContent = `Place: ${Overview.getInstance().getHouseItem().place}`;
        
        const dateRange = document.createElement('p');
        dateRange.textContent = `Date-Range: ${Overview.getInstance().getHouseItem().startDate} - ${Overview.getInstance().getHouseItem().endDate}`;

        const roomCount = document.createElement('p');
        roomCount.textContent = `Room-Count: ${Overview.getInstance().getHouseItem().roomCount}`;

        const bedCount = document.createElement('p');
        bedCount.textContent = `Bed-Count: ${Overview.getInstance().getHouseItem().bedCount}`;

        const button = document.createElement('button');
        button.textContent = '❌';
        button.onclick = () => {
          Overview.getInstance().deleteHouseItem();
          this.closest('p-house-item').remove();
          Overview.getInstance().calculatePrice();
        }

        header.append(title);
        header.append(button);
        body.append(placeText);
        body.append(dateRange);
        body.append(roomCount);
        body.append(bedCount);
        container.append(header);
        container.append(body);

        const style = document.createElement('style');
        style.textContent = `
          .h-item-card{
            border-top: 1px solid black;
            border-bottom: 1px solid black;
            width: 100%;
            height: fit-content;
          }

          .h-item-card .h-item-header{
            position: relative;
            display: flex;
            align-items: center;
            width: 100%;
            height: 10%;
          }

          .h-item-card .h-item-header button{
            margin-left: auto;
            border: none;
            outline: none;
            width: 30px;
            height: 30px;
            cursor: pointer;
          }

          .h-item-card .h-item-body{
            display: flex;
            flex-flow: column;
            width: 100%;
            height: 90%;
          }

          .h-item-card .h-item-body p{
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
  customElements.define('p-house-item', HouseItemCard);
})();