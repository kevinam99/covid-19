import Service from './service'

async function addUserSubscription(req, res) {
  return res.status(201).json({ id: 101, name: 'Jane Doe', mobile: '+934923492349', email: 'email@domain.com' })
}

async function getUser(req, res) {
  const userID = req.params.userID.trim()

  const user = await Service.getUser(userID)

  return res.json(user)
}

async function getSubscribedUsers(req, res) {
  return res.status(200).json(['a', 'b', 'c'])
}

async function stopSubscription(req, res) {
  return res.status(200).json({ id: 101, status: 'unsubscribed'})
}


function errorResponse(res, message: string, status = 500) {
  return res.status(status).json({ message })
}


export default {
  addUserSubscription,
  getUser,
  getSubscribedUsers,
  stopSubscription
}
