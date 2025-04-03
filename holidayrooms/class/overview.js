const overviewPromise = (async () => {
  const { HTTPService } = await import('../http-service.js');
  
  class Overview{
    static instance;
  
    #houseItem = {
      houseId: -1,
      roomCount: -1,
      bedCount: -1,
      price: 0,
      place: '',
      startDate: '',
      endDate: ''
    };
  
    #activityItems = [];
  
    static getInstance(){
      if(!this.instance){
        this.instance = new Overview();
      }
      
      return this.instance;
    }
  
    getHouseItem(){
      return this.#houseItem;
    }
  
    getActivityItems(){
      return this.#activityItems;
    }
  
    getActivityItemById(id){
      const item = this.#activityItems.find(x => x.id === id);
      return item;
    }
  
    addHouse(item){
      this.#houseItem = item;
    }
  
    addActivity(item){
      this.#activityItems.push(item);
    }
  
    deleteHouseItem(){
      this.#houseItem = {
        houseId: -1,
        roomCount: -1,
        bedCount: -1,
        price: 0,
        startDate: '',
        endDate: ''
      };
    }
  
    deleteActivityItem(itemKey){
      const indexOfSearchedItem = this.#activityItems.indexOf(this.#activityItems.find(x => x.id === itemKey));
      if(indexOfSearchedItem !== -1){
        this.#activityItems.splice(indexOfSearchedItem, 1);
      }
    }

    calculatePrice(){
      const housePrice = this.#houseItem.price.price !== undefined ? parseFloat(this.#houseItem.price.price.toString().replace(',', '.')) : parseFloat('0,00'.replace(',', '.'));
      let activityPrice = 0;
      this.#activityItems.forEach((value) => {
        activityPrice += parseFloat((value.price || 0));
      });
      const result = housePrice + activityPrice;
      
      document.getElementById('resultPrice').textContent = result.toLocaleString("de-DE", { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '€';
    }
  
    async book(){
      if(this.#houseItem.houseId === '-1')
        return alert('You need to book a house first');
  
      const data = {
        houseId: this.#houseItem.houseId,
        startDate: this.#houseItem.startDate,
        endDate: this.#houseItem.endDate,
        activityIds: this.#activityItems.map(x => x.id)
      };
  
      const res = await HTTPService.postData('book_house.php', data, 'pdf');
  
      if(res){
        const link = document.createElement('a');
        link.href = URL.createObjectURL(res);
        link.download = '.pdf';
        link.click();
        window.location.reload();
      }
    }
  }

  return Overview;
})();

export async function getOverviewClass(){
  return overviewPromise;
}
