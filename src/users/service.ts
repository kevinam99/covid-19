import User from './model'

async function addUser(attributes) {
  const user = User(attributes)
  return user.save()
}

async function updateUser(userID: string, attributes) {
  return User.findOneAndUpdate({ _id: userID }, attributes)
}

async function getUserByID(userID) {
  return User.findOne({ _id: userID })
}

async function changeSubscription(userID: string, emailSubscribed: boolean, phoneSubscribed: boolean) {
  return updateUser(userID, { emailSubscribed, phoneSubscribed })
}


const Service = {
  addUser,
  updateUser,
  getUserByID,
  changeSubscription
}

export default Service
