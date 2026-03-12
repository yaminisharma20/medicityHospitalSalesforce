import { LightningElement, track } from 'lwc';
import registerPatient from '@salesforce/apex/MedicityHospitalController.registerPatient';
import getPatients from '@salesforce/apex/mediCityHospitalController.getPatients';
import triagePatients from '@salesforce/apex/mediCityHospitalController.updateTriage';
//registration
export default class MedicityHospital extends LightningElement {

    @track name = '';
    @track age;
    @track gender = '';
    @track bloodGroup = '';
    @track contact = '';
    @track department = '';
@track patients = [];
    successMessage = '';
    errorMessage = '';
selectedSeverity = {};
selectedWard = {}; 
    genderOptions = [
        { label: 'Male', value: 'Male' },
        { label: 'Female', value: 'Female' },
        { label: 'Other', value: 'Other' }
    ];

    bloodOptions = [
        { label: 'A+', value: 'A+' },
        { label: 'B+', value: 'B+' },
        { label: 'O+', value: 'O+' },
        { label: 'AB+', value: 'AB+' }
    ];

    departmentOptions = [
        { label: 'Cardiology', value: 'Cardiology' },
        { label: 'Neurology', value: 'Neurology' },
        { label: 'Orthopedics', value: 'Orthopedics' },
        { label: 'General', value: 'General' }
    ];
severityOptions=[
{label:'Low',value:'Low'},
{label:'Medium',value:'Medium'},
{label:'High',value:'High'},
{label:'Critical',value:'Critical'}
]


wardOptions=[
{label:'General',value:'General'},
{label:'ICU',value:'ICU'},
{label:'Emergency',value:'Emergency'}
]

    handleName(event){
        this.name = event.target.value;
    }

    handleAge(event){
        this.age = event.target.value;
    }

    handleGender(event){
        this.gender = event.target.value;
    }

    handleBlood(event){
        this.bloodGroup = event.target.value;
    }

    handleContact(event){
        this.contact = event.target.value;
    }

    handleDepartment(event){
        this.department = event.target.value;
    }

    
    
connectedCallback(){
    this.loadPatients();
}


handleRegister(){

    registerPatient({
        name: this.name,
        age: this.age,
        gender: this.gender,
        bloodGroup: this.bloodGroup,
        contact: this.contact,
        department: this.department
    })

    .then(() => {

        // reset form
        this.name = '';
        this.age = '';
        this.gender = '';
        this.bloodGroup = '';
        this.contact = '';
        this.department = '';

        // reload patients from database
        this.loadPatients();

    })

    .catch(error => {
        console.error(error);
    });

}
loadPatients(){

    getPatients()
    .then(result => {
        this.patients = result;
    })
    .catch(error => {
        console.error(error);
    });

}
get triagePatients(){

    return this.patients.filter(p => p.Severity__c === 'Pending');

}
handleTriage(event){

    const patientId = event.target.dataset.id;

    const severity = this.selectedSeverity[patientId];
    const ward = this.selectedWard[patientId];

    triagePatient({
        patientId: patientId,
        severity: severity,
        ward: ward
    })

    .then(() => {

        this.loadPatients(); // refresh UI

    })

    .catch(error => {
        console.error(error);
    });

}
handleSeverityChange(event){

    const patientId = event.target.dataset.id;

    this.selectedSeverity[patientId] = event.target.value;

}
handleWardChange(event){

    const patientId = event.target.dataset.id;

    this.selectedWard[patientId] = event.target.value;

}



get activePatients() {
    return this.patients.filter(
        p => p.Severity__c && !p.Discharged__c
    );
}
}
