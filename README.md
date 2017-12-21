# FGases dataflow project

## Repository structure

- **aggregation**: Harvesting and aggregation scripts, and import tool
- **angular**
    - **ext-resources-conversions**: Scripts regarding external resources for webform and QA
    - **schema**: Contains the FGases data schema 
    - **webform**: Legacy version of the webform, now obsolete and kept for historical reasons
    - **webform-v2**: The active version of the webform
    - **xml**: XML and JSON file resources
    - **xsl**: XSLT conversions including _HTML printout_
- **xqueries**: QA scripts and utilities

### aggregation

See corresponding README file.

### angular

For some reason, the TripleDev team decided to use the same repository when the FGases regulation software was majorly refactored, and placed the resulting components (webform, HTML printout) in this directory.

#### angular/ext-resources-conversions

See corresponding README file.

#### angular/schema

The schema that has been utilized since 2015. Up until the time of writing, all changes have been incremental, hence backwards compatible. This has allowed us to re-use the same file by just applying any necessary addition to the schema.

#### angular/webform

Obsolete, kept for historical reasons.

#### angular/webform-v2

See corresponding README file.


#### angular/xml

Contains various XML and JSON resources. The most crucial files contained here are the following:
- _fgases-gases-2015.xml_: The gas list used by the webform, HTML printout and QA scripts. **Must be updated each year** to include frequently reported user mixes. See _angular/ext-resources-conversions_ for more.
- _fgases-labels-en.xml_: The string resources used by the webform and HTML printout. Note that while the webform build process bundles this resource with the rest of the form project, there is no such functionality for HTML printout, thus **this file must be manually deployed to converters each time it is updated, so that changes in text may be reflected into the printout!**

#### angular/xsl

Contains the HTML prinout XSLT plus other conversions.

### xqueries

See corresponding README file.
