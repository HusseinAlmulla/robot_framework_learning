*** Settings ***
Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}


*** Keywords ***
Call Update Contact Request
    [Arguments]    ${id}    ${body}    ${status}    ${with_auth}=True
    ${headers}    Get Header With Auth    ${with_auth}
    ${response}    PUT On Session    contact_list    /contacts/${id}    json=${body}    headers=${headers}    expected_status=${status}
    RETURN    ${response}

_Create Contact Dictionary Object
    ${fname}    Generate Random String    10
    ${lname}    Generate Random String    10
    ${email}    Generate Email
    ${phone_int}    Generate Random Number
    ${phone}    Convert To String    ${phone_int}
    ${contact}=    Create Dictionary
    ...    firstName=${fname}
    ...    lastName=${lname}
    ...    birthdate=1992-02-02
    ...    email=${email}
    ...    phone=${phone}
    ...    street1=13 School St.
    ...    street2=Apt. 5
    ...    city=Columbia
    ...    stateProvince=QC
    ...    postalCode=12345
    ...    country=USA
    RETURN    ${contact}

*** Test Cases ***
Update Valid Contact
    ${contact}=    _Create Contact Dictionary Object
    ${response}    Call Update Contact Request    68d7a79e6a8d430015645a55    ${contact}   200
    ${json}    Set Variable    ${response.json()}
    Should Not Be Empty    ${json}
    Should Be Equal    ${json['_id']}    68d7a79e6a8d430015645a55
    Should Be Equal    ${json['firstName']}    ${contact['firstName']}
    Should Be Equal    ${json['lastName']}    ${contact['lastName']}
    Should Be Equal    ${json['email']}    ${contact['email']}
    Should Be Equal    ${json['phone']}    ${contact['phone']}
    Should Be Equal    ${json['postalCode']}    ${contact['postalCode']}
    Should Be Equal    ${json['city']}    ${contact['city']}
    
    
Add Then Update Valid Contact
    ${contact}=    _Create Contact Dictionary Object
    ${updated_contact}=    _Create Contact Dictionary Object

    Log To Console    ---- Add new contact ----
    ${response_add}    Call Post Add Contact Request    ${contact}    201
    ${json_add}    Set Variable    ${response_add.json()}

    Log To Console    ---- update the added contact ----
    ${response_update}    Call Update Contact Request    ${json_add['_id']}    ${updated_contact}   200
    ${json_update}    Set Variable    ${response_update.json()}

    Should Not Be Empty    ${json_update}
    #updated check
    Should Be Equal    ${json_update['_id']}    ${json_add['_id']}
    Should Be Equal    ${json_update['firstName']}    ${updated_contact['firstName']}
    Should Be Equal    ${json_update['lastName']}    ${updated_contact['lastName']}
    Should Be Equal    ${json_update['email']}    ${updated_contact['email']}
    Should Be Equal    ${json_update['city']}    ${updated_contact['city']}
    Should Be Equal    ${json_update['phone']}    ${updated_contact['phone']}

    # not updated
    Should Be Equal    ${json_update['postalCode']}    ${contact['postalCode']}
    Should Be Equal    ${json_update['country']}    ${contact['country']}
    Should Be Equal    ${json_update['postalCode']}    ${contact['postalCode']}


Update Onlay Names
    ${fname}    Generate Random String    10
    ${lname}    Generate Random String    10
    ${contact}=    Create Dictionary
    ...    firstName=${fname}
    ...    lastName=${lname}

    ${response}    Call Update Contact Request    68d7a79e6a8d430015645a55    ${contact}   200
    ${json}    Set Variable    ${response.json()}
    Should Not Be Empty    ${json}
    Should Be Equal    ${json['_id']}    68d7a79e6a8d430015645a55
    Should Be Equal    ${json['firstName']}    ${contact['firstName']}
    Should Be Equal    ${json['lastName']}    ${contact['lastName']}


Invalid Update When Not Including First And Last Names (Expected 401)
    ${email}    Generate Email
    ${phone_int}    Generate Random Number
    ${phone}    Convert To String    ${phone_int}
    ${contact}=    Create Dictionary
    ...    birthdate=1992-02-02
    ...    email=${email}
    ...    phone=${phone}
    ...    street1=13 School St.
    ...    street2=Apt. 5
    ...    city=Columbia
    ...    stateProvince=QC
    ...    postalCode=12345
    ...    country=USA

    ${response}    Call Update Contact Request    68d7a79e6a8d430015645a55    ${contact}   400
    ${json}    Set Variable    ${response.json()}
    Should Not Be Empty    ${json}
    Should Contain    ${json['message']}    Validation failed: lastName: Path `lastName` is required., firstName: Path `firstName` is required
    
    

Update With Invalid Phone Number (Expected 401)
    ${contact}=    Create Dictionary
    ...    firstName=fname
    ...    lastName=lname
    ...    phone=666

    ${response}    Call Update Contact Request    68d7a79e6a8d430015645a55    ${contact}   400
    ${json}    Set Variable    ${response.json()}
    Should Not Be Empty    ${json}
    Should Contain    ${json['message']}    Validation failed: phone: Phone number is invalid
    
    
Update Without Auth Token (Expected 401)
    ${contact}=    Create Dictionary
    ...    firstName=fname
    ...    lastName=lname

    ${response}    Call Update Contact Request    68d7a79e6a8d430015645a55    ${contact}   401    False
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['error']}    Please authenticate
    
