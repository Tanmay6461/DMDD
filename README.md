# Members
Tanmay, Ankit, Sahil


# To Run the script 
Run all the files in sequential manner.
Run as admin : env_setup.sql , 3_permissions.sql
Other files : run as OMS


  # ONCO THERAPY MANAGEMENT SYSTEM

## Project Overview
The ONCO THERAPY MANAGEMENT SYSTEM is a comprehensive healthcare database application designed to manage oncology treatment procedures, patient records, medication tracking, and diagnostic testing. This system aims to streamline the workflow of oncology departments by providing an integrated solution for tracking patient care from diagnosis through treatment.

## Database Structure

The system is built on a relational database with the following key tables:

### Patient Management
- **Patient**: Stores core patient demographic information
- **Patient_Address**: Contains patient address details for correspondence and home care
- **Medical_History**: Tracks patient symptoms, diagnoses, and condition detection dates

### Medical Provider Information
- **Doctor_Details**: Maintains information about oncologists and other specialists including their specializations

### Treatment Management
- **Drug_Details**: Catalogs all cancer treatment drugs, including pricing information
- **Medication_Information**: Records medication prescriptions, administrations, and the responsible physician
- **Diagnostic_Test**: Contains available cancer diagnostic tests and their associated costs
- **Prescribed_Diagnostics**: Tracks diagnostic test orders, administration dates, and results

## Key Features

- **Comprehensive Patient Tracking**: Complete patient demographic and medical history management
- **Specialist Directory**: Database of oncologists and their specializations
- **Medication Management**: Full tracking of prescribed oncology medications
- **Diagnostic Test Management**: Recording and retrieval of cancer diagnostic test results
- **Data Validation**: Database constraints and triggers to ensure data integrity (e.g., preventing future dates in medical history)
- **Financial Tracking**: Cost information for drugs and diagnostic procedures

## Business Rules & Constraints

The system enforces several important business rules:
- Medical history dates cannot be in the future (enforced by trigger)
- Drug prices and diagnostic test charges must be positive values
- Patient records must maintain referential integrity with their treatment records
- Complete audit trail of medication administration
- Structured diagnostic test results

## Technical Implementation

- **Database**: Oracle Database with PL/SQL
- **Data Integrity**: Foreign key constraints, check constraints, and custom triggers
- **Identity Management**: Auto-generated IDs for key entities
- **Data Types**: Appropriate sizing for all fields (names, addresses, etc.)

## Future Enhancements

- Treatment protocol management module
- Radiation therapy tracking
- Appointment scheduling system
- Integration with medical imaging systems
- Patient portal for accessing treatment information
- Advanced reporting and analytics
- Insurance and billing integration

## Installation

1. Execute the provided SQL script to create the database schema
2. The script will:
   - Drop existing tables (if any)
   - Create the necessary table structure
   - Set up constraints and relationships
   - Create data validation triggers
   - Populate the database with sample data

## Sample Data

The system comes pre-loaded with sample data including:
- 5 doctors with various specializations
- 5 patients with address information
- 5 cancer drugs with pricing
- 5 diagnostic tests with associated costs
- Sample medical history records
- Sample medication prescriptions
- Sample diagnostic test results


![image](https://github.com/user-attachments/assets/876b1f6c-0e0c-44ef-af8b-5b7028702bc3)

 
