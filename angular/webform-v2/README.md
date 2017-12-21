# FGases webform (2016 onward)

## Development requirements

Make sure you have the following installed and available to your PATH:
- Git
- Node JS
- Apache Ant
- Python 2.7

Also, you will need an HTTP server to proxy the form during development. Either one of Apache or Node HTTP server will do. The latter can be installed via npm:
```bash
npm install -g http-server
```

## Bootstraping

1. Checkout either one of the following:
    - https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/FGases/
    - https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/FGases/angular

    It is important **not to checkout just the webform-v2 directory**, as the build process has external dependencies to the _angular/xml_ directory.
2. From the webform directory, execute:
    ```bash
    npm install
    ```
    This will execute bower, which in turn will download all project dependencies.
    
## Webform development

By proxying the _app_ directory with an HTTP server, one may execute the webform directly from the browser, and view any changes made instantly by just refreshing. The project contains mock functionality that servers this exact purpose. All mock components are found in the _app/mock_ directory.

If Node HTTP server has been installed, you may execute the following from the _/app_ directory:
```bash
http-server
```
Node server will notify the developer at which address they may access the project via the browser.

## Build process

For ease of deployment on the WebQ platform (webforms, webq2test) one may use the developed ant build process. This process creates a build that conforms to the flat file structure imposed by WebQ, and also converts (most) dependencies from local to CDN based (cdnjs). Additionally, the process may also create an archive that can be imported to the WebQ platform through the WebQ import process. This is even handier as it eliminates the requirement to upload all project files, one by one.

- To build for **webq2test.eionet.europa.eu** execute:
    ```bash
    ant build-test -Dproject=project_name
    ```
- To build for **webforms.eionet.europa.eu** execute:
    ```bash
    ant build-prod -Dproject=project_name
    ```
    
where _project_name_ is the name of the webform project in WebQ.

## Deployment considerations

### Additional steps of deployment

Apart from deploying the webform archive to the corresponding WebQ instance, there are a couple of extra steps required:

- In the case of **test** build/platform:
    - Upload/update the file _xsl/fgases-extra-registry-data.xsl_ at the **converterstest** platform.
    - Upload/update the file _xml/fgases-extra-registry-data.xml_ at the **converterstest** platform.
- In the case of **production** build/platform:
    - Upload/update the file _xsl/fgases-extra-registry-data.xsl_ at the **convertersbdr** platform.

Essentially this is a conversion used by WebQ **internally** in order to filter our company data per companyId. Note that the XSLT **is executed by WebQ, not xmlconv**, via its _/proxyWithConversion_ service.

### Deployment environments

The build and deployment process as described above is based on the assumption of two alternate environments:
- Test
    - https://converterstest.eionet.europa.eu
    - https://webq2test.eionet.europa.eu
- Production
    - https://convertersbdr.eionet.europa.eu
    - https://webformsbdr.eionet.europa.eu

Should anything change in the composition of the environments (e.g. domain names), these changes must be reflected in the source code of the webform and the deployment process. Specifically, the following files will require modification:
- build-archiver.py
- app/js/services/data/data-proxy.js

### Working modes after deployment

When build for _test_ the webform will be marked to operate both locally from webq2test and remotely from BDR. The local option is discarded in the production build. The _test_ build enables _local_ execution, in order to allow for testing directly from webq2test. This is very useful for rapid deployment and acceptance of features, as it eliminates the need for a full BDR-based workflow.

The local mode is the reason why the _xml/fgases-extra-registry-data.xml_ is required to be deployed at the **converterstest** platform, as mentioned above. When executed locally, the webform operates in a mode where it is self-sustained, using dummy data. The aforementioned file contains pseudo-registry data for the dummy company of the local mode.
