exports.handler = async (event, context) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    const headerNameSrc = 'X-Amz-Meta-Last-Modified';
    const headerNameDst = 'Last-Modified';
    
    const headerNameHSTS = 'Strict-Transport-Security';
    const headerNameCSP = 'Content-Security-Policy';
    const headerNameXFO = 'X-Frame-Options';
    const headerNameCTO = 'X-Content-Type-Options';
    const headerNameRP = 'Referrer-Policy';
    const headerNameFP = 'Feature-Policy';
    const headerNameXSS = 'X-XSS-Protection'
    if (headers[headerNameSrc.toLowerCase()]) {
        headers[headerNameDst.toLowerCase()] = [{
            key: headerNameDst,
            value: headers[headerNameSrc.toLowerCase()][0].value,
        }];
    }
    
    headers[headerNameHSTS.toLowerCase()] = [{
      key: headerNameHSTS,
      value: 'max-age=31536000; includeSubDomains; preload',
    }];
    headers[headerNameCSP.toLowerCase()] = [{
      key: headerNameCSP,
      value: 'default-src \'self\'; script-src \'self\' https://storage.googleapis.com ; connect-src \'self\' https://*.execute-api.us-east-1.amazonaws.com https://*.auth.us-east-1.amazoncognito.com https://fonts.googleapis.com https://fonts.gstatic.com ; img-src \'self\' data:; style-src \'self\' https://fonts.googleapis.com ; font-src \'self\' https://fonts.gstatic.com ; manifest-src \'self\'; base-uri \'self\'; form-action \'self\'; frame-ancestors \'none\'; prefetch-src \'self\';',
    }];
    headers[headerNameFP.toLowerCase()] = [{
      key: headerNameFP,
      value: 'geolocation \'none\'; midi \'none\'; notifications \'none\'; push \'none\'; sync-xhr \'none\'; microphone \'none\'; camera \'none\'; magnetometer \'none\'; gyroscope \'none\'; speaker \'none\'; vibrate \'none\'; fullscreen \'none\'; payment \'none\';',
    }];
    headers[headerNameXFO.toLowerCase()] = [{
      key: headerNameXFO,
      value: 'DENY',
    }];
    headers[headerNameCTO.toLowerCase()] = [{
      key: headerNameCTO,
      value: 'nosniff',
    }];
    headers[headerNameRP.toLowerCase()] = [{
      key: headerNameRP,
      value: 'no-referrer',
    }];
    headers[headerNameXSS.toLowerCase()] = [{
      key: headerNameXSS,
      value: '1; mode=block',
    }];

    console.log(`Updated response to ${JSON.stringify(response)}`)
    return response;
};
