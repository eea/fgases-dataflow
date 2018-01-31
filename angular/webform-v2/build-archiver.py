import sys
import os.path
import shutil
import zipfile

BUILD_DIR = 'build'
DEST_DIR = 'dist'
DEST_ZIP_FILE = DEST_DIR + '/out.zip'
PROJECT_META_FILE = 'webform-project-export.metadata'
PROD_SCHEMA_URL = 'http://dd.eionet.europa.eu/schemas/fgases-2017/FGasesReporting.xsd'


def createFormFileMetadata(filename, isTestDeployment, projectName):
	template = """{
        "title": "Fluorinated gases (F-Gases) (Article 19)",
        "file": {
            "name": "%(filename)s"
        },
        "newXmlFileName": "fgases.xml",
        "emptyInstanceUrl": "https://%(webqHost)s/download/project/%(projectName)s/file/fgases-instance-empty.xml",
        "xmlSchema": "%(xmlSchema)s",
        "active": true,
        "localForm": %(isLocal)s,
        "remoteForm": true,
        "fileType": "WEBFORM"
    }"""
	templateArgs = {
		'filename': filename,
        'webqHost': resolveWebQHost(isTestDeployment),
        'xmlSchema': resolveXmlSchemaFile(isTestDeployment, projectName),
		'projectName': projectName,
        'isLocal': str(isTestDeployment).lower()
	}

	return template % templateArgs

def resolveXmlSchemaFile(isTestDeployment, projectName):
    if isTestDeployment:
        return composeTestSchemaUrl(projectName)

    return PROD_SCHEMA_URL

def composeTestSchemaUrl(projectName):
    # fileTemplate = "http://%(webqHost)s/download/project/%(projectName)s/file/FGasesReporting2017.xsd"
    # templateArgs = { 
    #     'webqHost': resolveWebQHost(True), 
    #     'projectName' : projectName
    # }
    # return fileTemplate % templateArgs

    # Return the production schema for now
    return PROD_SCHEMA_URL

def resolveWebQHost(isTestDeployment):
    if isTestDeployment:
        return 'webq2test.eionet.europa.eu'

    return 'webformsbdr.eionet.europa.eu'

def createSimpleFileMetadata(filename):
    template = """{
        "title": "%(filename)s",
        "file": {
            "name": "%(filename)s"
        },
        "fileType": "FILE"
    }"""
    templateArgs = {
        'filename': filename
    }

    return template % templateArgs 

def createFileMetadata(filename, isTestDeployment, projectName):
    if (filename == 'index.html'):
        return createFormFileMetadata(filename, isTestDeployment, projectName)
    else:
        return createSimpleFileMetadata(filename)

def copyResources(isTestDeployment, projectName):
    resources = [
        '../xml/fgases-labels-en.xml',
        '../xml/fgases-gases-2015.xml'
    ]

    if isTestDeployment:
        resources.extend(listTestResources())
    else:
        resources.extend([
            '../xml/fgases-instance-empty.xml'
        ])

    for resource in resources:
        shutil.copy(resource, BUILD_DIR)

    if isTestDeployment:
        copyEmptyInstanceForTest(projectName)

def listTestResources():
    return [
        '../schema/FGasesReporting2017.xsd',
        '../xml/fgases-company-info-test.json',
        '../xml/fgases-company-reg-code-test.json',
        '../xml/fgases-company-vat-test.json'
    ]

def copyEmptyInstanceForTest(projectName):
    with open('../xml/fgases-instance-empty.xml') as source, open(BUILD_DIR + '/fgases-instance-empty.xml', 'w') as dest:
        for line in source:
            destLine = line.replace(PROD_SCHEMA_URL, composeTestSchemaUrl(projectName))
            dest.write(destLine)

def listProjectFiles():
    projectFiles = []

    for entry in os.listdir(BUILD_DIR):
        entryPath = os.path.join(BUILD_DIR, entry)

        if os.path.isfile(entryPath) and entry != PROJECT_META_FILE:
            projectFiles.append(entry)

    return projectFiles

def generateProjectMetadata(isTestDeployment, projectName):
    projectFiles = listProjectFiles()
    index = 0
    metadataWriter = None

    try:
        metadataWriter = open(BUILD_DIR + '/webform-project-export.metadata', 'w')
        metadataWriter.write('{ "projectFiles": [')

        for projectFile in projectFiles:
            fileMetadata = createFileMetadata(projectFile, isTestDeployment, projectName)

            if index < len(projectFiles) - 1:
                fileMetadata += ','

            metadataWriter.write(fileMetadata)
            index += 1

        metadataWriter.write('] }')
        metadataWriter.flush()
    finally:
        if metadataWriter != None:
            metadataWriter.close()

def createProjectArchive():
    os.makedirs(DEST_DIR)
    zf = None

    try:
        zf = zipfile.ZipFile(DEST_ZIP_FILE, 'w', zipfile.ZIP_DEFLATED)

        for dirname, subdirs, files in os.walk(BUILD_DIR):
            for filename in files:
                filePath = os.path.abspath(os.path.join(dirname, filename))
                zf.write(filePath, filename)
    finally:
        if zf != None:
            zf.close()


if __name__ == '__main__':
    isTestDeployment = sys.argv[1] == 'test'
    projectName = sys.argv[2]
    copyResources(isTestDeployment, projectName)
    generateProjectMetadata(isTestDeployment, projectName)
    createProjectArchive()
