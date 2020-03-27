import * as express from 'express'
import Controller from './controller'

const router = express.Router()

router.post('/', Controller.receiveChatMessage)
router.post('/update', Controller.receiveSentMessageUpdate)

export default router
