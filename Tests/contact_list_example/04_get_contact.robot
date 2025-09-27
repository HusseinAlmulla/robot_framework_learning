*** Settings ***
Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}


*** Keywords ***
Call Get Contact Request
    [Arguments]    ${id}   ${status}    ${with_auth}=True
    ${headers}    Get Header With Auth    ${with_auth}
    ${response}    GET On Session    contact_list    /contacts/${id}    headers=${headers}    expected_status=${status}
    RETURN    ${response}


*** Test Cases ***
Get Contact
    ${response}    Call Get Contact Request    68d7a79e6a8d430015645a55    200
    ${json}    Set Variable    ${response.json()}
    Should Not Be Empty    ${json}
    Should Be Equal    ${json['_id']}    68d7a79e6a8d430015645a55
    Should Not Be Empty    ${json['firstName']}
    Should Not Be Empty    ${json['lastName']}


Get Contact With Invalid Id (Expected 401)
    ${response}    Call Get Contact Request    68d7a79e6a8d430015645a5    400
    Should Not Be Empty    ${response.text}
    Should Be Equal    ${response.text}    Invalid Contact ID

    
Call Get Request Without Auth Token (Expected 401)
    ${response}    Call Get Contact Request    68d7a79e6a8d430015645a5    401    False
    ${json}    Set Variable    ${response.json()}
    Should Contain    ${json['error']}    Please authenticate
