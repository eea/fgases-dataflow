**Deployment steps**


- **Step 1**
 Create a schema for your obligation in http://dd.eionet.europa.eu/

- **Step 2**
Based on the schema previously created, generate an empty instance (xml file that contains all the fields that are described in the schema with no data in them)
- **Step 3**
	- Build the project using the command **npm run build**
	- Copy **webform-project-export.metadata**  from the dist-example to the dist folder
	- Add the empty instance generated in **Step 2** to the dist folder
	- Add the schema generated in **Step 1** to your dist folder.
	*Very important: anywhere you link the schema, do not use the link from webforms, use the one from dd.eionet.europa.eu*
	- Edit the last 2 objects in the **webform-project-export.metada** to use your "xmlSchema" generated on **Step 1** and your "emptyInstanceUrl" generated on **Step 2**
- **Step 4** 
Create a project on webq/webforms for your webform
- **Step 5**
Add all contents of your dist folder to a zip archive and upload it it the project created in previous step
- **Step 6** 
Create a dataflow mapping for your obligation in the zope interface of the platform that will be used for reporting (bdr/cdr)
