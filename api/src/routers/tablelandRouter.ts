import express, { Request, Response } from 'express'
import { TableInserOrUpdateBody } from '../utils/types'

import fetch from 'node-fetch'
//@ts-ignore
globalThis.fetch = fetch
import { Wallet, providers } from "ethers"
import { connect, Connection, CreateTableOptions, CreateTableReceipt, ReadQueryResult } from "@textile/tableland"
import { InsertOrUpdate } from '../utils/queries'

/**
 * Router Definition
 */
export const tableLandRouter = express.Router()

/**
 * @dev create table in tableland
 */

// Since we don't have Metamask, you need to supply a private key directly
const privateKey: number = process.env.prKey
const tablelandToken: string = process.env.tablelandToken as string
const infuraId: string = process.env.infuraId as string

const wallet = new Wallet(privateKey);
const infuraProvider = new providers.InfuraProvider("rinkeby", infuraId);
const signer = wallet.connect(infuraProvider);

let TBL: Connection;
const JWTtoken = { token: tablelandToken }

//connection
const tbl = async (): Promise<Connection> => {
  return await connect({ network: "testnet", signer, token: JWTtoken })
};

tableLandRouter.post('/insertOrUpdateTable', async (req: Request, res: Response) => {
  try {
    const _tbl = await tbl()
    const body = req.body as TableInserOrUpdateBody
    const res = _tbl.create(InsertOrUpdate(
      body.tableId, 
      body.tokenId, 
      body.projectId, 
      body.collectionId, 
      body.supply, 
      body.description, 
      body.name, 
      body.external_url, 
      body.attributes, 
      body.layers, 
      body.image))
    if (res) {
      return res.status(200).send(res)
    }
    res.status(404).send('update or insert unsuccessful')
  } catch (e) {
    res.status(500).send(e.message)
  }
})