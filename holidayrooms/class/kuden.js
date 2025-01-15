import { Role } from "./rolle";

export class Kunde{
  id;
  name;
  email;
  tel;
  role;

  constructor(id, name, email, tel, role){
    if(!(role instanceof Role)){
      throw new Error('Role must be an instance of Role');
    }
    this.role = role;
    this.id = id;
    this.name = name;
    this.email = email;
    this.tel = tel;
  }
}