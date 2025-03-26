import { LightningElement, api } from "lwc";

export default class ZipCodeDisplay extends LightningElement {
  @api places = [];
  @api columns = [];
}