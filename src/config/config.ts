const Config = {
  development: {
    dbString: process.env.DB_STRING || 'mongodb://localhost:27017/covid',
    emailToken: 'sdfsdf'
  },
  production: {
    dbString: process.env.DB_STRING || 'mongodb://localhost:27017/covid',
    emailToken: 'sdfsdf'
  },
  locationList: [
    'ind', // full country
    // individual states
    'ga',
    'ka',
    'mh',
    'kl',
    'mp',
    'hp'
  ],
  countryList: [
    'in'
  ],
  statusMsgs: {
    201: 'Created',
    202: 'Request Accepted',
    400: 'Oops! You seem to have sent some wrong data',
    401: 'Auth failed.',
    403: 'Sorry! You don\'t have access',
    404: 'Couldn\'t find the requested endpoint',
    500: 'Sorry, something went wrong. This one is on us'
  }
}

export default Config