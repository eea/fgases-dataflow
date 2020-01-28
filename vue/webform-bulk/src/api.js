import axios from 'axios';
import company from './assets/companies.json'
import prefill from './assets/prefill-test.json'
// import envelopexml from './assets/envelopexml.xml'
// var envelopexml = require('-!xml-loader?!./assets/envelopexml.xml');



const logRequests = process.env.NODE_ENV === 'production';

// request parameters
export let isTestSession = false;
let baseUri = getParameterByName('base_uri');
let fileId = getParameterByName('fileId');
export let companyId = getParameterByName('companyId');
export let envelope = getParameterByName('envelope');
let sessionId = getParameterByName('sessionid');
let testCompanyId = getParameterByName('testCompanyId');

console.log('baseUri', baseUri)
console.log('fileId', fileId)
console.log('companyId', companyId)
console.log('envelope', envelope)
console.log('seesionId', sessionId)



// if companyId parameter is missing, then run the form in test mode.
// it is possible to set test company id with testCopmanyId parameter
// if (!sessionId) {
// isTestSession = true;
// }


const api = axios.create({
  baseURL: baseUri,
  withCredentials: true
})

function fetch(path) {
  logRequests && console.log(`fetching ${path}...`);

  return api.get(path);
}

function post(path, data) {
  logRequests && console.log(`posting ${path} with data ${data}...`);

  return api.post(path, data);
}


function getWebQUrl(path) {
  let url = baseUri + path;
  url += "?fileId=" + fileId;
  if (sessionId && sessionId != null) {
    url += "&sessionid=" + sessionId;
  }
  return url;
}

// helper function for getting query string parameter values. AngularJS solution $location.search() doesn't work in IE8.

function getParameterByName(name) {
  let searchArr;
  if (isTestSession == true) {
    //searchArr = 'http://webq2test.eionet.europa.eu//webform/project/fgases-bulk-verification-2018/file/index.html?fileId=14401&base_uri=&envelope=https://bdr-test.eionet.europa.eu/fgases/be/10022/envwnwlua&base_uri=https://bdr-test.eionet.europa.eu/webq/&language=En&obligation=http://rod.eionet.europa.eu/obligations/764&companyId=10022&sessionid=fc14846908a47e91db1d1994436cc841'.split('?');
    searchArr = 'https://bdr-test.eionet.europa.eu/webq/WebQMenu?language=En&envelope=https://bdr-test.eionet.europa.eu/fgases/be/11729/colwpmkngbi/envxhhv5g&obligation=http://rod.eionet.europa.eu/obligations/764&schema=http://dd.eionet.europa.eu/schemas/fgases-2019/f-gases-bulk-verification-2018.xsd&add=true&file_id=F-gases_verification_reporting__bulk_imports___1.xml&companyId=11729'.split('?');
  } else {
    searchArr = window.location.search.split('?');
  }
  let search = '?' + searchArr[searchArr.length - 1];
  let match = new RegExp('[?&]' + name + '=([^&]*)').exec(search);
  return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
};


function getDomain(url) {
  return url.split("/").slice(0, 3).join("/");
}


export function getCompanyData(companyId) {
  let url;
  // https://bdr-test.eionet.europa.eu/european_registry/organisation?id=9989
  let webqUri = getWebQUrl('/restProxy');
  if (!isTestSession) {
    url = webqUri + "&uri=" + encodeURIComponent(getDomain(envelope) + "/european_registry/organisation?id=" + companyId);
    var data = fetch(url).then(function (response) {
      return response;
    });

    return data;
  } else {
    return company
  }
};



export function saveInstance(data) {
  let url = getWebQUrl("/saveXml");
  return post(url, data);
};


export function getInstance() {
  let url = null;
  console.log('gettinginstance')
  if (!isTestSession) {
    url = getWebQUrl("/download/converted_user_file");
    return fetch(url);
  } else {
    // testing on non-production workflow
    return prefill;
  }
};

export function getEnvelopeXML(url) {
  if (!isTestSession) {
    return fetch(url + "/xml");
  } else {
    return
  }
};


export function getURLlist() {
  let testlist = [{
   // value: 'https://bdr-test.eionet.europa.eu/fgases/be/10022/envworfzg',
    value: 'https://bdr-test.eionet.europa.eu/fgases/be/11729/colwpmkngbi/envxhhv5g',
    text: 'test miruna'
  }]
  if (!isTestSession) {
    return fetch(envelope + '/get_fgas_deliveries')
  } else return testlist
}



export function uploadFile(file) {
  var uploadUri;
  var domain = getDomain(window.location.href);

  var webqUri = getWebQUrl('/restProxyFileUpload');
  uploadUri = domain + webqUri + "&uri=" + envelope + "/manage_addDocument";

  return axios({
    // baseURL: 'http://localhost:8000/api/0.1/',
    method: 'post',
    withCredentials: true,
    // 'content-type': 'multipart/form-data',
    async: false,
    cache: false,
    contentType: false,
    processData: false,
    url: uploadUri,
    // responseType:'arraybuffer',
    data: file
  })

};


export function getSupportingFiles() {
  const url = envelope + '/get_envelope_supporting_files?buster=' + new Date().getTime();

  return axios({
    // baseURL: 'http://localhost:8000/api/0.1/',
    method: "get",
    withCredentials: true,
    // 'content-type': 'multipart/form-data',
    cache: false,
    url: url
    // responseType:'arraybuffer',
  })
}
