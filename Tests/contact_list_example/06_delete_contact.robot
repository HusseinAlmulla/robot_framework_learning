*** Settings ***
Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}


*** Keywords ***
Call Delete Contact Request
    [Arguments]    ${id}   ${status}    ${with_auth}=True
    ${headers}    Get Header With Auth    ${with_auth}
    ${response}    DELETE On Session    contact_list    /contacts/${id}    headers=${headers}    expected_status=${status}
    RETURN    ${response}


*** Test Cases ***
Delete Contact
    ${contact}=    Create Dictionary
    ...    firstName=fname
    ...    lastName=lname
    ...    birthdate=1992-02-02
    ...    email=email@email.com
    ...    phone=938842222
    ...    street1=13 School St.
    ...    street2=Apt. 5
    ...    city=Columbia
    ...    stateProvince=QC
    ...    postalCode=12345
    ...    country=USA

    Log To Console    ---- Add new contact ----
    ${response_add}    Call Post Add Contact Request    ${contact}    201
    ${json_add}    Set Variable    ${response_add.json()}
    Should Not Be Empty    ${json_add['_id']}

    Log To Console    ---- deleted the added contact ----
    ${response}    Call Delete Contact Request    ${json_add['_id']}    200
    Should Not Be Empty    ${response.text}
    Should Be Equal    ${response.text}    Contact deleted


Delete Without Auth Token (Expected 401)
    ${response}    Call Delete Contact Request    68d7a79e6a8d430015645a55    401    False
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['error']}    Please authenticate
