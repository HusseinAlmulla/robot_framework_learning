*** Settings ***
Library    RequestsLibrary
Library    RequestsLibrary
Library    DebugLibrary
Library    String
Library    Collections
Library    FakerLibrary

Resource    ../../resources/resources.resource

*** Variables ***

${Auth_Token}

*** Keywords ***
Get Login Token
    ${headers}    Create Dictionary    content-type=application/json
    ${body}    Create Dictionary    email=testing_robot@email.com    password=123456789
    ${response}    POST On Session    contact_list    /users/login    json=${body}    headers=${headers}
    ${token}    Set Variable    ${response.json()['token']}
    Set Global Variable    ${Auth_Token}    ${token}
    Log To Console    ---Called login to get token---
    
Get Header With Auth
    [Arguments]    ${With_Auth}=True
    IF    ${With_Auth}
        Run Keyword If    '${Auth_Token}' == ''    Get Login Token
        ${headers}    Create Dictionary    Authorization=Bearer ${Auth_Token}   content-type=application/json
    ELSE
        ${headers}    Create Dictionary    content-type=application/json
    END
    RETURN    ${headers}


Call Post Add Contact Request
    [Arguments]    ${body}   ${status}    ${with_auth}=True
    ${headers}    Get Header With Auth    ${with_auth}
    ${response}    POST On Session    contact_list    /contacts    json=${body}    headers=${headers}    expected_status=${status}
    RETURN    ${response}
    
    
Generate Email
    ${first_name}=    Generate Random String    10
    ${last_name}=     Generate Random String    10
    ${email}=    Set Variable    ${first_name}_${last_name}@email.com
    ${email_lower}=    Convert To Lower Case    ${email}
    RETURN    ${email_lower}


Generate Random Number
    [Arguments]    ${length}=10
    ${number}=    Evaluate    int(''.join(__import__('random').choices('0123456789', k=${length})))
    RETURN    ${number}
