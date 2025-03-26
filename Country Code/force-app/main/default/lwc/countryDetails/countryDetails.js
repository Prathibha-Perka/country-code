import { LightningElement } from "lwc";
import fetchZIPCodeData from "@salesforce/apex/ZIPCodeAPIService.fetchZIPCodeData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CountryDetails extends LightningElement {
  formattedData = {};
  isDifferentCountryCode = false;
  isUSZipCode = false;

  columns = [
    { label: "Place Name", fieldName: "place_name" },
    { label: "State", fieldName: "state" },
    { label: "State Abbreviation", fieldName: "state_abbreviation" },
    { label: "Longitude", fieldName: "longitude" },
    { label: "Latitude", fieldName: "latitude" }
  ];

  // Trigger on Enter key
  handleKeyUp(event) {
    if (event.key === "Enter") {
      this.fetchData();
    }
  }

  async fetchData() {
    const input = this.template.querySelector(".input");
    const _zipcode = input?.value?.trim();

    if (!_zipcode) {
      input.reportValidity();
      return;
    }
    let result;
    try {
      result = await fetchZIPCodeData({ zipCode: _zipcode });
    } catch (error) {
      this.showToast(
        error?.body?.message || "An error occurred",
        "Error",
        "error"
      );
      return;
    }
    console.log("API Response:", result);

    try {
      this.formattedData = await this.checkUserCountryWithCode(
        JSON.parse(result)
      );
    } catch (error) {
      this.showToast(
        error?.body?.message || "Error processing response",
        "Error",
        "error"
      );
    }
  }

  async checkUserCountryWithCode(zIPCodeResult) {
    return new Promise((resolve, reject) => {
      try {
        const country = zIPCodeResult?.country_abbreviation;
        if (!country) {
          reject("Country data not found");
          return;
        }

        this.isDifferentCountryCode = country !== "US";
        this.isUSZipCode = !this.isDifferentCountryCode;
        console.log("Is Different Country:", this.isDifferentCountryCode);
        resolve(zIPCodeResult);
      } catch (error) {
        reject(error);
      }
    });
  }

  showToast(msg, title, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        message: msg,
        title: title,
        variant: variant
      })
    );
  }

  closePopUp() {
    this.isDifferentCountryCode = false;
  }
}