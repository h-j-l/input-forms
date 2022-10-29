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
${SCORE_SCREENSHOT}     ${OUTPUT_DIR}${/}score.png


*** Tasks ***
Do the challenge
    Download the Excel file
    Open the challenge page
    Input data
    Save the score
    [Teardown]    End challenge


*** Keywords ***
Download the Excel file
    Download    ${EXCEL_FILE_URL}    overwrite=True    target_file=${EXCEL_FILE}

Open the challenge page
    Open Headless Chrome Browser    ${CHALLENGE_URL}

Read the Excel file
    Open Workbook    ${EXCEL_FILE}    read_only=True
    ${worksheet}=    Read Worksheet As Table    header=True
    Close Workbook
    RETURN    ${worksheet}

Input data
    ${worksheet}=    Read the Excel file
    Click Button When Visible    //button[starts-with(@class, 'waves-effect')]
    FOR    ${row}    IN    @{worksheet}
        Input one row    ${row}
    END

Input one row
    [Arguments]    ${row}
    Execute Javascript
    ...    document.querySelector("input[ng-reflect-name='labelFirstName']").value = "${row}[First Name]";
    ...    document.querySelector("input[ng-reflect-name='labelLastName']").value = "${row}[Last Name]";
    ...    document.querySelector("input[ng-reflect-name='labelCompanyName']").value = "${row}[Company Name]";
    ...    document.querySelector("input[ng-reflect-name='labelRole']").value = "${row}[Role in Company]";
    ...    document.querySelector("input[ng-reflect-name='labelAddress']").value = "${row}[Address]";
    ...    document.querySelector("input[ng-reflect-name='labelEmail']").value = "${row}[Email]";
    ...    document.querySelector("input[ng-reflect-name='labelPhone']").value = "${row}[Phone Number]";
    ...    document.querySelector("input[value='Submit']").click();

Save the score
    Screenshot    class:congratulations    ${SCORE_SCREENSHOT}
    ${score}=    Get Text    class:message2
    Create File    ${SCORE_FILE}    content=${score}    overwrite=True

End challenge
    Close Browser
