*** Settings ***
Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}


*** Test Cases ***
Add Valid Contact
    ${contact}    Create Dictionary
    ...    firstName=John11
    ...    lastName=Doe111
    ...    birthdate=1970-01-01
    ...    email=jdoe@fake.com
    ...    phone=8005555555
    ...    street1=1 Main St.
    ...    street2=Apartment A
    ...    city=Anytown
    ...    stateProvince=KS
    ...    postalCode=12345
    ...    country=USA

    ${response}    Call Post Add Contact Request    ${contact}    201
    ${json}    Set Variable    ${response.json()}
    Should Be Equal    ${contact['firstName']}    ${json['firstName']}
    Should Be Equal    ${contact['lastName']}    ${json['lastName']}
    Should Be Equal    ${contact['email']}    ${json['email']}
    Should Be Equal    ${contact['phone']}    ${json['phone']}
    Should Be Equal    ${contact['postalCode']}    ${json['postalCode']}
    Should Be Equal    ${contact['street1']}    ${json['street1']}
    Should Be Equal    ${contact['street2']}    ${json['street2']}
    Should Be Equal    ${contact['stateProvince']}    ${json['stateProvince']}
    Should Be Equal    ${contact['country']}    ${json['country']}



Add Valid Contact With Missing Fields
    ${contact}    Create Dictionary
    ...    firstName=John11
    ...    lastName=Doe111
    ...    birthdate=1970-01-01
    ...    email=jdoe@fake.com
    ...    phone=8005555555

    ${response}    Call Post Add Contact Request    ${contact}    201
    ${json}    Set Variable    ${response.json()}
    Should Be Equal    ${contact['firstName']}    ${json['firstName']}
    Should Be Equal    ${contact['lastName']}    ${json['lastName']}
    Should Be Equal    ${contact['email']}    ${json['email']}
    Should Be Equal    ${contact['phone']}    ${json['phone']}



Add Valid Contact With First And Last Names Only
    ${contact}    Create Dictionary
    ...    firstName=John11
    ...    lastName=Doe111

    ${response}    Call Post Add Contact Request    ${contact}    201
    ${json}    Set Variable    ${response.json()}
    Should Be Equal    ${contact['firstName']}    ${json['firstName']}
    Should Be Equal    ${contact['lastName']}    ${json['lastName']}
    

Add InValid Contact Without First And Last Names Only (Expected 400)
    ${contact}    Create Dictionary
    ...    birthdate=1970-01-01
    ...    email=jdoe@fake.com
    ...    phone=8005555555
    ...    street1=1 Main St.
    ...    street2=Apartment A
    ...    city=Anytown
    ...    stateProvince=KS
    ...    postalCode=12345
    ...    country=USA

    ${response}    Call Post Add Contact Request    ${contact}    400
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['message']}    Contact validation failed: lastName: Path `lastName` is required., firstName: Path `firstName` is required.


Add InValid Contact Without First Names Only (Expected 400)
    ${contact}    Create Dictionary
    ...    lastName=Doe111

    ${response}    Call Post Add Contact Request    ${contact}    400
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['message']}    Contact validation failed: firstName: Path `firstName` is required.



Add Invalid Contact Without Last Names Only (Expected 400)
    ${contact}    Create Dictionary
    ...    firstName=John11

    ${response}    Call Post Add Contact Request    ${contact}    400
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['message']}    Contact validation failed: lastName: Path `lastName` is required
    

Call Contact Request Without Auth Token (Expected 401)
    ${contact}    Create Dictionary
    ...    firstName=John11
    ...    lastName=Doe111
    
    ${response}    Call Post Add Contact Request    ${contact}    401    False
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['error']}    Please authenticate

        
Add Contact With Invalid Phone Number (Expected 400)
    ${contact}    Create Dictionary
    ...    firstName=John11
    ...    lastName=Doe111
    ...    phone=8005

    ${response}    Call Post Add Contact Request    ${contact}    400
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['message']}    Contact validation failed: phone: Phone number is invalid


