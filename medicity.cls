public with sharing class mediCityHospitalController {

    /*
    -------------------------------------------------------------
    1. REGISTER PATIENT
    -------------------------------------------------------------
    Called from LWC when user submits registration form.
    Creates a Patient__c record in database.
    */

    @AuraEnabled
    public static Id registerPatient(
        String name,
        Integer age,
        String gender,
        String bloodGroup,
        String contact,
        String department
    ){
        Patient__c patient = new Patient__c();

        patient.Name = name;
        patient.Age__c = age;
        patient.Gender__c = gender;
        patient.Blood_Group__c = bloodGroup;
        patient.Contact__c = contact;
        patient.Department__c = department;

        patient.Severity__c = 'Pending';
        patient.Discharged__c = false;

        insert patient;

        return patient.Id;
    }



    /*
    -------------------------------------------------------------
    2. GET ACTIVE PATIENTS
    -------------------------------------------------------------
    Fetch all admitted patients (not discharged).
    Used by LWC tables: triage queue + active patients
    */

    @AuraEnabled(cacheable=true)
    public static List<Patient__c> getPatients(){

        return [
            SELECT Id,
                   Patient_ID__c,
                   Name,
                   
                   Contact__c,
                   
                   Severity__c,
                   ward__c,
                   
                   Discharged__c
            FROM Patient__c
            WHERE Discharged__c = false
            ORDER BY CreatedDate DESC
        ];
    }



    /*
    -------------------------------------------------------------
    3. UPDATE TRIAGE
    -------------------------------------------------------------
    Nurse assigns severity + ward.
    */

    @AuraEnabled
    public static void updateTriage(
        Id patientId,
        String severity,
        String ward
    ){

        Patient__c patient = [
            SELECT Id, Severity__c, ward__c
            FROM Patient__c
            WHERE Id = :patientId
        ];

        patient.Severity__c = severity;
        patient.ward__c = ward;

        update patient;
    }



    /*
    -------------------------------------------------------------
    4. UPDATE SEVERITY
    -------------------------------------------------------------
    Used when doctor clicks "Mark Critical" or "Stabilize"
    */

    @AuraEnabled
    public static void updateSeverity(
        Id patientId,
        String severity
    ){

        Patient__c patient = [
            SELECT Id, Severity__c
            FROM Patient__c
            WHERE Id = :patientId
        ];

        patient.Severity__c = severity;

        update patient;
    }



    /*
    -------------------------------------------------------------
    5. ADD MEDICINE
    -------------------------------------------------------------
    Inserts medicine linked to patient
    */

    @AuraEnabled
    public static void addMedicine(
        Id patientId,
        String medicineName,
        String dosage,
        String frequency
    ){

        Medicine__c med = new Medicine__c();

        med.Name = medicineName;
        med.Dosage__c = dosage;
        med.Frequency__c = frequency;
        med.Patient__c = patientId;

        insert med;
    }



    /*
    -------------------------------------------------------------
    6. DISCHARGE PATIENT
    -------------------------------------------------------------
    Marks patient discharged and stores reason/date
    */

    @AuraEnabled
    public static void dischargePatient(
        Id patientId,
        String reason
    ){

        Patient__c patient = [
            SELECT Id,
                   Discharged__c,
                   Discharge_Reason__c,
                   Discharge_Date__c
            FROM Patient__c
            WHERE Id = :patientId
        ];

        patient.Discharged__c = true;
        patient.Discharge_Reason__c = reason;
        patient.Discharge_Date__c = Date.today();

        update patient;
    }



    /*
    -------------------------------------------------------------
    7. GET PATIENT HISTORY
    -------------------------------------------------------------
    Fetch discharged patients for history section
    */

    @AuraEnabled(cacheable=true)
    public static List<Patient__c> getDischargedPatients(){

        return [
            SELECT Id,
                   Patient_ID__c,
                   Name,
                   Age__c,
                   Gender__c,
                   Department__c,
                   Severity__c,
                   Discharge_Reason__c,
                   Discharge_Date__c
            FROM Patient__c
            WHERE Discharged__c = true
            ORDER BY Discharge_Date__c DESC
        ];
    }



    /*
    -------------------------------------------------------------
    8. ANALYTICS DATA
    -------------------------------------------------------------
    Returns department-wise patient count
    */

    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getAnalytics(){

        Map<String,Integer> result = new Map<String,Integer>();

        for(AggregateResult ar : [
            SELECT Department__c dept,
                   COUNT(Id) total
            FROM Patient__c
            WHERE Discharged__c = false
            GROUP BY Department__c
        ]){

            result.put(
                (String) ar.get('dept'),
                (Integer) ar.get('total')
            );
        }

        return result;
    }

}
