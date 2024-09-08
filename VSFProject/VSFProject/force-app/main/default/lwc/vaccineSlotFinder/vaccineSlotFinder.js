import { LightningElement } from 'lwc';

export default class VaccineSlotFinder extends LightningElement {
    centers = [];
    dates = [];

    connectedCallback(){
        // "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public"
        this.fetchVaccineSlots();
    }

    async fetchVaccineSlots(){
        const vaccineSlotRes = await fetch(
            "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public"
        );
        const slotsData = await vaccineSlotRes.json();
        console.log(slotsData);
    }

    get hideMessage(){
        return false;
    }
}