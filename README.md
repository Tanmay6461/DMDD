# DMDD
Tanmay, Ankit, Sahil


# Run the script 
1. Run the env-setup script
2. Run other scripts squentially 

# Onco Therapy Management System (OMS)

## Overview
This is an Oracle-based Healthcare Management System that allows for patient registration, medical record management, diagnostic test ordering, and billing. The system is designed to streamline healthcare operations by providing a centralized database for patient information, medications, and diagnostic tests.

## Database Schema

The system consists of the following tables:

- **Doctor_Details**: Stores information about healthcare providers
- **Patient**: Contains patient demographic information
- **Patient_Address**: Stores patient address details
- **Medical_History**: Records patient symptoms, diagnoses, and dates
- **Drug_Details**: Catalogs medications with pricing information
- **Medication_Information**: Tracks prescribed medications
- **Diagnostic_Test**: Lists available diagnostic tests with pricing
- **Prescribed_Diagnostics**: Records ordered diagnostic tests and results

## Setup Instructions

### Prerequisites
- Oracle Database (compatible with Oracle 19c or later)
- SQL*Plus or another Oracle client

## Core Functionality

### Patient Management
- **Register Patient**: Add new patients to the system
- **Update Patient Details**: Modify patient information
- **Delete Patient Record**: Remove patient data with cascading deletion

### Doctor Management
- **Register Doctor**: Add new doctors with specializations
- **Update Doctor**: Modify doctor information
- **Delete Doctor**: Remove doctor records (with dependency checks)

### Medical Records
- **Add Medical Record**: Record patient symptoms, diagnoses, and prescribe medications
- **Order Diagnostic Test**: Schedule diagnostic tests and record results

### Billing
- **Get Patient Bill**: Generate a detailed bill showing medication and diagnostic charges

![image](https://github.com/user-attachments/assets/876b1f6c-0e0c-44ef-af8b-5b7028702bc3)


## Security

The system implements two levels of access:
- **OMS**: Schema owner with full administrative privileges
- **OMS_APP_USER**: Application user with limited read/write access

## Error Handling

The system includes comprehensive error handling through:
- Input validation to ensure data integrity
- Exception handling for database operations
- Custom error codes and messages

## Data Constraints and Validation

- Enforces positive values for prices and charges
- Prevents future dates for medical records
- Validates demographic data length and format
- Checks for existence of references before foreign key operations
- Warns about potential duplicate prescriptions or tests

## Notes

- The system includes triggers to validate data before insertion
- Most procedures include transaction management (commit/rollback)
