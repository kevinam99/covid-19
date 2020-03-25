import * as express from 'express'
import Controller from './controller'

const router = express.Router()

router.get('/', Controller.getSubscribedUsers)
router.get('/:userID', Controller.getUser)

router.post('/', Controller.addUserSubscription)
router.delete('/:userID', Controller.stopSubscription)

export default router
