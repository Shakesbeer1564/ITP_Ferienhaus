// Einkaufkorb/Übersicht worüber der Benutzer seine Sachen anschauen kann und schlussendlich buchen kann
export class Overview{
  #items = []; // type --> { key, item (also activity oder room)}

  constructor(){

  }

  getItem(itemKey){
    const item = Object.keys(this.#items).find(x => x[key] === itemKey);
    return item;
  }

  addItem(item){
    this.#items.push(item);
  }

  delete(itemKey){
    const indexOfSearchedItem = this.#items.indexOf(Object.keys(this.#items).find(x => x[key] === itemKey));
    if(indexOfSearchedItem !== -1){
      this.#items.splice(indexOfSearchedItem, 1);
    }
  }
}