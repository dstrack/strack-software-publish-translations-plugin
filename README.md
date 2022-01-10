# Publish Translations Plug-In
This Plug-In keeps the translated applications up-to-date automatically by seeding and publishing the running application with an asynchronous background job.

A required task for APEX developers is: When any modification is made to your primary application, perform the "Seed" and "Publish" operations to recreate an updated version of your translated application(s). This can be quite annoying when you have to repeat this task dozens of times.

## The Plug-In solves the following problems:
1. When you develop multilingual APEX applications, you have to repeat the "Seed" and "Publish" operations as often as you make any changes.
For example: When your application's primary language is English and you inspect the german version of your app you may find issues with truncated labels because of the space for much longer item labels. When you change the "Column Span" of an item you have to repeat the seed & publish operations to see the result of your change in the german app.
2. When you install multilingual APEX applications on a different website via the import application process, you have to manually perform the publish operation to see the translated version of your app.
3. You have to wait many seconds until the  "Seed" and "Publish" operations are completed before you can continue with your work.

## The Plug-In process performs the following steps: 
- Retrieve the last updated date of the application.
- Retrieve the value of a preference variable PUBLISH_TRANSLATIONSXX where XX is the application id.
- Compares the last updated date with the preference variable and quit when then values are equal.
- Store the last updated date in the preference variable.
- Create a small script to seed & publish the app in all supported languages.
- Execute the script immediately or asynchronous.

## Installation
import the file process_type_plugin_com_strack_software_publish_translations.sql in the Supporting Objects / Plug-Ins page.

## Implementation
This example implements a process that is runs when you load the home page after a change in your application.
- Go to the home page of your application.
- Open the Pre-Rendering section and add a Process
  - Name: Publish Translations
  - Type: Seed and Publish Translations (Plug-In)
  - Settings
    - Execute Asynchronous: Yes/No (When this option is set to Yes, then the seed and publish of the translated apps is executed asynchronous by an scheduler job. Otherwise, the application user has to wait until the seed and publish process is completed.) 
    - Seed Translations: Yes/No (Seeding the translation copies all translatable text into the translation text repository. When this option is set to Yes, then seeding of the translated text is executed. Otherwise, the seeding of translatable text is skipped.)
  - Execution Options
    - Point: After Header
  - Success Message: Started publishing of translations. 


![Publish-Translations-Process](https://github.com/dstrack/strack-software-publish-translations-plugin/blob/main/Publish-Translations-Process.png)

You can check the process execution with the following queries:
- SELECT * FROM USER_SCHEDULER_RUNNING_JOBS WHERE JOB_NAME LIKE 'PUBLISH_TRANSLATIONS%';
- SELECT * FROM USER_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME LIKE 'PUBLISH_TRANSLATIONS%' ORDER BY LOG_DATE DESC;

After execution of the process the translated apps are up-to-date.
On the page Shared Components \ Translate - in the List of Translations the column Requires-Synchronization will display _No_ in every row.
![Translations-Requires-Synchronization](https://github.com/dstrack/strack-software-publish-translations-plugin/blob/main/Translations-Requires-Synchronization.png)
