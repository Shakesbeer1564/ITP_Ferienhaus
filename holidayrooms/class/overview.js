// Einkaufkorb/Übersicht worüber der Benutzer seine Sachen anschauen kann und schlussendlich buchen kann
export class Overview{
  static instance;
  #items = []; // type --> { key, item (also activity oder room)}

  static getInstance(){
    if(!this.instance){
      this.instance = new Overview();
    }
    
    return this.instance;
  }

  getItem(itemKey){
    const item = this.#items.find(x => x.key === itemKey);
    return item;
  }

  addItem(item){
    this.#items.push(item);
  }

  deleteItem(itemKey){
    const indexOfSearchedItem = this.#items.indexOf(this.#items.find(x => x.key === itemKey));
    if(indexOfSearchedItem !== -1){
      this.#items.splice(indexOfSearchedItem, 1);
    }
  }
}