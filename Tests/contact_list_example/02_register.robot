*** Settings ***

Resource       ../user_keywords/GeneralKeywords.robot
Suite Setup    Create Session    contact_list     ${CONTACT_LIST_URL}

*** Variables ***
*** Keywords ***

Call Post Add User Request
    [Arguments]    ${firstName}    ${lastName}    ${email}    ${password}    ${status}
    ${headers}    Create Dictionary    content-type=application/json
    ${body}    Create Dictionary    firstName=${firstName}    lastName=${lastName}    email=${email}    password=${password}
    ${response}    POST On Session    contact_list    /users    json=${body}    headers=${headers}    expected_status=${status}
    RETURN    ${response}


Add Invalid User (Expected 400)
    [Tags]    Invalid
    [Arguments]    ${firstName}    ${lastName}    ${email}    ${password}    @{expected_message}
    # or we cam ignore the error and continue by   "Run Keyword And Ignore Error"
    ${response}    Call Post Add User Request    firstName=${firstName}    lastName=${lastName}    email=${email}    password=${password}    status=400
    ${body}=    Set Variable    ${response.json()}
    Should Contain    ${body['message']}    User validation failed
    FOR    ${msg}    IN    @{expected_message}
        Should Contain    ${body['message']}    ${msg}
    END

    Status Should Be    400

*** Test Cases ***

Register New User
    ${first_name}=    Generate Random String    10
    ${last_name}=     Generate Random String    10
    ${email}=    Generate Email
    ${password}=      Generate Random String    10
    ${response}    Call Post Add User Request    ${first_name}    ${last_name}    ${email}    ${password}    201
    ${json}=    Set Variable    ${response.json()}
    Status Should Be    201
    Should Be Equal    ${json['user']['email']}    ${email}
    Should Be Equal    ${json['user']['firstName']}    ${first_name}
    Should Be Equal    ${json['user']['lastName']}    ${last_name}
    Should Not Be Empty    ${json['token']}


Template Add Invalid User (Expected 400)
    [Template]    Add Invalid User (Expected 400)
    #firstName            lastName            email                      password            message
    ${EMPTY}              ${EMPTY}            ${EMPTY}                   ${EMPTY}       `firstName` is required    `lastName` is required    Email is invalid    `password` is required     
    ${EMPTY}              ${EMPTY}            ${EMPTY}                   1234567        `firstName` is required    `lastName` is required    Email is invalid
    ${EMPTY}              ${EMPTY}            email@email.com            1234567        `firstName` is required     `lastName` is required
    ${EMPTY}              lastname            email@email.com            1234567        `firstName` is required
    firstname             lastname            email@email                1234567         Email is invalid
    firstname             lastname            email                      1234567         Email is invalid
    firstname             lastname           email@email.com             123456         `password` (`123456`) is shorter than the minimum allowed length (7)
    firstname             lastname           email@email.com             1234           `password` (`1234`) is shorter than the minimum allowed length (7)
