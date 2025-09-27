*** Settings ***
Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}

*** Variables ***

*** Keywords ***
Call Post Login Request
    [Arguments]    ${email}    ${password}    ${status}
    ${headers}    Create Dictionary    content-type=application/json
    ${body}    Create Dictionary    email=${email}    password=${password}
    ${response}     POST On Session    contact_list    /users/login    json=${body}    headers=${headers}    expected_status=${status}
    RETURN    ${response}


Login Invalid User (Expected 401)
    [Arguments]    ${email}    ${password}
    # or we cam ignore the error and continue by   "Run Keyword And Ignore Error"
    ${response}    Call Post Login Request    ${email}  ${password}    401


*** Test Cases ***
Login User
    ${response}    Call Post Login Request    testing_robot@email.com    123456789    200
    ${token}    Set Variable    ${response.json()['token']}
    ${email}    Set Variable    ${response.json()['user']['email']}
    Should Be Equal    ${email}    testing_robot@email.com
    Should Not Be Empty    ${token}

Template Invalid Login (Expected 401)
    [Template]    Login Invalid User (Expected 401)
    testing@email.com    123456789
    testing_robot@email.com    12345
    sad@email.com    12345
    ${EMPTY}    ${EMPTY}

