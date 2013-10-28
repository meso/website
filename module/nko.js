var http = require('http'),
    qs = require('querystring'),
    os = require('os');

module.exports = function ping(code, callback) {
  if (process.env.NODE_ENV !== 'production')
    return callback && callback(Error('NODE_ENV !== production'));
  if (typeof code !== 'string')
    throw Error('Go to http://nodeknockout.com/teams/mine to get your code.');

  var subdomain = process.env.SUBDOMAIN
    , hostname = subdomain ? subdomain : os.hostname();

  var params = {
    hostname: hostname,
    os: os.type(),
    release: os.release(),
    teamcode: code,
  },
  // options = {
  //   host: 'nodeknockout.com',
  //   port: 80,
  //       path: '/deploys?' + qs.stringify(params)
  // };

  // For testing
  options = {
    host: 'localhost',
    port: 8003,
    path: '/deploys?' + qs.stringify(params)
  };


  setTimeout(function (){
    console.log('Sending ping to NKO team');
    http.get(options)
      .on('response', function (res) {
        console.log('Ping NKO OK');
        if (callback) callback(null, res); 
     })
      .on('error', function (err) { 
        if (callback) callback(err); 
     })

  }, 5000);

};
