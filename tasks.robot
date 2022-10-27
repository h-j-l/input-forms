*** Settings ***
Documentation       RPA Challenge: Input Forms

Library             RPA.Browser.Selenium
Library             RPA.Excel.Files
Library             RPA.FileSystem
Library             RPA.HTTP


*** Variables ***
${CHALLENGE_URL}        https://www.rpachallenge.com
${EXCEL_FILE_URL}       https://www.rpachallenge.com/assets/downloadFiles/challenge.xlsx
${EXCEL_FILE}           ${OUTPUT_DIR}${/}challenge.xlsx
${SCORE_FILE}           ${OUTPUT_DIR}${/}score.txt


*** Tasks ***
Do the challenge
    Download the Excel file
    Open the challenge page
    Input data
    Read and save the score
    [Teardown]    End challenge


*** Keywords ***
Download the Excel file
    Download    ${EXCEL_FILE_URL}    overwrite=True    target_file=${EXCEL_FILE}

Open the challenge page
    Open Available Browser    ${CHALLENGE_URL}
    Maximize Browser Window

Input data
    Open Workbook    ${EXCEL_FILE}    read_only=True
    ${worksheet}=    Read Worksheet As Table    header=True
    Close Workbook
    # The page is reloaded to reset the timer.
    Reload Page
    Wait Until Page Contains Element    css:button.waves-effect
    Click Button    css:button.waves-effect
    FOR    ${row}    IN    @{worksheet}
        Input one row    ${row}
    END

Input one row
    [Arguments]    ${row}
    Input Text    css:input[ng-reflect-name="labelFirstName"]    ${row}[First Name]
    Input Text    css:input[ng-reflect-name="labelLastName"]    ${row}[Last Name]
    Input Text    css:input[ng-reflect-name="labelCompanyName"]    ${row}[Company Name]
    Input Text    css:input[ng-reflect-name="labelRole"]    ${row}[Role in Company]
    Input Text    css:input[ng-reflect-name="labelAddress"]    ${row}[Address]
    Input Text    css:input[ng-reflect-name="labelEmail"]    ${row}[Email]
    Input Text    css:input[ng-reflect-name="labelPhone"]    ${row}[Phone Number]
    Click Button    css:input[value="Submit"]

Read and save the score
    ${score}=    Get Text    css:div[class="message2"]
    Create File    ${SCORE_FILE}    content=${score}    overwrite=True

End challenge
    Close Browser
